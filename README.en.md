# ChatGPT / Chrome / VS Code WebSocket Proxy Launcher

A lightweight, component-based Windows launcher that gives selected ChatGPT, Chrome, and VS Code process trees a local proxy without enabling Clash TUN mode or changing persistent Windows proxy or environment settings.

> This is not an official OpenAI tool. Networking behavior may change after ChatGPT, Chrome, or VS Code updates.

[中文说明](./README.md)

## Background

ChatGPT Work and Codex may prefer WebSocket for long-lived connections. With Clash, FlClash, Clash Verge, or similar proxy clients running without TUN mode, HTTP may work while WebSocket connects directly, times out, or repeatedly reconnects.

The same process-inheritance gap can affect components used by the ChatGPT Chrome extension and the local `codex.exe app-server` launched by the VS Code Codex extension. This project injects proxy settings only into targets selected by the user. Chrome and VS Code remain optional.

## Supported targets

| Target | Menu option | Use case |
| --- | --- | --- |
| ChatGPT Windows App | ChatGPT | Desktop ChatGPT and Work |
| Google Chrome | Chrome | Chrome traffic and child Native Host processes |
| Visual Studio Code | VS Code | The Codex IDE extension |
| Custom selection | ChatGPT + Chrome / All | Multiple detected targets |

Missing optional applications are not required. The All option starts only detected applications.

## Quick start

1. Start your local proxy application and identify its HTTP or Mixed proxy port.
2. Fully exit every application you intend to relaunch, including tray/background processes.
3. Double-click [`Start-WithProxy.cmd`](./Start-WithProxy.cmd), enter the port, and then choose from the target menu.

Enter only the port, such as `7897`; the proxy host is fixed to `127.0.0.1`. Press Enter without typing anything to use `7890`, resulting in `http://127.0.0.1:7890`.

To change the port or skip the interactive menu, use the unified PowerShell launcher:

```powershell
# Detect installed targets without launching anything
.\Start-WithProxy.ps1 -ListAvailable

# VS Code only
.\Start-WithProxy.ps1 -Target VSCode -Proxy 127.0.0.1:7897

# ChatGPT and Chrome for the ChatGPT Chrome extension
.\Start-WithProxy.ps1 -Target ChatGPT,Chrome -Proxy 127.0.0.1:7897

# All detected targets
.\Start-WithProxy.ps1 -Target All -Proxy 127.0.0.1:7897
```

Proxy URLs using `http`, `https`, and `socks5` are accepted. A value without a scheme is treated as HTTP.

## Choosing targets

### ChatGPT desktop only

Double-click `Start-WithProxy.cmd` and select ChatGPT, or run:

```powershell
.\Start-WithProxy.ps1 -Target ChatGPT
```

Chrome and VS Code are not required.

### ChatGPT Chrome extension

Use menu option ChatGPT + Chrome or run:

```powershell
.\Start-WithProxy.ps1 -Target ChatGPT,Chrome
```

OpenAI documentation describes the Chrome extension as communicating with a cooperating native application and includes Native Host troubleshooting. The combined mode covers the ChatGPT desktop process tree, Chrome networking, and environment inherited by Chrome child processes. The Chrome launcher also supplies `--proxy-server` for Chrome HTTP/WSS routing. See [OpenAI Docs: Chrome extension](https://learn.chatgpt.com/docs/chrome-extension).

You can still launch Chrome alone when that is all you need. The selected Chrome process sends its traffic to the local proxy port, where the proxy application's rules can choose direct or proxy routing.

### VS Code Codex extension

Select VS Code from the unified menu, or run:

```powershell
.\Start-WithProxy.ps1 -Target VSCode
```

The VS Code Extension Host and the local `codex.exe app-server` it launches inherit the scoped proxy variables.

Alternatively, configure VS Code itself:

```json
{
  "http.proxy": "http://127.0.0.1:7890"
}
```

That is a persistent VS Code preference. Use this project's launcher when you want the proxy to disappear with the process instead. See [OpenAI Docs: Codex IDE extension](https://learn.chatgpt.com/docs/codex/ide) and [Codex environment variables](https://learn.chatgpt.com/docs/config-file/environment-variables).

## Existing processes

Proxy environment and launch flags apply only when a new process is created. The scripts refuse to close an existing application by default.

After saving your work, explicitly use `-Restart` if needed:

```powershell
.\Start-WithProxy.ps1 -Target VSCode -Proxy 127.0.0.1:7890 -Restart
.\Start-WithProxy.ps1 -Target ChatGPT,Chrome -Proxy 127.0.0.1:7890 -Restart
```

`-Restart` force-stops all matching processes, so use it carefully.

## How it works

The unified entry point and new optional launchers use [`ProxyLauncher.Core.ps1`](./ProxyLauncher.Core.ps1). It performs target detection, validates the proxy URL, sets `HTTP_PROXY`, `HTTPS_PROXY`, `WS_PROXY`, `WSS_PROXY`, and local `NO_PROXY` only in the launcher process, then starts the selected application. Chrome additionally receives `--proxy-server`.

The project does not:

- change Windows user or system environment variables;
- change registry or Windows system proxy settings;
- enable TUN, install a driver, or modify routes;
- install Chrome, VS Code, or extensions;
- require administrator privileges.

The desktop workaround is motivated by a public Windows report where HTTP respected the system proxy but WebSocket timed out; explicit `HTTP_PROXY` and `HTTPS_PROXY` settings restored WebSocket transport. See [openai/codex#29958](https://github.com/openai/codex/issues/29958).

## Troubleshooting

- Run `.\Start-WithProxy.ps1 -ListAvailable` to inspect target detection without launching applications.
- Fully exit existing Chrome or VS Code background processes before launching.
- Verify that the proxy client is running and that the URL scheme matches the selected port type.
- Confirm that Clash rules allow `chatgpt.com` TCP 443 and WebSocket Upgrade traffic.
- Make sure the application was started by this project rather than an older process.
- For Chrome extension failures, verify the desktop app, extension, and Native Host installation.

## Files

| File | Purpose |
| --- | --- |
| `Start-WithProxy.cmd` | The only double-click entry point; opens the target menu |
| `Start-WithProxy.ps1` | Unified command-line and multi-target launcher |
| `Start-ChatGPTWithProxy.ps1` | Compatibility ChatGPT-only script |
| `Start-ChromeWithProxy.ps1` | Chrome-only PowerShell entry point |
| `Start-VSCodeWithProxy.ps1` | VS Code-only PowerShell entry point |
| `ProxyLauncher.Core.ps1` | Shared detection and scoped proxy logic |

## Uninstall

Delete the repository directory. No service, driver, scheduled task, or persistent proxy configuration is installed.

## License

[MIT License](./LICENSE)
