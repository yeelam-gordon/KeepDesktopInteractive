# KeepDesktopInteractive

> [!WARNING]
> **Disconnect handoff leaves your remote Windows desktop unlocked.** Anyone at its physical keyboard or with interactive VM-console access can use your session without signing in to Windows.
> **Do not use on a shared PC others can walk up to.** For Hyper-V, trust everyone allowed to open VMConnect. A cloud Dev Box or pipeline test account is not automatically safe: console access and account permissions still matter.
> This is **not automation behind a locked screen**. [Safety examples and requirements](docs/configuration.md).

![Before/after: closing or locking your notebook, losing the network, or minimizing RDP can leave remote apps running but the agent stuck. Host handoff and compatible client rendering help preserve mouse input, typing, and screenshots. Verify your setup; console handoff leaves the remote desktop unlocked.](https://raw.githubusercontent.com/yeelam-gordon/KeepDesktopInteractive/1213eb0de83bb0db3f6bae6d1a8c98e682c2135d/assets/keep-desktop-interactive.png)

For **AI agents and UI tests on Windows PCs or VMs accessed over RDP**.
Each situation has different requirements:

| When you... | What helps |
| --- | --- |
| **Close your notebook or lose the network** | Once Windows detects an RDP disconnect, the host task hands your existing session to the console. Closing the lid is covered only if it causes that disconnect; network-loss detection can take time. |
| **Lock your local screen** | Passed with client setup applied and the notebook awake on our tested client/host pair; verify with your own client. This is not the same as locking the remote desktop. |
| **Minimize the remote window** | Client-side rendering configuration helps keep automation usable; support varies by RDP client. |

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

- **Reboot:** settings persist; log in and unlock once, then restart your apps and automation.
- **Limits:** remote desktop locking, sleep, shutdown, and sign-out can still stop automation.

[Setup results, troubleshooting, undo, and implementation details](docs/configuration.md)

## License

[MIT](LICENSE) · Copyright 2026 yeelam-gordon.
