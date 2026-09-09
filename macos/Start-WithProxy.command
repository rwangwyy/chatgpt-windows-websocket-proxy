#!/bin/bash
set -euo pipefail
script_dir="$(cd "$(dirname "$0")" && pwd)"
. "$script_dir/ProxyLauncher.Mac.sh"
set +e

proxy="http://127.0.0.1:7890"
target_arg=""
restart="false"
list_available="false"
while [[ $# -gt 0 ]]; do
    case "$1" in
        --target|-Target) target_arg="$2"; shift 2 ;;
        --proxy|-Proxy) proxy="$2"; shift 2 ;;
        --restart|-Restart) restart="true"; shift ;;
        --list-available|-ListAvailable) list_available="true"; shift ;;
        *) echo "Unknown option: $1" >&2; exit 1 ;;
    esac
done
proxy="$(normalize_proxy "$proxy")" || exit 1

app_name() {
    case "$1" in
        ChatGPT) echo "ChatGPT" ;;
        Chrome) echo "Google Chrome" ;;
        VSCode) echo "Visual Studio Code" ;;
    esac
}

available_targets() {
    local target app
    for target in ChatGPT Chrome VSCode; do
        app="$(find_app "$(app_name "$target")" 2>/dev/null || true)"
        [[ -n "$app" ]] && echo "$target"
    done
}

if [[ "$list_available" == "true" ]]; then
    echo "macOS target availability:"
    for target in ChatGPT Chrome VSCode; do
        if available_targets | grep -Fxq "$target"; then echo "  $target: installed"; else echo "  $target: not found"; fi
    done
    exit 0
fi

while [[ -z "$target_arg" ]]; do
    echo "Select targets / 请选择目标："
    echo "  1. ChatGPT"
    echo "  2. Google Chrome"
    echo "  3. Visual Studio Code"
    echo "  4. ChatGPT + Chrome"
    echo "  5. All installed targets / 本机已安装的全部组件"
    echo "  6. Change proxy port / 修改代理端口（当前：${proxy##*:}）"
    echo "  0. Cancel / 取消"
    read -r -p "Enter a number / 请输入数字：" selection
    case "$selection" in
        1) target_arg="ChatGPT" ;;
        2) target_arg="Chrome" ;;
        3) target_arg="VSCode" ;;
        4) target_arg="ChatGPT,Chrome" ;;
        5) target_arg="All" ;;
        6)
            read -r -p "Enter new port / 请输入新端口：" port
            if [[ "$port" =~ ^[0-9]+$ && "$port" -ge 1 && "$port" -le 65535 ]]; then proxy="${proxy%:*}:$port"; echo "Proxy port updated: $port"; else [[ -z "$port" ]] || echo "Invalid port."; fi
            echo ;;
        0) exit 0 ;;
        *) echo "Invalid selection."; echo ;;
    esac
done

IFS=',' read -r -a requested <<< "$target_arg"
targets=()
for target in "${requested[@]}"; do
    case "$target" in
        ChatGPT|Chrome|VSCode) targets+=("$target") ;;
        All) while IFS= read -r installed; do [[ -n "$installed" ]] && targets+=("$installed"); done < <(available_targets) ;;
        *) echo "Unknown target: $target" >&2; exit 1 ;;
    esac
done

failed=0
for target in "${targets[@]}"; do
    app_args=()
    [[ "$target" == "Chrome" ]] && app_args=("--proxy-server=$proxy")
    if start_mac_app "$(app_name "$target")" "$proxy" "$restart" "${app_args[@]}"; then :; else echo "[$target] failed to start." >&2; failed=$((failed + 1)); fi
done

if [[ "$failed" -eq 0 && "${TERM_PROGRAM:-}" == "Apple_Terminal" && "${TERM_SESSION_ID:-}" == *:* ]]; then
    osascript -e 'tell application "Terminal" to close front window' >/dev/null 2>&1 &
fi
exit "$failed"
