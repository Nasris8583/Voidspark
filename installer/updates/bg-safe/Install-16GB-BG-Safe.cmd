@echo off
setlocal
title Voidspark 16 GB Battleground Safe Update
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Install-16GB-BG-Safe.ps1" %*
if errorlevel 1 (
  echo.
  echo The update was not installed. Read the error above.
  pause
  exit /b 1
)
echo.
pause

