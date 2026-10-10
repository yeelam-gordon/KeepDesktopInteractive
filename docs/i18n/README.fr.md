# KeepDesktopInteractive — Gardez les interactions après déconnexion RDP

<a id="languages"></a>

<details>
<summary>Languages / 语言 / 言語 / اللغات (16)</summary>

[English](../../README.md) · [简体中文](README.zh-CN.md) · [繁體中文](README.zh-TW.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Español](README.es.md) · [Português (Brasil)](README.pt-BR.md) · [Français](README.fr.md) · [Deutsch](README.de.md) · [Italiano](README.it.md) · [Русский](README.ru.md) · [Türkçe](README.tr.md) · [Tiếng Việt](README.vi.md) · [Bahasa Indonesia](README.id.md) · [हिन्दी](README.hi.md) · [العربية](README.ar.md)

</details>

Windows App côté client, Microsoft Dev Box côté hôte ou autre environnement Windows RDP : gardez clics, saisie et captures de l’agent computer-use après détection de la déconnexion ; cessez de surveiller la fenêtre connectée (réduction uniquement avec rendu compatible vérifié) ; réutilisez la session ouverte sans mot de passe enregistré ni connexion automatique.

Console déverrouillée ; respectez les règles. Réduction de Windows Sandbox : non validée.

<img src="../../assets/keep-desktop-interactive.png" width="700" alt="Avant et apr&#232;s d&#233;connexion RDP ou r&#233;duction : les applications restent ouvertes, mais clics, saisie et captures peuvent &#233;chouer ; transfert vers la console et client compatible aident.">

- **Préservez les entrées de l’agent après déconnexion :** gardez clics, saisie et captures sur le bureau existant après détection de la déconnexion RDP par Windows ; détecter la perte du réseau peut prendre du temps.
- **Ne surveillez plus constamment la fenêtre connectée :** éloignez-vous de la fenêtre distante ; la réduction exige un rendu compatible et un test d’entrée distinct réussi dans votre environnement. Le client doit continuer à afficher le bureau distant lorsque sa fenêtre est réduite ; vérifiez séparément clics, saisie et captures.
- **Réutilisez le travail déjà ouvert :** gardez session et applications sans enregistrer de mot de passe ni activer la connexion automatique ; l’outil ne vous connecte pas après redémarrage.

Concept aux libellés anglais, pas un test en direct. Compatibilité du client et verrouillage local avec ordinateur portable non en veille restent conditionnels.

> **Le transfert laisse le bureau distant déverrouillé.** Toute personne pouvant utiliser la console physique ou interactive de la VM peut utiliser la session sans connexion Windows. Évitez un PC partagé accessible ou une console non fiable. Pas d’automatisation derrière un écran verrouillé ni de contournement des règles. [Configuration et risques d’accès](../configuration.md).

Uniquement si les règles permettent le transfert RDP/console : vérifiez votre environnement, sans certification universelle Dev Box.

[Configuration et risques d’accès](#setup) → [Vérifier les entrées réelles](#proof) · [Limites](#limits) · [Annuler](#undo) · Réduction de Windows Sandbox : pas encore validée.

**[Windows Sandbox](https://learn.microsoft.com/en-us/windows/security/application-security/application-isolation/windows-sandbox/) — fenêtre réduite ; candidat NON VALIDÉ:** Quand la fenêtre Windows Sandbox sur l’hôte est réduite et que l’invité et ses applications continuent de fonctionner, clics, saisie et captures peuvent-ils continuer ? Déploiement et continuité non validés : cet outil peut fonctionner ou non avec le rendu du client ou le transfert de l’invité ; testez séparément, ce n’est pas une solution déjà vérifiée.

## Windows App / RDP

Le diagnostic installé tente clics, saisie et capture environ 10 secondes après chaque déconnexion RDP de l’utilisateur configuré, même en usage normal, et peut interférer avec l’agent. Aucun paramètre documenté du lanceur ne désactive uniquement ce diagnostic ; désinstaller l’hôte retire aussi le transfert.

Route Windows App/RDP : déconnexion = transfert de l’hôte ; réduction = rendu compatible plus configuration de l’hôte. Conservez la configuration testée à deux ordinateurs et vérifiez chaque mode. Aucun agent intégré/démarré, mot de passe enregistré ou connexion automatique. [→](../configuration.md#mode-choice)

Le mainteneur rapporte que les entrées ont continué à fonctionner avec l’écran local verrouillé uniquement sur le couple testé, ordinateur portable non en veille et client configuré ; le bureau distant n’était pas verrouillé. Fermer le capot ou perdre le réseau exige que Windows détecte la déconnexion.

## Windows Sandbox — UNVALIDATED

Sandbox est une expérience proposée : arrêtez si aucun déploiement/test autorisé et réalisable n’est établi. Relevez clics, saisie et capture sans données sensibles en fenêtre visible ; réduisez durant un intervalle enregistré avec invité/apps actifs, répétez entrées et nouvelle capture, puis restaurez et inspectez. Non validé ; en cas d’échec, gardez la fenêtre visible. Les procédures RDP à deux ordinateurs, de déconnexion et fermeture/réouverture ne constituent pas une procédure Sandbox. [→](../configuration.md#sandbox-minimized-window-experiment)

<a id="setup"></a>

Avant installation : hôte allumé, non en veille et déverrouillé, usage permis par les règles. Prérequis Windows, administrateur, Git, PowerShell 5.1 et VBScript ci-dessous.

## Deux ordinateurs, deux configurations

L’**hôte distant** est le PC/VM Windows exécutant l’automatisation. Le **client local** est le PC Windows exécutant RDP/Windows App. Windows PowerShell 5.1, VBScript et Git pour le clonage sont nécessaires ; l’installation sur l’hôte exige l’approbation d’un administrateur. Sur chacun, obtenez une copie neuve et fiable dans le dossier privé de l’utilisateur actuel, jamais dans un dossier partagé modifiable :
<details>
<summary>Windows App / Microsoft Dev Box / Hyper-V</summary>

> **Attention : le transfert vers la console laisse le bureau Windows distant déverrouillé.** Toute personne ayant accès au clavier physique ou à la console interactive de la VM peut utiliser votre session sans se connecter à Windows. N’utilisez pas un PC partagé accessible à d’autres personnes. Vous devez faire confiance aux administrateurs Hyper-V et aux personnes pouvant ouvrir VMConnect. Windows App est le client de connexion ; Microsoft Dev Box est le poste cloud géré. Le risque vient de l’accès d’autrui à la console déverrouillée, pas d’une insécurité intrinsèque du produit. Un hôte géré pour un développeur, sans accès interactif à la console par des personnes non fiables, présente moins de risque qu’un PC partagé. Ne supposez pas que Microsoft Dev Box offre cet accès. Respectez les règles de votre organisation : ce projet ne permet ni l’automatisation derrière un écran distant verrouillé ni le contournement des politiques de verrouillage.

</details>


```powershell
git clone https://github.com/yeelam-gordon/KeepDesktopInteractive.git "$env:LOCALAPPDATA\KeepDesktopInteractiveSource"
Set-Location "$env:LOCALAPPDATA\KeepDesktopInteractiveSource"
```
Ouvrez le dossier cloné sur chaque ordinateur et exécutez les commandes depuis ce dossier : la première sur l’hôte (approuvez l’élévation), la seconde sur le client local.
```powershell
wscript.exe .\start-desktop-session-setup.vbs
```
```powershell
wscript.exe .\set-local-rdp-minimize-rendering.vbs
```
Fermez complètement le client distant, rouvrez-le puis reconnectez-vous. Vérifiez les [résultats d’installation](../configuration.md#quick-setup) : hôte `Installed: true` / `Status: Ready` ; client `Succeeded: true`.

## Première vérification

<a id="proof"></a>

- Après détection de la déconnexion RDP par Windows, la session existante passe à la console pour aider à maintenir les entrées GUI.
- Le réglage de rendu aide les clients compatibles en fenêtre réduite ; vérifiez ce cas séparément.
- Vérifiez clics, saisie et captures réels avec des résultats privés du bon mode, pas seulement des applications ouvertes.

Avant le test, relevez l’heure, cessez toute autre automatisation UI, sauvegardez le travail sensible et écartez les fenêtres confidentielles ; la déconnexion lance le diagnostic. Exigez un fichier modifié après le début et Passed/Mode corrects ; testez ensuite clic/saisie/capture dans une application inoffensive à la résolution finale de console. Le diagnostic ne valide pas toutes les applications. [→](../configuration.md#reported-compatibility-evidence)

**Déconnexion :** déconnectez RDP normalement, attendez 30 secondes, puis reconnectez-vous. Le diagnostic est automatique. **Réduction :** lancez la commande suivante sur l’hôte et réduisez immédiatement la fenêtre distante du client pendant 90 secondes. Restaurez-la ensuite. Le test attend 60 secondes avant les entrées réelles et la capture.
```powershell
wscript.exe .\test-interactive-desktop-automation.vbs --minimized-test
```
Sur l’hôte, consultez le nouveau `%LOCALAPPDATA%\KeepDesktopInteractive\desktop-proof.json`. Voici les champs attendus selon le test, à titre d’exemple, et non des mesures effectuées ici :
```json
{ "Passed": true, "Mode": "AfterDisconnect" }
```
```json
{ "Passed": true, "Mode": "WhileClientMinimized" }
```
Le succès en fenêtre réduite ne compte que si elle reste réduite pendant les entrées et la capture ; l’hôte ne peut pas observer cet état. Gardez les journaux et captures privés : ils peuvent inclure d’autres éléments visibles sur le bureau. [Détails](../configuration.md#verify-on-each-new-machine).

<a id="limits"></a>

## Limites, échecs et annulation

Le réglage est documenté pour Remote Desktop Connection classique ; sa prise en charge par Windows App dépend de la version. Un succès ne prouve pas une compatibilité universelle. Le couple initial a réussi le test avec la fenêtre du client réduite avant le durcissement, mais n’a pas été revérifié après déploiement. Après redémarrage, connectez-vous et déverrouillez une fois, puis relancez les applications et l’automatisation. Les bureaux sans interface ne sont pas couverts. Verrouillage distant, veille, arrêt et fermeture de session peuvent encore interrompre l’automatisation. [Toutes les limites](../configuration.md#requirements-and-limitations).

Si `Passed: false`, lisez `Error`, `Stage` et les journaux. Si la preuve manque ou est ancienne, vérifiez l’installation et recommencez. Si le client ne gère pas la réduction, gardez la fenêtre visible ou utilisez la déconnexion vérifiée séparément. [Dépannage](../../README.md#if-the-proof-fails) · [Contrôles](../configuration.md#configuration-checks).

<a id="undo"></a>

Retirer les tâches/restaurer le client ne verrouille pas automatiquement la console actuelle. Sauvegardez et terminez l’automatisation ; verrouillez l’hôte manuellement et vérifiez la connexion exigée, ou déconnectez volontairement la session pour terminer les applications. Verrouiller interrompt l’automatisation GUI.

Depuis les dossiers clonés respectifs, désinstallez sur l’hôte et restaurez sur le même client avec le même utilisateur :
```powershell
wscript.exe .\start-desktop-session-setup.vbs --uninstall
```
```powershell
wscript.exe .\set-local-rdp-minimize-rendering.vbs --restore
```
Conservez `%LOCALAPPDATA%\KeepDesktopInteractive\local-rdp-minimize-backup.json` du client jusqu’à ce que la restauration ne soit plus nécessaire. Les opérations sont indépendantes et ne suppriment pas les preuves. [Annulation](../configuration.md#undo) · [Guide anglais de référence](../configuration.md) · [README anglais](../../README.md).

Mettez à jour dans un nouveau dossier privé, jamais par clonage dans un dossier existant non vide ; gardez ancienne copie et sauvegardes, réinstallez et vérifiez. [→](../configuration.md#updating-the-first-prototype)
