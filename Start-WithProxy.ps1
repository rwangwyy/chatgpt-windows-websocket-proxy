<#
.SYNOPSIS
    Selectively starts ChatGPT, Chrome, and/or VS Code with a process-scoped proxy.

.EXAMPLE
    .\Start-WithProxy.ps1

.EXAMPLE
    .\Start-WithProxy.ps1 -Target ChatGPT,Chrome -Proxy 127.0.0.1:7897

.EXAMPLE
    .\Start-WithProxy.ps1 -ListAvailable
#>
[CmdletBinding()]
param(
    [ValidateSet("ChatGPT", "Chrome", "VSCode", "All")]
    [string[]]$Target,

    [string]$Proxy = "http://127.0.0.1:7890",

    [switch]$Restart,

    [switch]$ListAvailable
)

$ErrorActionPreference = "Stop"
. "$PSScriptRoot\ProxyLauncher.Core.ps1"

if ($ListAvailable) {
    Get-ProxyTargetAvailability | Format-Table -AutoSize
    exit 0
}

if (-not $Target -or $Target.Count -eq 0) {
    while (-not $Target -or $Target.Count -eq 0) {
        $proxyUri = [Uri](ConvertTo-ProxyUri $Proxy)

        Write-Host "请选择要使用代理启动的组件 / Select targets:"
        Write-Host "  1. ChatGPT Windows App"
        Write-Host "  2. Google Chrome"
        Write-Host "  3. Visual Studio Code"
        Write-Host "  4. ChatGPT + Chrome（推荐用于 ChatGPT Chrome 扩展）"
        Write-Host "  5. 本机已安装的全部组件 / All installed"
        Write-Host "  6. 修改代理端口（当前：$($proxyUri.Port)） / Change proxy port (current: $($proxyUri.Port))"
        Write-Host "  0. 取消 / Cancel"

        $selection = (Read-Host "请输入数字 / Enter a number").Trim()
        switch ($selection) {
            "1" { $Target = @("ChatGPT") }
            "2" { $Target = @("Chrome") }
            "3" { $Target = @("VSCode") }
            "4" { $Target = @("ChatGPT", "Chrome") }
            "5" { $Target = @("All") }
            "6" {
                $portText = (Read-Host "请输入新端口（回车保持 $($proxyUri.Port)） / Enter new port (Enter keeps $($proxyUri.Port))").Trim()
                if (-not [string]::IsNullOrWhiteSpace($portText)) {
                    $port = 0
                    if (-not [int]::TryParse($portText, [ref]$port) -or $port -lt 1 -or $port -gt 65535) {
                        Write-Warning "端口必须是 1 到 65535 之间的数字。 / Port must be a number from 1 to 65535."
                    }
                    else {
                        $Proxy = "$($proxyUri.Scheme)://$($proxyUri.Host):$port"
                        Write-Host "代理端口已更新 / Proxy port updated: $port"
                    }
                }
                Write-Host ""
            }
            "0" { exit 0 }
            default {
                Write-Warning "无效选择。 / Invalid selection."
                Write-Host ""
            }
        }
    }
}

$availability = @(Get-ProxyTargetAvailability)
if ($Target -contains "All") {
    $Target = @($availability | Where-Object Installed | Select-Object -ExpandProperty Target)
    $skipped = @($availability | Where-Object { -not $_.Installed } | Select-Object -ExpandProperty Target)
    if ($skipped.Count -gt 0) {
        Write-Host "跳过未安装组件：$($skipped -join ', ')"
    }
}

$Target = @($Target | Where-Object { $_ -ne "All" } | Select-Object -Unique)
if ($Target.Count -eq 0) {
    Write-Error "没有检测到可启动的组件。"
    exit 1
}

$failed = 0
foreach ($targetName in $Target) {
    try {
        Start-ProxyTarget -Target $targetName -Proxy $Proxy -Restart:$Restart | Out-Null
    }
    catch {
        $failed++
        Write-Warning "[$targetName] $($_.Exception.Message)"
    }
}

if ($failed -gt 0) {
    exit 1
}
