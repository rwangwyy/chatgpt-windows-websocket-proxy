# Changelog

## [Unreleased]

- No changes yet.

## [1.1.0] - 2026-08-18

- Add optional Chrome and VS Code proxy launchers.
- Add a unified launcher with an interactive target menu and target combinations.
- Keep `Start-WithProxy.cmd` as the only double-click entry point; individual targets remain available through PowerShell.
- Prompt bilingually for the local HTTP/Mixed proxy port before showing the target menu; pressing Enter uses port `7890`.
- Add installed-target detection and the `-ListAvailable` command.
- Route Chrome through the selected proxy with a process launch flag.
- Expand the Chinese and English documentation for ChatGPT, the ChatGPT Chrome extension, and the Codex VS Code extension.

## [1.0.0] - 2026-08-11

- Add a process-scoped proxy launcher for the Windows ChatGPT app.
- Support HTTP, HTTPS, and WebSocket proxy environment variables.
- Detect the installed AppX package and executable dynamically.
- Avoid persistent environment-variable, registry, system-proxy, and TUN changes.
