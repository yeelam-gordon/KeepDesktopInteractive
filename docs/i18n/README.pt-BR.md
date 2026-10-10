# KeepDesktopInteractive — GUI Windows após desconectar RDP

<a id="languages"></a>

<details>
<summary>Languages / 语言 / 言語 / اللغات (16)</summary>

[English](../../README.md) · [简体中文](README.zh-CN.md) · [繁體中文](README.zh-TW.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Español](README.es.md) · [Português (Brasil)](README.pt-BR.md) · [Français](README.fr.md) · [Deutsch](README.de.md) · [Italiano](README.it.md) · [Русский](README.ru.md) · [Türkçe](README.tr.md) · [Tiếng Việt](README.vi.md) · [Bahasa Indonesia](README.id.md) · [हिन्दी](README.hi.md) · [العربية](README.ar.md)

</details>

Windows App como cliente, Microsoft Dev Box como host ou outro ambiente Windows RDP: mantenha cliques, digitação e capturas do agente computer-use após detectar a desconexão; pare de vigiar a janela conectada (minimizar exige renderização compatível verificada); reutilize a sessão iniciada sem salvar senhas nem ativar logon automático.

Console desbloqueado; respeite as políticas. Minimização do Windows Sandbox: não validada.

<img src="../../assets/keep-desktop-interactive.png" width="700" alt="Antes e depois de desconectar o RDP ou minimizar: os aplicativos continuam abertos, mas cliques, digita&#231;&#227;o e capturas podem parar; transfer&#234;ncia para o console e cliente compat&#237;vel ajudam.">

- **Mantenha a entrada do agente após desconectar:** preserve cliques, digitação e capturas no desktop existente quando o Windows detectar a desconexão RDP; detectar a perda da rede pode levar tempo.
- **Pare de vigiar a janela conectada:** afaste-se da janela remota; minimizar exige renderização compatível e um teste separado de entrada bem-sucedido no seu ambiente.
- **Reutilize o trabalho já iniciado:** mantenha sessão e aplicativos abertos sem salvar senhas ou ativar logon automático; a ferramenta não faz login por você após reiniciar.

Conceito com rótulos em inglês, não teste ao vivo. Suporte do cliente e bloqueio local com notebook acordado têm condições.

> **A transferência deixa a área de trabalho remota desbloqueada.** Quem puder operar o console físico ou interativo da VM pode usar a sessão sem entrar no Windows. Não use PC compartilhado acessível ou console não confiável. Não automatiza uma tela bloqueada nem contorna políticas. [Configuração e riscos de acesso](../configuration.md).

Somente onde as políticas permitam configurar a transferência RDP/console; valide seu ambiente, sem certificação universal de Dev Box.

[Configuração e riscos de acesso](#setup) → [Verificar entrada real](#proof) · [Limites](#limits) · [Desfazer](#undo) · Minimização do Windows Sandbox: ainda não validada.

**[Windows Sandbox](https://learn.microsoft.com/en-us/windows/security/application-security/application-isolation/windows-sandbox/) — janela minimizada; candidato NÃO VALIDADO:** Quando a janela do Windows Sandbox no host está minimizada e o convidado e seus aplicativos continuam rodando, os cliques, a digitação e as capturas continuam? Instalação e continuidade não validadas: esta ferramenta pode funcionar ou não com a renderização do cliente ou transferência do convidado; teste separadamente, não é uma solução já comprovada.

## Windows App / RDP

O diagnóstico instalado tenta cliques, digitação e captura cerca de 10 segundos após cada desconexão RDP do usuário configurado, inclusive no uso normal, podendo interferir no agente. Não há opção documentada do lançador para desativar só o diagnóstico; desinstalar o host também remove a transferência.

Rota Windows App/RDP: desconexão usa transferência do host; minimização usa renderização compatível e configuração do host. Mantenha a configuração testada de dois computadores e valide cada modo. Sem integração ou início de agentes, senhas salvas ou logon automático. [→](../configuration.md#mode-choice)

O mantenedor relata bloqueio local bem-sucedido apenas no par testado, notebook acordado e cliente configurado, não bloqueio remoto; tampa/rede exigem detecção da desconexão pelo Windows.

## Windows Sandbox — UNVALIDATED

Sandbox é um experimento proposto: pare se não estabelecer um método aprovado de instalação/teste. Registre cliques, digitação e captura sem dados sensíveis com janela visível; minimize por intervalo registrado mantendo convidado e apps ativos, repita entrada/captura nova e restaure para conferir. Não validado; se falhar, mantenha a janela visível. As instruções RDP de dois computadores, desconexão e fechar/reabrir não são um procedimento Sandbox. [→](../configuration.md#sandbox-minimized-window-experiment)

<a id="setup"></a>

Antes de instalar: host ligado, acordado e desbloqueado, com uso permitido pelas políticas. Requisitos de Windows, administrador, Git, PowerShell 5.1 e VBScript abaixo.

## Dois computadores, configurações separadas

O **host remoto** é o PC/VM Windows que executa a automação. O **cliente local** é o PC Windows com RDP/Windows App. São necessários Windows PowerShell 5.1, VBScript e Git para clonar; a instalação no host exige aprovação de administrador. Em ambos, obtenha uma cópia nova e confiável na pasta privada do usuário atual, nunca em um local compartilhado gravável:
<details>
<summary>Windows App / Microsoft Dev Box / Hyper-V</summary>

> **Aviso: a transferência para o console deixa a área de trabalho remota do Windows desbloqueada.** Quem tiver acesso ao teclado físico ou ao console interativo da VM poderá usar sua sessão sem entrar no Windows. Não use em um PC compartilhado ao qual outras pessoas possam ter acesso físico. Confie nos administradores do Hyper-V e em todos que possam abrir o VMConnect. Windows App é o cliente de conexão; Microsoft Dev Box é a estação de trabalho gerenciada na nuvem. O risco é outra pessoa poder operar o console desbloqueado, não uma insegurança inerente do produto. Um host gerenciado para um desenvolvedor sem acesso interativo ao console por pessoas não confiáveis tem menor risco que um PC compartilhado. Não presuma que Microsoft Dev Box oferece esse acesso. Respeite as políticas da organização: a ferramenta não automatiza atrás de uma tela remota bloqueada nem contorna políticas de bloqueio.

</details>


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

- Após o Windows detectar a desconexão RDP, a sessão existente passa ao console para ajudar a manter a entrada GUI.
- O ajuste de renderização ajuda clientes compatíveis ao minimizar; exige teste separado.
- Confira cliques, digitação e capturas reais com resultados privados do modo correto, não apenas aplicativos abertos.

Antes do teste, registre o início, pare outras automações UI, salve trabalho sensível e afaste janelas confidenciais; desconectar dispara o diagnóstico. Exija arquivo modificado após o início e Passed/Mode corretos; depois teste clique/digitação/captura em app inofensivo na resolução final do console. O diagnóstico não comprova todos os apps. [→](../configuration.md#reported-compatibility-evidence)

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

<a id="limits"></a>

## Limites, falhas e desfazer

O ajuste é documentado para o Remote Desktop Connection clássico; no Windows App depende da versão. Um teste bem-sucedido em um par cliente/host não comprova compatibilidade com todos os clientes. O par original passou no teste minimizado antes do reforço de segurança, mas não foi revalidado após a implantação. Após reiniciar, faça logon e desbloqueie uma vez, depois reinicie os aplicativos e a automação. Desktops sem interface não são cobertos. Bloqueio remoto, suspensão, desligamento e saída da sessão ainda podem interromper a automação. [Limites completos](../configuration.md#requirements-and-limitations).

Com `Passed: false`, leia `Error`, `Stage` e os registros. Se a prova estiver ausente ou antiga, confira a instalação e repita o teste. Para clientes sem suporte à minimização, mantenha a janela visível ou use a desconexão verificada separadamente. [Diagnóstico](../../README.md#if-the-proof-fails) · [Verificações](../configuration.md#configuration-checks).

<a id="undo"></a>

Remover tarefas/restaurar o cliente não bloqueia automaticamente o console atual. Salve e termine a automação; bloqueie o host manualmente e confira a exigência de logon, ou saia da sessão intencionalmente para encerrar apps. Bloquear interrompe automação GUI.

Das respectivas pastas clonadas, desinstale no host e restaure no mesmo cliente e usuário:
```powershell
wscript.exe .\start-desktop-session-setup.vbs --uninstall
```
```powershell
wscript.exe .\set-local-rdp-minimize-rendering.vbs --restore
```
Guarde `%LOCALAPPDATA%\KeepDesktopInteractive\local-rdp-minimize-backup.json` do cliente até não precisar mais restaurar. As operações são independentes e não apagam evidências. [Desfazer](../configuration.md#undo) · [Guia canônico em inglês](../configuration.md) · [README em inglês](../../README.md).

Atualize em um destino privado novo, não em pasta existente não vazia; preserve cópia antiga e backups, reinstale e valide. [→](../configuration.md#updating-the-first-prototype)
