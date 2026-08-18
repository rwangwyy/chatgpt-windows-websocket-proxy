Set-StrictMode -Version 2.0

function ConvertTo-ProxyUri {
    [CmdletBinding()]
    param([Parameter(Mandatory = $true)][string]$Value)

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

    if (@("http", "https", "socks5") -notcontains $uri.Scheme.ToLowerInvariant()) {
        throw "不支持的代理协议：$($uri.Scheme)。请使用 http、https 或 socks5。"
    }

    return $uri.AbsoluteUri.TrimEnd('/')
}

function Set-ProcessProxy {
    [CmdletBinding()]
    param([Parameter(Mandatory = $true)][string]$ProxyUri)

    # 仅修改当前 PowerShell 进程；随后启动的应用和子进程会继承这些变量。
    $env:HTTP_PROXY = $ProxyUri
    $env:HTTPS_PROXY = $ProxyUri
    $env:WS_PROXY = $ProxyUri
    $env:WSS_PROXY = $ProxyUri

    $entries = @()
    if (-not [string]::IsNullOrWhiteSpace($env:NO_PROXY)) {
        $entries += @($env:NO_PROXY -split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_ })
    }

    foreach ($localAddress in @("localhost", "127.0.0.1", "::1")) {
        if ($entries -notcontains $localAddress) {
            $entries = @($localAddress) + $entries
        }
    }

    $env:NO_PROXY = ($entries | Select-Object -Unique) -join ','
}

function Get-FirstExistingFile {
    param([string[]]$Candidates)

    foreach ($candidate in $Candidates | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Select-Object -Unique) {
        if (Test-Path -LiteralPath $candidate -PathType Leaf) {
            return (Resolve-Path -LiteralPath $candidate).Path
        }
    }

    return $null
}

function Get-ChatGPTTargetInfo {
    $package = @(
        Get-AppxPackage -Name "OpenAI.Codex" -ErrorAction SilentlyContinue
        Get-AppxPackage -Name "OpenAI.ChatGPT" -ErrorAction SilentlyContinue
    ) | Sort-Object Version -Descending | Select-Object -First 1

    if (-not $package) {
        return $null
    }

    $manifest = Get-AppxPackageManifest -Package $package
    $application = @($manifest.Package.Applications.Application) |
        Where-Object { -not [string]::IsNullOrWhiteSpace([string]$_.Executable) } |
        Select-Object -First 1

    if (-not $application) {
        return $null
    }

    $executable = Join-Path $package.InstallLocation ([string]$application.Executable)
    if (-not (Test-Path -LiteralPath $executable -PathType Leaf)) {
        return $null
    }

    return [PSCustomObject]@{
        Target = "ChatGPT"
        DisplayName = "ChatGPT Windows App"
        Executable = $executable
        ProcessNames = @([IO.Path]::GetFileNameWithoutExtension($executable))
        Version = [string]$package.Version
    }
}

function Get-ChromeTargetInfo {
    $candidates = @()

    if ($env:ProgramFiles) {
        $candidates += Join-Path $env:ProgramFiles "Google\Chrome\Application\chrome.exe"
    }
    if (${env:ProgramFiles(x86)}) {
        $candidates += Join-Path ${env:ProgramFiles(x86)} "Google\Chrome\Application\chrome.exe"
    }
    if ($env:LOCALAPPDATA) {
        $candidates += Join-Path $env:LOCALAPPDATA "Google\Chrome\Application\chrome.exe"
    }

    $command = Get-Command chrome.exe -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($command) {
        $candidates += $command.Source
    }

    $executable = Get-FirstExistingFile $candidates
    if (-not $executable) {
        return $null
    }

    return [PSCustomObject]@{
        Target = "Chrome"
        DisplayName = "Google Chrome"
        Executable = $executable
        ProcessNames = @("chrome")
        Version = [Diagnostics.FileVersionInfo]::GetVersionInfo($executable).ProductVersion
    }
}

function Get-VSCodeTargetInfo {
    $candidates = @()

    if ($env:LOCALAPPDATA) {
        $candidates += Join-Path $env:LOCALAPPDATA "Programs\Microsoft VS Code\Code.exe"
        $candidates += Join-Path $env:LOCALAPPDATA "Programs\Microsoft VS Code Insiders\Code - Insiders.exe"
    }
    if ($env:ProgramFiles) {
        $candidates += Join-Path $env:ProgramFiles "Microsoft VS Code\Code.exe"
        $candidates += Join-Path $env:ProgramFiles "Microsoft VS Code Insiders\Code - Insiders.exe"
    }
    if (${env:ProgramFiles(x86)}) {
        $candidates += Join-Path ${env:ProgramFiles(x86)} "Microsoft VS Code\Code.exe"
    }

    foreach ($commandName in @("code.exe", "code-insiders.exe", "code", "code-insiders")) {
        $command = Get-Command $commandName -ErrorAction SilentlyContinue | Select-Object -First 1
        if (-not $command) {
            continue
        }

        if ([IO.Path]::GetExtension($command.Source) -ieq ".exe") {
            $candidates += $command.Source
        }
        else {
            $installRoot = Split-Path (Split-Path $command.Source -Parent) -Parent
            $candidates += Join-Path $installRoot "Code.exe"
            $candidates += Join-Path $installRoot "Code - Insiders.exe"
        }
    }

    $executable = Get-FirstExistingFile $candidates
    if (-not $executable) {
        return $null
    }

    return [PSCustomObject]@{
        Target = "VSCode"
        DisplayName = "Visual Studio Code"
        Executable = $executable
        ProcessNames = @([IO.Path]::GetFileNameWithoutExtension($executable))
        Version = [Diagnostics.FileVersionInfo]::GetVersionInfo($executable).ProductVersion
    }
}

function Get-ProxyTargetInfo {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet("ChatGPT", "Chrome", "VSCode")]
        [string]$Target
    )

    switch ($Target) {
        "ChatGPT" { return Get-ChatGPTTargetInfo }
        "Chrome" { return Get-ChromeTargetInfo }
        "VSCode" { return Get-VSCodeTargetInfo }
    }
}

function Get-ProxyTargetAvailability {
    foreach ($targetName in @("ChatGPT", "Chrome", "VSCode")) {
        $info = Get-ProxyTargetInfo -Target $targetName
        [PSCustomObject]@{
            Target = $targetName
            Installed = [bool]$info
            Version = if ($info) { $info.Version } else { "-" }
            Executable = if ($info) { $info.Executable } else { "-" }
        }
    }
}

function Stop-TargetIfNeeded {
    param(
        [Parameter(Mandatory = $true)]$TargetInfo,
        [switch]$Restart
    )

    $running = @()
    foreach ($processName in $TargetInfo.ProcessNames) {
        $running += @(Get-Process -Name $processName -ErrorAction SilentlyContinue)
    }
    $running = @($running | Sort-Object Id -Unique)

    if ($running.Count -eq 0) {
        return
    }

    if (-not $Restart) {
        throw "$($TargetInfo.DisplayName) 已经在运行。请先完全退出，或确认没有未保存内容后使用 -Restart。"
    }

    $processIds = @($running | Select-Object -ExpandProperty Id)
    $running | Stop-Process -Force
    foreach ($processId in $processIds) {
        Wait-Process -Id $processId -Timeout 5 -ErrorAction SilentlyContinue
    }
}

function Start-ProxyTarget {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet("ChatGPT", "Chrome", "VSCode")]
        [string]$Target,

        [Parameter(Mandatory = $true)]
        [string]$Proxy,

        [switch]$Restart
    )

    $proxyUri = ConvertTo-ProxyUri $Proxy
    $targetInfo = Get-ProxyTargetInfo -Target $Target
    if (-not $targetInfo) {
        throw "未检测到 $Target。该组件是可选的，请先安装它，或改为启动其他目标。"
    }

    Stop-TargetIfNeeded -TargetInfo $targetInfo -Restart:$Restart
    Set-ProcessProxy -ProxyUri $proxyUri

    $arguments = @()
    if ($Target -eq "Chrome") {
        # 环境变量供 Chrome 启动的 Native Host 继承；此参数覆盖 Chrome 自身的 HTTP/WSS 代理解析。
        $arguments += "--proxy-server=$proxyUri"
    }

    Write-Host "正在启动：$($targetInfo.DisplayName) $($targetInfo.Version)"
    Write-Host "进程代理：$proxyUri"

    if ($arguments.Count -gt 0) {
        Start-Process -FilePath $targetInfo.Executable -ArgumentList $arguments
    }
    else {
        Start-Process -FilePath $targetInfo.Executable
    }

    return $targetInfo
}
