@echo off
setlocal
set "PB_ROOT=%~dp0"
set "PB_RUNTIME=%PB_ROOT%playerbot-v2-runtime"
set "OPENSSL_MODULES=%PB_RUNTIME%"
set "PATH=%PB_RUNTIME%;%PB_ROOT%;%PATH%"

if not exist "%PB_ROOT%bnetserver.exe" (
  echo Missing bnetserver.exe
  pause
  exit /b 1
)
if not exist "%PB_RUNTIME%\worldserver.exe" (
  echo Missing playerbot-v2-runtime\worldserver.exe
  pause
  exit /b 1
)

start "TrinityCore Login 12.0.7" /D "%PB_ROOT%" "%PB_ROOT%bnetserver.exe" -c "%PB_ROOT%bnetserver.conf"
timeout /t 3 /nobreak >nul
start "TrinityCore Playerbot V2 12.0.7" /D "%PB_ROOT%" "%PB_RUNTIME%\worldserver.exe" -c "%PB_ROOT%worldserver.conf"

echo Login and world services started.
exit /b 0
