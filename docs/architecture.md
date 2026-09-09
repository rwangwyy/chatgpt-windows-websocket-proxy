# 工作原理与目录 / Architecture and Layout

## 中文

项目只向用户选择的应用进程树注入代理，不修改系统代理、持久环境变量、注册表、路由或 TUN 设置。启动器设置 `HTTP_PROXY`、`HTTPS_PROXY`、`WS_PROXY`、`WSS_PROXY` 和本地 `NO_PROXY`，随后创建的应用及子进程继承这些变量。

Chrome 额外接收 `--proxy-server`，覆盖浏览器自身的代理解析。macOS 入口直接启动 App 包内可执行文件，以确保 GUI 应用和子进程继承启动环境。

目录按系统划分：

| 目录 | 内容 |
| --- | --- |
| `windows/` | PowerShell、CMD 入口和 Windows 共享逻辑 |
| `macos/` | `.command` 入口和 macOS 共享 shell 逻辑 |
| `docs/` | 双语对照的详细文档 |
| `.github/` | GitHub Actions Release 配置 |
| `assets/` | 项目媒体资源 |

这不是 OpenAI 官方工具。ChatGPT、Chrome、VS Code 或代理客户端更新后，网络行为可能变化。

## English

The project injects proxy settings only into the process tree selected by the user. It does not change system proxy settings, persistent environment variables, the registry, routes, or TUN configuration. The launcher sets `HTTP_PROXY`, `HTTPS_PROXY`, `WS_PROXY`, `WSS_PROXY`, and local `NO_PROXY`; newly created applications and child processes inherit them.

Chrome additionally receives `--proxy-server` to override its own proxy resolution. The macOS entries launch the executable inside the app bundle directly so GUI applications and child processes inherit the launch environment.

The repository is organized by operating system:

| Directory | Contents |
| --- | --- |
| `windows/` | PowerShell, CMD entries, and Windows shared logic |
| `macos/` | `.command` entries and shared macOS shell logic |
| `docs/` | Detailed bilingual documentation |
| `.github/` | GitHub Actions Release configuration |
| `assets/` | Project media assets |

This is not an official OpenAI tool. Networking behavior may change after updates to ChatGPT, Chrome, VS Code, or the proxy client.
