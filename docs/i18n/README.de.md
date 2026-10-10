# KeepDesktopInteractive — GUI-Eingaben nach RDP-Trennung erhalten

<a id="languages"></a>

<details>
<summary>Languages / 语言 / 言語 / اللغات (16)</summary>

[English](../../README.md) · [简体中文](README.zh-CN.md) · [繁體中文](README.zh-TW.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Español](README.es.md) · [Português (Brasil)](README.pt-BR.md) · [Français](README.fr.md) · [Deutsch](README.de.md) · [Italiano](README.it.md) · [Русский](README.ru.md) · [Türkçe](README.tr.md) · [Tiếng Việt](README.vi.md) · [Bahasa Indonesia](README.id.md) · [हिन्दी](README.hi.md) · [العربية](README.ar.md)

</details>

Windows App als Client, Microsoft Dev Box als Host oder eine andere Windows-RDP-Umgebung: computer-use-Agenten klicken, tippen und erfassen Screenshots nach erkannter Trennung weiter; Sie müssen das verbundene Fenster nicht ständig beobachten (Minimieren nur mit geprüfter kompatibler Darstellung); nutzen Sie die angemeldete Sitzung ohne gespeicherte Passwörter oder automatische Anmeldung weiter.

Konsole bleibt entsperrt; Richtlinien beachten. Windows Sandbox minimieren: unvalidiert.

<img src="../../assets/keep-desktop-interactive.png" width="700" alt="Vor und nach RDP-Trennung oder Minimierung: Anwendungen laufen weiter, aber Klicks, Eingaben und Screenshots k&#246;nnen ausfallen; Konsolen&#252;bergabe und kompatibler Client helfen.">

- **Agenteneingaben nach Trennung erhalten:** Klicks, Eingaben und Screenshots auf dem bestehenden Desktop bleiben nach erkannter RDP-Trennung nutzbar; die Netzwerkerkennung kann Zeit benötigen.
- **Nicht ständig das verbundene Fenster betreuen:** Vom Remotefenster weggehen; minimierte Nutzung erfordert kompatible Clientdarstellung und einen gesonderten erfolgreichen Eingabetest Ihrer Umgebung. Der Client muss den Remotedesktop auch bei minimiertem Fenster weiter darstellen; prüfen Sie Klicks, Eingaben und Screenshots separat.
- **Angemeldete Sitzung weiterverwenden:** Bestehende Sitzung und offene Apps ohne Passwortspeicherung oder automatische Anmeldung behalten; nach einem Neustart meldet das Tool Sie nicht an.

Konzept mit englischen Beschriftungen, kein Live-Test. Clientunterstützung und lokale Sperre mit Notebook außerhalb des Energiesparmodus sind bedingt.

> **Die Übergabe lässt den entfernten Desktop entsperrt.** Wer die physische oder interaktive VM-Konsole bedienen kann, kann die Sitzung ohne Windows-Anmeldung nutzen. Nicht auf zugänglichen gemeinsamen PCs oder nicht vertrauenswürdigen Konsolen verwenden. Keine Automatisierung hinter einer Sperre oder Richtlinienumgehung. [Einrichtung und Zugriffsrisiken](../configuration.md).

Nur wenn Richtlinien die RDP/Konsolenübergabe erlauben; prüfen Sie Ihre Umgebung. Keine pauschale Dev-Box-Zertifizierung.

[Einrichtung und Zugriffsrisiken](#setup) → [Echte Eingabe prüfen](#proof) · [Grenzen](#limits) · [Rücknahme](#undo) · Windows Sandbox minimieren: noch nicht validiert.

**[Windows Sandbox](https://learn.microsoft.com/en-us/windows/security/application-security/application-isolation/windows-sandbox/) — minimiertes Fenster; NICHT VALIDIERTER Kandidat:** Wenn das Windows-Sandbox-Fenster auf dem Host minimiert ist und Gast sowie Apps weiterlaufen, funktionieren Klicks, Eingaben und Screenshots weiter? Bereitstellung und Eingabekontinuität sind nicht validiert; ob dieses Tool mit Clientdarstellung oder Gastübergabe funktioniert, ist unbekannt und separat zu testen, keine bereits bestätigte Lösung.

## Windows App / RDP

Installierte Diagnosen versuchen etwa 10 Sekunden nach jeder RDP-Trennung des eingerichteten Nutzers echte Eingaben/Aufnahmen, auch im Alltag, und können mit Agenten konkurrieren. Kein dokumentierter Starter-Schalter deaktiviert nur Diagnosen; Hostdeinstallation entfernt auch die Übergabe.

Windows-App/RDP-Weg: Trennung nutzt Hostübergabe, Minimierung kompatible Clientdarstellung plus Hosteinrichtung. Behalten Sie die geprüfte Zwei-Rechner-Einrichtung und prüfen Sie jeden Modus. Keine Agentenintegration oder -startfunktion, Passwortspeicherung oder automatische Anmeldung. [→](../configuration.md#mode-choice)

Der Maintainer berichtet, dass Eingaben bei gesperrtem lokalem Bildschirm nur mit dem getesteten Paar funktionierten: Das Notebook war nicht im Energiesparmodus und der Client war eingerichtet. Der entfernte Desktop war nicht gesperrt. Beim Schließen des Deckels oder bei Netzverlust greift die Übergabe erst, wenn Windows eine Trennung erkennt.

## Windows Sandbox — UNVALIDATED

Sandbox ist ein vorgeschlagenes Experiment: stoppen, wenn keine genehmigte, funktionierende Installations-/Testmethode feststeht. Klicks, Eingaben und Aufnahme ohne sensible Daten bei sichtbarem Fenster erfassen; für protokolliertes Intervall minimieren, Gast/Apps aktiv halten, echte Eingabe/neue Aufnahme wiederholen, wiederherstellen und prüfen. Nicht validiert; bei Fehler Fenster sichtbar halten. RDP-Zwei-Rechner-, Trennungs- und Schließen/Öffnen-Schritte sind kein Sandbox-Verfahren. [→](../configuration.md#sandbox-minimized-window-experiment)

<a id="setup"></a>

Vor der Installation: Host eingeschaltet, nicht im Energiesparmodus und entsperrt; Richtlinien müssen dies erlauben. Windows, Administratorzustimmung, Git, PowerShell 5.1 und VBScript sind unten aufgeführt.

## Zwei Rechner, getrennte Einrichtung

Der **entfernte Host** ist der Windows-PC/die VM mit der Automatisierung. Der **lokale Client** ist der Windows-PC mit RDP/Windows App. Erforderlich sind Windows PowerShell 5.1, VBScript sowie Git zum Klonen; die Hostinstallation benötigt Administratorzustimmung. Auf beiden Rechnern eine neue, vertrauenswürdige Kopie im privaten Ordner des aktuellen Benutzers erstellen, nicht in einem gemeinsam beschreibbaren Ordner:
<details>
<summary>Windows App / Microsoft Dev Box / Hyper-V</summary>

> **Warnung: Die Übergabe an die Konsole lässt den entfernten Windows-Desktop entsperrt.** Wer Zugriff auf die physische Tastatur oder die interaktive VM-Konsole hat, kann Ihre Sitzung ohne Windows-Anmeldung benutzen. Nicht auf gemeinsam genutzten PCs einsetzen, an die andere herantreten können. Hyper-V-Administratoren und alle Personen mit VMConnect-Zugriff müssen vertrauenswürdig sein. Windows App ist der Verbindungsclient; Microsoft Dev Box die verwaltete Cloudworkstation. Das Risiko ist fremder Zugriff auf die entsperrte Konsole, nicht eine grundsätzliche Unsicherheit des Produkts. Ein verwalteter Host für einen Entwickler ohne interaktiven Konsolenzugang für nicht vertrauenswürdige Personen ist risikoärmer als ein gemeinsam genutzter PC. Setzen Sie einen solchen Zugang bei Microsoft Dev Box nicht voraus. Beachten Sie die Richtlinien Ihrer Organisation: Dies ermöglicht weder Automatisierung hinter einem gesperrten entfernten Bildschirm noch das Umgehen von Sperrrichtlinien.

</details>


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

- Nach erkannter RDP-Trennung übergibt Windows die vorhandene Sitzung an die Konsole, um GUI-Eingaben nutzbar zu halten.
- Die Darstellungseinstellung hilft kompatiblen Clients beim Minimieren; separat prüfen.
- Prüfen Sie echte Klicks, Eingaben und Screenshots mit privaten Ergebnissen im richtigen Modus, nicht nur laufende Apps.

Vor dem Test die Startzeit notieren, andere UI-Automatisierung beenden, sensible Arbeit speichern und vertrauliche Fenster entfernen; Trennung startet Diagnose. Dateizeit nach Start und korrektes Passed/Mode verlangen; dann harmlose repräsentative Klick-/Eingabe-/Aufnahmeaufgabe bei resultierender Konsolenauflösung prüfen. Die Diagnose beweist nicht alle Apps. [→](../configuration.md#reported-compatibility-evidence)

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

<a id="limits"></a>

## Grenzen, Fehler und Rücknahme

Die Einstellung ist für die klassische Remote Desktop Connection dokumentiert; Windows App hängt von der Version ab. Ein Erfolg belegt keine universelle Unterstützung. Das ursprüngliche Paar bestand den Minimierungstest vor der Härtung; nach der Bereitstellung wurde er nicht erneut geprüft. Nach einem Neustart einmal anmelden und entsperren, dann Anwendungen und Automatisierung neu starten. Headless-Desktops sind nicht abgedeckt. Entfernte Bildschirmsperre, Energiesparmodus, Herunterfahren und Abmelden können die Automatisierung weiterhin stoppen. [Alle Grenzen](../configuration.md#requirements-and-limitations).

Bei `Passed: false` die Felder `Error`, `Stage` und Protokolle lesen. Fehlende oder alte Nachweise: Einrichtung prüfen und erneut testen. Unterstützt der Client Minimierung nicht, Fenster sichtbar lassen oder den separat geprüften Trennungsablauf verwenden. [Fehlersuche](../../README.md#if-the-proof-fails) · [Konfigurationsprüfungen](../configuration.md#configuration-checks).

<a id="undo"></a>

Taskentfernung/Clientwiederherstellung sperrt die aktuelle Konsole nicht automatisch. Speichern und Automatisierung beenden; Host manuell sperren und Anmeldepflicht prüfen oder bewusst abmelden, um Apps zu beenden. Sperren stoppt GUI-Automatisierung.

Jeweils aus dem geklonten Ordner auf dem Host deinstallieren und auf demselben Client unter demselben Benutzer wiederherstellen:
```powershell
wscript.exe .\start-desktop-session-setup.vbs --uninstall
```
```powershell
wscript.exe .\set-local-rdp-minimize-rendering.vbs --restore
```
Die Clientdatei `%LOCALAPPDATA%\KeepDesktopInteractive\local-rdp-minimize-backup.json` behalten, bis keine Wiederherstellung mehr nötig ist. Die Vorgänge sind unabhängig und löschen keine Diagnosebelege. [Rücknahme](../configuration.md#undo) · [Maßgeblicher englischer Leitfaden](../configuration.md) · [Englisches README](../../README.md).

Für Updates neues privates Ziel statt vorhandenem nicht leerem Ordner verwenden; alte Kopie und Sicherungen bis Einrichtung und Nachweise erfolgreich sind behalten. [→](../configuration.md#updating-the-first-prototype)
