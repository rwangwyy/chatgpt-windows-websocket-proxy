# 工作原理与目录 / Architecture and Layout

## 中文

Windows ChatGPT 使用 `IApplicationActivationManager` 按应用 ID 激活，保留 MSIX 程序包身份。启动期间通过 `IPackageDebugSettings.EnableDebugging` 传入代理环境块，并提供 `Resume-PackageThread.ps1` 辅助命令。Windows 会暂挂新进程的启动线程，辅助脚本检查程序包身份和线程归属后恢复该线程；没有附加调试器。随后在 `finally` 中调用 `DisableDebugging` 并释放接口，恢复正常生命周期行为。其他 Windows 目标仍按普通进程启动。

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

Windows ChatGPT is activated by application ID through `IApplicationActivationManager` to retain MSIX package identity. During activation, `IPackageDebugSettings.EnableDebugging` supplies the proxy environment block and the `Resume-PackageThread.ps1` helper command. Windows suspends the new startup thread; the helper checks package identity and thread ownership before resuming it, without attaching a debugger. A `finally` block calls `DisableDebugging` and releases the interfaces to restore normal lifecycle behavior. Other Windows targets still launch as ordinary processes.

API references: [ActivateApplication](https://learn.microsoft.com/en-us/windows/win32/api/shobjidl_core/nf-shobjidl_core-iapplicationactivationmanager-activateapplication), [EnableDebugging](https://learn.microsoft.com/en-us/windows/win32/api/shobjidl_core/nf-shobjidl_core-ipackagedebugsettings-enabledebugging).

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
