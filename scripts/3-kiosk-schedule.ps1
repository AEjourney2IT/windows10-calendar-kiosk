# Calendar Kiosk - step 6: daily sleep/wake schedule.
# Run while signed in as Calendar, in regular PowerShell (not admin):
#   powershell -ExecutionPolicy Bypass -File .\3-kiosk-schedule.ps1
# Change the times below to fit your family.

$WakeAM  = '6:00AM'
$SleepAM = '9:00AM'
$WakePM  = '2:00PM'
$SleepPM = '7:00PM'

# Remove any earlier kiosk tasks
Get-ScheduledTask "Kiosk*" -ErrorAction SilentlyContinue | Unregister-ScheduledTask -Confirm:$false

$s = New-ScheduledTaskSettingsSet -WakeToRun -StartWhenAvailable

# Wake: wait 15 s, then press the invisible F15 key so the screen turns on
$wake = New-ScheduledTaskAction -Execute powershell.exe -Argument '-WindowStyle Hidden -Command "Start-Sleep 15; (New-Object -ComObject WScript.Shell).SendKeys(''{F15}'')"'

# Sleep
$sleep = New-ScheduledTaskAction -Execute rundll32.exe -Argument 'powrprof.dll,SetSuspendState 0,1,0'

Register-ScheduledTask "Kiosk Wake AM"  -Action $wake  -Trigger (New-ScheduledTaskTrigger -Daily -At $WakeAM)  -Settings $s | Out-Null
Register-ScheduledTask "Kiosk Sleep AM" -Action $sleep -Trigger (New-ScheduledTaskTrigger -Daily -At $SleepAM) | Out-Null
Register-ScheduledTask "Kiosk Wake PM"  -Action $wake  -Trigger (New-ScheduledTaskTrigger -Daily -At $WakePM)  -Settings $s | Out-Null
Register-ScheduledTask "Kiosk Sleep PM" -Action $sleep -Trigger (New-ScheduledTaskTrigger -Daily -At $SleepPM) | Out-Null

Write-Host "Schedule created. Next runs:"
Get-ScheduledTask "Kiosk*" | Get-ScheduledTaskInfo | Select-Object TaskName, NextRunTime | Format-Table -AutoSize
