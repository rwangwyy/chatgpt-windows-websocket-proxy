# ChatGPT / Chrome / VS Code WebSocket 代理启动器

一个轻量、可选组件化的 Windows 启动器：在不启用 Clash TUN 模式、不修改 Windows 系统代理和持久环境变量的情况下，让 ChatGPT Windows App、ChatGPT Chrome 扩展相关进程以及 VS Code Codex 扩展继承本地代理配置。

> 这不是 OpenAI 官方工具。ChatGPT、Chrome 或 VS Code 更新后，网络行为可能变化。

[English](./README.en.md)

## 项目背景

ChatGPT Work 和 Codex 在部分 Windows 版本中会优先使用 WebSocket 进行长连接通信。对于使用 Clash、FlClash、Clash Verge 等代理、但没有开启 TUN 模式的环境，HTTP 请求可能可以正常通过代理，而 WebSocket 却直接连接、超时或反复重连。

桌面应用中可能连续出现 `Reconnecting 1/5` 至 `Reconnecting 5/5`，随后回退到 HTTP；累计等待可能达到约 75 秒。类似的进程代理继承问题也可能影响 ChatGPT Chrome 扩展所依赖的本机组件，以及 VS Code Codex 扩展启动的本地 `codex.exe app-server`。

本项目只为所选应用的进程树注入代理。用户可以单独选择 ChatGPT、Chrome 或 VS Code，不需要安装或启动其他组件。

## 支持的目标

| 目标 | 菜单选项 | 适用情况 |
| --- | --- | --- |
| ChatGPT Windows App | ChatGPT | 只使用桌面应用或 ChatGPT Work |
| Google Chrome | Chrome | 需要 Chrome 自身及其 Native Host 继承代理 |
| Visual Studio Code | VS Code | 使用 VS Code 中的 Codex 扩展 |
| 自选组合 | ChatGPT + Chrome / 全部 | 同时启动多个已安装目标 |

没有安装 Chrome 或 VS Code 不影响 ChatGPT 启动器；“全部”模式也只启动本机检测到的组件。

## 快速开始

1. 启动你的本地代理软件，确认其 HTTP 或 Mixed 代理端口。
2. 完全退出准备通过代理启动的应用，包括托盘和后台进程。
3. 双击 [`Start-WithProxy.cmd`](./Start-WithProxy.cmd)，先输入端口号，再按菜单选择目标。

这里只需要输入端口号，例如 `7897`；代理主机固定为 `127.0.0.1`。不输入直接回车时使用默认端口 `7890`，即 `http://127.0.0.1:7890`。

需要更换端口或跳过交互菜单时，可以使用统一 PowerShell 入口：

```powershell
# 查看本机检测结果，不启动任何应用
.\Start-WithProxy.ps1 -ListAvailable

# 只启动 VS Code
.\Start-WithProxy.ps1 -Target VSCode -Proxy 127.0.0.1:7897

# 同时启动 ChatGPT 与 Chrome
.\Start-WithProxy.ps1 -Target ChatGPT,Chrome -Proxy 127.0.0.1:7897

# 启动所有已安装目标，自动跳过未安装组件
.\Start-WithProxy.ps1 -Target All -Proxy 127.0.0.1:7897
```

支持完整代理地址：

```powershell
.\Start-WithProxy.ps1 -Target ChatGPT -Proxy http://127.0.0.1:7897
.\Start-WithProxy.ps1 -Target Chrome -Proxy socks5://127.0.0.1:7891
```

默认按 HTTP 代理处理没有协议前缀的地址。只有确认端口是 SOCKS5 时才使用 `socks5://`；代理软件的 HTTP 和 SOCKS 端口可能不同。

## 如何选择

### 只使用 ChatGPT 桌面应用

双击 `Start-WithProxy.cmd` 并选择“ChatGPT”，或运行：

```powershell
.\Start-WithProxy.ps1 -Target ChatGPT
```

这是原项目已经验证成功的使用方式，不需要启动 Chrome 或 VS Code。

### 使用 ChatGPT Chrome 扩展

推荐从统一菜单选择“ChatGPT + Chrome”，或运行：

```powershell
.\Start-WithProxy.ps1 -Target ChatGPT,Chrome
```

OpenAI 官方文档说明 Chrome 扩展会与配套本机应用通信，并在 Native Host 缺失时要求重新关联桌面应用。因此组合模式同时覆盖：

- ChatGPT 桌面进程及其子进程；
- Chrome 自身的 HTTP/WSS 请求；
- 由 Chrome 启动、可继承环境变量的本机组件。

Chrome 启动器还会传入 `--proxy-server`。这会让该 Chrome 进程的流量进入本地代理端口，再由代理软件的规则决定直连或代理。只想覆盖 Chrome 时，在菜单中单独选择“Chrome”即可。

参见 [OpenAI Docs：Chrome extension](https://learn.chatgpt.com/docs/chrome-extension)。

### 使用 VS Code Codex 扩展

在统一菜单中选择“VS Code”，或运行：

```powershell
.\Start-WithProxy.ps1 -Target VSCode
```

VS Code 的 Extension Host 和它启动的 `codex.exe app-server` 会继承启动器的代理变量。

也可以不用本项目启动 VS Code，而是在 VS Code 用户设置中配置：

```json
{
  "http.proxy": "http://127.0.0.1:7890"
}
```

这是 VS Code 自身的持久配置；如果希望关闭 VS Code 后代理设置自然消失，请使用本项目的启动器。参见 [OpenAI Docs：Codex IDE extension](https://learn.chatgpt.com/docs/codex/ide) 和 [Codex environment variables](https://learn.chatgpt.com/docs/config-file/environment-variables)。

## 应用已经在运行时

启动参数和进程环境只在创建新进程时生效。如果目标已经运行，脚本默认会停止并提示，不会自动结束应用。

确认没有未保存内容后，可以显式使用 `-Restart`：

```powershell
.\Start-WithProxy.ps1 -Target VSCode -Proxy 127.0.0.1:7890 -Restart
.\Start-WithProxy.ps1 -Target ChatGPT,Chrome -Proxy 127.0.0.1:7890 -Restart
```

`-Restart` 会强制结束目标的全部同名进程，请谨慎使用。

## 工作原理

统一入口和新增的可选启动器使用共享核心 [`ProxyLauncher.Core.ps1`](./ProxyLauncher.Core.ps1)，它会：

1. 验证并规范化 HTTP、HTTPS 或 SOCKS5 代理地址；
2. 自动检测用户选择的应用，不要求其他可选组件存在；
3. 仅在当前 PowerShell 进程中设置 `HTTP_PROXY`、`HTTPS_PROXY`、`WS_PROXY`、`WSS_PROXY` 和本地 `NO_PROXY`；
4. 从该进程启动目标，使应用及其子进程继承代理；
5. 对 Chrome 额外传入 `--proxy-server`，覆盖浏览器自身的代理解析。

它不会：

- 写入 Windows 用户或系统环境变量；
- 修改注册表或 Windows 系统代理开关；
- 开启 TUN、安装驱动或修改路由；
- 安装 Chrome、VS Code 或任何扩展；
- 要求管理员权限。

关闭通过脚本启动的应用后，这些代理变量随进程树消失。

桌面端 workaround 的依据是 Windows 上“系统代理对 HTTP 生效，但 WebSocket 仍可能超时”的公开复现；显式设置 `HTTP_PROXY` 和 `HTTPS_PROXY` 后 WebSocket 恢复。参见 [openai/codex#29958](https://github.com/openai/codex/issues/29958)。

## 故障排查

### 提示目标已经运行

完全退出对应应用后重试。Chrome 和 VS Code 都包含多个后台进程，仅关闭一个窗口可能不够；也可以在确认无未保存内容后使用 `-Restart`。

### 提示未检测到组件

该组件是可选的。运行以下命令查看自动检测结果：

```powershell
.\Start-WithProxy.ps1 -ListAvailable
```

如果软件使用便携版或非标准安装路径，当前版本可能无法自动发现，请提交 Issue 并附上安装位置，但不要包含账号或 Token。

### 启动后仍然重连

- 确认代理软件正在运行，端口类型与地址协议一致；
- 确认节点和规则允许 `chatgpt.com` 的 TCP 443 与 WebSocket Upgrade；
- 在 Clash 连接列表中确认对应进程出现；
- 确认应用确实通过本项目启动，而不是复用了旧进程；
- Chrome 扩展连接问题请确认 ChatGPT 桌面应用、Chrome 扩展和 Native Host 均已正确安装。

### 双击窗口一闪而过

从 PowerShell 运行对应脚本查看详细错误：

```powershell
cd "D:\path\to\ProxyFix"
.\Start-WithProxy.ps1 -ListAvailable
```

## 文件说明

| 文件 | 用途 |
| --- | --- |
| `Start-WithProxy.cmd` | 唯一的双击入口，显示目标选择菜单 |
| `Start-WithProxy.ps1` | 统一命令行和多目标入口 |
| `Start-ChatGPTWithProxy.ps1` | 兼容保留的 ChatGPT 独立脚本 |
| `Start-ChromeWithProxy.ps1` | Chrome 独立 PowerShell 入口 |
| `Start-VSCodeWithProxy.ps1` | VS Code 独立 PowerShell 入口 |
| `ProxyLauncher.Core.ps1` | 共享检测、代理注入和启动逻辑 |
| `README.en.md` | English documentation |

## 卸载

删除本仓库目录即可。项目不安装服务、驱动或常驻组件，也不写入系统代理配置。

## 贡献

欢迎提交 Issue 或 Pull Request。请尽量提供 Windows 版本、目标应用版本、代理软件和端口类型、运行命令及错误信息。请勿粘贴账号、Token、订阅链接或其他敏感信息。

## 许可证

[MIT License](./LICENSE)
