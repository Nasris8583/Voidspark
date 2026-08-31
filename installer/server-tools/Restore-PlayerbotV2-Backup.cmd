@echo off
setlocal
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Restore-PlayerbotV2-Backup.ps1"
echo.
pause
