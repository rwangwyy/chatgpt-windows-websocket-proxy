#!/bin/bash

set -euo pipefail
script_dir="$(cd "$(dirname "$0")" && pwd)"
. "$script_dir/ProxyLauncher.Mac.sh"

proxy="${1:-http://127.0.0.1:7890}"
restart="false"
if [[ "${1:-}" == "--restart" ]]; then
    proxy="http://127.0.0.1:7890"
    restart="true"
elif [[ "${2:-}" == "--restart" ]]; then
    restart="true"
fi

proxy="$(normalize_proxy "$proxy")"
start_mac_app "Visual Studio Code" "$proxy" "$restart"

if [[ "${TERM_PROGRAM:-}" == "Apple_Terminal" && "${TERM_SESSION_ID:-}" == *:* ]]; then
    osascript -e 'tell application "Terminal" to close front window' >/dev/null 2>&1 &
fi
exit 0
