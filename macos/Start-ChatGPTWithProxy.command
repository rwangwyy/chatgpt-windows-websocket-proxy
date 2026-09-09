#!/bin/bash

# Starts the macOS ChatGPT app with a proxy limited to this app process tree.
# Double-click this file in Finder, or run it from Terminal with a proxy URL.

set -euo pipefail

script_dir="$(cd "$(dirname "$0")" && pwd)"
proxy="${1:-http://127.0.0.1:7890}"
restart="false"

if [[ "${1:-}" == "--restart" ]]; then
    proxy="http://127.0.0.1:7890"
    restart="true"
elif [[ "${2:-}" == "--restart" ]]; then
    restart="true"
fi

if [[ "$proxy" != *"://"* ]]; then
    proxy="http://$proxy"
fi

scheme="${proxy%%://*}"
rest="${proxy#*://}"
scheme_lower="$(printf '%s' "$scheme" | tr '[:upper:]' '[:lower:]')"
case "$scheme_lower" in
    http|https|socks5) ;;
    *) echo "Unsupported proxy scheme: $scheme (use http, https, or socks5)." >&2; exit 1 ;;
esac

host="${rest%:*}"
port="${rest##*:}"
if [[ -z "$host" || "$host" == "$rest" || ! "$port" =~ ^[0-9]+$ || "$port" -lt 1 || "$port" -gt 65535 ]]; then
    echo "Invalid proxy address: $proxy" >&2
    echo "Example: 127.0.0.1:7890 or http://127.0.0.1:7890" >&2
    exit 1
fi

app=""
for candidate in "$HOME/Applications/ChatGPT.app" "/Applications/ChatGPT.app"; do
    if [[ -d "$candidate" ]]; then
        app="$candidate"
        break
    fi
done

if [[ -z "$app" ]] && command -v mdfind >/dev/null 2>&1; then
    app="$(mdfind "kMDItemFSName == 'ChatGPT.app'" | head -n 1 || true)"
fi

if [[ -z "$app" || ! -f "$app/Contents/Info.plist" ]]; then
    echo "ChatGPT.app was not found. Install it in /Applications or ~/Applications." >&2
    exit 1
fi

executable_name="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleExecutable' "$app/Contents/Info.plist" 2>/dev/null || true)"
executable="$app/Contents/MacOS/$executable_name"
if [[ -z "$executable_name" || ! -x "$executable" ]]; then
    echo "Could not find the ChatGPT executable inside: $app" >&2
    exit 1
fi

if pgrep -x "$executable_name" >/dev/null 2>&1; then
    if [[ "$restart" != "true" ]]; then
        echo "ChatGPT is already running. Quit it completely, or run:"
        echo "  $script_dir/Start-ChatGPTWithProxy.command $proxy --restart"
        exit 2
    fi

    pkill -x "$executable_name" || true
    for _ in 1 2 3 4 5; do
        pgrep -x "$executable_name" >/dev/null 2>&1 || break
        sleep 1
    done
fi

export HTTP_PROXY="$proxy"
export HTTPS_PROXY="$proxy"
export WS_PROXY="$proxy"
export WSS_PROXY="$proxy"
if [[ -n "${NO_PROXY:-}" ]]; then
    export NO_PROXY="localhost,127.0.0.1,::1,$NO_PROXY"
else
    export NO_PROXY="localhost,127.0.0.1,::1"
fi

echo "Starting ChatGPT with process-scoped proxy: $proxy"
"$executable" >/dev/null 2>&1 &

# A Finder-launched .command runs in a temporary Terminal window. Close the
# front Terminal window after the app has been handed off.
if [[ "${TERM_PROGRAM:-}" == "Apple_Terminal" && "${TERM_SESSION_ID:-}" == *:* ]]; then
    osascript -e 'tell application "Terminal" to close front window' >/dev/null 2>&1 &
fi
exit 0
