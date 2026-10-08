# KeepDesktopInteractive

![KeepDesktopInteractive: remote desktop disconnects or minimizes can interrupt UI automation; configure the remote host and local client so the same user session keeps working.](assets/keep-desktop-interactive.png)

**Close the remote desktop window, not your automation.**

For **Windows PCs and VMs accessed over RDP**, including Windows App and
Remote Desktop Connection.

Disconnecting or minimizing a remote desktop can break mouse input, typing, and
screenshots even while your apps keep running. This project addresses both:
**console handoff on the host, minimized rendering on the client.**

## Two computers. Two launchers.

Use a **fresh trusted clone** on both computers, inside your existing user's private folder.

```powershell
git clone https://github.com/yeelam-gordon/KeepDesktopInteractive.git "$env:LOCALAPPDATA\KeepDesktopInteractiveSource"
```

| Where | Double-click | Then |
| --- | --- | --- |
| **Remote Windows PC or VM** | `start-desktop-session-setup.vbs` | Approve administrator setup |
| **Your local Windows PC** running Windows App / RDP | `set-local-rdp-minimize-rendering.vbs` | Fully close and reopen the remote client |

No stored passwords, no autologon, no background agent server. Automation stays
in your logged-in user session. Requires Windows PowerShell 5.1 and VBScript.

Installed scripts live in `%ProgramData%\KeepDesktopInteractive`: **Administrators
and SYSTEM can modify them; your normal user can only read and execute them.**
Do not install from a shared writable checkout. Updating installed code requires
administrator approval.

## Prove it works

**Disconnect:** disconnect for 30 seconds, then reconnect. The diagnostic runs automatically.

**Minimize:** run this on the remote machine, then minimize the client for 90 seconds:

```powershell
wscript.exe .\test-interactive-desktop-automation.vbs --minimized-test
```

Check `%LOCALAPPDATA%\KeepDesktopInteractive\desktop-proof.json` for
**`Passed: true`** and the matching mode. Private logs and screenshots stay
beside that result, outside the installed scripts and Git checkout.

## Know before using

- **Security:** disconnect handoff intentionally leaves the desktop unlocked. Use only where permitted.
- **Minimize:** client support varies, especially Windows App versions. Verify your own setup.
- **Reboot:** settings persist; log in and unlock once, then restart your apps and automation.
- **Limits:** sleep, shutdown, lock policies, and sign-out can still stop automation.

[Setup results, troubleshooting, undo, and implementation details](docs/configuration.md)

## License

[MIT](LICENSE) · Copyright 2026 yeelam-gordon.
