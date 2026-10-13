@echo off
REM Calendar Kiosk - step 4: sign in to the Calendar account automatically.
REM Run as Owner: right-click this file > Run as administrator.
REM The password is typed when asked. It is never saved in this file.

net session >nul 2>&1
if errorlevel 1 (
  echo Please right-click this file and choose "Run as administrator".
  pause
  exit /b 1
)

set "KIOSK_USER=Calendar"
set /p "KIOSK_PASS=Enter the password for the %KIOSK_USER% account: "

set "WL=HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
reg add "%WL%" /v DefaultUserName /t REG_SZ /d "%KIOSK_USER%" /f
reg add "%WL%" /v DefaultPassword /t REG_SZ /d "%KIOSK_PASS%" /f
reg add "%WL%" /v DefaultDomainName /t REG_SZ /d "%COMPUTERNAME%" /f
reg add "%WL%" /v AutoAdminLogon /t REG_SZ /d 1 /f

set "KIOSK_PASS="
echo.
echo Done. Restart the PC: it should sign straight into %KIOSK_USER%.
pause
