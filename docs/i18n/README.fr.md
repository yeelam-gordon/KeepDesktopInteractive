# KeepDesktopInteractive — Automatisation de l’interface Windows après déconnexion RDP

[English](../../README.md) · [简体中文](README.zh-CN.md) · [繁體中文](README.zh-TW.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Español](README.es.md) · [Português (Brasil)](README.pt-BR.md) · [Français](README.fr.md) · [Deutsch](README.de.md) · [Italiano](README.it.md) · [Русский](README.ru.md) · [Türkçe](README.tr.md) · [Tiếng Việt](README.vi.md) · [Bahasa Indonesia](README.id.md) · [हिन्दी](README.hi.md) · [العربية](README.ar.md)

> **Attention : le transfert vers la console laisse le bureau Windows distant déverrouillé.** Toute personne ayant accès au clavier physique ou à la console interactive de la VM peut utiliser votre session sans se connecter à Windows. N’utilisez pas un PC partagé accessible à d’autres personnes. Vous devez faire confiance aux administrateurs Hyper-V et aux personnes pouvant ouvrir VMConnect. Un compte de test ou une VM cloud n’est pas automatiquement sûr. Respectez les règles de votre organisation : ce projet ne permet ni l’automatisation derrière un écran distant verrouillé ni le contournement des politiques de verrouillage.

L’automatisation de l’interface Windows s’arrête après déconnexion RDP ? Préservez une session **déjà ouverte et déverrouillée** pour les clics, la saisie et les captures de vos agents computer-use ou tests UI existants. Les échecs lorsque la fenêtre est réduite constituent un cas distinct, nécessitant un client compatible et une vérification séparée. Aucun agent n’est intégré nativement ou démarré ; aucun mot de passe n’est stocké et aucune connexion automatique n’est activée.

## Deux ordinateurs, deux configurations

L’**hôte distant** est le PC/VM Windows exécutant l’automatisation. Le **client local** est le PC Windows exécutant RDP/Windows App. Windows PowerShell 5.1, VBScript et Git pour le clonage sont nécessaires ; l’installation sur l’hôte exige l’approbation d’un administrateur. Sur chacun, obtenez une copie neuve et fiable dans le dossier privé de l’utilisateur actuel, jamais dans un dossier partagé modifiable :
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

## Limites, échecs et annulation

Le réglage est documenté pour Remote Desktop Connection classique ; sa prise en charge par Windows App dépend de la version. Un succès ne prouve pas une compatibilité universelle. Le couple initial a réussi le test avec la fenêtre du client réduite avant le durcissement, mais n’a pas été revérifié après déploiement. Après redémarrage, connectez-vous et déverrouillez une fois, puis relancez les applications et l’automatisation. Les bureaux sans interface ne sont pas couverts. Verrouillage distant, veille, arrêt et fermeture de session peuvent encore interrompre l’automatisation. [Toutes les limites](../configuration.md#requirements-and-limitations).

Si `Passed: false`, lisez `Error`, `Stage` et les journaux. Si la preuve manque ou est ancienne, vérifiez l’installation et recommencez. Si le client ne gère pas la réduction, gardez la fenêtre visible ou utilisez la déconnexion vérifiée séparément. [Dépannage](../../README.md#if-the-proof-fails) · [Contrôles](../configuration.md#configuration-checks).

Depuis les dossiers clonés respectifs, désinstallez sur l’hôte et restaurez sur le même client avec le même utilisateur :
```powershell
wscript.exe .\start-desktop-session-setup.vbs --uninstall
```
```powershell
wscript.exe .\set-local-rdp-minimize-rendering.vbs --restore
```
Conservez `%LOCALAPPDATA%\KeepDesktopInteractive\local-rdp-minimize-backup.json` du client jusqu’à ce que la restauration ne soit plus nécessaire. Les opérations sont indépendantes et ne suppriment pas les preuves. [Annulation](../configuration.md#undo) · [Guide anglais de référence](../configuration.md) · [README anglais](../../README.md).
