# KeepDesktopInteractive — Automazione GUI Windows dopo la disconnessione RDP

[English](../../README.md) · [简体中文](README.zh-CN.md) · [繁體中文](README.zh-TW.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Español](README.es.md) · [Português (Brasil)](README.pt-BR.md) · [Français](README.fr.md) · [Deutsch](README.de.md) · [Italiano](README.it.md) · [Русский](README.ru.md) · [Türkçe](README.tr.md) · [Tiếng Việt](README.vi.md) · [Bahasa Indonesia](README.id.md) · [हिन्दी](README.hi.md) · [العربية](README.ar.md)

> **Attenzione: il passaggio alla console lascia il desktop Windows remoto sbloccato. Chi ha accesso alla tastiera fisica o alla console interattiva della VM può usare la sessione senza accedere a Windows. Non usare un PC condiviso a cui altri possano avvicinarsi. Devi fidarti degli amministratori Hyper-V e di chiunque possa aprire VMConnect. Un account di test o una VM cloud non è automaticamente sicuro. Rispetta le regole della tua organizzazione: non è automazione dietro uno schermo remoto bloccato e non aggira le politiche di blocco.**

L’automazione GUI Windows si ferma dopo la disconnessione RDP? Mantieni una sessione **già aperta e sbloccata** per clic, digitazione e schermate dei tuoi agenti computer-use o test UI esistenti. La mancata risposta con la finestra ridotta a icona è un caso distinto: richiede un client compatibile e una verifica separata. Nessuna integrazione nativa o avvio degli agenti, nessuna password memorizzata e nessun accesso automatico.

**Due computer:** l’host remoto è il PC/VM Windows che esegue l’automazione; il client locale è il PC Windows con RDP/Windows App. Servono Windows PowerShell 5.1, VBScript e Git per clonare. L’installazione sull’host richiede l’approvazione di un amministratore. Su entrambi, ottieni una nuova copia attendibile nella cartella privata dell’utente attuale, mai in una cartella condivisa scrivibile.

```powershell
git clone https://github.com/yeelam-gordon/KeepDesktopInteractive.git "$env:LOCALAPPDATA\KeepDesktopInteractiveSource"
Set-Location "$env:LOCALAPPDATA\KeepDesktopInteractiveSource"
```

Apri la cartella clonata su ciascun computer ed esegui i comandi da lì. Il primo va eseguito sull’host remoto, approvando l’elevazione; il secondo sul client locale.

```powershell
wscript.exe .\start-desktop-session-setup.vbs
```

```powershell
wscript.exe .\set-local-rdp-minimize-rendering.vbs
```

Chiudi completamente il client remoto, riaprilo e riconnettiti. [Risultati dell’installazione](../configuration.md#quick-setup): sull’host `Installed: true` e `Status: Ready`; sul client `Succeeded: true`.

**Prima verifica:** disconnetti RDP normalmente, attendi 30 secondi e riconnettiti; la diagnosi è automatica. Per la prova separata della finestra ridotta a icona, esegui il comando seguente sull’host remoto, riduci subito la finestra del client e lasciala così per 90 secondi, poi ripristinala. La prova attende 60 secondi prima di inviare input reale e acquisire lo schermo.

```powershell
wscript.exe .\test-interactive-desktop-automation.vbs --minimized-test
```

Sull’host controlla il nuovo `%LOCALAPPDATA%\KeepDesktopInteractive\desktop-proof.json`. Questi sono esempi dei campi attesi per ciascuna prova, non risultati misurati durante questo aggiornamento:

```json
{ "Passed": true, "Mode": "AfterDisconnect" }
```

```json
{ "Passed": true, "Mode": "WhileClientMinimized" }
```

La prova con finestra ridotta vale solo se la finestra rimane ridotta durante input e acquisizione: l’host non può osservarne lo stato. Mantieni privati registri e immagini, che possono includere contenuti vicini del desktop. [Dettagli della verifica](../configuration.md#verify-on-each-new-machine).

**Limiti:** l’impostazione è documentata per Remote Desktop Connection classico; Windows App dipende dalla versione. Il manutentore riferisce che la coppia originale client/host ha superato la prova con finestra ridotta prima del rafforzamento della sicurezza, ma non è stata ricontrollata dopo la distribuzione. Non è supporto universale. Dopo un riavvio accedi e sblocca una volta, poi riavvia applicazioni e automazione. I desktop senza interfaccia non sono coperti. Il blocco del desktop remoto, la sospensione, lo spegnimento e l’uscita dall’account Windows possono fermare l’automazione. [Tutti i limiti](../configuration.md#requirements-and-limitations).

Con `Passed: false`, leggi `Error`, `Stage` e i registri. Se manca la prova o è vecchia, verifica l’installazione e ripetila. Se il client non supporta la finestra ridotta, lasciala visibile o usa la disconnessione verificata separatamente. [Risoluzione dei problemi](../../README.md#if-the-proof-fails) · [Controlli](../configuration.md#configuration-checks).

**Annullamento:** esegui dalle rispettive cartelle clonate. Il primo comando rimuove le attività pianificate dall’host remoto; il secondo ripristina il client sullo stesso PC locale e con lo stesso utente.

```powershell
wscript.exe .\start-desktop-session-setup.vbs --uninstall
```

```powershell
wscript.exe .\set-local-rdp-minimize-rendering.vbs --restore
```

Conserva `%LOCALAPPDATA%\KeepDesktopInteractive\local-rdp-minimize-backup.json` del client finché non serve più il ripristino. Le operazioni sono indipendenti e non eliminano le prove diagnostiche. [Annullamento](../configuration.md#undo) · [Guida canonica inglese](../configuration.md) · [README inglese](../../README.md).
