<#
.SYNOPSIS
    Starts the Windows ChatGPT app with a process-scoped proxy.

.DESCRIPTION
    Injects proxy variables only into the launcher process and its ChatGPT
    child process. It does not modify persistent Windows environment variables,
    registry values, system proxy settings, routes, or TUN configuration.

.PARAMETER Proxy
    HTTP, HTTPS, or SOCKS5 proxy URL. A host:port value is treated as HTTP.

.PARAMETER Restart
    Force-stop an existing ChatGPT process before launching a new one.
    Use only when there is no unsaved work.

.EXAMPLE
    .\Start-ChatGPTWithProxy.ps1 -Proxy 127.0.0.1:7897

.EXAMPLE
    .\Start-ChatGPTWithProxy.ps1 -Proxy socks5://127.0.0.1:7891 -Restart
#>
[CmdletBinding()]
param(
    # Clash 的 HTTP 或 Mixed 端口。也可以传入完整地址，例如 socks5://127.0.0.1:7890。
    [Parameter(Position = 0)]
    [string]$Proxy = "http://127.0.0.1:7890",

    # 客户端已经在运行时，显式指定此开关才会强制重启它。
    [switch]$Restart
)

$ErrorActionPreference = "Stop"
. "$PSScriptRoot\ProxyLauncher.Core.ps1"
try {
    Start-ProxyTarget -Target ChatGPT -Proxy $Proxy -Restart:$Restart | Out-Null
}
catch {
    Write-Error $_.Exception.Message
    exit 1
}
