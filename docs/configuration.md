# Configuration guide

> [!WARNING]
> **Console handoff intentionally leaves the configured user's Windows desktop unlocked after remote disconnect.**
> Anyone with physical keyboard/mouse access or interactive VM-console access can use that session without signing in to Windows.
>
> **Deployment context:** Windows App is the connection client; Microsoft Dev Box is the managed cloud workstation/service. The specific risk is another person's access to the unlocked console, not inherent insecurity of either product. A single-developer managed host with no untrusted interactive-console path is lower-risk than a shared physical PC. Do not assume Microsoft Dev Box exposes a console to others; assess actual access and account permissions, including credentials and test data. This utility does not bypass service sign-in, MFA, or organization policies.
>
> **Hyper-V:** trust the host administrators and everyone allowed to open VMConnect, because they can use the unlocked desktop.
>
> **Do not use:** a shared PC others can walk up to, or a VM with console access for people you do not trust. Follow your organization's policies.

## Scope

The host can be a physical Windows PC or a Windows VM. It needs a logged-in,
unlocked interactive user session and working Windows RDP/console support.
The client-side registry setup is for a local Windows RDP client.
Linux/macOS hosts, headless desktops, and clients that ignore this registry setting
are not covered. Multi-user Remote Desktop Services deployments are not validated;
the project configures one automation user per host and will not displace another
console user. Managed policies may prohibit the required unlocked desktop.

## Mode choice

Installed diagnostics attempt real clicks, typing and capture **10 seconds after every configured-user RDP disconnect**, including later normal use, and can contend with your GUI agent. Reserve the desktop for diagnostics; no dedicated supported diagnostic-only opt-out launcher flag is documented. Host uninstall removes handoff too. Overlapping triggers are ignored while a diagnostic is already running (`IgnoreNew`); this is not a once-only installation test.

**Windows App/RDP route only:** disconnect uses host console handoff; minimization uses compatible local rendering plus the documented host setup. Keep the tested two-computer setup: host `start-desktop-session-setup.vbs` installs protected tasks/diagnostics; local `set-local-rdp-minimize-rendering.vbs` configures client rendering. Verify `AfterDisconnect` and `WhileClientMinimized` separately for the modes you rely on. No optional-client installation shortcut is asserted from untested static inspection.

## Sandbox minimized-window experiment

**PROPOSED, UNVALIDATED, not a verified installation route.** Establish an approved, workable guest/host deployment and test method first; if none is established, stop. Do not assume the shipped probe or local RDP registry setting works with Sandbox. Windows App/RDP two-computer setup, disconnect tests and client close/reopen recovery below are not Sandbox instructions.

Record a non-sensitive visible-window baseline of intended clicks, typed text and fresh capture. Minimize the host's Sandbox window for a recorded interval while confirming the guest/apps keep running; perform the same real input and new capture during that interval. Restore the window and inspect new evidence and app state. Record actual host/guest builds, renderer, method and interval; continuing processes alone are not success. Keep the window visible if input/capture fails. Undo only changes actually applied through a verified method; do not close the guest to preserve ongoing work. This plan has not been run.

## Reported compatibility evidence

Maintainer-reported history, not current environment certification. Unknown metadata is not inferred from current HEAD. Installation Ready is not an input-compatibility result; Windows App brand evidence is not universal Microsoft Dev Box validation.

| Scenario | Reported result / deployed protection / date | Client version / host build / tested revision |
| --- | --- | --- |
| AfterDisconnect | Fresh protected-installation pass reported; date unknown | All unknown / not retained |
| WhileClientMinimized, original Windows App/Windows host | Pass before hardening; **not rechecked after deployment**; date unknown | All unknown / not retained |
| Local notebook screen locked, notebook awake, client configured | Tested-pair pass reported 2026-10-08; protection state unknown; JSON mode not retained | All unknown / not retained |
| Windows Sandbox host window minimized, guest/apps alive | **UNVALIDATED**; deployment/input/capture method unknown | All unknown; no tested revision |

## Quick setup

Create a fresh clone from this trusted GitHub repository on both computers.
Use a private folder under the existing user's profile, not a shared location
such as `C:\s`. No new Windows account or profile is required.

```powershell
git clone https://github.com/yeelam-gordon/KeepDesktopInteractive.git "$env:LOCALAPPDATA\KeepDesktopInteractiveSource"
```

| Where | Run | What it does |
| --- | --- | --- |
| Remote Windows PC or VM, logged in as the automation user | Double-click `start-desktop-session-setup.vbs` and approve administrator elevation | Install persistent disconnect-handoff and diagnostic tasks for that user |
| Local PC running Windows App or Remote Desktop Connection | Double-click `set-local-rdp-minimize-rendering.vbs` | Set the current user's minimized-rendering value in the 32-bit registry view and, on 64-bit Windows, the 64-bit view |

Fully close and reopen the remote client after client setup, then reconnect.
A client PC reboot is usually unnecessary.

**That's the setup:** one launcher on the remote machine, one on the local PC.
Then run the checks below once to prove both capabilities on your machines.

Setup deliberately hides PowerShell console windows through VBScript. Administrator
approval remains visible. VBScript and Windows PowerShell 5.1 must be available.

Check setup results:

- Remote: `%LOCALAPPDATA%\KeepDesktopInteractive\elevation-result.json`, then
  `%ProgramData%\KeepDesktopInteractive\setup-result.json` with `Installed: true`
  and `Status: Ready`.
- Local: `%LOCALAPPDATA%\KeepDesktopInteractive\local-rdp-minimize-result.json`
  with `Succeeded: true`.

Setup never forces a disconnect or sends UI input. The installed diagnostic task
uses protected copies in `%ProgramData%\KeepDesktopInteractive`, not the checkout.
Moving or editing the checkout does not change installed behavior; reinstall to update.

## Security boundaries

The safeguards below protect installed code and task definitions from tampering.
They do **not** protect an unlocked desktop from someone with console access.
Console handoff does not change RDP authentication or allow unauthenticated RDP connections.

| Location | Who may modify it | Purpose |
| --- | --- | --- |
| Private source checkout | Your current user and administrators | Trusted setup input; never clone into a folder writable by other users |
| `%ProgramData%\KeepDesktopInteractive` | Administrators and SYSTEM only | Installed executable scripts, activation record, and SYSTEM handoff log |
| `%LOCALAPPDATA%\KeepDesktopInteractive` | Your current user and administrators | Diagnostic results, screenshots, client registry backup, and setup result |

Installers reject untrusted owners, other-user write/replace permissions, hard-linked
files, and reparse points. Pre-created untrusted installation directories are rejected,
not adopted. Directory protection also checks ancestor replacement permissions.

Source is not Authenticode-signed. Obtain a fresh trusted checkout; copying a
potentially tampered shared checkout to a private folder does not authenticate it.
Setup checks the source before elevation and again before importing it.

Persistent tasks are registered disabled with restrictive task permissions. They are
activated only after protected code and task checks finish. Until the final atomic
`Status: Ready` activation record exists, both task actions refuse to operate.
Failed setup disables touched tasks and reports failure; interrupted setup may leave
new staged tasks registered, but the activation guard prevents their handoff or input.
During migration, legacy tasks are disabled before installed files or activation
state are changed, with the shared-checkout diagnostic disabled first.
Rerun setup to recover. Do not assume a failed update preserved the previous installation.

## Verify on each new machine

**Before any live probe:** record test start time; no other UI automation may use this desktop. Save sensitive work and move confidential windows out of the capture area. Disconnect triggers an automatic input/capture diagnostic.

Confirm the proof file was **updated after this test started** using its file modified time, then require `Passed: true` and the matching `Mode`; an old successful file is not this run. No invented JSON timestamp field is needed. After success, perform one harmless representative app click/type/capture task at the **resulting console resolution**; the generic probe does not prove every app or coordinate locator.

**Disconnect:** disconnect normally, wait 30 seconds, then reconnect.
The automatic diagnostic should report `Passed: true` and `Mode: AfterDisconnect`
in `%LOCALAPPDATA%\KeepDesktopInteractive\desktop-proof.json`.

**Minimize:** run this on the remote machine:

```powershell
wscript.exe .\test-interactive-desktop-automation.vbs --minimized-test
```

Immediately minimize the remote client and leave it minimized for 90 seconds.
The probe waits 60 seconds before attempting real mouse input, typing, and screen
capture. Restore the client and check the private `desktop-proof.json` for `Passed: true`
and `Mode: WhileClientMinimized`.

Detailed results, logs, and cropped test-window screenshots are saved under
`%LOCALAPPDATA%\KeepDesktopInteractive\Diagnostics\<timestamp>-<pid>`.
Screenshots can include nearby desktop content; keep them private. These files
and local registry backups are outside the checkout.

The remote machine cannot observe whether the client window is minimized. A passing
minimize test proves this case only if you kept the client minimized during input
and screenshot capture.

### Locking the local notebook

On 2026-10-08, real mouse input, typing, and screenshot capture passed while the
local notebook was locked and kept awake, with the RDP client left open. The
probe ran in the remote user's non-console session, so this result did not rely
on console handoff. The user confirmed the local lock interval; the remote host
cannot observe the notebook's lock screen.

This verifies the tested client/host setup, not every RDP client or a separate
lock-screen protection feature. Locking the local notebook is different from
locking the remote desktop: this project does not unlock a locked remote desktop.
Local sleep or client policies can also disconnect RDP; a disconnect then invokes
the normal host handoff, subject to the same safeguards and unlocked-console warning.

## What persists

- After disconnect, a SYSTEM task transfers only the selected user's disconnected
  session to the console with `tscon`. Applications and UI automation
  continue as that user, not SYSTEM.
- A separate interactive-user task runs diagnostics 10 seconds after disconnect.
  It completes within a bounded run; there is no polling while connected.
- Tasks and client registry settings survive reboot. After a remote reboot, log
  in and unlock once. Restart your applications and automation runners
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

The protected installation passed a fresh after-disconnect test with real mouse
input, typing, and screenshot capture. Minimized-client behavior passed on the
original Windows App / Windows host pair before hardening; it has not been
rechecked after deployment. Post-reboot behavior and other machines need separate
verification.

Only one automation user is configured per remote machine. Reinstalling for a
different user is refused until the existing installation is removed. SYSTEM
executes an embedded, protected copy of the handoff script, not a user-writable
script file. Reinstall after changing that script.

## Undo

Removing host tasks and restoring client registry values **does not automatically lock the current unlocked console**. After saving work and finishing automation, manually lock the host and verify console sign-in is required, or sign out intentionally to end applications. Lock/sign-out can stop GUI automation; sign-out ends user apps.

Remove remote scheduled tasks from the remote machine:

```powershell
wscript.exe .\start-desktop-session-setup.vbs --uninstall
```

Restore the original client registry values on the same client PC and user:

```powershell
wscript.exe .\set-local-rdp-minimize-rendering.vbs --restore
```

Keep `%LOCALAPPDATA%\KeepDesktopInteractive\local-rdp-minimize-backup.json`
until restoration is no longer needed.
Neither operation deletes diagnostic evidence. Host removal does not change
client settings, and client restoration does not remove host tasks.

## Configuration checks

Static syntax check, including compilation of embedded C# declarations. It does not
run setup, discovery, filesystem tests, or UI input:

```powershell
powershell.exe -NoProfile -File .\Test-DesktopSessionConfiguration.ps1 -SyntaxOnly
```

When you are ready for non-UI configuration and filesystem safeguards:

```powershell
powershell.exe -NoProfile -File .\Test-DesktopSessionConfiguration.ps1
powershell.exe -NoProfile -File .\Test-DesktopSessionSecurity.ps1
```

This checks script syntax, launcher wiring, and read-only session discovery.
The security check uses a temporary private test directory to verify rejection of
unsafe ownership, permissions, hard links, and reparse points. It does not disconnect
you or change registry values or scheduled tasks.

After installing, run `Test-DesktopSessionSecurity.ps1 -Installed` as the normal,
non-elevated automation user. It also verifies the installed code cannot be opened
for writing and checks installed task permissions. Run live disconnect/minimize
checks separately when no other UI automation is using the desktop.

## Updating the first prototype

For updates, use a **new private destination**, not a repeat clone into an existing nonempty folder. Keep old checkout and backups until protected installation and fresh relied-on-mode proofs pass.

Do not run setup from the old shared checkout. Clone the updated repository into
your private profile, then run setup there with administrator approval. Runtime
diagnostics will move to your private data directory after deployment; old evidence
is retained. No host tasks are changed merely by updating the development checkout.

To explicitly uninstall the previous tasks before installing the replacement,
use one administrator approval:

```powershell
wscript.exe .\start-desktop-session-setup.vbs --replace
```

The replacement checks that both old tasks were removed before creating new ones.
It retains logs and does not disconnect you or send UI input.

For the first prototype's old installation location, setup removes its managed
tasks before installing into `%ProgramData%\KeepDesktopInteractive`. Old logs and
files remain at their original location as evidence; no task references them
after successful migration. Uninstall also recognizes the old location when
the current installation directory does not exist.

If the old client setup saved its original registry backup beside the old scripts,
restore with that original client version first, then apply the updated setup.
Otherwise a fresh backup could capture the already-modified value rather than
the pre-setup setting. Do not discard the original backup.

## References

- [Microsoft: preserving a UI test session after RDP disconnect](https://learn.microsoft.com/en-us/azure/devops/pipelines/test/ui-testing-considerations?view=azure-devops#visible-ui-testing-using-self-hosted-windows-agents)
- [Microsoft: tscon](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/tscon)
- [SmartBear: minimized Remote Desktop client settings](https://support.smartbear.com/testleft/docs/using/running-tests/remote-computers/rdp/running-tests-in-minimized-remote-desktop-window.html)

## Related projects

Console handoff is established prior art, not a new Windows capability.

| Project | Relationship |
| --- | --- |
| [Batzendev.RemoteDesktopLockPrevent](https://github.com/batzen/Batzendev.RemoteDesktopLockPrevent) | Closest equivalent: a LocalSystem service reacts to remote disconnect and calls `tscon`; its relevant implementation is old |
| [Microsoft customer-scripts](https://github.com/microsoft/customer-scripts) | Small manual console-handoff script; the repository is archived |
| [WinAppDriver](https://github.com/microsoft/WinAppDriver) | Broader Windows UI testing framework with an interactive-desktop and `tscon` deployment guide |
| [OpenRPA](https://github.com/open-rpa/openrpa) | Broader unattended robot orchestration with credential-backed RDP sessions and robot startup |

KeepDesktopInteractive stays focused on preserving one already logged-in user's
desktop, client minimized rendering, and real-input verification. It does not
provision robot sessions or add credential storage, autologon, or lock-policy
workarounds.

## License

[MIT](../LICENSE). You may use, modify, and redistribute the code under that license.

The README PNG is AI-generated concept artwork, not a test screenshot.
`assets\keep-desktop-interactive.svg` preserves an earlier illustration; it is
not the editable source of the current PNG. Both are covered by the project license.
