# ChatGPT Windows WebSocket Proxy Launcher

A lightweight Windows launcher that injects proxy settings into the ChatGPT desktop process. It is intended to keep both HTTP and WebSocket traffic on a local Clash HTTP/Mixed port without enabling Clash TUN mode or changing persistent Windows proxy settings.

> This is not an official OpenAI tool. Future ChatGPT client updates may change its networking behavior.

## Background

After some ChatGPT/Codex Windows app updates, Work mode began preferring WebSocket for long-lived communication. In setups using Clash, FlClash, Clash Verge, or similar proxies without TUN mode, ordinary HTTP requests may follow the proxy while WebSocket connections bypass it or fail to establish.

The app may then repeatedly show `Reconnecting 1/5` through `Reconnecting 5/5` before falling back to HTTP. In typical environments, this reconnect sequence can take around 75 seconds in total. Even after the fallback succeeds, the HTTP connection experience is generally less stable and efficient than WebSocket.

This project provides a small, reversible launcher that injects proxy settings only into the ChatGPT process tree. Its goal is to route Work mode WebSocket traffic through the local Clash proxy, reduce unnecessary reconnect delays, and restore a more stable WebSocket experience without enabling TUN mode or changing persistent Windows proxy settings.

## Requirements

- Windows Store ChatGPT desktop app
- Clash, FlClash, Clash Verge, or another local HTTP/Mixed proxy
- A local proxy address, such as `http://127.0.0.1:7890`

## Quick start

1. Start your proxy client and identify its HTTP or Mixed port.
2. Fully exit ChatGPT, including its tray/background process.
3. Double-click [`Start-ChatGPTWithProxy.cmd`](./Start-ChatGPTWithProxy.cmd).

The default proxy is `http://127.0.0.1:7890`. Pass a different port to the `.cmd` launcher:

```text
Start-ChatGPTWithProxy.cmd 127.0.0.1:7897
```

Or run the PowerShell script directly:

```powershell
.\Start-ChatGPTWithProxy.ps1 -Proxy 127.0.0.1:7897
```

Full proxy URLs are supported:

```powershell
.\Start-ChatGPTWithProxy.ps1 -Proxy http://127.0.0.1:7897
.\Start-ChatGPTWithProxy.ps1 -Proxy socks5://127.0.0.1:7891
```

Use `socks5://` only when the selected port is actually a SOCKS5 port. HTTP and SOCKS ports are often different in Clash configurations.

## If ChatGPT is already running

The launcher does not force-close an existing ChatGPT process by default. Exit ChatGPT first. If you have no unsaved work and explicitly want to restart it:

```powershell
.\Start-ChatGPTWithProxy.ps1 -Proxy 127.0.0.1:7890 -Restart
```

## How it works

The launcher finds the installed AppX package, sets `HTTP_PROXY`, `HTTPS_PROXY`, `WS_PROXY`, and `WSS_PROXY` only in the launcher process, and starts ChatGPT from that process.

It does not modify:

- Windows user or system environment variables;
- the registry or Windows system proxy settings;
- routes, drivers, or TUN configuration;
- administrator-only system state.

The workaround is motivated by a public Windows report where HTTP respected the system proxy but WebSocket transport timed out; explicit `HTTP_PROXY` and `HTTPS_PROXY` settings made WebSocket transport work. See [openai/codex#29958](https://github.com/openai/codex/issues/29958).

## Troubleshooting

- Make sure the proxy client is running and the selected port is HTTP or Mixed.
- Check that `chatgpt.com` TCP 443 and WebSocket Upgrade traffic are allowed by your proxy rules.
- Confirm that `ChatGPT.exe` appears in the proxy connection list.
- Make sure ChatGPT was started by this launcher, rather than an older instance.
- If the app cannot be found, verify that it was installed through Microsoft Store for the current Windows user. See the [official OpenAI instructions](https://help.openai.com/en/articles/9982051-using-the-chatgpt-windows-app).

## License

[MIT License](./LICENSE)
