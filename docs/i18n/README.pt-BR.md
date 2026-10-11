# KeepDesktopInteractive — Mantenha a entrada GUI após desconectar RDP

<a id="languages"></a>

<details>
<summary>Languages (16)</summary>

[English](../../README.md) · [简体中文](README.zh-CN.md) · [繁體中文](README.zh-TW.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Español](README.es.md) · [Português (Brasil)](README.pt-BR.md) · [Français](README.fr.md) · [Deutsch](README.de.md) · [Italiano](README.it.md) · [Русский](README.ru.md) · [Türkçe](README.tr.md) · [Tiếng Việt](README.vi.md) · [Bahasa Indonesia](README.id.md) · [हिन्दी](README.hi.md) · [العربية](README.ar.md)

</details>

Para agentes e testes de UI em um desktop Windows existente: Windows App é o cliente; Microsoft Dev Box pode ser o host, assim como outro computador Windows com RDP.

<img src="../../assets/keep-desktop-interactive.png" width="320" alt="Ilustração conceitual: mantenha cliques e digitação após desconectar; pare de vigiar a janela remota ao minimizá-la com um cliente compatível testado; reutilize o desktop em que você já iniciou sessão sem salvar senhas. A transferência para o console o deixa desbloqueado.">

Ilustração conceitual com rótulos em inglês, não uma prova.

- **Mantenha cliques, digitação e capturas.**
- **Pare de vigiar a conexão.**
- **Reutilize o desktop em que você já iniciou sessão e os apps abertos, sem salvar senhas.**

> **A transferência deixa a área de trabalho remota desbloqueada.** Quem puder operar o console físico ou interativo da VM pode usar a sessão sem entrar no Windows. Não use PC compartilhado acessível ou console não confiável. Não automatiza uma tela bloqueada nem contorna políticas. [Configuração e riscos de acesso](../configuration.md).

Ambos os computadores precisam de Windows. O host deve estar com sessão aberta, desbloqueado e sem suspensão, conforme as políticas. São necessários aprovação de administrador no host, Git, Windows PowerShell 5.1 e VBScript.

O diagnóstico instalado tenta cliques, digitação e captura cerca de 10 segundos após cada desconexão RDP do usuário configurado, inclusive no uso normal, podendo interferir no agente.

<a id="setup"></a>

## Configure os dois computadores

Clone uma cópia nova e confiável na pasta privada do usuário atual em ambos, nunca em pasta compartilhada gravável. Abra `%LOCALAPPDATA%\KeepDesktopInteractiveSource` no Explorador e clique duas vezes no iniciador correspondente.

```powershell
git clone https://github.com/yeelam-gordon/KeepDesktopInteractive.git "$env:LOCALAPPDATA\KeepDesktopInteractiveSource"
```

| Host remoto / Cliente local | |
| --- | --- |
| Host remoto | `start-desktop-session-setup.vbs` — aprove a elevação |
| Cliente local | `set-local-rdp-minimize-rendering.vbs` — feche completamente Windows App/RDP, reabra e reconecte |

[resultados da instalação](../configuration.md#quick-setup): Host remoto `%LOCALAPPDATA%\KeepDesktopInteractive\elevation-result.json` → `%ProgramData%\KeepDesktopInteractive\setup-result.json`: `Installed: true`, `Status: Ready`; Cliente local `%LOCALAPPDATA%\KeepDesktopInteractive\local-rdp-minimize-result.json`: `Succeeded: true`.

<a id="proof"></a>

## Verifique a entrada real

Antes do teste, registre o início, pare outras automações UI, salve trabalho sensível e afaste janelas confidenciais; desconectar dispara o diagnóstico. Exija arquivo modificado após o início e Passed/Mode corretos; depois teste clique/digitação/captura em app inofensivo na resolução final do console. O diagnóstico não comprova todos os apps.

Desconecte por 30 segundos e reconecte. No host, confira se `%LOCALAPPDATA%\KeepDesktopInteractive\desktop-proof.json` foi atualizado neste teste, com `Passed: true` e `Mode: AfterDisconnect`.

Minimizar é condicional: siga separadamente o [teste de 90 segundos / espera de 60 segundos](../configuration.md#verify-on-each-new-machine) para `WhileClientMinimized`. Se falhar, mantenha a janela visível.

<a id="limits"></a>

- Após reiniciar, entre, desbloqueie e abra os apps manualmente; sem logon automático. O bloqueio remoto, a suspensão e a saída da sessão podem interromper a automação da GUI.
- Compatibilidade depende do cliente e versão, não é certificação universal de Dev Box: [evidências](../configuration.md#reported-compatibility-evidence).
- Windows Sandbox minimizado com convidado ativo: **NÃO VALIDADO**; [experimento](../configuration.md#sandbox-minimized-window-experiment), não instruções RDP.

## Falhas e desfazer

Prova falhou, está ausente ou antiga? Confira `Error`, `Stage` e a instalação; repita o teste. [Diagnóstico](../configuration.md#proof-and-setup-troubleshooting) · [Verificações](../configuration.md#configuration-checks)

<a id="undo"></a>

Remover tarefas do host e restaurar o registro do cliente não bloqueia o console. Salve e termine a automação; bloqueie o host e confirme a exigência de logon, ou saia da sessão para encerrar apps.

[Desfazer](../configuration.md#undo) · [Guia canônico em inglês](../configuration.md) · [README em inglês](../../README.md) · [Atualizações](../configuration.md#updating-the-first-prototype)
