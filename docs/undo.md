# Kiosk Undo Commands

Use these to reverse the Calendar kiosk sleep/wake setup.

## 1. Remove the sleep/wake schedule
Sign in as **Calendar**, open regular PowerShell (not admin):

```powershell
Get-ScheduledTask "Kiosk*" | Unregister-ScheduledTask -Confirm:$false
```

## 2. Restore power settings
Sign in as **Owner**, open PowerShell as administrator:

```bat
powercfg /restoredefaultschemes
powercfg /hibernate on
```

- `restoredefaultschemes` resets screen-off, sleep and wake-timer settings to Windows defaults.
- `hibernate on` turns hibernation and Fast Startup back on.

## 3. Re-allow nightly maintenance wake (optional)
Control Panel → Security and Maintenance → Maintenance → *Change maintenance settings* → check **Allow scheduled maintenance to wake up my computer**.

## 4. Turn off automatic sign-in to Calendar (optional)
Sign in as **Owner**, open PowerShell as administrator, type `cmd`, press Enter, then:

```bat
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v AutoAdminLogon /t REG_SZ /d 0 /f
reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v DefaultPassword /f
```

## 5. Stop One Calendar opening at sign-in (optional)
Sign in as **Calendar**, press Win+R, type `shell:startup`, and delete the One Calendar shortcut.
