@echo off
setlocal
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0Start-WithProxy.ps1" -PromptForPort %*
set "exitCode=%ERRORLEVEL%"
if not "%exitCode%"=="0" pause
exit /b %exitCode%
