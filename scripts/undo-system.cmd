@echo off
REM Calendar Kiosk - restore power settings and turn off auto sign-in.
REM Run as Owner: right-click this file > Run as administrator.

net session >nul 2>&1
if errorlevel 1 (
  echo Please right-click this file and choose "Run as administrator".
  pause
  exit /b 1
)

powercfg /restoredefaultschemes
powercfg /hibernate on

set "WL=HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
reg add "%WL%" /v AutoAdminLogon /t REG_SZ /d 0 /f
reg delete "%WL%" /v DefaultPassword /f

echo.
echo Done. Power settings restored and auto sign-in turned off.
echo To stop One Calendar at sign-in: as Calendar, Win+R ^> shell:startup ^> delete the shortcut.
pause
