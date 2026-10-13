@echo off
REM Calendar Kiosk - step 5: power settings for scheduled sleep and wake.
REM Run as Owner: right-click this file > Run as administrator.

net session >nul 2>&1
if errorlevel 1 (
  echo Please right-click this file and choose "Run as administrator".
  pause
  exit /b 1
)

REM Real sleep instead of hibernation
powercfg /hibernate off
REM Screen stays on during awake hours
powercfg /change monitor-timeout-ac 0
REM Backup sleep after 6 hours idle (if someone wakes it at night)
powercfg /change standby-timeout-ac 360
REM Allow scheduled tasks to wake the PC
powercfg /setacvalueindex SCHEME_CURRENT SUB_SLEEP RTCWAKE 1
powercfg /setactive SCHEME_CURRENT

echo.
echo Done. One manual step left:
echo Control Panel ^> Security and Maintenance ^> Maintenance ^> Change maintenance settings
echo and uncheck "Allow scheduled maintenance to wake up my computer".
pause
