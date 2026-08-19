# Changelog

## [Unreleased]

- Add an automated GitHub Release workflow that publishes a complete ZIP and `SHA256SUMS.txt` for `v*` tags.
- Document checksum verification and unblocking the ZIP before extraction.
- Add a prominent three-step quick-start section at the top of both README files.

## [1.1.0] - 2026-08-18

- Add optional Chrome and VS Code proxy launchers.
- Add a unified launcher with an interactive target menu and target combinations.
- Keep `Start-WithProxy.cmd` as the only double-click entry point; individual targets remain available through PowerShell.
- Add a bilingual menu option for changing the local HTTP/Mixed proxy port; the default remains `7890`.
- Add installed-target detection and the `-ListAvailable` command.
- Route Chrome through the selected proxy with a process launch flag.
- Expand the Chinese and English documentation for ChatGPT, the ChatGPT Chrome extension, and the Codex VS Code extension.

## [1.0.0] - 2026-08-11

- Add a process-scoped proxy launcher for the Windows ChatGPT app.
- Support HTTP, HTTPS, and WebSocket proxy environment variables.
- Detect the installed AppX package and executable dynamically.
- Avoid persistent environment-variable, registry, system-proxy, and TUN changes.
