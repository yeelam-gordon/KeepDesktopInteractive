# KeepDesktopInteractive — Windows GUI 断开后继续操作

<a id="languages"></a>

<details>
<summary>Languages / 语言 / 言語 / اللغات (16)</summary>

[English](../../README.md) · [简体中文](README.zh-CN.md) · [繁體中文](README.zh-TW.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Español](README.es.md) · [Português (Brasil)](README.pt-BR.md) · [Français](README.fr.md) · [Deutsch](README.de.md) · [Italiano](README.it.md) · [Русский](README.ru.md) · [Türkçe](README.tr.md) · [Tiếng Việt](README.vi.md) · [Bahasa Indonesia](README.id.md) · [हिन्दी](README.hi.md) · [العربية](README.ar.md)

</details>

Windows App 客户端、Microsoft Dev Box 主机或其他 Windows RDP 环境：让 computer-use 智能体在检测到断开后继续点击、输入、截图；不再盯着连接窗口（最小化须验证兼容渲染）；复用已登录会话，无需保存密码或自动登录。

控制台保持未锁定；遵守策略。Windows Sandbox 最小化尚未验证。

<img src="../../assets/keep-desktop-interactive.png" width="700" alt="RDP 断开或窗口最小化前后：应用仍在运行，但点击、输入和截图可能停止；控制台移交与兼容客户端设置有助于维持操作。">

- **断开后继续智能体操作：** Windows 检测到 RDP 断开后，保留现有桌面的点击、输入和截图能力；网络断开检测可能延迟。
- **不再守着连接窗口：** 可以离开远程窗口；最小化使用须有兼容客户端渲染，并在你的环境单独通过实际输入测试。 客户端须在窗口最小化时继续绘制远程画面，并另行验证点击、输入和截图。
- **复用已登录的会话：** 保留当前用户会话和已打开应用，不保存密码、不启用自动登录；重启后不会替你登录。

概念图，英文标签，并非实测结果。支持因客户端版本而异；本地笔记本屏幕锁定后能否继续远程操作，须在笔记本不睡眠且完成客户端设置时验证，这不表示远程桌面可锁定。

> **断开移交会留下未锁定的远程桌面。** 能操作实体或交互式 VM 控制台的人无需登录 Windows 就能使用会话。不要用于他人可接触的共享电脑或不可信控制台；不支持锁屏后自动化或策略绕过。 [设置与访问风险](../configuration.md).

仅适用于策略允许配置 RDP/控制台移交的环境，须自行验证，并非所有 Dev Box 配置都受支持。

[设置与访问风险](#setup) → [验证实际输入](#proof) · [限制](#limits) · [撤销](#undo) · Windows Sandbox 最小化：尚未验证。

**[Windows Sandbox](https://learn.microsoft.com/en-us/windows/security/application-security/application-isolation/windows-sandbox/) — 窗口最小化；尚未验证的候选场景:** 当主机上的 Windows Sandbox 窗口最小化、来宾及应用仍运行时，能否继续点击、输入和截图？部署及输入连续性尚未验证；本工具可能适用，也可能不适用于 Sandbox 的客户端渲染或来宾移交，须单独测试，并非已有解决方案。

## Windows App / RDP

已安装的诊断会在配置用户每次 RDP 断开后约 10 秒尝试点击、输入及截图，包括日常断开，可能干扰智能体；未提供有文档说明的、仅停用诊断而保留移交的启动选项，卸载主机也移除移交。

Windows App/RDP 路线：断开靠主机移交，最小化靠兼容客户端渲染及主机设置；保留下面已测试的双电脑设置，两种情况分别验证。本工具不原生集成或启动智能体，不保存密码或自动登录。 [→](../configuration.md#mode-choice)

维护者报告的本地屏幕锁定通过仅限笔记本唤醒、已设置客户端的测试组合，不是远程锁屏；合盖或断网仅在 Windows 检测到断开后触发移交。

## Windows Sandbox — UNVALIDATED

Sandbox 仅为拟议实验：先确认获准且可行的部署/测试方法，否则停止；用无敏感内容做可见窗口点击、输入、截图基线，再最小化一段记录的时间，确认来宾及应用仍运行，重复实际输入及新截图，恢复窗口检查。未验证，失败时保持窗口可见；下面的 RDP 双电脑、断开及关闭/重开客户端说明不适用。 [→](../configuration.md#sandbox-minimized-window-experiment)

<a id="setup"></a>

安装前：主机须保持开机、唤醒及未锁定，组织策略允许此用途。其余 Windows、管理员批准、Git、PowerShell 5.1 和 VBScript 要求见下方。

## 两台电脑，分别设置

**远程主机**运行自动化；**本地客户端**运行 RDP/Windows App。两者都是 Windows PC/VM，需要 Windows PowerShell 5.1、VBScript 和用于克隆的 Git。主机安装需要管理员批准。两台电脑都在当前用户的私有目录获取可信的新副本，不使用共享可写目录：
<details>
<summary>Windows App / Microsoft Dev Box / Hyper-V</summary>

> **警告：断开后的控制台移交会让远程 Windows 桌面保持未锁定。** 能接触实体键盘或交互式 VM 控制台的人，无需登录 Windows 就能使用你的会话。不要用于他人可接触的共享电脑；Hyper-V 管理员和能打开 VMConnect 的人必须可信。Windows App 是连接客户端，Microsoft Dev Box 是托管云工作站。风险来自他人能操作未锁定的控制台，并非产品本身不安全。若单一开发者的托管主机没有不可信人员的交互控制台访问路径，其风险低于共用实体电脑；不要假定 Microsoft Dev Box 提供这种路径。遵守组织策略；本工具无法在已锁定的远程桌面上执行自动化，也不能绕过锁屏策略。

</details>


```powershell
git clone https://github.com/yeelam-gordon/KeepDesktopInteractive.git "$env:LOCALAPPDATA\KeepDesktopInteractiveSource"
Set-Location "$env:LOCALAPPDATA\KeepDesktopInteractiveSource"
```
分别打开克隆目录并从该目录执行。远程主机运行第一条并批准提权，本地客户端运行第二条：
```powershell
wscript.exe .\start-desktop-session-setup.vbs
```
```powershell
wscript.exe .\set-local-rdp-minimize-rendering.vbs
```
完全关闭并重新打开远程客户端，再连接。[安装结果](../configuration.md#quick-setup)：主机 `Installed: true`、`Status: Ready`；客户端 `Succeeded: true`。

## 首次验证

<a id="proof"></a>

- Windows 检测到 RDP 断开后，将现有会话移交控制台，帮助维持 GUI 操作。
- 兼容客户端可通过渲染设置改善最小化输入，须单独验证。
- 查看与本次测试类型对应的诊断结果，确认真实点击、输入和截图正常；不要只看应用仍运行。诊断记录请保持私密。

测试前记录开始时间，确保无其他 UI 自动化操作桌面，保存敏感工作并移开机密窗口；断开会自动触发探测。成功须文件修改时间晚于本次开始时间、Passed 和 Mode 正确，再用最终控制台分辨率在无害测试应用中点击、输入、截图；探测通过不代表所有应用正常。 [→](../configuration.md#reported-compatibility-evidence)

**断开：** 正常断开 RDP，等待 30 秒后重连；诊断自动运行。**最小化：** 在远程主机运行下面命令，立即将本地远程窗口最小化并保持 90 秒，再恢复窗口。探针等待 60 秒后才进行实际输入和截图。
```powershell
wscript.exe .\test-interactive-desktop-automation.vbs --minimized-test
```
在主机查看新的 `%LOCALAPPDATA%\KeepDesktopInteractive\desktop-proof.json`。对应测试应包含以下字段（仅预期示例，不是本次实测）：
```json
{ "Passed": true, "Mode": "AfterDisconnect" }
```
```json
{ "Passed": true, "Mode": "WhileClientMinimized" }
```
最小化成功只在输入及截图时始终保持最小化才有效；主机无法观察客户端状态。日志和截图可能包含附近桌面内容，请保持私密。[验证详情](../configuration.md#verify-on-each-new-machine)。

<a id="limits"></a>

## 限制、失败与撤销

经典 Remote Desktop Connection 有相关渲染设置；Windows App 是否支持取决于版本。一次通过不能证明所有客户端都支持。加固前的原始组合曾通过最小化测试，部署后尚未复测。重启后必须登录并解锁一次，再启动应用和自动化；不支持无头桌面。远程锁屏、睡眠、关机和注销仍会中断自动化。[完整限制](../configuration.md#requirements-and-limitations)。

`Passed: false`：查看 `Error`、`Stage` 和日志；证据缺失或陈旧：检查安装结果并重新测试。客户端不支持最小化：保持窗口可见，或使用单独验证过的断开流程。[排查](../../README.md#if-the-proof-fails) · [配置检查](../configuration.md#configuration-checks)。

<a id="undo"></a>

卸载主机任务、恢复客户端设置不会自动锁定现有控制台；保存并结束自动化后手动锁定主机，确认控制台需要登录，或有意注销以结束应用。锁定会停止 GUI 自动化。

从各自克隆目录执行：远程主机卸载，本地客户端以原用户恢复。
```powershell
wscript.exe .\start-desktop-session-setup.vbs --uninstall
```
```powershell
wscript.exe .\set-local-rdp-minimize-rendering.vbs --restore
```
保留客户端的 `%LOCALAPPDATA%\KeepDesktopInteractive\local-rdp-minimize-backup.json`，直到不再需要恢复。两项操作相互独立，不删除诊断证据。[撤销](../configuration.md#undo) · [英文权威指南](../configuration.md) · [英文 README](../../README.md)。

更新时使用新的私有目录，不要向已有非空目录重复克隆；保留旧副本及备份，重新设置并验证。 [→](../configuration.md#updating-the-first-prototype)
