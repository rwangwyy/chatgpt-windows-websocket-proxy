# 使用说明 / Usage

## 中文

### Windows

1. 启动本地代理软件，确认 HTTP 或 Mixed 代理端口。
2. 完全退出要启动的应用，包括托盘和后台进程。
3. 双击 [`windows/Start-WithProxy.cmd`](../windows/Start-WithProxy.cmd)，按菜单选择目标。

默认代理为 `http://127.0.0.1:7890`。也可以从 `windows/` 目录运行：

```powershell
.\Start-WithProxy.ps1 -ListAvailable
.\Start-WithProxy.ps1 -Target ChatGPT,Chrome -Proxy 127.0.0.1:7897
.\Start-WithProxy.ps1 -Target VSCode -Proxy socks5://127.0.0.1:7891
.\Start-WithProxy.ps1 -Target All -Proxy 127.0.0.1:7890
```

如果目标已经运行，脚本默认提示并退出；确认没有未保存内容后，可追加 `-Restart` 强制重启。

### macOS

直接双击 [`macos/Start-WithProxy.command`](../macos/Start-WithProxy.command)，然后选择 ChatGPT、Chrome、VS Code、ChatGPT + Chrome 或全部已安装目标。成功启动后启动用的 Terminal 会自动关闭。

命令行示例：

```bash
./macos/Start-WithProxy.command --list-available
./macos/Start-WithProxy.command --target ChatGPT,Chrome --proxy 127.0.0.1:7890
./macos/Start-WithProxy.command --target VSCode --proxy 127.0.0.1:7890
./macos/Start-WithProxy.command --target All --proxy 127.0.0.1:7890
```

也可以使用独立入口：

```bash
./macos/Start-ChatGPTWithProxy.command 127.0.0.1:7890
./macos/Start-ChromeWithProxy.command 127.0.0.1:7890
./macos/Start-VSCodeWithProxy.command 127.0.0.1:7890
```

macOS 脚本会从 `/Applications`、`~/Applications` 或 Spotlight 查找应用。首次使用如果没有执行权限：

```bash
chmod +x macos/*.command
```

### Chrome 插件和 VS Code 插件

Chrome 入口会传入 `--proxy-server`，并让 Chrome 启动的 Native Host 继承代理。使用 ChatGPT Chrome 插件时，应同时选择 ChatGPT + Chrome，或先启动 ChatGPT 再启动 Chrome。

VS Code 入口会让 Extension Host 及其启动的 Codex `app-server` 继承代理。

### 代理地址

支持 `http`、`https` 和 `socks5`。不带协议时按 HTTP 处理：

```text
127.0.0.1:7890
http://127.0.0.1:7890
socks5://127.0.0.1:7891
```

## English

### Windows

1. Start the local proxy client and identify its HTTP or Mixed port.
2. Fully quit the target applications, including tray and background processes.
3. Double-click [`windows/Start-WithProxy.cmd`](../windows/Start-WithProxy.cmd) and choose a target.

The default proxy is `http://127.0.0.1:7890`. You can also run commands from `windows/`:

```powershell
.\Start-WithProxy.ps1 -ListAvailable
.\Start-WithProxy.ps1 -Target ChatGPT,Chrome -Proxy 127.0.0.1:7897
.\Start-WithProxy.ps1 -Target VSCode -Proxy socks5://127.0.0.1:7891
.\Start-WithProxy.ps1 -Target All -Proxy 127.0.0.1:7890
```

Running targets are refused by default. Add `-Restart` only after saving work.

### macOS

Double-click [`macos/Start-WithProxy.command`](../macos/Start-WithProxy.command) and choose ChatGPT, Chrome, VS Code, ChatGPT + Chrome, or all installed targets. The launcher Terminal closes after successful startup.

Command-line examples:

```bash
./macos/Start-WithProxy.command --list-available
./macos/Start-WithProxy.command --target ChatGPT,Chrome --proxy 127.0.0.1:7890
./macos/Start-WithProxy.command --target VSCode --proxy 127.0.0.1:7890
./macos/Start-WithProxy.command --target All --proxy 127.0.0.1:7890
```

Standalone entries are also available. If Finder reports a permission problem, run `chmod +x macos/*.command` once.

### Chrome and VS Code extensions

The Chrome entry passes `--proxy-server` and lets Chrome-launched Native Host processes inherit the proxy. For the ChatGPT Chrome extension, select ChatGPT + Chrome or launch ChatGPT and Chrome separately.

The VS Code entry lets the Extension Host and its Codex `app-server` child process inherit the proxy.

### Proxy URLs

`http`, `https`, and `socks5` are supported. Values without a scheme are treated as HTTP.
