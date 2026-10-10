# KeepDesktopInteractive — Mantieni l’input GUI dopo la disconnessione RDP

<a id="languages"></a>

<details>
<summary>Languages / 语言 / 言語 / اللغات (16)</summary>

[English](../../README.md) · [简体中文](README.zh-CN.md) · [繁體中文](README.zh-TW.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Español](README.es.md) · [Português (Brasil)](README.pt-BR.md) · [Français](README.fr.md) · [Deutsch](README.de.md) · [Italiano](README.it.md) · [Русский](README.ru.md) · [Türkçe](README.tr.md) · [Tiếng Việt](README.vi.md) · [Bahasa Indonesia](README.id.md) · [हिन्दी](README.hi.md) · [العربية](README.ar.md)

</details>

Windows App come client, Microsoft Dev Box come host o altro ambiente Windows RDP: mantieni clic, digitazione e catture dell’agente computer-use dopo il rilevamento della disconnessione; smetti di sorvegliare la finestra connessa (riduzione a icona solo con rendering compatibile verificato); riusa la sessione aperta senza password salvate o accesso automatico.

Console sbloccata; rispetta le politiche. Windows Sandbox ridotto a icona: non validato.

<img src="../../assets/keep-desktop-interactive.png" width="700" alt="Prima e dopo disconnessione RDP o finestra ridotta: le app restano attive ma clic, digitazione e catture possono fallire; passaggio alla console e client compatibile aiutano.">

- **Mantieni l’input dell’agente dopo la disconnessione:** conserva clic, digitazione e catture nel desktop esistente quando Windows rileva la disconnessione RDP; il rilevamento della perdita di rete può richiedere tempo.
- **Non sorvegliare continuamente la finestra connessa:** allontanati dalla finestra remota; l’uso ridotto a icona richiede rendering compatibile e un test separato di input riuscito nel tuo ambiente. Il client deve continuare a disegnare il desktop remoto con la finestra ridotta a icona; verifica separatamente clic, digitazione e catture.
- **Riusa la sessione già autenticata:** conserva sessione e app senza salvare password o attivare l’accesso automatico; lo strumento non ti autentica dopo un riavvio.

Concetto con etichette inglesi, non test dal vivo. Supporto del client e blocco locale con portatile non in sospensione sono condizionati.

> **Il passaggio lascia il desktop remoto sbloccato.** Chi può usare la console fisica o interattiva della VM può usare la sessione senza accedere a Windows. Non usare PC condivisi accessibili o console non fidate. Non automatizza dietro uno schermo bloccato e non aggira le politiche. [Configurazione e rischi di accesso](../configuration.md).

Solo se le politiche consentono di configurare il passaggio RDP/console; verifica il tuo ambiente, senza certificazione universale Dev Box.

[Configurazione e rischi di accesso](#setup) → [Verificare l’input reale](#proof) · [Limiti](#limits) · [Annullamento](#undo) · Windows Sandbox ridotto a icona: non ancora validato.

**[Windows Sandbox](https://learn.microsoft.com/en-us/windows/security/application-security/application-isolation/windows-sandbox/) — finestra ridotta; candidato NON VALIDATO:** Quando la finestra di Windows Sandbox sull’host è ridotta a icona e guest e app continuano a funzionare, clic, digitazione e catture continuano? Distribuzione e continuità non validate: questo strumento potrebbe funzionare o meno con il rendering del client o il passaggio del guest; prova separatamente, non è una soluzione già verificata.

## Windows App / RDP

La diagnosi installata tenta clic, input e cattura circa 10 secondi dopo ogni disconnessione RDP dell’utente configurato, anche nell’uso normale, e può interferire con l’agente. Nessuna opzione documentata del lanciatore disattiva solo la diagnosi; disinstallare l’host rimuove anche il passaggio.

Percorso Windows App/RDP: disconnessione = passaggio dell’host; finestra ridotta = rendering compatibile più configurazione dell’host. Mantieni la configurazione testata su due computer e verifica ogni modalità. Nessuna integrazione/avvio agenti, password salvate o accesso automatico. [→](../configuration.md#mode-choice)

Il manutentore riferisce che l’input ha continuato a funzionare con lo schermo locale bloccato solo sulla coppia testata, con il portatile non in sospensione e il client configurato. Il desktop remoto non era bloccato. Quando chiudi il coperchio o perdi la rete, il passaggio avviene solo dopo che Windows rileva la disconnessione.

## Windows Sandbox — UNVALIDATED

Sandbox è un esperimento proposto: fermati se non stabilisci un metodo autorizzato di installazione/test. Registra clic, digitazione e cattura senza dati sensibili con finestra visibile; riduci per un intervallo registrato con guest/app attivi, ripeti input e nuova cattura, ripristina e controlla. Non validato; se fallisce mantieni la finestra visibile. I passi RDP a due computer, disconnessione e chiusura/riapertura non sono una procedura Sandbox. [→](../configuration.md#sandbox-minimized-window-experiment)

<a id="setup"></a>

Prima di installare: host acceso, attivo e sbloccato, con uso consentito dalle politiche. Requisiti Windows, amministratore, Git, PowerShell 5.1 e VBScript sotto.

## Due computer

L’host remoto è il PC/VM Windows che esegue l’automazione; il client locale è il PC Windows con RDP/Windows App. Servono Windows PowerShell 5.1, VBScript e Git per clonare. L’installazione sull’host richiede l’approvazione di un amministratore. Su entrambi, ottieni una nuova copia attendibile nella cartella privata dell’utente attuale, mai in una cartella condivisa scrivibile.

<details>
<summary>Windows App / Microsoft Dev Box / Hyper-V</summary>

> **Windows App è il client di connessione; Microsoft Dev Box è la workstation cloud gestita. Il rischio è l’accesso altrui alla console sbloccata, non un’insicurezza intrinseca del prodotto. Un host gestito per uno sviluppatore senza accesso interattivo alla console da parte di persone non fidate presenta meno rischi di un PC condiviso. Non presumere che Microsoft Dev Box offra tale accesso. Rispetta le regole della tua organizzazione: non è automazione dietro uno schermo remoto bloccato e non aggira le politiche di blocco.**

</details>


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

<a id="proof"></a>

- Quando Windows rileva la disconnessione RDP, la sessione esistente passa alla console per aiutare a mantenere l’input GUI.
- L’impostazione di rendering aiuta i client compatibili con finestra ridotta; verifica separatamente.
- Controlla clic, digitazione e catture reali con risultati privati nella modalità corretta, non solo app aperte.

Prima del test registra l’inizio, ferma altre automazioni UI, salva il lavoro sensibile e allontana finestre riservate; disconnettere avvia la diagnosi. Richiedi file modificato dopo l’inizio e Passed/Mode corretti; poi prova clic/digitazione/cattura in app innocua alla risoluzione finale della console. La diagnosi non prova tutte le app. [→](../configuration.md#reported-compatibility-evidence)

## Prima verifica

Disconnetti RDP normalmente, attendi 30 secondi e riconnettiti; la diagnosi è automatica. Per la prova separata della finestra ridotta a icona, esegui il comando seguente sull’host remoto, riduci subito la finestra del client e lasciala così per 90 secondi, poi ripristinala. La prova attende 60 secondi prima di inviare input reale e acquisire lo schermo.

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

<a id="limits"></a>

## Limiti

L’impostazione è documentata per Remote Desktop Connection classico; Windows App dipende dalla versione. Il manutentore riferisce che la coppia originale client/host ha superato la prova con finestra ridotta prima del rafforzamento della sicurezza, ma non è stata ricontrollata dopo la distribuzione. Non è supporto universale. Dopo un riavvio accedi e sblocca una volta, poi riavvia applicazioni e automazione. I desktop senza interfaccia non sono coperti. Il blocco del desktop remoto, la sospensione, lo spegnimento e l’uscita dall’account Windows possono fermare l’automazione. [Tutti i limiti](../configuration.md#requirements-and-limitations).

Con `Passed: false`, leggi `Error`, `Stage` e i registri. Se manca la prova o è vecchia, verifica l’installazione e ripetila. Se il client non supporta la finestra ridotta, lasciala visibile o usa la disconnessione verificata separatamente. [Risoluzione dei problemi](../../README.md#if-the-proof-fails) · [Controlli](../configuration.md#configuration-checks).

<a id="undo"></a>

Rimuovere attività/ripristinare il client non blocca automaticamente la console attuale. Salva e termina l’automazione; blocca manualmente l’host verificando l’accesso richiesto, oppure esci intenzionalmente dall’account per terminare le app. Bloccare ferma l’automazione GUI.

## Annullamento

Esegui dalle rispettive cartelle clonate. Il primo comando rimuove le attività pianificate dall’host remoto; il secondo ripristina il client sullo stesso PC locale e con lo stesso utente.

```powershell
wscript.exe .\start-desktop-session-setup.vbs --uninstall
```

```powershell
wscript.exe .\set-local-rdp-minimize-rendering.vbs --restore
```

Conserva `%LOCALAPPDATA%\KeepDesktopInteractive\local-rdp-minimize-backup.json` del client finché non serve più il ripristino. Le operazioni sono indipendenti e non eliminano le prove diagnostiche. [Annullamento](../configuration.md#undo) · [Guida canonica inglese](../configuration.md) · [README inglese](../../README.md).

Aggiorna in una nuova destinazione privata, non in una cartella esistente non vuota; conserva copia precedente e backup, reinstalla e verifica. [→](../configuration.md#updating-the-first-prototype)
