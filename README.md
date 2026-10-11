# KeepDesktopInteractive — Keep your GUI agent working after remote disconnect

<a id="languages"></a>

<details>
<summary>Languages (16)</summary>

[English](README.md) · [简体中文](docs/i18n/README.zh-CN.md) · [繁體中文](docs/i18n/README.zh-TW.md) · [日本語](docs/i18n/README.ja.md) · [한국어](docs/i18n/README.ko.md) · [Español](docs/i18n/README.es.md) · [Português (Brasil)](docs/i18n/README.pt-BR.md) · [Français](docs/i18n/README.fr.md) · [Deutsch](docs/i18n/README.de.md) · [Italiano](docs/i18n/README.it.md) · [Русский](docs/i18n/README.ru.md) · [Türkçe](docs/i18n/README.tr.md) · [Tiếng Việt](docs/i18n/README.vi.md) · [Bahasa Indonesia](docs/i18n/README.id.md) · [हिन्दी](docs/i18n/README.hi.md) · [العربية](docs/i18n/README.ar.md)

</details>

For computer-use agents and UI tests that need clicks, typing and screenshots after you disconnect. Windows App is the client; Microsoft Dev Box or another Windows RDP machine is the already signed-in host.

<img src="assets/keep-desktop-interactive.png" width="320" alt="Concept illustration: keep clicks and typing working after disconnect; stop watching the remote window when minimized with a tested compatible client; reuse your signed-in desktop without stored passwords. Console handoff leaves it unlocked.">

Concept illustration; English labels, not proof.

- **Keep clicks, typing and screenshots working.**
- **Stop babysitting the connection.**
- **Reuse your already signed-in desktop and open apps; no stored passwords.**

<a id="know-before-using"></a>

> **Handoff leaves the console unlocked.** Anyone with actual physical or interactive VM-console access can use your session without Windows sign-in. Avoid shared walk-up PCs and untrusted consoles; follow policy.

Need Windows on both computers; an already logged-in, unlocked, awake host; policy permission; host administrator approval; Git, Windows PowerShell 5.1 and VBScript. Installed diagnostics attempt real input and capture 10 seconds after **every** configured-user RDP disconnect and can contend with your agent. [Requirements and risks](docs/configuration.md#requirements-and-limitations).

<a id="two-computers-two-launchers"></a>

## Set up both computers

On **both computers**, clone trusted source into the current user’s private folder, never a shared writable checkout:

```powershell
git clone https://github.com/yeelam-gordon/KeepDesktopInteractive.git "$env:LOCALAPPDATA\KeepDesktopInteractiveSource"
```

Open `%LOCALAPPDATA%\KeepDesktopInteractiveSource` in File Explorer on each computer; double-click:

| Where | Launcher / next action |
| --- | --- |
| Remote host | `start-desktop-session-setup.vbs` — approve elevation |
| Local client | `set-local-rdp-minimize-rendering.vbs` — fully close/reopen Windows App/RDP, reconnect |

[Setup results](docs/configuration.md#quick-setup): host `%LOCALAPPDATA%\KeepDesktopInteractive\elevation-result.json` → `%ProgramData%\KeepDesktopInteractive\setup-result.json`: `Installed: true`, `Status: Ready`; client `%LOCALAPPDATA%\KeepDesktopInteractive\local-rdp-minimize-result.json`: `Succeeded: true`.

<a id="prove-it-works"></a>

## Prove real input

Reserve the desktop, save work, hide confidential windows and record test start time. Disconnect for **30 seconds**, reconnect, then inspect `%LOCALAPPDATA%\KeepDesktopInteractive\desktop-proof.json`: its modified time must be after test start, with `Passed: true` and `Mode: AfterDisconnect`. Then test your own app’s clicks, typing and capture at the resulting console resolution. Keep screenshots private.

**Minimizing is conditional:** separately follow the [90-second test / 60-second probe delay](docs/configuration.md#verify-on-each-new-machine); require a fresh `WhileClientMinimized` pass. Otherwise keep the client visible.

## Limits

- No post-reboot login or autologon; remote locking, sleep and sign-out can stop automation.
- Client/version-specific compatibility, not universal Dev Box certification: [evidence](docs/configuration.md#reported-compatibility-evidence).
- Windows Sandbox minimized with guest/apps alive: **UNVALIDATED** [experiment](docs/configuration.md#sandbox-minimized-window-experiment), not RDP instructions.

<a id="if-the-proof-fails"></a>

**Failed, missing or stale proof?** Check `Error`, `Stage`, [setup results](docs/configuration.md#quick-setup) and [cause-specific remedies](docs/configuration.md#proof-and-setup-troubleshooting).

<a id="undo"></a>

**[Undo](docs/configuration.md#undo):** remove host tasks and restore client registry values separately. This **does not lock the console**. When finished, save work, lock the host and verify sign-in is required, or intentionally sign out to end apps.

<a id="updates-and-trust"></a>

[Updates and administrator approval](docs/configuration.md#updating-the-first-prototype) · [Security boundaries](docs/configuration.md#security-boundaries) · [Full guide](docs/configuration.md) · [MIT](LICENSE)
