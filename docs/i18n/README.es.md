# KeepDesktopInteractive — Mantén los clics al desconectar RDP

<a id="languages"></a>

<details>
<summary>Languages / 语言 / 言語 / اللغات (16)</summary>

[English](../../README.md) · [简体中文](README.zh-CN.md) · [繁體中文](README.zh-TW.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Español](README.es.md) · [Português (Brasil)](README.pt-BR.md) · [Français](README.fr.md) · [Deutsch](README.de.md) · [Italiano](README.it.md) · [Русский](README.ru.md) · [Türkçe](README.tr.md) · [Tiếng Việt](README.vi.md) · [Bahasa Indonesia](README.id.md) · [हिन्दी](README.hi.md) · [العربية](README.ar.md)

</details>

Windows App como cliente, Microsoft Dev Box como host u otro entorno Windows RDP: conserva clics, escritura y capturas del agente computer-use tras detectar la desconexión; deja de vigilar la ventana conectada (minimizar exige renderizado compatible verificado); reutiliza tu sesión iniciada sin guardar contraseñas ni activar el inicio automático.

La consola queda desbloqueada; respeta las políticas. Minimización de Windows Sandbox: no validada.

<img src="../../assets/keep-desktop-interactive.png" width="700" alt="Antes y despu&#233;s de desconectar RDP o minimizar: las aplicaciones siguen abiertas, pero pueden fallar los clics, la escritura y las capturas; el traspaso a la consola y un cliente compatible ayudan.">

- **Mantén la entrada del agente tras desconectar:** conserva clics, escritura y capturas en el escritorio existente cuando Windows detecta la desconexión RDP; detectar la pérdida de red puede tardar.
- **Deja de vigilar la ventana conectada:** puedes apartarte de la ventana remota; minimizar exige renderizado compatible y una prueba independiente de entrada satisfactoria en tu entorno. El cliente debe seguir dibujando el escritorio remoto con la ventana minimizada; verifica clics, escritura y capturas por separado.
- **Reutiliza el trabajo ya iniciado:** conserva la sesión y las aplicaciones abiertas sin guardar contraseñas ni activar el inicio automático; no inicia sesión por ti tras reiniciar.

Concepto con etiquetas inglesas, no prueba en vivo. Compatibilidad del cliente y bloqueo local con portátil sin suspensión son condicionales.

> **El traspaso deja el escritorio remoto desbloqueado.** Quien pueda operar la consola física o interactiva de la VM puede usar la sesión sin iniciar sesión en Windows. No uses un PC compartido accesible ni una consola no fiable. No automatiza una pantalla bloqueada ni elude políticas. [Configuración y riesgos de acceso](../configuration.md).

Solo donde las políticas permitan configurar el traspaso RDP/consola; verifica tu entorno, sin certificación universal de Dev Box.

[Configuración y riesgos de acceso](#setup) → [Verificar entrada real](#proof) · [Límites](#limits) · [Revertir](#undo) · Minimización de Windows Sandbox: aún no validada.

**[Windows Sandbox](https://learn.microsoft.com/en-us/windows/security/application-security/application-isolation/windows-sandbox/) — ventana minimizada; candidato NO VALIDADO:** Cuando la ventana de Windows Sandbox en el host está minimizada y el invitado y sus aplicaciones siguen funcionando, ¿continúan los clics, la escritura y las capturas? Instalación y continuidad no validadas: esta herramienta puede funcionar o no con el renderizado del cliente o traspaso del invitado; prueba por separado, no es una solución ya comprobada.

## Windows App / RDP

El diagnóstico instalado intenta clics, escritura y captura unos 10 segundos después de cada desconexión RDP del usuario configurado, también en uso normal, y puede interferir con el agente. No hay opción documentada del lanzador para desactivar solo el diagnóstico; desinstalar el host quita también el traspaso.

Ruta Windows App/RDP: desconexión = traspaso del host; minimización = renderizado compatible más configuración del host. Conserva la configuración probada de dos equipos y verifica cada modo. Sin integración o arranque de agentes, contraseñas guardadas ni inicio automático. [→](../configuration.md#mode-choice)

El mantenedor informó que la entrada funcionó con la pantalla local bloqueada solo en el par probado, con el portátil sin suspensión y el cliente configurado; no se bloqueó el escritorio remoto. Cerrar la tapa o perder la red requiere que Windows detecte la desconexión.

## Windows Sandbox — UNVALIDATED

Sandbox es un experimento propuesto: si no puedes establecer un método autorizado de instalación/prueba, detente. Registra clics, escritura y captura sin datos sensibles con la ventana visible; minimiza un intervalo registrado mientras invitado y apps siguen activos, repite entrada/captura nueva y restaura para revisar. No validado; si falla, mantén visible la ventana. Las instrucciones RDP de dos equipos, desconexión y cerrar/reabrir no son un procedimiento Sandbox. [→](../configuration.md#sandbox-minimized-window-experiment)

<a id="setup"></a>

Antes de instalar: host encendido, sin suspensión y desbloqueado, con permiso según las políticas. Requisitos de Windows, administrador, Git, PowerShell 5.1 y VBScript abajo.

## Dos equipos, dos configuraciones

El **host remoto** es el PC/VM Windows donde se ejecuta la automatización. El **cliente local** es el PC Windows con RDP/Windows App. Necesitas Windows PowerShell 5.1, VBScript y Git para clonar; la instalación del host requiere aprobación de administrador. En ambos equipos, obtén una copia nueva y fiable en la carpeta privada del usuario actual, nunca en una ubicación compartida con escritura:
<details>
<summary>Windows App / Microsoft Dev Box / Hyper-V</summary>

> **Advertencia: el traspaso a la consola deja el escritorio remoto de Windows desbloqueado.** Quien tenga acceso al teclado físico o a la consola interactiva de la VM puede usar tu sesión sin iniciar sesión en Windows. No lo uses en un PC compartido al que otros puedan acercarse. Debes confiar en los administradores de Hyper-V y en quienes puedan abrir VMConnect. Windows App es el cliente de conexión; Microsoft Dev Box es la estación de trabajo cloud administrada. El riesgo es que otra persona pueda operar la consola desbloqueada, no una inseguridad inherente del producto. Un host administrado para un desarrollador sin acceso interactivo a la consola por personas no fiables tiene menos riesgo que un PC compartido. No supongas que Microsoft Dev Box ofrece ese acceso. Respeta las políticas de tu organización: esto no permite automatizar detrás de una pantalla remota bloqueada ni eludir políticas de bloqueo.

</details>


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

<a id="proof"></a>

- Tras detectar la desconexión RDP, Windows permite el traspaso de la sesión existente a la consola para mantener la entrada GUI.
- El ajuste de renderizado ayuda a clientes compatibles al minimizar; necesita una prueba separada.
- Comprueba clics, escritura y capturas reales con resultados privados del modo correcto, no solo aplicaciones abiertas.

Antes de probar, registra la hora inicial, evita otra automatización UI, guarda el trabajo sensible y aparta ventanas confidenciales; desconectar activa el diagnóstico. Exige modificación del archivo posterior al inicio y Passed/Mode correctos; luego prueba clic/escritura/captura en una app inofensiva con la resolución final de consola. El diagnóstico no demuestra todas las apps. [→](../configuration.md#reported-compatibility-evidence)

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

<a id="limits"></a>

## Límites, fallos y reversión

El ajuste está documentado para Remote Desktop Connection clásico; Windows App depende de su versión. Una prueba no demuestra compatibilidad universal. El par original pasó la prueba minimizada antes del endurecimiento, pero no se ha vuelto a comprobar tras el despliegue. Después de reiniciar, inicia sesión, desbloquea una vez y vuelve a arrancar aplicaciones y automatización. No cubre escritorios sin interfaz; bloquear el host, suspenderlo, apagarlo o cerrar sesión puede detener la automatización. [Límites completos](../configuration.md#requirements-and-limitations).

Con `Passed: false`, lee `Error`, `Stage` y los registros. Si falta la prueba o está anticuada, revisa la instalación y repítela. Si el cliente no admite minimización, deja la ventana visible o usa el flujo de desconexión verificado por separado. [Diagnóstico](../../README.md#if-the-proof-fails) · [Comprobaciones](../configuration.md#configuration-checks).

<a id="undo"></a>

Quitar tareas/restaurar el cliente no bloquea automáticamente la consola actual. Guarda y termina la automatización; bloquea manualmente el host y verifica que exige inicio de sesión, o cierra sesión intencionalmente para terminar apps. Bloquear detiene automatización GUI.

Desde las carpetas clonadas respectivas, desinstala en el host y restaura en el mismo cliente y usuario:
```powershell
wscript.exe .\start-desktop-session-setup.vbs --uninstall
```
```powershell
wscript.exe .\set-local-rdp-minimize-rendering.vbs --restore
```
Conserva `%LOCALAPPDATA%\KeepDesktopInteractive\local-rdp-minimize-backup.json` del cliente hasta que ya no necesites restaurar. Son operaciones independientes y no borran las pruebas. [Reversión](../configuration.md#undo) · [Guía canónica en inglés](../configuration.md) · [README en inglés](../../README.md).

Para actualizar usa un destino privado nuevo, no una carpeta existente no vacía; conserva la copia anterior y respaldos, reinstala y verifica. [→](../configuration.md#updating-the-first-prototype)
