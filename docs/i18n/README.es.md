# KeepDesktopInteractive — Mantén los clics al desconectar RDP

<a id="languages"></a>

<details>
<summary>Languages (16)</summary>

[English](../../README.md) · [简体中文](README.zh-CN.md) · [繁體中文](README.zh-TW.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Español](README.es.md) · [Português (Brasil)](README.pt-BR.md) · [Français](README.fr.md) · [Deutsch](README.de.md) · [Italiano](README.it.md) · [Русский](README.ru.md) · [Türkçe](README.tr.md) · [Tiếng Việt](README.vi.md) · [Bahasa Indonesia](README.id.md) · [हिन्दी](README.hi.md) · [العربية](README.ar.md)

</details>

Para agentes y pruebas UI en un escritorio Windows existente: Windows App es el cliente; Microsoft Dev Box puede ser el host, al igual que otro equipo Windows con RDP.

<img src="../../assets/keep-desktop-interactive.png" width="320" alt="Ilustración conceptual: conserva clics y escritura tras desconectar; deja de vigilar la ventana remota al minimizarla con un cliente compatible probado; reutiliza el escritorio donde ya has iniciado sesión sin guardar contraseñas. El traspaso a la consola lo deja desbloqueado.">

Ilustración conceptual con etiquetas inglesas, no una prueba.

- **Conserva clics, escritura y capturas.**
- **Deja de vigilar la conexión.**
- **Reutiliza el escritorio donde ya has iniciado sesión y las apps abiertas, sin guardar contraseñas.**

> **El traspaso deja el escritorio remoto desbloqueado.** Quien pueda operar la consola física o interactiva de la VM puede usar la sesión sin iniciar sesión en Windows. No uses un PC compartido accesible ni una consola no fiable. No automatiza una pantalla bloqueada ni elude políticas. [Configuración y riesgos de acceso](../configuration.md).

Ambos equipos deben usar Windows. El host debe estar conectado a su sesión, desbloqueado y sin suspensión; las políticas deben permitirlo. Necesitas aprobación de administrador en el host, Git, Windows PowerShell 5.1 y VBScript.

El diagnóstico instalado intenta clics, escritura y captura unos 10 segundos después de cada desconexión RDP del usuario configurado, también en uso normal, y puede interferir con el agente.

<a id="setup"></a>

## Configura ambos equipos

Clona una copia nueva y fiable en la carpeta privada del usuario actual en ambos equipos, nunca en una carpeta compartida con escritura. Abre `%LOCALAPPDATA%\KeepDesktopInteractiveSource` en el Explorador y haz doble clic en el lanzador correspondiente.

```powershell
git clone https://github.com/yeelam-gordon/KeepDesktopInteractive.git "$env:LOCALAPPDATA\KeepDesktopInteractiveSource"
```

| Host remoto / Cliente local | |
| --- | --- |
| Host remoto | `start-desktop-session-setup.vbs` — aprueba la elevación |
| Cliente local | `set-local-rdp-minimize-rendering.vbs` — cierra completamente Windows App/RDP, vuelve a abrirlo y reconecta |

[resultados de instalación](../configuration.md#quick-setup): Host remoto `%LOCALAPPDATA%\KeepDesktopInteractive\elevation-result.json` → `%ProgramData%\KeepDesktopInteractive\setup-result.json`: `Installed: true`, `Status: Ready`; Cliente local `%LOCALAPPDATA%\KeepDesktopInteractive\local-rdp-minimize-result.json`: `Succeeded: true`.

<a id="proof"></a>

## Comprueba la entrada real

Antes de probar, registra la hora inicial, evita otra automatización UI, guarda el trabajo sensible y aparta ventanas confidenciales; desconectar activa el diagnóstico. Comprueba que la hora de modificación del archivo sea posterior al inicio del test y que los valores `Passed` y `Mode` correspondan a esta prueba; luego realiza una prueba inocua de clic, escritura y captura en tu aplicación con la resolución final de consola. El diagnóstico no demuestra todas las apps.

Desconecta durante 30 segundos y reconecta. En el host, comprueba que `%LOCALAPPDATA%\KeepDesktopInteractive\desktop-proof.json` se haya actualizado en esta prueba, con `Passed: true` y `Mode: AfterDisconnect`.

Minimizar es condicional: sigue por separado la [prueba de 90 segundos / espera de 60 segundos](../configuration.md#verify-on-each-new-machine) para `WhileClientMinimized`. Si falla, deja la ventana visible.

<a id="limits"></a>

- Tras reiniciar, inicia sesión, desbloquea y abre tus apps manualmente; sin inicio automático. El bloqueo remoto, la suspensión y el cierre de sesión pueden detener la automatización de la GUI.
- Compatibilidad según cliente y versión, no certificación universal de Dev Box: [evidencia](../configuration.md#reported-compatibility-evidence).
- Windows Sandbox minimizado con el invitado activo: **NO VALIDADO**; [experimento](../configuration.md#sandbox-minimized-window-experiment), no instrucciones RDP.

## Fallos y reversión

Si el resultado indica un fallo, falta o está desactualizado, revisa `Error`, `Stage` y la instalación; repite el test. [Diagnóstico](../configuration.md#proof-and-setup-troubleshooting) · [Comprobaciones](../configuration.md#configuration-checks)

<a id="undo"></a>

Quitar tareas del host y restaurar el registro del cliente no bloquea la consola. Guarda y termina la automatización; bloquea el host y verifica que exige inicio de sesión, o cierra sesión para terminar las apps.

[Reversión](../configuration.md#undo) · [Guía canónica en inglés](../configuration.md) · [README en inglés](../../README.md) · [Actualizaciones](../configuration.md#updating-the-first-prototype)
