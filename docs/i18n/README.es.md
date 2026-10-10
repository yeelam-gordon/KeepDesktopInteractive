# KeepDesktopInteractive — Automatización GUI de Windows tras desconectar RDP

[English](../../README.md) · [简体中文](README.zh-CN.md) · [繁體中文](README.zh-TW.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Español](README.es.md) · [Português (Brasil)](README.pt-BR.md) · [Français](README.fr.md) · [Deutsch](README.de.md) · [Italiano](README.it.md) · [Русский](README.ru.md) · [Türkçe](README.tr.md) · [Tiếng Việt](README.vi.md) · [Bahasa Indonesia](README.id.md) · [हिन्दी](README.hi.md) · [العربية](README.ar.md)

> **Advertencia: el traspaso a la consola deja el escritorio remoto de Windows desbloqueado.** Quien tenga acceso al teclado físico o a la consola interactiva de la VM puede usar tu sesión sin iniciar sesión en Windows. No lo uses en un PC compartido al que otros puedan acercarse. Debes confiar en los administradores de Hyper-V y en quienes puedan abrir VMConnect. Una cuenta de pruebas o una VM en la nube no es automáticamente segura. Respeta las políticas de tu organización: esto no permite automatizar detrás de una pantalla remota bloqueada ni eludir políticas de bloqueo.

¿La automatización GUI de Windows se detiene al desconectar RDP? Conserva una sesión **ya iniciada y desbloqueada** para los clics, la escritura y las capturas de tus agentes computer-use o pruebas UI existentes. La pérdida de entrada al minimizar es un caso separado que exige un cliente compatible y una prueba propia. No hay integración nativa ni arranque de agentes, contraseñas guardadas o inicio automático de sesión.

## Dos equipos, dos configuraciones

El **host remoto** es el PC/VM Windows donde se ejecuta la automatización. El **cliente local** es el PC Windows con RDP/Windows App. Necesitas Windows PowerShell 5.1, VBScript y Git para clonar; la instalación del host requiere aprobación de administrador. En ambos equipos, obtén una copia nueva y fiable en la carpeta privada del usuario actual, nunca en una ubicación compartida con escritura:
```powershell
git clone https://github.com/yeelam-gordon/KeepDesktopInteractive.git "$env:LOCALAPPDATA\KeepDesktopInteractiveSource"
Set-Location "$env:LOCALAPPDATA\KeepDesktopInteractiveSource"
```
Abre la carpeta clonada en cada equipo y ejecuta los comandos desde ella: el primero en el host (aprueba la elevación), el segundo en el cliente local.
```powershell
wscript.exe .\start-desktop-session-setup.vbs
```
```powershell
wscript.exe .\set-local-rdp-minimize-rendering.vbs
```
Cierra completamente el cliente remoto, ábrelo de nuevo y reconecta. Comprueba los [resultados de instalación](../configuration.md#quick-setup): host `Installed: true` y `Status: Ready`; cliente `Succeeded: true`.

## Primera comprobación

**Desconexión:** desconecta RDP normalmente, espera 30 segundos y reconecta. El diagnóstico es automático. **Minimización:** ejecuta lo siguiente en el host y minimiza inmediatamente la ventana remota del cliente durante 90 segundos. Luego restáurala. La prueba espera 60 segundos antes de enviar entrada real y capturar la pantalla.
```powershell
wscript.exe .\test-interactive-desktop-automation.vbs --minimized-test
```
Consulta el resultado nuevo en `%LOCALAPPDATA%\KeepDesktopInteractive\desktop-proof.json` del host. Estos campos ilustran el éxito esperado según la prueba; no son resultados medidos aquí:
```json
{ "Passed": true, "Mode": "AfterDisconnect" }
```
```json
{ "Passed": true, "Mode": "WhileClientMinimized" }
```
El éxito minimizado solo cuenta si mantuviste la ventana minimizada durante la entrada y captura; el host no observa ese estado. Mantén privados los registros y capturas, que pueden incluir otras zonas visibles del escritorio. [Detalles](../configuration.md#verify-on-each-new-machine).

## Límites, fallos y reversión

El ajuste está documentado para Remote Desktop Connection clásico; Windows App depende de su versión. Una prueba no demuestra compatibilidad universal. El par original pasó la prueba minimizada antes del endurecimiento, pero no se ha vuelto a comprobar tras el despliegue. Después de reiniciar, inicia sesión, desbloquea una vez y vuelve a arrancar aplicaciones y automatización. No cubre escritorios sin interfaz; bloquear el host, suspenderlo, apagarlo o cerrar sesión puede detener la automatización. [Límites completos](../configuration.md#requirements-and-limitations).

Con `Passed: false`, lee `Error`, `Stage` y los registros. Si falta la prueba o está anticuada, revisa la instalación y repítela. Si el cliente no admite minimización, deja la ventana visible o usa el flujo de desconexión verificado por separado. [Diagnóstico](../../README.md#if-the-proof-fails) · [Comprobaciones](../configuration.md#configuration-checks).

Desde las carpetas clonadas respectivas, desinstala en el host y restaura en el mismo cliente y usuario:
```powershell
wscript.exe .\start-desktop-session-setup.vbs --uninstall
```
```powershell
wscript.exe .\set-local-rdp-minimize-rendering.vbs --restore
```
Conserva `%LOCALAPPDATA%\KeepDesktopInteractive\local-rdp-minimize-backup.json` del cliente hasta que ya no necesites restaurar. Son operaciones independientes y no borran las pruebas. [Reversión](../configuration.md#undo) · [Guía canónica en inglés](../configuration.md) · [README en inglés](../../README.md).
