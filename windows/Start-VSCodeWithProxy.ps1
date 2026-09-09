<#
.SYNOPSIS
    Starts Visual Studio Code so the Codex extension inherits proxy variables.
#>
[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string]$Proxy = "http://127.0.0.1:7890",

    [switch]$Restart
)

$ErrorActionPreference = "Stop"
. "$PSScriptRoot\ProxyLauncher.Core.ps1"

try {
    Start-ProxyTarget -Target VSCode -Proxy $Proxy -Restart:$Restart | Out-Null
}
catch {
    Write-Error $_.Exception.Message
    exit 1
}
