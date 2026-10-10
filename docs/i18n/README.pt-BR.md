# KeepDesktopInteractive — Automação GUI do Windows após desconectar o RDP

A automação GUI do Windows para após desconectar o RDP? Preserve uma sessão **já iniciada e desbloqueada** para cliques, digitação e capturas de tela dos seus agentes computer-use ou testes de UI existentes. Falhas ao minimizar são um caso separado, com compatibilidade do cliente e verificação próprias. Não há integração nativa nem inicialização de agentes, armazenamento de senhas ou logon automático.

> **A transferência deixa a área de trabalho remota desbloqueada.** Quem puder operar o console físico ou interativo da VM pode usar a sessão sem entrar no Windows. Não use PC compartilhado acessível ou console não confiável. Não automatiza uma tela bloqueada nem contorna políticas. [Configuração e riscos de acesso](../configuration.md).

[Configuração e riscos de acesso](#setup) → [Verificar entrada real](#proof) · [Limites](#limits) · [Desfazer](#undo)

- Após o Windows detectar a desconexão RDP, a sessão existente passa ao console para ajudar a manter a entrada GUI.
- O ajuste de renderização ajuda clientes compatíveis ao minimizar; exige teste separado.
- Confira cliques, digitação e capturas reais com resultados privados do modo correto, não apenas aplicativos abertos.

<details>
<summary>Languages</summary>

[English](../../README.md) · [简体中文](README.zh-CN.md) · [繁體中文](README.zh-TW.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Español](README.es.md) · [Português (Brasil)](README.pt-BR.md) · [Français](README.fr.md) · [Deutsch](README.de.md) · [Italiano](README.it.md) · [Русский](README.ru.md) · [Türkçe](README.tr.md) · [Tiếng Việt](README.vi.md) · [Bahasa Indonesia](README.id.md) · [हिन्दी](README.hi.md) · [العربية](README.ar.md)

</details>

<a id="setup"></a>

Antes de instalar: host ligado, acordado e desbloqueado, com uso permitido pelas políticas. Requisitos de Windows, administrador, Git, PowerShell 5.1 e VBScript abaixo.

## Dois computadores, configurações separadas

O **host remoto** é o PC/VM Windows que executa a automação. O **cliente local** é o PC Windows com RDP/Windows App. São necessários Windows PowerShell 5.1, VBScript e Git para clonar; a instalação no host exige aprovação de administrador. Em ambos, obtenha uma cópia nova e confiável na pasta privada do usuário atual, nunca em um local compartilhado gravável:
```powershell
git clone https://github.com/yeelam-gordon/KeepDesktopInteractive.git "$env:LOCALAPPDATA\KeepDesktopInteractiveSource"
Set-Location "$env:LOCALAPPDATA\KeepDesktopInteractiveSource"
```
Abra a pasta clonada em cada computador e execute os comandos nela: o primeiro no host (aprove a elevação), o segundo no cliente local.
```powershell
wscript.exe .\start-desktop-session-setup.vbs
```
```powershell
wscript.exe .\set-local-rdp-minimize-rendering.vbs
```
Feche completamente o cliente remoto, abra-o novamente e reconecte. Confira os [resultados da instalação](../configuration.md#quick-setup): host `Installed: true` e `Status: Ready`; cliente `Succeeded: true`.

## Primeira verificação

<a id="proof"></a>

**Desconexão:** desconecte o RDP normalmente, espere 30 segundos e reconecte. O diagnóstico é automático. **Minimização:** execute o comando abaixo no host e minimize imediatamente a janela remota no cliente por 90 segundos. Depois restaure-a. A prova espera 60 segundos antes da entrada real e da captura de tela.
```powershell
wscript.exe .\test-interactive-desktop-automation.vbs --minimized-test
```
No host, abra o resultado novo em `%LOCALAPPDATA%\KeepDesktopInteractive\desktop-proof.json`. Os campos abaixo exemplificam o sucesso esperado para cada teste; não são medições desta alteração:
```json
{ "Passed": true, "Mode": "AfterDisconnect" }
```
```json
{ "Passed": true, "Mode": "WhileClientMinimized" }
```
A prova minimizada só vale se a janela permaneceu minimizada durante a entrada e a captura; o host não observa esse estado. Mantenha registros e capturas privados, pois podem incluir conteúdo próximo da área de trabalho. [Detalhes](../configuration.md#verify-on-each-new-machine).

<img src="../../assets/keep-desktop-interactive.png" width="700" alt="Antes e depois de desconectar o RDP ou minimizar: os aplicativos continuam abertos, mas cliques, digita&#231;&#227;o e capturas podem parar; transfer&#234;ncia para o console e cliente compat&#237;vel ajudam.">

Ilustração conceitual: à esquerda, aplicativos ativos com automação travada; à direita, cliques, digitação e capturas esperados após configurar. Os rótulos estão em inglês: não é uma interface traduzida nem um teste ao vivo. Minimizar depende do cliente; fechar o notebook ou perder a rede exige que o Windows detecte a desconexão RDP. O console permanece desbloqueado; valide sua configuração. O bloqueio local passou apenas no par relatado pelo mantenedor, com notebook acordado e configuração do cliente aplicada. O teste minimizado foi anterior ao reforço de segurança e não foi refeito após a implantação.

<a id="limits"></a>

## Limites, falhas e desfazer

O ajuste é documentado para o Remote Desktop Connection clássico; no Windows App depende da versão. Um teste bem-sucedido em um par cliente/host não comprova compatibilidade com todos os clientes. O par original passou no teste minimizado antes do reforço de segurança, mas não foi revalidado após a implantação. Após reiniciar, faça logon e desbloqueie uma vez, depois reinicie os aplicativos e a automação. Desktops sem interface não são cobertos. Bloqueio remoto, suspensão, desligamento e saída da sessão ainda podem interromper a automação. [Limites completos](../configuration.md#requirements-and-limitations).

Com `Passed: false`, leia `Error`, `Stage` e os registros. Se a prova estiver ausente ou antiga, confira a instalação e repita o teste. Para clientes sem suporte à minimização, mantenha a janela visível ou use a desconexão verificada separadamente. [Diagnóstico](../../README.md#if-the-proof-fails) · [Verificações](../configuration.md#configuration-checks).

<a id="undo"></a>

Das respectivas pastas clonadas, desinstale no host e restaure no mesmo cliente e usuário:
```powershell
wscript.exe .\start-desktop-session-setup.vbs --uninstall
```
```powershell
wscript.exe .\set-local-rdp-minimize-rendering.vbs --restore
```
Guarde `%LOCALAPPDATA%\KeepDesktopInteractive\local-rdp-minimize-backup.json` do cliente até não precisar mais restaurar. As operações são independentes e não apagam evidências. [Desfazer](../configuration.md#undo) · [Guia canônico em inglês](../configuration.md) · [README em inglês](../../README.md).

<details>
<summary>Windows App / Microsoft Dev Box / Hyper-V</summary>

> **Aviso: a transferência para o console deixa a área de trabalho remota do Windows desbloqueada.** Quem tiver acesso ao teclado físico ou ao console interativo da VM poderá usar sua sessão sem entrar no Windows. Não use em um PC compartilhado ao qual outras pessoas possam ter acesso físico. Confie nos administradores do Hyper-V e em todos que possam abrir o VMConnect. Windows App é o cliente de conexão; Microsoft Dev Box é a estação de trabalho gerenciada na nuvem. O risco é outra pessoa poder operar o console desbloqueado, não uma insegurança inerente do produto. Um host gerenciado para um desenvolvedor sem acesso interativo ao console por pessoas não confiáveis tem menor risco que um PC compartilhado. Não presuma que Microsoft Dev Box oferece esse acesso. Respeite as políticas da organização: a ferramenta não automatiza atrás de uma tela remota bloqueada nem contorna políticas de bloqueio.

</details>
