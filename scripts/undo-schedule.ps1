# Calendar Kiosk - remove the sleep/wake schedule.
# Run as Calendar in regular PowerShell.

Get-ScheduledTask "Kiosk*" -ErrorAction SilentlyContinue | Unregister-ScheduledTask -Confirm:$false
Write-Host "Kiosk schedule removed."
