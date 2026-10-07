# KeepDesktopInteractive

![KeepDesktopInteractive: remote desktop disconnects or minimizes can interrupt UI automation; configure the remote host and local client so the same user session keeps working.](assets/keep-desktop-interactive.png)

**Close the remote desktop window, not your automation.**

Disconnecting or minimizing a remote desktop can break mouse input, typing, and
screenshots even while your apps keep running. This project addresses both:
**console handoff on the host, minimized rendering on the client.**

## Two computers. Two launchers.

Clone or download this repo on both computers, into a permanent folder.
The repo is **private** for now; access is required.

```powershell
git clone https://github.com/yeelam-gordon/KeepDesktopInteractive.git C:\s\KeepDesktopInteractive
```

| Where | Double-click | Then |
| --- | --- | --- |
| **Remote machine** (Devbox / Windows VM) | `launch-desktop-session-setup.vbs` | Approve administrator setup |
| **Your local PC** running Windows App / RDP | `set-local-rdp-minimize-rendering.vbs` | Fully close and reopen the remote client |

No stored passwords, no autologon, no background agent server. Automation stays
in your logged-in user session. Requires Windows PowerShell 5.1 and VBScript.

## Prove it works

**Disconnect:** disconnect for 30 seconds, then reconnect. The diagnostic runs automatically.

**Minimize:** run this on the remote machine, then minimize the client for 90 seconds:

```powershell
wscript.exe .\test-desktop-after-disconnect.vbs --minimized-test
```

Check `desktop-proof.json` for **`Passed: true`** and the matching mode.
Logs and screenshots stay in `Diagnostics\`, excluded from Git.

## Know before using

- **Security:** disconnect handoff intentionally leaves the desktop unlocked. Use only where permitted.
- **Minimize:** client support varies, especially Windows App versions. Verify your own setup.
- **Reboot:** settings persist; log in and unlock once, then restart your apps and automation.
- **Limits:** sleep, shutdown, lock policies, and sign-out can still stop automation.

[Setup results, troubleshooting, undo, and implementation details](docs/configuration.md)

## License

[MIT](LICENSE) · Copyright 2026 yeelam-gordon.
