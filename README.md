# Calendar Kiosk (Windows 10 + One Calendar)

Turn a spare Windows 10 desktop into a family wall calendar. The PC signs into a dedicated Windows account on its own, opens **One Calendar** synced with Google Calendar, and is only awake while the family is home.

## What's in this repo

| Path | What it does | Run as |
|---|---|---|
| `scripts/1-set-autologon.cmd` | Auto sign-in to Calendar (asks for the password, never stores it in the file) | Owner, Run as administrator |
| `scripts/2-power-settings.cmd` | Sleep, screen and wake-timer settings | Owner, Run as administrator |
| `scripts/3-kiosk-schedule.ps1` | Creates the four daily sleep/wake tasks (times editable at the top) | Calendar, regular PowerShell |
| `scripts/check-schedule.ps1` | Shows the next sleep/wake times | Calendar |
| `scripts/undo-schedule.ps1` | Removes the schedule | Calendar |
| `scripts/undo-system.cmd` | Restores power settings and turns off auto sign-in | Owner, Run as administrator |
| `docs/undo.md` | Step-by-step undo guide | — |

The scripts do the same thing as the manual steps below. Use whichever you prefer.

To run a `.ps1` script: `powershell -ExecutionPolicy Bypass -File .\scripts\3-kiosk-schedule.ps1`

## Schedule

| Time | Action | Reason |
|---|---|---|
| 6:00 AM | Wake | Before we wake up |
| 9:00 AM | Sleep | We've left for the day |
| 2:00 PM | Wake | We're close to home |
| 7:00 PM | Sleep | Bedtime |

Awake 8 hours a day, asleep 16.

## Hardware used

| Item | Detail |
|---|---|
| PC | HP EliteDesk |
| Processor | Intel Core i5-6500 @ 3.20 GHz |
| RAM | 16 GB |
| Graphics | Intel HD Graphics 530 |
| Storage | 954 GB SATA SSD |
| Windows | Windows 10 Pro 22H2 (build 19045), 64-bit |
| Display | Monitor, no touch |

> **Security note:** Windows 10 consumer Extended Security Updates end October 13, 2026. Keep this PC single-purpose. Don't use it for banking, email or other personal sign-ins.

## Accounts

| Account | Type | Purpose |
|---|---|---|
| Owner | Administrator | Maintenance and setup only |
| Calendar | Standard user | Signs in automatically and runs the display |

Use your own password for the Calendar account. Don't commit it to this repo.

## Why One Calendar

Options considered:

- **Browser kiosk** showing a Google Calendar embed URL. Simple, but the embed is display-only.
- **[Prism](https://github.com/sandydargoport/prism)**, a self-hosted family dashboard. Polished, but needs Docker, WSL and Google Cloud OAuth setup. Dropped as too much configuration.
- **One Calendar** (Microsoft Store). Syncs with Google Calendar, installs like any app, no server to maintain. **Chosen.**

## Setup

### 0. Fresh Windows 10 install
1. Back up anything on the PC. The install erases the drive.
2. On another PC, use the **Windows 10 Media Creation Tool** to make an install USB (8 GB or larger).
3. Boot the PC from the USB (boot menu key is usually F12, F11, F8 or Esc), choose *Custom: Install Windows only*, delete the old partitions and install.
4. During setup, create the **Owner** admin account and turn off the optional privacy settings.
5. Run **Settings → Update & Security → Windows Update** until no updates remain.
6. Set the correct time zone and turn on *Set time automatically*. The schedule depends on it.

### 1. Create the Calendar user (as Owner)
Settings → Accounts → Family & other users → **Add someone else to this PC** → create a local account named `Calendar` with no admin rights.

### 2. Install One Calendar (as Calendar)
1. Sign in as `Calendar`.
2. Open Microsoft Store, search **One Calendar**, and click Get.
3. Open One Calendar and sign into your Google account.

### 3. Open One Calendar at sign-in (as Calendar)
1. Press Win+R, type `shell:AppsFolder`, press Enter.
2. Right-click **One Calendar** → *Create shortcut* (it lands on the desktop).
3. Press Win+R, type `shell:startup`, and move the shortcut into that folder.

### 4. Sign in to Calendar automatically (as Owner)
Open PowerShell as administrator, type `cmd` and press Enter to switch to **Command Prompt**, then run (replace `YOUR_PASSWORD` with the Calendar account's password):

```bat
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v DefaultUserName /t REG_SZ /d Calendar /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v DefaultPassword /t REG_SZ /d YOUR_PASSWORD /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v DefaultDomainName /t REG_SZ /d %COMPUTERNAME% /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v AutoAdminLogon /t REG_SZ /d 1 /f
```

Restart. The PC should go straight into Calendar and open One Calendar.

> The password is stored in plain text in the registry. Use one that isn't used anywhere else.

### 5. Power settings (as Owner)
In admin PowerShell or Command Prompt:

```bat
powercfg /hibernate off
powercfg /change monitor-timeout-ac 0
powercfg /change standby-timeout-ac 360
powercfg /setacvalueindex SCHEME_CURRENT SUB_SLEEP RTCWAKE 1
powercfg /setactive SCHEME_CURRENT
```

| Command | Effect |
|---|---|
| `hibernate off` | Scheduled sleep is a real sleep, not hibernation |
| `monitor-timeout-ac 0` | Screen stays on during awake hours |
| `standby-timeout-ac 360` | Backup sleep after 6 hours idle (if woken at night) |
| `RTCWAKE 1` | Allows scheduled tasks to wake the PC |

Then turn off nightly maintenance wake: Control Panel → Security and Maintenance → Maintenance → *Change maintenance settings* → uncheck **Allow scheduled maintenance to wake up my computer**.

### 6. Sleep/wake schedule (as Calendar)
In regular PowerShell (not admin), paste all at once:

```powershell
Get-ScheduledTask "Kiosk*" -ErrorAction SilentlyContinue | Unregister-ScheduledTask -Confirm:$false
$s = New-ScheduledTaskSettingsSet -WakeToRun -StartWhenAvailable
$wake = New-ScheduledTaskAction -Execute powershell.exe -Argument '-WindowStyle Hidden -Command "Start-Sleep 15; (New-Object -ComObject WScript.Shell).SendKeys(''{F15}'')"'
$sleep = New-ScheduledTaskAction -Execute rundll32.exe -Argument 'powrprof.dll,SetSuspendState 0,1,0'
Register-ScheduledTask "Kiosk Wake AM" -Action $wake -Trigger (New-ScheduledTaskTrigger -Daily -At 6:00AM) -Settings $s
Register-ScheduledTask "Kiosk Sleep AM" -Action $sleep -Trigger (New-ScheduledTaskTrigger -Daily -At 9:00AM)
Register-ScheduledTask "Kiosk Wake PM" -Action $wake -Trigger (New-ScheduledTaskTrigger -Daily -At 2:00PM) -Settings $s
Register-ScheduledTask "Kiosk Sleep PM" -Action $sleep -Trigger (New-ScheduledTaskTrigger -Daily -At 7:00PM)
```

The wake tasks press an invisible F15 key 15 seconds after waking, so the screen turns on instead of staying dark. One Calendar stays open through sleep.

Check the schedule:

```powershell
Get-ScheduledTask "Kiosk*" | Get-ScheduledTaskInfo | Select TaskName, NextRunTime
```

## Undo

**Remove the schedule** (as Calendar, regular PowerShell):
```powershell
Get-ScheduledTask "Kiosk*" | Unregister-ScheduledTask -Confirm:$false
```

**Restore power settings** (as Owner, admin):
```bat
powercfg /restoredefaultschemes
powercfg /hibernate on
```

**Turn off auto sign-in** (as Owner, admin Command Prompt):
```bat
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v AutoAdminLogon /t REG_SZ /d 0 /f
reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v DefaultPassword /f
```

**Stop One Calendar at sign-in** (as Calendar): Win+R → `shell:startup` → delete the shortcut.

## Lessons learned

- **PowerShell and Command Prompt are not interchangeable.** PowerShell drops a blank `""` argument and doesn't expand `%COMPUTERNAME%`, so the auto sign-in settings saved wrong and Windows showed "The user name or password is incorrect." Type `cmd` first when commands are written for Command Prompt.
- **Auto sign-in is more reliable with a real password.** A blank password with `netplwiz` kept stopping at the sign-in screen. A simple password stored in the registry worked.
- **Simpler beat feature-rich.** Prism looked great but needed a server stack. One Calendar did the job with a Store install and a startup shortcut.
- **Each Windows user is separate.** The app, startup shortcut and scheduled tasks are set up while signed in as Calendar, because that's the account the display runs under.

## Troubleshooting

- **Stops at the sign-in screen:** rerun step 4 in Command Prompt (not PowerShell). Windows turns `AutoAdminLogon` off after a failed attempt.
- **Doesn't wake on schedule:** check that `powercfg /waketimers` (as Owner) lists the next wake, and that the PC was asleep, not shut down.
- **Wakes but the screen stays dark:** press a key once, then confirm the wake tasks exist with the check command above.
