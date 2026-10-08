# KeepDesktopInteractive

> [!WARNING]
> **After disconnect, this project's console handoff intentionally leaves your Windows desktop unlocked.**
> Anyone with physical keyboard/mouse access or interactive VM-console access can use your Windows session without signing in to Windows.
>
> **Lower-risk examples:** a cloud Dev Box/VM where untrusted people cannot reach a physical screen or open its console; or a dedicated pipeline test machine/account with the same access restrictions. A test account may still have access to credentials, test data, and other systems.
>
> **Hyper-V:** people allowed to open VMConnect can use the unlocked desktop. Only enable this if you trust the host administrators and everyone granted VM-console access.
>
> **Do not use:** a shared office PC others can walk up to, or a VM whose console is accessible to people you do not trust. Follow your organization's policies. This is **not automation behind a locked screen**.

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

- **Minimize:** client support varies, especially Windows App versions. Verify your own setup.
- **Reboot:** settings persist; log in and unlock once, then restart your apps and automation.
- **Limits:** sleep, shutdown, lock policies, and sign-out can still stop automation.

[Setup results, troubleshooting, undo, and implementation details](docs/configuration.md)

## License

[MIT](LICENSE) · Copyright 2026 yeelam-gordon.
