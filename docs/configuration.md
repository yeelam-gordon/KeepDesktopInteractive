# Configuration guide

## Quick setup

Clone or download this private repository on both computers. Put it in a permanent,
user-writable folder such as `C:\s\KeepDesktopInteractive`.

```powershell
git clone https://github.com/yeelam-gordon/KeepDesktopInteractive.git C:\s\KeepDesktopInteractive
```

The repository is currently private, so cloning or downloading requires access.

| Where | Run | What it does |
| --- | --- | --- |
| Remote Windows machine, logged in as the automation user | Double-click `launch-desktop-session-setup.vbs` and approve administrator elevation | Install persistent disconnect-handoff and diagnostic tasks for that user |
| Local PC running Windows App or Remote Desktop Connection | Double-click `set-local-rdp-minimize-rendering.vbs` | Set the current user's minimized-rendering registry value in the 32-bit and 64-bit registry views |

Fully close and reopen the remote client after client setup, then reconnect.
A client PC reboot is usually unnecessary.

**That's the setup:** one launcher on the remote machine, one on the local PC.
Then run the checks below once to prove both capabilities on your machines.

Setup deliberately hides PowerShell console windows through VBScript. Administrator
approval remains visible. VBScript and Windows PowerShell 5.1 must be available.

Check setup results:

- Remote: `elevation-result.json` beside the scripts, then
  `%ProgramData%\DevboxDesktopSession\setup-result.json` with `Installed: true`.
- Local: `local-rdp-minimize-result.json` with `Succeeded: true`.

The remote setup does not disconnect you unless you explicitly request
`--verify-disconnect`. Do not move the remote project folder after installation:
the diagnostic task references its location. Rerun setup if you move it.

## Verify on each new machine

**Disconnect:** disconnect normally, wait 30 seconds, then reconnect.
The automatic diagnostic should report `Passed: true` and `Mode: AfterDisconnect`
in `desktop-proof.json`.

**Minimize:** run this on the remote machine:

```powershell
wscript.exe .\test-desktop-after-disconnect.vbs --minimized-test
```

Immediately minimize the remote client and leave it minimized for 90 seconds.
The probe waits 60 seconds before attempting real mouse input, typing, and screen
capture. Restore the client and check `desktop-proof.json` for `Passed: true`
and `Mode: WhileClientMinimized`.

Detailed results, logs, and cropped test-window screenshots are saved under
`Diagnostics\<timestamp>-<pid>`. Screenshots can include nearby desktop content;
keep them private. These files and local registry backups are excluded from Git.

The remote machine cannot observe whether the client window is minimized. A passing
minimize test proves this case only if you kept the client minimized during input
and screenshot capture.

## What persists

- After disconnect, a SYSTEM task transfers only the selected user's disconnected
  session to the console with `tscon`. Copilot, applications, and UI automation
  continue as that user, not SYSTEM.
- A separate interactive-user task runs diagnostics 10 seconds after disconnect.
  It completes within a bounded run; there is no polling while connected.
- Tasks and client registry settings survive reboot. After a remote reboot, log
  in and unlock once. Restart Copilot, your applications, and automation runners
  unless you separately configured them to start at logon. This project does not
  enable autologon or restart your applications.
- You can reconnect normally. No RDP authentication, networking, or firewall
  settings are changed.

## Requirements and limitations

This intentionally keeps the remote desktop **unlocked** after disconnect. Use it
only on an access-controlled machine where your organization's policies allow it.
The host installer requires administrator approval; UI automation itself should
run in the selected user's interactive session, not a service in Session 0.

The machine must remain powered on. Sleep, hibernation, automatic shutdown,
disconnected-session logoff, screensaver locks, and organization-enforced lock
policies can still interrupt automation. Setup does not change or bypass these
policies and does not unlock a desktop that is already locked.

Console handoff can change the display resolution. Verify your automation with
the console resolution rather than assuming it matches the remote client's.

The client setting is `RemoteDesktop_SuppressWhenMinimized = 2` under
`HKCU\Software\Microsoft\Terminal Server Client`. It is documented for classic
Remote Desktop Connection. Windows App behavior depends on the version; run the
minimize test rather than assuming support.

Both capabilities passed live tests on the original Windows App / Windows host
pair. Post-reboot behavior and different machines must be verified separately.

Only one automation user is configured per remote machine. Reinstalling for a
different user is refused until the existing installation is removed. SYSTEM
executes an embedded, protected copy of the handoff script, not a user-writable
script file. Reinstall after changing that script.

## Undo

Remove remote scheduled tasks from the remote machine:

```powershell
wscript.exe .\launch-desktop-session-setup.vbs --uninstall
```

Restore the original client registry values on the same client PC and user:

```powershell
wscript.exe .\set-local-rdp-minimize-rendering.vbs --restore
```

Keep `local-rdp-minimize-backup.json` until restoration is no longer needed.
Neither operation deletes diagnostic evidence. Host removal does not change
client settings, and client restoration does not remove host tasks.

## Configuration checks

```powershell
powershell.exe -NoProfile -File .\Test-Configuration.ps1
```

This checks script syntax, launcher wiring, and read-only session discovery.
It does not disconnect you or change registry values.

## References

- [Microsoft: preserving a UI test session after RDP disconnect](https://learn.microsoft.com/en-us/azure/devops/pipelines/test/ui-testing-considerations?view=azure-devops#visible-ui-testing-using-self-hosted-windows-agents)
- [Microsoft: tscon](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/tscon)
- [SmartBear: minimized Remote Desktop client settings](https://support.smartbear.com/testleft/docs/using/running-tests/remote-computers/rdp/running-tests-in-minimized-remote-desktop-window.html)

## License

[MIT](../LICENSE). You may use, modify, and redistribute the code under that license.
Keeping the GitHub repository private limits who can access it; it does not change
the license terms.

The README illustration is original project artwork, not a test screenshot.
Its editable source is `assets\keep-desktop-interactive.svg`; the PNG is rendered
from that source. Both are covered by the project license.
