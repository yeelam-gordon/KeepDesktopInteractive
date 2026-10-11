# KeepDesktopInteractive — Gardez les interactions après déconnexion RDP

<a id="languages"></a>

<details>
<summary>Languages (16)</summary>

[English](../../README.md) · [简体中文](README.zh-CN.md) · [繁體中文](README.zh-TW.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Español](README.es.md) · [Português (Brasil)](README.pt-BR.md) · [Français](README.fr.md) · [Deutsch](README.de.md) · [Italiano](README.it.md) · [Русский](README.ru.md) · [Türkçe](README.tr.md) · [Tiếng Việt](README.vi.md) · [Bahasa Indonesia](README.id.md) · [हिन्दी](README.hi.md) · [العربية](README.ar.md)

</details>

Pour agents et tests UI sur un bureau Windows existant : Windows App est le client ; Microsoft Dev Box peut être l’hôte, comme un autre ordinateur Windows avec RDP.

<img src="../../assets/keep-desktop-interactive.png" width="320" alt="Illustration conceptuelle : gardez clics et saisie après déconnexion ; ne surveillez plus la fenêtre distante lors de sa réduction avec un client compatible testé ; réutilisez le bureau où votre session est déjà ouverte, sans mot de passe enregistré. Le transfert vers la console le laisse déverrouillé.">

Illustration conceptuelle, libellés anglais, pas une preuve.

- **Gardez clics, saisie et captures.**
- **Ne surveillez plus la connexion.**
- **Réutilisez le bureau où votre session est déjà ouverte et les apps ouvertes, sans mot de passe enregistré.**

> **Le transfert laisse le bureau distant déverrouillé.** Toute personne pouvant utiliser la console physique ou interactive de la VM peut utiliser la session sans ouvrir de session Windows. Évitez un PC partagé accessible ou une console non fiable. Pas d’automatisation derrière un écran verrouillé ni de contournement des règles. [Configuration et risques d’accès](../configuration.md).

Les deux ordinateurs doivent utiliser Windows. L’hôte doit avoir une session ouverte, déverrouillée et sans veille, autorisée par les règles. Il faut l’accord d’un administrateur sur l’hôte, Git, Windows PowerShell 5.1 et VBScript.

Le diagnostic installé tente clics, saisie et capture environ 10 secondes après chaque déconnexion RDP de l’utilisateur configuré, même en usage normal, et peut interférer avec l’agent.

<a id="setup"></a>

## Configurez les deux ordinateurs

Clonez une copie neuve et fiable dans le dossier privé de l’utilisateur actuel sur chacun, jamais dans un dossier partagé modifiable. Ouvrez `%LOCALAPPDATA%\KeepDesktopInteractiveSource` dans l’Explorateur et double-cliquez sur le lanceur correspondant.

```powershell
git clone https://github.com/yeelam-gordon/KeepDesktopInteractive.git "$env:LOCALAPPDATA\KeepDesktopInteractiveSource"
```

| Hôte distant / Client local | |
| --- | --- |
| Hôte distant | `start-desktop-session-setup.vbs` — approuvez l’élévation |
| Client local | `set-local-rdp-minimize-rendering.vbs` — fermez complètement Windows App/RDP, rouvrez-le et reconnectez-vous |

[résultats d’installation](../configuration.md#quick-setup): Hôte distant `%LOCALAPPDATA%\KeepDesktopInteractive\elevation-result.json` → `%ProgramData%\KeepDesktopInteractive\setup-result.json`: `Installed: true`, `Status: Ready`; Client local `%LOCALAPPDATA%\KeepDesktopInteractive\local-rdp-minimize-result.json`: `Succeeded: true`.

<a id="proof"></a>

## Vérifiez les entrées réelles

Avant le test, relevez l’heure, cessez toute autre automatisation UI, sauvegardez le travail sensible et écartez les fenêtres confidentielles ; la déconnexion lance le diagnostic. Vérifiez que le fichier a été modifié après le début du test et que les valeurs `Passed` et `Mode` correspondent au résultat attendu ; testez ensuite clic/saisie/capture dans une application inoffensive à la résolution finale de console. Le diagnostic ne valide pas toutes les applications.

Déconnectez pendant 30 secondes, puis reconnectez-vous. Sur l’hôte, vérifiez que `%LOCALAPPDATA%\KeepDesktopInteractive\desktop-proof.json` a été actualisé pour ce test, avec `Passed: true` et `Mode: AfterDisconnect`.

La réduction est conditionnelle : suivez séparément le [test de 90 secondes / délai de 60 secondes](../configuration.md#verify-on-each-new-machine) pour `WhileClientMinimized`. En cas d’échec, gardez la fenêtre visible.

<a id="limits"></a>

- Après redémarrage, ouvrez et déverrouillez la session puis relancez les apps ; pas de connexion automatique. Le verrouillage distant, la veille et la fermeture de session peuvent arrêter l’automatisation de l’interface graphique.
- Compatibilité selon client et version, pas de certification universelle Dev Box : [preuves](../configuration.md#reported-compatibility-evidence).
- Windows Sandbox réduit avec invité actif : **NON VALIDÉ** ; [expérience](../configuration.md#sandbox-minimized-window-experiment), pas une procédure RDP.

## Échecs et annulation

Preuve échouée, absente ou ancienne ? Vérifiez `Error`, `Stage` et l’installation, puis recommencez. [Dépannage](../configuration.md#proof-and-setup-troubleshooting) · [Contrôles](../configuration.md#configuration-checks)

<a id="undo"></a>

Retirer les tâches de l’hôte et restaurer le registre du client ne verrouille pas la console. Sauvegardez et terminez l’automatisation ; verrouillez l’hôte et vérifiez la demande de connexion, ou fermez la session pour terminer les apps.

[Annulation](../configuration.md#undo) · [Guide anglais de référence](../configuration.md) · [README anglais](../../README.md) · [Mises à jour](../configuration.md#updating-the-first-prototype)
