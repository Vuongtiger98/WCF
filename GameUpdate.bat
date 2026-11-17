@echo off
setlocal DisableDelayedExpansion
chcp 65001 >nul
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0gameupdate\Update.ps1" -GameRoot "%~dp0." -Pause
exit /b %errorlevel%
