# KeepDesktopInteractive — GUI-Eingaben nach RDP-Trennung erhalten

<a id="languages"></a>

<details>
<summary>Languages (16)</summary>

[English](../../README.md) · [简体中文](README.zh-CN.md) · [繁體中文](README.zh-TW.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Español](README.es.md) · [Português (Brasil)](README.pt-BR.md) · [Français](README.fr.md) · [Deutsch](README.de.md) · [Italiano](README.it.md) · [Русский](README.ru.md) · [Türkçe](README.tr.md) · [Tiếng Việt](README.vi.md) · [Bahasa Indonesia](README.id.md) · [हिन्दी](README.hi.md) · [العربية](README.ar.md)

</details>

Für Agenten und UI-Tests auf einem bestehenden Windows-Desktop: Windows App ist der Client; Microsoft Dev Box kann der Host sein, ebenso ein anderer Windows-Rechner mit RDP.

<img src="../../assets/keep-desktop-interactive.png" width="700" alt="Konzept: RDP-Client schließen, verbunden minimieren oder trennen. Apps rechnen weiter; vorher ist die Eingabe des unzufriedenen Bots blockiert, danach sendet er Hello und lächelt. Vertrauenswürdiger bereits entsperrter Host; Konsole bleibt entsperrt. Clientverhalten prüfen.">

Konzeptbild mit englischen Beschriftungen, kein Testnachweis.

- **Klicks, Eingaben und Screenshots erhalten.**
- **Die Verbindung nicht ständig betreuen.**
- **Den bereits angemeldeten Desktop und offene Apps weiterverwenden, ohne gespeicherte Passwörter.**

> **Die Übergabe lässt den entfernten Desktop entsperrt.** Wer die physische oder interaktive VM-Konsole bedienen kann, kann die Sitzung ohne Windows-Anmeldung nutzen. Nicht auf zugänglichen gemeinsamen PCs oder nicht vertrauenswürdigen Konsolen verwenden. Keine Automatisierung hinter einer Sperre oder Richtlinienumgehung. [Einrichtung und Zugriffsrisiken](../configuration.md).

Beide Rechner benötigen Windows. Der Host muss angemeldet, entsperrt und ohne Energiesparmodus laufen; Richtlinien müssen dies erlauben. Erforderlich sind Administratorzustimmung am Host, Git, Windows PowerShell 5.1 und VBScript.

Installierte Diagnosen versuchen etwa 10 Sekunden nach jeder RDP-Trennung des eingerichteten Nutzers echte Eingaben/Aufnahmen, auch im Alltag, und können mit Agenten konkurrieren.

<a id="setup"></a>

## Beide Rechner einrichten

Auf beiden Rechnern eine neue, vertrauenswürdige Kopie im privaten Benutzerordner klonen, nie in einem gemeinsam beschreibbaren Ordner. `%LOCALAPPDATA%\KeepDesktopInteractiveSource` im Explorer öffnen und den jeweiligen Starter doppelklicken.

```powershell
git clone https://github.com/yeelam-gordon/KeepDesktopInteractive.git "$env:LOCALAPPDATA\KeepDesktopInteractiveSource"
```

| Entfernter Host / Lokaler Client | |
| --- | --- |
| Entfernter Host | `start-desktop-session-setup.vbs` — Rechteerhöhung bestätigen |
| Lokaler Client | `set-local-rdp-minimize-rendering.vbs` — Windows App/RDP vollständig schließen, neu öffnen und verbinden |

[Einrichtungsergebnisse](../configuration.md#quick-setup): Entfernter Host `%LOCALAPPDATA%\KeepDesktopInteractive\elevation-result.json` → `%ProgramData%\KeepDesktopInteractive\setup-result.json`: `Installed: true`, `Status: Ready`; Lokaler Client `%LOCALAPPDATA%\KeepDesktopInteractive\local-rdp-minimize-result.json`: `Succeeded: true`.

<a id="proof"></a>

## Echte Eingaben prüfen

Vor dem Test die Startzeit notieren, andere UI-Automatisierung beenden, sensible Arbeit speichern und vertrauliche Fenster entfernen; Trennung startet Diagnose. Prüfen Sie, dass die Änderungszeit der Datei nach dem Testbeginn liegt und die Werte `Passed` und `Mode` stimmen; Prüfen Sie dann eine harmlose, repräsentative Klick-/Eingabe-/Screenshot-Aufgabe bei der resultierenden Konsolenauflösung. Die Diagnose beweist nicht alle Apps.

30 Sekunden trennen und erneut verbinden. Auf dem Host muss `%LOCALAPPDATA%\KeepDesktopInteractive\desktop-proof.json` für diesen Test aktualisiert sein, mit `Passed: true` und `Mode: AfterDisconnect`.

Minimieren ist bedingt: den [90-Sekunden-Test / 60-Sekunden-Vorlauf](../configuration.md#verify-on-each-new-machine) für `WhileClientMinimized` separat durchführen. Bei Fehlern das Fenster sichtbar lassen.

<a id="limits"></a>

- Nach Neustart selbst anmelden, entsperren und Apps starten; keine automatische Anmeldung. Remote-Sperre, Energiesparmodus und Abmeldung können die GUI-Automatisierung stoppen.
- Kompatibilität hängt von Client und Version ab; keine allgemeine Dev-Box-Zertifizierung: [Nachweise](../configuration.md#reported-compatibility-evidence).
- Windows Sandbox minimiert bei aktivem Gast: **NICHT VALIDIERT**; [Experiment](../configuration.md#sandbox-minimized-window-experiment), keine RDP-Anleitung.

## Fehler und Rücknahme

Fehlerhafter, fehlender oder alter Nachweis? `Error`, `Stage` und Einrichtung prüfen, dann erneut testen. [Fehlersuche](../configuration.md#proof-and-setup-troubleshooting) · [Konfigurationsprüfungen](../configuration.md#configuration-checks)

<a id="undo"></a>

Hosttasks entfernen und Clientregistrierung wiederherstellen sperrt die Konsole nicht. Speichern und Automatisierung beenden; Host sperren und Anmeldepflicht prüfen oder bewusst abmelden, um Apps zu beenden.

[Rücknahme](../configuration.md#undo) · [Maßgeblicher englischer Leitfaden](../configuration.md) · [Englisches README](../../README.md) · [Updates](../configuration.md#updating-the-first-prototype)
