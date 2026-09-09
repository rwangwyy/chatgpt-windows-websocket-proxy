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

function Normalize-ProxyUri {
    param([string]$Value)

    if ([string]::IsNullOrWhiteSpace($Value)) {
        throw "代理地址不能为空。示例：127.0.0.1:7890 或 http://127.0.0.1:7890"
    }

    if ($Value -notmatch "^[a-zA-Z][a-zA-Z0-9+.-]*://") {
        $Value = "http://$Value"
    }

    try {
        $uri = [Uri]$Value
    }
    catch {
        throw "无效的代理地址：$Value"
    }

    if (-not $uri.Host -or $uri.Port -lt 1) {
        throw "代理地址必须包含主机和端口：$Value"
    }

    return $uri.AbsoluteUri.TrimEnd('/')
}

function Get-ChatGPTApp {
    # 新版客户端的内部包名是 OpenAI.Codex；保留 OpenAI.ChatGPT 以兼容旧版本/变体。
    $package = @(
        Get-AppxPackage -Name "OpenAI.Codex" -ErrorAction SilentlyContinue
        Get-AppxPackage -Name "OpenAI.ChatGPT" -ErrorAction SilentlyContinue
    ) | Sort-Object Version -Descending | Select-Object -First 1

    if (-not $package) {
        throw "找不到 ChatGPT Windows 商店版。请先安装客户端，或检查当前 Windows 用户是否安装了它。"
    }

    $manifest = Get-AppxPackageManifest -Package $package
    $application = @($manifest.Package.Applications.Application) | Select-Object -First 1
    if (-not $application -or [string]::IsNullOrWhiteSpace([string]$application.Executable)) {
        throw "无法从 ChatGPT 安装包读取启动程序。"
    }

    $executable = Join-Path $package.InstallLocation ([string]$application.Executable)
    if (-not (Test-Path -LiteralPath $executable -PathType Leaf)) {
        throw "找不到 ChatGPT 启动程序：$executable"
    }

    return [PSCustomObject]@{
        Package = $package
        Executable = $executable
    }
}

$proxyUri = Normalize-ProxyUri $Proxy
$app = Get-ChatGPTApp
$processName = [IO.Path]::GetFileNameWithoutExtension($app.Executable)
$running = @(Get-Process -Name $processName -ErrorAction SilentlyContinue)

if ($running.Count -gt 0) {
    if (-not $Restart) {
        Write-Warning "ChatGPT 已经在运行。请先完全退出客户端（包括系统托盘），再重新运行此脚本。"
        Write-Warning "如果确认要强制重启，请追加参数：-Restart"
        exit 2
    }

    $running | Stop-Process -Force
    Start-Sleep -Milliseconds 300
}

# 这些变量只存在于本脚本及 ChatGPT 进程树中，不写入用户/系统环境变量、注册表或代理设置。
# 不设置 ALL_PROXY：Clash 的 7890/7897 可能是 HTTP 端口而不是 SOCKS 端口。
$env:HTTP_PROXY = $proxyUri
$env:HTTPS_PROXY = $proxyUri
$env:WS_PROXY = $proxyUri
$env:WSS_PROXY = $proxyUri

$localNoProxy = "localhost,127.0.0.1,::1"
if ([string]::IsNullOrWhiteSpace($env:NO_PROXY)) {
    $env:NO_PROXY = $localNoProxy
}
elseif ($env:NO_PROXY -notmatch "(^|,)127\.0\.0\.1(,|$)") {
    $env:NO_PROXY = "$localNoProxy,$($env:NO_PROXY)"
}

Write-Host "正在启动 ChatGPT：$($app.Package.Name) $($app.Package.Version)"
Write-Host "进程代理：$proxyUri"
Start-Process -FilePath $app.Executable
