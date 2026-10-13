# Calendar Kiosk - show the next sleep/wake times.
# Run as Calendar in regular PowerShell.

Get-ScheduledTask "Kiosk*" | Get-ScheduledTaskInfo |
  Select-Object TaskName, LastRunTime, NextRunTime |
  Format-Table -AutoSize

Write-Host "To confirm Windows will wake the PC, run as Owner (admin): powercfg /waketimers"
