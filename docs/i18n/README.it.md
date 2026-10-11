# KeepDesktopInteractive — Mantieni l’input GUI dopo la disconnessione RDP

<a id="languages"></a>

<details>
<summary>Languages (16)</summary>

[English](../../README.md) · [简体中文](README.zh-CN.md) · [繁體中文](README.zh-TW.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Español](README.es.md) · [Português (Brasil)](README.pt-BR.md) · [Français](README.fr.md) · [Deutsch](README.de.md) · [Italiano](README.it.md) · [Русский](README.ru.md) · [Türkçe](README.tr.md) · [Tiếng Việt](README.vi.md) · [Bahasa Indonesia](README.id.md) · [हिन्दी](README.hi.md) · [العربية](README.ar.md)

</details>

Per agenti e test UI su un desktop Windows esistente: Windows App è il client; Microsoft Dev Box può essere l’host, come un altro computer Windows con RDP.

<img src="../../assets/keep-desktop-interactive.png" width="320" alt="Illustrazione concettuale: mantieni clic e digitazione dopo la disconnessione; non sorvegliare la finestra remota quando è ridotta a icona con un client compatibile verificato; riutilizza il desktop a cui hai già effettuato l’accesso senza salvare password. Il passaggio alla console lo lascia sbloccato.">

Illustrazione concettuale con etichette inglesi, non una prova.

- **Mantieni clic, digitazione e catture.**
- **Non sorvegliare sempre la connessione.**
- **Riutilizza il desktop a cui hai già effettuato l’accesso e le app aperte, senza salvare password.**

> **Il passaggio lascia il desktop remoto sbloccato.** Chi può usare la console fisica o interattiva della VM può usare la sessione senza accedere a Windows. Non usare PC condivisi accessibili o console non fidate. Non automatizza dietro uno schermo bloccato e non aggira le politiche. [Configurazione e rischi di accesso](../configuration.md).

Entrambi i computer devono usare Windows. L’host deve avere una sessione aperta, sbloccata e senza sospensione, nel rispetto delle politiche. Servono approvazione amministrativa sull’host, Git, Windows PowerShell 5.1 e VBScript.

La diagnosi installata tenta clic, input e cattura circa 10 secondi dopo ogni disconnessione RDP dell’utente configurato, anche nell’uso normale, e può interferire con l’agente.

<a id="setup"></a>

## Configura entrambi i computer

Clona una copia nuova e attendibile nella cartella privata dell’utente attuale su entrambi, mai in una cartella condivisa scrivibile. Apri `%LOCALAPPDATA%\KeepDesktopInteractiveSource` in Esplora file e fai doppio clic sul relativo lanciatore.

```powershell
git clone https://github.com/yeelam-gordon/KeepDesktopInteractive.git "$env:LOCALAPPDATA\KeepDesktopInteractiveSource"
```

| Host remoto / Client locale | |
| --- | --- |
| Host remoto | `start-desktop-session-setup.vbs` — approva l’elevazione |
| Client locale | `set-local-rdp-minimize-rendering.vbs` — chiudi completamente Windows App/RDP, riaprilo e riconnettiti |

[Risultati dell’installazione](../configuration.md#quick-setup): Host remoto `%LOCALAPPDATA%\KeepDesktopInteractive\elevation-result.json` → `%ProgramData%\KeepDesktopInteractive\setup-result.json`: `Installed: true`, `Status: Ready`; Client locale `%LOCALAPPDATA%\KeepDesktopInteractive\local-rdp-minimize-result.json`: `Succeeded: true`.

<a id="proof"></a>

## Verifica l’input reale

Prima del test registra l’inizio, ferma altre automazioni UI, salva il lavoro sensibile e allontana finestre riservate; disconnettere avvia la diagnosi. Verifica che il file sia stato modificato dopo l’inizio del test e che i valori `Passed` e `Mode` corrispondano al risultato atteso; poi esegui una prova innocua di clic, digitazione e cattura in un’applicazione di prova alla risoluzione finale della console. La diagnosi non prova tutte le app.

Disconnetti per 30 secondi e riconnettiti. Sull’host, verifica che `%LOCALAPPDATA%\KeepDesktopInteractive\desktop-proof.json` sia aggiornato per questa prova, con `Passed: true` e `Mode: AfterDisconnect`.

La riduzione a icona è condizionata: segui separatamente la [prova di 90 secondi / attesa di 60 secondi](../configuration.md#verify-on-each-new-machine) per `WhileClientMinimized`. Se fallisce, lascia visibile la finestra.

<a id="limits"></a>

- Dopo il riavvio accedi, sblocca e avvia le app manualmente; niente accesso automatico. Il blocco remoto, la sospensione e la chiusura della sessione possono fermare l’automazione della GUI.
- Compatibilità secondo client e versione, non certificazione universale Dev Box: [evidenze](../configuration.md#reported-compatibility-evidence).
- Windows Sandbox ridotto con guest attivo: **NON VALIDATO**; [esperimento](../configuration.md#sandbox-minimized-window-experiment), non istruzioni RDP.

## Problemi e annullamento

Prova fallita, assente o vecchia? Controlla `Error`, `Stage` e l’installazione, poi riprova. [Risoluzione dei problemi](../configuration.md#proof-and-setup-troubleshooting) · [Controlli](../configuration.md#configuration-checks)

<a id="undo"></a>

Rimuovere le attività dell’host e ripristinare il registro del client non blocca la console. Salva e termina l’automazione; blocca l’host e verifica la richiesta di accesso, oppure esci dall’account per terminare le app.

[Annullamento](../configuration.md#undo) · [Guida canonica inglese](../configuration.md) · [README inglese](../../README.md) · [Aggiornamenti](../configuration.md#updating-the-first-prototype)
