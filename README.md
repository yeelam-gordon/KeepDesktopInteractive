# KeepDesktopInteractive

**Your remote agent should not need you to babysit an RDP window.**

You leave an AI agent or UI test working on a Windows VM or Dev Box. Then you
close your notebook, lock your local screen, lose the network, or minimize the
remote window. The remote apps may still be running, but **clicks, typing, and
screenshots can stop working**. Your agent is running, yet its work is stuck.

KeepDesktopInteractive helps keep that remote desktop usable when you step away:

| When you... | What helps |
| --- | --- |
| **Close your notebook or lose the network** | Once Windows detects an RDP disconnect, the host task hands your existing session to the console. Closing the lid is covered only if it causes that disconnect; network-loss detection can take time. |
| **Lock your local screen** | With client setup applied, real input and screenshots passed on our tested setup while the notebook stayed awake. Verify your own client. |
| **Minimize the remote window** | Client-side rendering configuration helps keep automation usable; support varies by RDP client. |

**Two launchers: one on the remote Windows PC/VM, one on your local Windows PC.**
No stored passwords or autologon. The remote machine must stay awake and its
desktop unlocked; this does not keep automation working through a remote lock,
sign-out, or shutdown.

> [!WARNING]
> **After disconnect, this project's console handoff intentionally leaves your Windows desktop unlocked.**
> Anyone with physical keyboard/mouse access or interactive VM-console access can use your Windows session without signing in to Windows.
>
> **Lower-risk examples:** a cloud Dev Box/VM where untrusted people cannot reach a physical screen or open its console; or a dedicated pipeline test machine/account with the same access restrictions. A test account may still have access to credentials, test data, and other systems.
>
> **Hyper-V:** people allowed to open VMConnect can use the unlocked desktop. Only enable this if you trust the host administrators and everyone granted VM-console access.
>
> **Do not use:** a shared office PC others can walk up to, or a VM whose console is accessible to people you do not trust. Follow your organization's policies. This is **not automation behind a locked screen**.

![Before/after: closing or locking your notebook, losing the network, or minimizing RDP can leave remote apps running but the agent stuck. Host handoff and compatible client rendering help preserve mouse input, typing, and screenshots. Verify your setup; console handoff leaves the remote desktop unlocked.](assets/keep-desktop-interactive.png?v=1213eb0)

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

- **Lock your local notebook:** remote mouse input, typing, and screenshots passed on our tested setup. Keep the notebook awake and the remote desktop unlocked; verify with your own RDP client.
- **Minimize:** client support varies, especially Windows App versions. Verify your own setup.
- **Reboot:** settings persist; log in and unlock once, then restart your apps and automation.
- **Limits:** remote desktop locking, sleep, shutdown, and sign-out can still stop automation. Locking your local notebook is not the same as locking the remote desktop.

[Setup results, troubleshooting, undo, and implementation details](docs/configuration.md)

## License

[MIT](LICENSE) · Copyright 2026 yeelam-gordon.
