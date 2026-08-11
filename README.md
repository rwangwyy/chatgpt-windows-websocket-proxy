# ChatGPT Windows WebSocket 代理启动器

一个轻量的 Windows 启动脚本：在不启用 Clash TUN 模式、不修改系统代理和持久环境变量的情况下，为 ChatGPT Windows 客户端注入进程级代理配置，使 HTTP 和 WebSocket 请求都通过 Clash 的本地 HTTP/Mixed 端口。

> 这不是 OpenAI 官方工具。ChatGPT 客户端或其网络实现更新后，行为可能发生变化。

## 项目背景

随着 ChatGPT/Codex Windows 客户端更新，Work 模式在部分版本中会优先使用 WebSocket 进行长连接通信。对于使用 Clash、FlClash、Clash Verge 等代理、但没有开启 TUN 模式的环境，HTTP 请求可能可以正常通过代理，而 WebSocket 连接却直接连接或无法建立。

此时客户端通常会反复显示 `Reconnecting 1/5` 至 `Reconnecting 5/5`，随后回退到 HTTP 连接。整个重连过程在常见网络环境下可能累计消耗约 75 秒；即使最终连接成功，回退后的 HTTP 长连接体验通常也不如 WebSocket 稳定、高效。

本项目旨在提供一个简洁、可撤销的启动方式：只在 ChatGPT 客户端进程及其子进程中注入代理配置，让 Work 模式下的 WebSocket 也通过 Clash 的本地代理端口，从而减少无意义的重连等待，并恢复更稳定的 WebSocket 连接体验。

## 适用场景

- Windows 商店版 ChatGPT 客户端
- Clash、FlClash、Clash Verge 等提供本地 HTTP/Mixed 代理端口的客户端
- 不希望开启 TUN，也不希望把代理写入 Windows 用户/系统环境变量
- HTTP 请求可以访问，但 ChatGPT 客户端 WebSocket 反复重连或超时

## 快速开始

1. 启动 Clash/FlClash/Clash Verge，确认本地 HTTP 或 Mixed 端口。
2. 完全退出 ChatGPT，包括系统托盘中的后台进程。
3. 双击 [`Start-ChatGPTWithProxy.cmd`](./Start-ChatGPTWithProxy.cmd)。

脚本默认使用 `http://127.0.0.1:7890`。如果你的端口不同，可以把端口作为参数传给 `.cmd`：

```text
Start-ChatGPTWithProxy.cmd 127.0.0.1:7897
```

也可以直接运行 PowerShell 脚本：

```powershell
.\Start-ChatGPTWithProxy.ps1 -Proxy 127.0.0.1:7897
```

支持完整代理地址：

```powershell
.\Start-ChatGPTWithProxy.ps1 -Proxy http://127.0.0.1:7897
.\Start-ChatGPTWithProxy.ps1 -Proxy socks5://127.0.0.1:7891
```

默认按 HTTP 代理处理端口。只有在确认端口是 SOCKS5 时，才使用 `socks5://`；Clash 的 HTTP 端口和 SOCKS 端口不一定相同。

## ChatGPT 已经在运行时

脚本默认不会强制关闭正在运行的客户端，而是提示你先退出。这是为了避免误杀进程或丢失未保存内容。

确认没有未保存内容后，可以使用 `-Restart`：

```powershell
.\Start-ChatGPTWithProxy.ps1 -Proxy 127.0.0.1:7890 -Restart
```

## 工作原理

启动器会：

1. 自动查找当前 Windows 用户安装的 ChatGPT AppX 包和实际启动文件；
2. 仅在启动进程中设置 `HTTP_PROXY`、`HTTPS_PROXY`、`WS_PROXY`、`WSS_PROXY`；
3. 由这个带有代理变量的进程启动 ChatGPT 客户端。

因此它不会：

- 修改 Windows 用户或系统环境变量；
- 修改注册表或 Windows 系统代理开关；
- 开启 TUN、安装驱动或修改路由；
- 要求管理员权限。

关闭 ChatGPT 后，这些代理变量随客户端进程树消失。

这个 workaround 的动机来自 Windows 客户端中“系统代理对 HTTP 生效，但 WebSocket 仍可能超时”的公开复现；显式设置 `HTTP_PROXY` 和 `HTTPS_PROXY` 后，WebSocket 可以正常工作。参见 [openai/codex#29958](https://github.com/openai/codex/issues/29958)。

## 故障排查

### 提示找不到 ChatGPT Windows 商店版

请确认 ChatGPT 已通过 Microsoft Store 安装，并且当前 Windows 用户可以正常启动它。官方安装说明见 [OpenAI Help Center](https://help.openai.com/en/articles/9982051-using-the-chatgpt-windows-app)。

### 启动后仍然反复重连

- 确认 Clash 正在运行，且传入的是 HTTP 或 Mixed 端口；
- 确认节点可用，规则允许 `chatgpt.com` 的 TCP 443 流量和 WebSocket Upgrade；
- 在 Clash 的连接列表中确认出现 `ChatGPT.exe`；
- 确认 ChatGPT 是通过脚本启动的，而不是之前已经运行的实例；
- 如果使用 SOCKS5，确认地址前缀写成 `socks5://`。

### 双击后窗口一闪而过

从 PowerShell 运行脚本，可以看到具体错误：

```powershell
cd "D:\path\to\ProxyFix"
.\Start-ChatGPTWithProxy.ps1 -Proxy 127.0.0.1:7890
```

## 文件说明

| 文件 | 用途 |
| --- | --- |
| `Start-ChatGPTWithProxy.cmd` | 推荐日常使用，双击即可启动 |
| `Start-ChatGPTWithProxy.ps1` | 主脚本，支持参数和详细错误信息 |
| `README.en.md` | English documentation |

## 卸载

删除本仓库目录即可。脚本不安装服务、驱动或常驻组件，也不写入系统代理配置。

## 贡献

欢迎提交 Issue 或 Pull Request。提交问题时，请尽量提供：Windows 版本、ChatGPT App 版本、代理软件和端口类型、运行命令及错误信息。请勿粘贴账号、Token、订阅链接或其他敏感信息。

## 许可证

[MIT License](./LICENSE)
