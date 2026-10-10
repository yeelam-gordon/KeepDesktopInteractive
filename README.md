# KeepDesktopInteractive - Keep Windows GUI automation running after RDP disconnects

> [!WARNING]
> **Disconnect handoff leaves your remote Windows desktop unlocked.** Anyone at its physical keyboard or with interactive VM-console access can use your session without signing in to Windows.
> **Do not use on a shared PC others can walk up to.** For Hyper-V, trust everyone allowed to open VMConnect. A cloud Dev Box or pipeline test account is not automatically safe: console access and account permissions still matter.
> This is **not automation behind a locked screen**. [Safety examples and requirements](docs/configuration.md).

![Before/after: closing or locking your notebook, losing the network, or minimizing RDP can leave remote apps running but the agent stuck. Host handoff and compatible client rendering help preserve mouse input, typing, and screenshots. Verify your setup; console handoff leaves the remote desktop unlocked.](https://raw.githubusercontent.com/yeelam-gordon/KeepDesktopInteractive/e9d356007267dc2b7ce8faa7e2b0559600d0fc9d/assets/keep-desktop-interactive.png)

**Languages:** [English](README.md) · [简体中文](docs/i18n/README.zh-CN.md) · [日本語](docs/i18n/README.ja.md) · [Español](docs/i18n/README.es.md) · [Português (Brasil)](docs/i18n/README.pt-BR.md) · [Français](docs/i18n/README.fr.md) · [Deutsch](docs/i18n/README.de.md)

If your **Windows GUI automation stops after RDP disconnect**, preserve an existing
unlocked session for **computer-use agents and UI tests on Windows PCs or VMs**.
This is an independent Windows utility, not a native integration with Copilot CLI,
Claude Code, Codex, Gemini CLI, Kimi, or Qwen CLI. It does not start or configure your agent.
Each situation has different requirements:

| When you... | What helps |
| --- | --- |
| **Close your notebook or lose the network** | Once Windows detects an RDP disconnect, the host task hands your existing session to the console. Closing the lid is covered only if it causes that disconnect; network-loss detection can take time. |
| **Lock your local screen** | Maintainer-reported pass with client setup applied and the notebook awake on the tested client/host pair; verify with your own client. This is not the same as locking the remote desktop. |
| **Minimize the remote window** | Client-side rendering configuration helps keep automation usable; support varies by RDP client. |

## Two computers. Two launchers.

Use a **fresh trusted clone** on both computers, inside your existing user's private folder.

```powershell
git clone https://github.com/yeelam-gordon/KeepDesktopInteractive.git "$env:LOCALAPPDATA\KeepDesktopInteractiveSource"
```

On **each computer**, open `%LOCALAPPDATA%\KeepDesktopInteractiveSource` in
File Explorer before double-clicking its launcher. Open PowerShell in that cloned
folder on the indicated computer for the command-line examples below:

```powershell
Set-Location "$env:LOCALAPPDATA\KeepDesktopInteractiveSource"
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

**Routine updates:** obtain a fresh trusted checkout in your private user folder,
then rerun `wscript.exe .\start-desktop-session-setup.vbs` on the remote host
from that folder and approve administrator elevation to update installed code.
Editing or updating the checkout alone does not update the protected installation.
Check [setup results](docs/configuration.md#quick-setup), then repeat both
[disconnect and minimized proofs](#prove-it-works) and inspect fresh matching-mode
results. An update is not proof of minimized-client compatibility.

## Prove it works

**Reported test history:** the maintainer reports a fresh after-disconnect pass
with the protected installation. The minimized-client pass was on the original
Windows App / Windows host pair **before hardening and has not been rechecked
after deployment**. These are reported results, not new tests performed for this
README update; verify both modes on your own setup. [Evidence scope and limits](docs/configuration.md#requirements-and-limitations).

**Disconnect:** disconnect for 30 seconds, then reconnect. The diagnostic runs automatically.

**Minimize:** run this on the remote machine, then minimize the client for 90 seconds:

```powershell
wscript.exe .\test-interactive-desktop-automation.vbs --minimized-test
```

Check `%LOCALAPPDATA%\KeepDesktopInteractive\desktop-proof.json` for
**`Passed: true`** and `Mode: AfterDisconnect` or `Mode: WhileClientMinimized`,
matching the test you just ran. A minimized pass counts only if the client stayed
minimized during real input and screenshot capture; the host cannot observe that state.
Private logs and screenshots stay
beside that result, outside the installed scripts and Git checkout.

## Know before using

- **Reboot:** settings persist; log in and unlock once, then restart your apps and automation.
- **Limits:** remote desktop locking, sleep, shutdown, and sign-out can still stop automation.

- **Client compatibility:** the rendering setting is documented for classic Remote
  Desktop Connection; Windows App support depends on its version. A pass on one
  client/host pair is not universal support. [Verification limits](docs/configuration.md#requirements-and-limitations).

## If the proof fails

| Symptom | Next action |
| --- | --- |
| `Passed: false` | Read `Error`, `Stage`, and private diagnostic logs; confirm the remote desktop is unlocked and awake, then check [requirements](docs/configuration.md#requirements-and-limitations) and [configuration checks](docs/configuration.md#configuration-checks). Running apps alone are not proof. |
| Missing or stale `desktop-proof.json` | Check remote `Installed: true` / `Status: Ready` and local `Succeeded: true` in [setup results](docs/configuration.md#quick-setup); failed/interrupted setup needs [recovery](docs/configuration.md#security-boundaries). Repeat the [correct test and timing](docs/configuration.md#verify-on-each-new-machine), then inspect the new result. |
| Minimized input fails or the client ignores the setting | Fully close/reopen the client after setup; verify [client/version limits](docs/configuration.md#requirements-and-limitations). Do not claim minimized support without a matching pass. Keep the client visible or use the separately verified disconnect workflow; [restore client settings](docs/configuration.md#undo) if unsuitable. |

Run host uninstall and client restore separately; preserve the client backup until
restoration is no longer needed. [Undo](docs/configuration.md#undo).

[Setup results, troubleshooting, undo, and implementation details](docs/configuration.md)

## License

[MIT](LICENSE) · Copyright 2026 yeelam-gordon.
