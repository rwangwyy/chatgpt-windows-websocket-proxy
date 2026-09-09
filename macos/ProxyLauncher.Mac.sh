#!/bin/bash

set -euo pipefail

normalize_proxy() {
    local value="$1"
    [[ "$value" == *"://"* ]] || value="http://$value"

    local scheme="${value%%://*}"
    local rest="${value#*://}"
    local scheme_lower
    scheme_lower="$(printf '%s' "$scheme" | tr '[:upper:]' '[:lower:]')"
    case "$scheme_lower" in
        http|https|socks5) ;;
        *) echo "Unsupported proxy scheme: $scheme (use http, https, or socks5)." >&2; return 1 ;;
    esac

    local host="${rest%:*}"
    local port="${rest##*:}"
    if [[ -z "$host" || "$host" == "$rest" || ! "$port" =~ ^[0-9]+$ || "$port" -lt 1 || "$port" -gt 65535 ]]; then
        echo "Invalid proxy address: $value" >&2
        echo "Example: 127.0.0.1:7890 or http://127.0.0.1:7890" >&2
        return 1
    fi

    printf '%s' "${value%/}"
}

set_proxy_environment() {
    local proxy="$1"
    export HTTP_PROXY="$proxy"
    export HTTPS_PROXY="$proxy"
    export WS_PROXY="$proxy"
    export WSS_PROXY="$proxy"
    if [[ -n "${NO_PROXY:-}" ]]; then
        export NO_PROXY="localhost,127.0.0.1,::1,$NO_PROXY"
    else
        export NO_PROXY="localhost,127.0.0.1,::1"
    fi
}

find_app() {
    local app_name="$1"
    local candidate
    for candidate in "$HOME/Applications/$app_name.app" "/Applications/$app_name.app"; do
        if [[ -d "$candidate" ]]; then
            printf '%s' "$candidate"
            return 0
        fi
    done

    if command -v mdfind >/dev/null 2>&1; then
        candidate="$(mdfind "kMDItemFSName == '$app_name.app'" | head -n 1 || true)"
        if [[ -n "$candidate" && -d "$candidate" ]]; then
            printf '%s' "$candidate"
            return 0
        fi
    fi

    return 1
}

app_executable() {
    local app="$1"
    local executable_name
    executable_name="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleExecutable' "$app/Contents/Info.plist" 2>/dev/null || true)"
    [[ -n "$executable_name" && -x "$app/Contents/MacOS/$executable_name" ]] || return 1
    printf '%s\n%s' "$executable_name" "$app/Contents/MacOS/$executable_name"
}

start_mac_app() {
    local app_name="$1"
    local proxy="$2"
    local restart="$3"
    shift 3
    local app executable_info executable_name executable

    app="$(find_app "$app_name" || true)"
    if [[ -z "$app" ]]; then
        echo "$app_name.app was not found. Install it in /Applications or ~/Applications." >&2
        return 1
    fi

    executable_info="$(app_executable "$app" || true)"
    if [[ -z "$executable_info" ]]; then
        echo "Could not find the executable inside: $app" >&2
        return 1
    fi
    executable_name="${executable_info%%$'\n'*}"
    executable="${executable_info#*$'\n'}"

    if pgrep -f "$executable" >/dev/null 2>&1; then
        if [[ "$restart" != "true" ]]; then
            echo "$app_name is already running. Quit it completely, or use --restart." >&2
            return 2
        fi
        pkill -f "$executable" || true
        sleep 1
    fi

    set_proxy_environment "$proxy"
    echo "Starting $app_name with process-scoped proxy: $proxy"
    "$executable" "$@" >/dev/null 2>&1 &
}
