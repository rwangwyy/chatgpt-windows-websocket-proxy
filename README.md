# ChatGPT / Chrome / VS Code WebSocket 代理启动器

一个按进程注入本地代理的 Windows/macOS 启动器，帮助 ChatGPT App、ChatGPT Chrome 插件相关进程和 VS Code Codex 插件使用 WebSocket 代理。它不修改系统代理、不写入持久环境变量，也不需要 TUN 或管理员权限。

> 这不是 OpenAI 官方工具。应用或代理客户端更新后，网络行为可能变化。

## 快速开始

### Windows

1. 从 [GitHub Releases](https://github.com/rwangwyy/chatgpt-windows-websocket-proxy/releases) 下载并解压 ZIP。
2. 双击 [`windows/Start-WithProxy.cmd`](./windows/Start-WithProxy.cmd)。
3. 在菜单中选择目标；默认代理为 `http://127.0.0.1:7890`。

### macOS

双击 [`macos/Start-WithProxy.command`](./macos/Start-WithProxy.command)，按菜单选择目标。成功启动后启动用的 Terminal 会自动关闭。

首次使用若没有执行权限：

```bash
chmod +x macos/*.command
```

## 支持目标

- ChatGPT App
- Google Chrome（包括 Chrome Native Host）
- Visual Studio Code（包括 Extension Host 和 Codex `app-server`）
- ChatGPT + Chrome 组合启动

## 文档索引

- [使用说明 / Usage](./docs/usage.md)
- [故障排查 / Troubleshooting](./docs/troubleshooting.md)
- [工作原理与目录 / Architecture and Layout](./docs/architecture.md)
- [English README](./README.en.md)

## 项目信息

- [变更记录 / Changelog](./docs/CHANGELOG.md)
- [MIT License](./LICENSE)
