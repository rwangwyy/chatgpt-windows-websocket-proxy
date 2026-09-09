# 故障排查 / Troubleshooting

## 中文

### 启动后仍然重连

- 确认代理软件正在运行，且端口类型与协议一致。
- 确认代理规则允许 `chatgpt.com` 的 TCP 443 和 WebSocket Upgrade。
- 确认应用是通过本项目启动，而不是复用了旧进程。
- Chrome 插件场景确认 ChatGPT App、Chrome 扩展和 Native Host 都已安装。
- VS Code 场景确认 Codex 扩展使用的是通过本项目启动的 VS Code。

### 提示目标已经运行

完全退出对应应用，包括托盘和后台进程，再重试。确认没有未保存内容后，可以使用 Windows 的 `-Restart` 或 macOS 的 `--restart`。

### 提示未检测到组件

Windows 运行 `windows/Start-WithProxy.ps1 -ListAvailable`；macOS 运行 `macos/Start-WithProxy.command --list-available`。便携版或非标准安装路径可能无法自动发现。

### 双击后窗口一闪而过

从终端运行对应入口以查看错误信息。macOS 首次使用可能需要执行：

```bash
chmod +x macos/*.command
```

不要关闭 Defender、SmartScreen 或添加安全排除项。Windows Release ZIP 应先解除锁定并验证 SHA-256。

### 代理端口不确定

默认端口是 `7890`，但代理软件的 HTTP、Mixed 和 SOCKS5 端口可能不同。只有确认端口类型后，才使用对应协议，例如 `socks5://127.0.0.1:7891`。

## English

### The app still reconnects

- Confirm that the proxy client is running and that the URL scheme matches the port type.
- Confirm that proxy rules allow TCP 443 and WebSocket Upgrade traffic for `chatgpt.com`.
- Confirm that the app was launched by this project rather than reusing an older process.
- For Chrome, verify the ChatGPT app, extension, and Native Host are installed.
- For VS Code, verify that the Codex extension is running inside a VS Code instance launched by this project.

### The target is already running

Fully quit the application, including tray and background processes. After saving work, use Windows `-Restart` or macOS `--restart` if necessary.

### A target is not detected

Run `windows/Start-WithProxy.ps1 -ListAvailable` on Windows or `macos/Start-WithProxy.command --list-available` on macOS. Portable and non-standard installations may not be discovered automatically.

### The window disappears after double-clicking

Run the entry point from a terminal to see the error. On macOS, run `chmod +x macos/*.command` once if needed.

Do not disable Defender or SmartScreen. For Windows Release ZIPs, unblock the archive and verify its SHA-256 first.

### The proxy port is unclear

The default is `7890`, but HTTP, Mixed, and SOCKS5 ports may differ. Use `socks5://127.0.0.1:7891` only when that port is actually SOCKS5.
