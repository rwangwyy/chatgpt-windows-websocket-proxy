# ChatGPT / Chrome / VS Code WebSocket Proxy Launcher

A process-scoped proxy launcher for Windows and macOS. It helps ChatGPT, ChatGPT Chrome extension processes, and the VS Code Codex extension use a local proxy for WebSocket traffic without changing system proxy settings, persistent environment variables, routes, or TUN configuration.

> This is not an official OpenAI tool. Networking behavior may change after application or proxy-client updates.

## Quick start

### Windows

1. Download and extract the ZIP from [GitHub Releases](https://github.com/rwangwyy/chatgpt-windows-websocket-proxy/releases).
2. Double-click [`windows/Start-WithProxy.cmd`](./windows/Start-WithProxy.cmd).
3. Choose a target from the menu. The default proxy is `http://127.0.0.1:7890`.

### macOS

Double-click [`macos/Start-WithProxy.command`](./macos/Start-WithProxy.command) and choose a target. The launcher Terminal closes after successful startup.

If Finder reports a permission problem on first use:

```bash
chmod +x macos/*.command
```

## Supported targets

- ChatGPT app
- Google Chrome, including Chrome Native Host processes
- Visual Studio Code, including the Extension Host and Codex `app-server`
- ChatGPT + Chrome combined launch

## Documentation index

- [Usage / 使用说明](./docs/usage.md)
- [Troubleshooting / 故障排查](./docs/troubleshooting.md)
- [Architecture and Layout / 工作原理与目录](./docs/architecture.md)
- [中文 README](./README.md)

## Project information

- [Changelog / 变更记录](./docs/CHANGELOG.md)
- [MIT License](./LICENSE)
