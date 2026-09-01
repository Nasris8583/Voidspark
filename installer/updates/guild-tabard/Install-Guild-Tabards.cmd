@echo off
setlocal
title Voidspark Automatic Guild Tabards
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Install-Guild-Tabards.ps1" %*
if errorlevel 1 (
  echo.
  echo The update was not installed. Read the error above.
  pause
  exit /b 1
)
echo.
pause

