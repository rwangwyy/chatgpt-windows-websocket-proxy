# 变更记录 / Changelog

## [2.0.0] - 2026-09-09

- 按系统整理项目目录：Windows 文件移入 `windows/`，macOS 文件移入 `macos/`。
- 为 macOS 增加 ChatGPT、Chrome、VS Code 独立入口和统一入口。
- macOS 入口支持进程级代理、目标检测、组合启动、端口修改和 `--restart`。
- 将详细使用、排查和原理说明整理到 `docs/`，并提供中英文对照。
- 更新 Windows Release 打包路径和项目文档索引。

## [1.1.0] - 2026-08-18

- 新增可选的 Chrome 和 VS Code 代理启动器。
- 新增带交互菜单和组合目标的统一 Windows 入口。
- 保留 `Start-WithProxy.cmd` 作为 Windows 双击入口，独立目标继续支持 PowerShell。
- 新增修改本地 HTTP/Mixed 代理端口的双语菜单选项，默认端口为 `7890`。
- 新增已安装目标检测和 `-ListAvailable` 参数。
- Chrome 启动时传入 `--proxy-server`。
- 扩展 ChatGPT Chrome 插件和 VS Code Codex 插件的使用说明。
- 新增 GitHub Release 自动打包、SHA-256 校验和说明。

## [1.0.0] - 2026-08-11

- 新增 Windows ChatGPT App 进程级代理启动器。
- 支持 HTTP、HTTPS 和 WebSocket 代理环境变量。
- 动态检测 AppX 安装包和启动程序。
- 不写入持久环境变量、注册表或系统代理设置，也不修改路由或 TUN 配置。

## English

### [Unreleased]

- Organized the repository by platform: Windows files are under `windows/`, macOS files under `macos/`.
- Added standalone and unified macOS launchers for ChatGPT, Chrome, and VS Code.
- Added macOS process-scoped proxying, target detection, combined launch, port editing, and `--restart`.
- Moved detailed usage, troubleshooting, and architecture documentation into `docs/` with bilingual content.
- Updated Windows Release packaging paths and documentation indexes.

### [1.1.0] - 2026-08-18

- Added optional Chrome and VS Code proxy launchers.
- Added a unified Windows launcher with an interactive menu and target combinations.
- Kept `Start-WithProxy.cmd` as the Windows double-click entry point, with PowerShell entries for individual targets.
- Added a bilingual menu option for changing the local HTTP/Mixed proxy port; the default remains `7890`.
- Added installed-target detection and the `-ListAvailable` parameter.
- Added Chrome's `--proxy-server` launch argument.
- Expanded documentation for the ChatGPT Chrome extension and VS Code Codex extension.
- Added automated GitHub Release packaging and SHA-256 verification guidance.

### [1.0.0] - 2026-08-11

- Added a process-scoped proxy launcher for the Windows ChatGPT app.
- Supported HTTP, HTTPS, and WebSocket proxy environment variables.
- Detected the AppX package and executable dynamically.
- Avoided persistent environment variables, registry changes, system proxy changes, route changes, and TUN configuration.
