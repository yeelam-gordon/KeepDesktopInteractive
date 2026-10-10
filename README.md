# KeepDesktopInteractive — Windows GUI after disconnect

<a id="languages"></a>

<details>
<summary>Languages / 语言 / 言語 / اللغات (16)</summary>

**Languages:** [English](README.md) · [简体中文](docs/i18n/README.zh-CN.md) · [繁體中文](docs/i18n/README.zh-TW.md) · [日本語](docs/i18n/README.ja.md) · [한국어](docs/i18n/README.ko.md) · [Español](docs/i18n/README.es.md) · [Português (Brasil)](docs/i18n/README.pt-BR.md) · [Français](docs/i18n/README.fr.md) · [Deutsch](docs/i18n/README.de.md) · [Italiano](docs/i18n/README.it.md) · [Русский](docs/i18n/README.ru.md) · [Türkçe](docs/i18n/README.tr.md) · [Tiếng Việt](docs/i18n/README.vi.md) · [Bahasa Indonesia](docs/i18n/README.id.md) · [हिन्दी](docs/i18n/README.hi.md) · [العربية](docs/i18n/README.ar.md)

</details>

Windows App client, Microsoft Dev Box host, or Windows RDP? Keep your computer-use agent or UI test clicking, typing and taking screenshots after a detected disconnect; stop watching the connected client (minimize only with verified compatible rendering); reuse your signed-in session without stored passwords or autologon.

Unlocked console; follow policy. Windows Sandbox minimization: unvalidated.

<img src="assets/keep-desktop-interactive.png" width="700" alt="Before/after: closing or locking your notebook, losing the network, or minimizing RDP can leave remote apps running but the agent stuck. Host handoff and compatible client rendering help preserve mouse input, typing, and screenshots. Verify your setup; console handoff leaves the remote desktop unlocked.">

- **Keep agent input working after disconnect:** preserve clicks, typing and screenshots in the existing desktop once Windows detects the RDP disconnect; network detection may take time.
- **Stop babysitting the connected client:** step away from the remote window; minimized use requires compatible client rendering and a separate successful input test on your setup.
- **Reuse work already signed in:** keep the existing user session and open apps, without storing passwords or enabling autologon; this does not log you in after reboot.

Concept artwork; English labels, not live proof. Client support and awake-notebook local lock are conditional.

> [!WARNING]
> **Handoff leaves the remote desktop unlocked:** physical or interactive VM-console users can use your session without Windows sign-in. **Not for shared walk-up PCs or untrusted consoles; no lock-policy bypass.** [Access risks](docs/configuration.md).

Applies only where policy permits configuring RDP/console handoff; verify your host and client, not a blanket Dev Box certification.

**Start:** [Set up both computers](#two-computers-two-launchers) → [Prove real input](#prove-it-works) · [Limits](#know-before-using) · [Undo](docs/configuration.md#undo) · Windows Sandbox minimization: not yet validated.

**[Windows Sandbox](https://learn.microsoft.com/en-us/windows/security/application-security/application-isolation/windows-sandbox/) — minimized window; UNVALIDATED candidate:** When the Windows Sandbox window on the host is minimized and the guest and its apps keep running, can clicks, typing and screenshots continue? Deployment and input continuity are unvalidated; this utility may or may not work with Sandbox’s client renderer or guest handoff—test separately, not an existing fix.

## Know before using

Installed diagnostics attempt real clicks, typing and capture **10 seconds after every configured-user RDP disconnect**, including later normal use, and can contend with your GUI agent. Reserve the desktop for diagnostics; no dedicated supported diagnostic-only opt-out launcher flag is documented. Host uninstall removes handoff too. Overlapping triggers are ignored while a diagnostic is already running (`IgnoreNew`); this is not a once-only installation test.

| When you... | What helps |
| --- | --- |
| **Close your notebook or lose the network** | Once Windows detects an RDP disconnect, the host task hands your existing session to the console. Closing the lid is covered only if it causes that disconnect; network-loss detection can take time. |
| **Lock your local screen** | Maintainer-reported pass with client setup applied and the notebook awake on the tested client/host pair; verify with your own client. This is not the same as locking the remote desktop. |
| **Minimize the remote window** | Client-side rendering configuration helps keep automation usable; support varies by RDP client. |

- **Reboot:** settings persist; log in and unlock once, then restart your apps and automation.
- **Limits:** remote desktop locking, sleep, shutdown, and sign-out can still stop automation.

- **Client compatibility:** the rendering setting is documented for classic Remote
  Desktop Connection; Windows App support depends on its version. A pass on one
  client/host pair is not universal support. [Verification limits](docs/configuration.md#requirements-and-limitations).

This independent utility does not integrate/start your agent, store passwords or provide autologon. [Mode and component details](docs/configuration.md#mode-choice).

| Desired mode | Setup purpose / proof |
| --- | --- |
| Disconnect | Host handoff task; retain documented two-computer setup, then AfterDisconnect proof |
| Minimized client | Compatible local rendering **plus host setup**; retain both launchers, then WhileClientMinimized proof |

## Sandbox experiment — unvalidated

This is not a verified Sandbox installation path: Windows App/RDP setup, disconnect proof and close/reopen recovery below do not apply. Establish an approved working deployment/test method or stop. Proposed: harmless visible-window click/type/capture baseline → recorded minimized interval with guest/apps still alive → actual input/new capture during that interval → restore window and inspect. Continuing apps alone are not proof. If input/capture fails, **keep the window visible**. [Full proposed plan](docs/configuration.md#sandbox-minimized-window-experiment).

## Two computers. Two launchers.

**Need:** a Windows host and local Windows client; an existing logged-in, unlocked host kept powered on and awake; policies permitting this use; host administrator approval; Git, Windows PowerShell 5.1 and VBScript. Reboot requires login/unlock and restarting your apps; no headless execution or autologon. [Complete requirements](docs/configuration.md#requirements-and-limitations).

Use a **fresh trusted clone** in each current user's private folder. Never use a shared writable checkout; approve host administrator elevation.

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
| **Remote Windows PC or VM** | `start-desktop-session-setup.vbs` | Approve administrator setup; check `Installed: true` / `Status: Ready` |
| **Your local Windows PC** running Windows App / RDP | `set-local-rdp-minimize-rendering.vbs` | Check `Succeeded: true`; fully close/reopen the client and reconnect |

[Where to check setup results](docs/configuration.md#quick-setup). Then verify real input below; no stored passwords or background agent server.

## Prove it works

- **Keep existing GUI work usable after disconnect:** host handoff runs once Windows detects your RDP session disconnecting; network detection may take time.
- **Test minimized-window input separately:** the local rendering setting helps compatible clients, not every client/version.
- **Check actual clicks, typing and capture:** mode-specific private diagnostic results distinguish usable input from apps merely running.

**Before any live probe:** record test start time; no other UI automation may use this desktop. Save sensitive work and move confidential windows out of the capture area. Disconnect triggers an automatic input/capture diagnostic.

**Maintainer-reported evidence; not new tests or universal Dev Box certification:**

| Scenario | Reported result / deployed protection / date | Client version / host build / tested revision |
| --- | --- | --- |
| AfterDisconnect | Fresh protected-installation pass reported; date unknown | All unknown / not retained |
| WhileClientMinimized, original Windows App/Windows host | Pass before hardening; **not rechecked after deployment**; date unknown | All unknown / not retained |
| Local notebook screen locked, notebook awake, client configured | Tested-pair pass reported 2026-10-08; protection state unknown; JSON mode not retained | All unknown / not retained |
| Windows Sandbox host window minimized, guest/apps alive | **UNVALIDATED**; deployment/input/capture method unknown | All unknown; no tested revision |

[Evidence detail](docs/configuration.md#reported-compatibility-evidence).

Confirm the proof file was **updated after this test started** using its file modified time, then require `Passed: true` and the matching `Mode`; an old successful file is not this run. No invented JSON timestamp field is needed. After success, perform one harmless representative app click/type/capture task at the **resulting console resolution**; the generic probe does not prove every app or coordinate locator.

**Disconnect:** disconnect for 30 seconds, then reconnect. The diagnostic runs automatically.

**Minimize:** run this on the remote machine, then immediately minimize the client for 90 seconds (the probe waits 60 seconds before input/capture):

```powershell
wscript.exe .\test-interactive-desktop-automation.vbs --minimized-test
```

Check `%LOCALAPPDATA%\KeepDesktopInteractive\desktop-proof.json` for
**`Passed: true`** and `Mode: AfterDisconnect` or `Mode: WhileClientMinimized`,
matching the test you just ran. A minimized pass counts only if the client stayed
minimized during real input and screenshot capture; the host cannot observe that state.
Private logs and screenshots stay
beside that result, outside the installed scripts and Git checkout. They can include
other visible desktop content; do not publish them.

## If the proof fails

**Windows App/RDP route only; Sandbox uses its separate unvalidated plan and visible-window fallback.**

| Symptom | Next action |
| --- | --- |
| `Passed: false` | Read `Error`, `Stage`, and private diagnostic logs; confirm the remote desktop is unlocked and awake, then check [requirements](docs/configuration.md#requirements-and-limitations) and [configuration checks](docs/configuration.md#configuration-checks). Running apps alone are not proof. |
| Missing or stale `desktop-proof.json` | Check remote `Installed: true` / `Status: Ready` and local `Succeeded: true` in [setup results](docs/configuration.md#quick-setup); failed/interrupted setup needs [recovery](docs/configuration.md#security-boundaries). Repeat the [correct test and timing](docs/configuration.md#verify-on-each-new-machine), then inspect the new result. |
| Minimized input fails or the client ignores the setting | Fully close/reopen the client after setup; verify [client/version limits](docs/configuration.md#requirements-and-limitations). Do not claim minimized support without a matching pass. Keep the client visible or use the separately verified disconnect workflow; [restore client settings](docs/configuration.md#undo) if unsuitable. |

## Undo

Removing host tasks and restoring client registry values **does not automatically lock the current unlocked console**. After saving work and finishing automation, manually lock the host and verify console sign-in is required, or sign out intentionally to end applications. Lock/sign-out can stop GUI automation; sign-out ends user apps.

Run host uninstall and client restore separately; preserve the client backup until
restoration is no longer needed. [Undo](docs/configuration.md#undo).

[Setup results, troubleshooting, undo, and implementation details](docs/configuration.md)

## Updates and trust

Installed scripts live in `%ProgramData%\KeepDesktopInteractive`: **Administrators
and SYSTEM can modify them; your normal user can only read and execute them.**
Do not install from a shared writable checkout. Updating installed code requires
administrator approval.

**Routine updates:** use a new private destination rather than cloning into the existing nonempty folder; retain old checkout/backups until setup and fresh proofs pass. Then obtain a fresh trusted checkout in your private user folder,
then rerun `wscript.exe .\start-desktop-session-setup.vbs` on the remote host
from that folder and approve administrator elevation to update installed code.
Editing or updating the checkout alone does not update the protected installation.
Check [setup results](docs/configuration.md#quick-setup), then repeat both
[disconnect and minimized proofs](#prove-it-works) and inspect fresh matching-mode
results. An update is not proof of minimized-client compatibility.

## License

[MIT](LICENSE) · Copyright 2026 yeelam-gordon.
