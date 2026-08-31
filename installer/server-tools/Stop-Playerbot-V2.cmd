@echo off
setlocal
echo Stopping TrinityCore services...
taskkill /IM worldserver.exe /T >nul 2>&1
taskkill /IM bnetserver.exe /T >nul 2>&1
timeout /t 2 /nobreak >nul
tasklist /FI "IMAGENAME eq worldserver.exe" | find /I "worldserver.exe" >nul && taskkill /F /IM worldserver.exe /T >nul 2>&1
tasklist /FI "IMAGENAME eq bnetserver.exe" | find /I "bnetserver.exe" >nul && taskkill /F /IM bnetserver.exe /T >nul 2>&1
echo Server stopped.
exit /b 0
