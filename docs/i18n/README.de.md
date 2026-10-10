# KeepDesktopInteractive — Windows-GUI-Automatisierung nach RDP-Trennung erhalten

Windows-GUI-Automatisierung stoppt nach RDP-Trennung? Erhalten Sie eine **bereits angemeldete, entsperrte** Sitzung für Klicks, Texteingabe und Screenshots Ihrer vorhandenen computer-use-Agenten oder UI-Tests. Eingabefehler bei minimiertem Fenster sind ein eigener Fall und benötigen einen kompatiblen Client sowie einen separaten Nachweis. Keine native Agentenintegration oder Agentenstartfunktion, keine gespeicherten Passwörter und keine automatische Anmeldung.

> **Die Übergabe lässt den entfernten Desktop entsperrt.** Wer die physische oder interaktive VM-Konsole bedienen kann, kann die Sitzung ohne Windows-Anmeldung nutzen. Nicht auf zugänglichen gemeinsamen PCs oder nicht vertrauenswürdigen Konsolen verwenden. Keine Automatisierung hinter einer Sperre oder Richtlinienumgehung. [Einrichtung und Zugriffsrisiken](../configuration.md).

[Einrichtung und Zugriffsrisiken](#setup) → [Echte Eingabe prüfen](#proof) · [Grenzen](#limits) · [Rücknahme](#undo)

- Nach erkannter RDP-Trennung übergibt Windows die vorhandene Sitzung an die Konsole, um GUI-Eingaben nutzbar zu halten.
- Die Darstellungseinstellung hilft kompatiblen Clients beim Minimieren; separat prüfen.
- Prüfen Sie echte Klicks, Eingaben und Screenshots mit privaten Ergebnissen im richtigen Modus, nicht nur laufende Apps.

<details>
<summary>Languages</summary>

[English](../../README.md) · [简体中文](README.zh-CN.md) · [繁體中文](README.zh-TW.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Español](README.es.md) · [Português (Brasil)](README.pt-BR.md) · [Français](README.fr.md) · [Deutsch](README.de.md) · [Italiano](README.it.md) · [Русский](README.ru.md) · [Türkçe](README.tr.md) · [Tiếng Việt](README.vi.md) · [Bahasa Indonesia](README.id.md) · [हिन्दी](README.hi.md) · [العربية](README.ar.md)

</details>

<a id="setup"></a>

Vor Installation: Host eingeschaltet, wach und entsperrt; Richtlinien müssen dies erlauben. Windows, Administratorzustimmung, Git, PowerShell 5.1 und VBScript sind unten aufgeführt.

## Zwei Rechner, getrennte Einrichtung

Der **entfernte Host** ist der Windows-PC/die VM mit der Automatisierung. Der **lokale Client** ist der Windows-PC mit RDP/Windows App. Erforderlich sind Windows PowerShell 5.1, VBScript sowie Git zum Klonen; die Hostinstallation benötigt Administratorzustimmung. Auf beiden Rechnern eine neue, vertrauenswürdige Kopie im privaten Ordner des aktuellen Benutzers erstellen, nicht in einem gemeinsam beschreibbaren Ordner:
```powershell
git clone https://github.com/yeelam-gordon/KeepDesktopInteractive.git "$env:LOCALAPPDATA\KeepDesktopInteractiveSource"
Set-Location "$env:LOCALAPPDATA\KeepDesktopInteractiveSource"
```
Auf jedem Rechner den geklonten Ordner öffnen und die Befehle darin ausführen: den ersten auf dem Host (Anforderung zur Rechteerhöhung bestätigen), den zweiten auf dem lokalen Client.
```powershell
wscript.exe .\start-desktop-session-setup.vbs
```
```powershell
wscript.exe .\set-local-rdp-minimize-rendering.vbs
```
Den Remoteclient vollständig schließen, neu öffnen und erneut verbinden. [Einrichtungsergebnisse](../configuration.md#quick-setup) prüfen: Host `Installed: true` / `Status: Ready`; Client `Succeeded: true`.

## Erster Nachweis

<a id="proof"></a>

**Trennung:** RDP normal trennen, 30 Sekunden warten und erneut verbinden. Die Diagnose läuft automatisch. **Minimieren:** Folgendes auf dem Host ausführen und sofort das Remotefenster auf dem Client für 90 Sekunden minimieren. Danach wiederherstellen. Der Test wartet 60 Sekunden vor echter Eingabe und Bildschirmaufnahme.
```powershell
wscript.exe .\test-interactive-desktop-automation.vbs --minimized-test
```
Auf dem Host das neue Ergebnis in `%LOCALAPPDATA%\KeepDesktopInteractive\desktop-proof.json` prüfen. Diese Felder zeigen den erwarteten Erfolg für den jeweiligen Test, keine hier gemessenen Ergebnisse:
```json
{ "Passed": true, "Mode": "AfterDisconnect" }
```
```json
{ "Passed": true, "Mode": "WhileClientMinimized" }
```
Der Minimierungsnachweis gilt nur, wenn das Fenster während Eingabe und Aufnahme minimiert blieb; der Host kann diesen Zustand nicht beobachten. Protokolle und Bilder vertraulich halten, da benachbarter Desktopinhalt sichtbar sein kann. [Details](../configuration.md#verify-on-each-new-machine).

<img src="../../assets/keep-desktop-interactive.png" width="700" alt="Vor und nach RDP-Trennung oder Minimierung: Anwendungen laufen weiter, aber Klicks, Eingaben und Screenshots k&#246;nnen ausfallen; Konsolen&#252;bergabe und kompatibler Client helfen.">

Konzeptillustration: links laufen Anwendungen, während die Automatisierung stockt; rechts die nach Einrichtung erwarteten Klicks, Eingaben und Screenshots. Die Bildbeschriftung ist Englisch, keine übersetzte App-Oberfläche und kein Live-Test. Minimierung hängt vom Client ab; bei geschlossenem Notebook oder Netzverlust muss Windows eine RDP-Trennung erkennen. Die Konsole bleibt entsperrt; prüfen Sie Ihre Einrichtung. Die lokale Sperre bestand nur auf dem vom Maintainer berichteten Paar mit wachem Notebook und eingerichteten Client. Der Minimierungstest war vor der Härtung und wurde nach Bereitstellung nicht wiederholt.

<a id="limits"></a>

## Grenzen, Fehler und Rücknahme

Die Einstellung ist für die klassische Remote Desktop Connection dokumentiert; Windows App hängt von der Version ab. Ein Erfolg belegt keine universelle Unterstützung. Das ursprüngliche Paar bestand den Minimierungstest vor der Härtung; nach der Bereitstellung wurde er nicht erneut geprüft. Nach einem Neustart einmal anmelden und entsperren, dann Anwendungen und Automatisierung neu starten. Headless-Desktops sind nicht abgedeckt. Entfernte Bildschirmsperre, Energiesparmodus, Herunterfahren und Abmelden können die Automatisierung weiterhin stoppen. [Alle Grenzen](../configuration.md#requirements-and-limitations).

Bei `Passed: false` die Felder `Error`, `Stage` und Protokolle lesen. Fehlende oder alte Nachweise: Einrichtung prüfen und erneut testen. Unterstützt der Client Minimierung nicht, Fenster sichtbar lassen oder den separat geprüften Trennungsablauf verwenden. [Fehlersuche](../../README.md#if-the-proof-fails) · [Konfigurationsprüfungen](../configuration.md#configuration-checks).

<a id="undo"></a>

Jeweils aus dem geklonten Ordner auf dem Host deinstallieren und auf demselben Client unter demselben Benutzer wiederherstellen:
```powershell
wscript.exe .\start-desktop-session-setup.vbs --uninstall
```
```powershell
wscript.exe .\set-local-rdp-minimize-rendering.vbs --restore
```
Die Clientdatei `%LOCALAPPDATA%\KeepDesktopInteractive\local-rdp-minimize-backup.json` behalten, bis keine Wiederherstellung mehr nötig ist. Die Vorgänge sind unabhängig und löschen keine Diagnosebelege. [Rücknahme](../configuration.md#undo) · [Maßgeblicher englischer Leitfaden](../configuration.md) · [Englisches README](../../README.md).

<details>
<summary>Windows App / Microsoft Dev Box / Hyper-V</summary>

> **Warnung: Die Übergabe an die Konsole lässt den entfernten Windows-Desktop entsperrt.** Wer Zugriff auf die physische Tastatur oder die interaktive VM-Konsole hat, kann Ihre Sitzung ohne Windows-Anmeldung benutzen. Nicht auf gemeinsam genutzten PCs einsetzen, an die andere herantreten können. Hyper-V-Administratoren und alle Personen mit VMConnect-Zugriff müssen vertrauenswürdig sein. Windows App ist der Verbindungsclient; Microsoft Dev Box die verwaltete Cloudworkstation. Das Risiko ist fremder Zugriff auf die entsperrte Konsole, nicht eine grundsätzliche Unsicherheit des Produkts. Ein verwalteter Host für einen Entwickler ohne interaktiven Konsolenzugang für nicht vertrauenswürdige Personen ist risikoärmer als ein gemeinsam genutzter PC. Setzen Sie einen solchen Zugang bei Microsoft Dev Box nicht voraus. Beachten Sie die Richtlinien Ihrer Organisation: Dies ermöglicht weder Automatisierung hinter einem gesperrten entfernten Bildschirm noch das Umgehen von Sperrrichtlinien.

</details>
