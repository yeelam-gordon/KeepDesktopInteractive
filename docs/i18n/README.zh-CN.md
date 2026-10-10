# KeepDesktopInteractive — RDP 断开后继续 Windows 界面自动化

[English](../../README.md) · [简体中文](README.zh-CN.md) · [繁體中文](README.zh-TW.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Español](README.es.md) · [Português (Brasil)](README.pt-BR.md) · [Français](README.fr.md) · [Deutsch](README.de.md) · [Italiano](README.it.md) · [Русский](README.ru.md) · [Türkçe](README.tr.md) · [Tiếng Việt](README.vi.md) · [Bahasa Indonesia](README.id.md) · [हिन्दी](README.hi.md) · [العربية](README.ar.md)

> **警告：断开后的控制台移交会让远程 Windows 桌面保持未锁定。** 能接触实体键盘或交互式 VM 控制台的人，无需登录 Windows 就能使用你的会话。不要用于他人可接触的共享电脑；Hyper-V 管理员和能打开 VMConnect 的人必须可信。测试账号或云端 VM 并不自动安全。遵守组织策略；本工具无法在已锁定的远程桌面上执行自动化，也不能绕过锁屏策略。

RDP 断开后自动化停止？本工具保留**已经登录且未锁定**的 Windows 会话，供现有 computer-use 智能体或 UI 测试继续点击、输入和截图。远程桌面最小化后无法点击输入是另一个问题，需要兼容的客户端及单独验证。不提供智能体原生集成，不启动智能体，不保存密码或启用自动登录。

## 两台电脑，分别设置

**远程主机**运行自动化；**本地客户端**运行 RDP/Windows App。两者都是 Windows PC/VM，需要 Windows PowerShell 5.1、VBScript 和用于克隆的 Git。主机安装需要管理员批准。两台电脑都在当前用户的私有目录获取可信的新副本，不使用共享可写目录：
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

## 限制、失败与撤销

经典 Remote Desktop Connection 有相关渲染设置；Windows App 是否支持取决于版本。一次通过不能证明所有客户端都支持。加固前的原始组合曾通过最小化测试，部署后尚未复测。重启后必须登录并解锁一次，再启动应用和自动化；不支持无头桌面。远程锁屏、睡眠、关机和注销仍会中断自动化。[完整限制](../configuration.md#requirements-and-limitations)。

`Passed: false`：查看 `Error`、`Stage` 和日志；证据缺失或陈旧：检查安装结果并重新测试。客户端不支持最小化：保持窗口可见，或使用单独验证过的断开流程。[排查](../../README.md#if-the-proof-fails) · [配置检查](../configuration.md#configuration-checks)。

从各自克隆目录执行：远程主机卸载，本地客户端以原用户恢复。
```powershell
wscript.exe .\start-desktop-session-setup.vbs --uninstall
```
```powershell
wscript.exe .\set-local-rdp-minimize-rendering.vbs --restore
```
保留客户端的 `%LOCALAPPDATA%\KeepDesktopInteractive\local-rdp-minimize-backup.json`，直到不再需要恢复。两项操作相互独立，不删除诊断证据。[撤销](../configuration.md#undo) · [英文权威指南](../configuration.md) · [英文 README](../../README.md)。
