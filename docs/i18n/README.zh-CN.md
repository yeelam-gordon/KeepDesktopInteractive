# KeepDesktopInteractive — 远程连接断开后继续 GUI 操作

<a id="languages"></a>

<details>
<summary>Languages (16)</summary>

[English](../../README.md) · [简体中文](README.zh-CN.md) · [繁體中文](README.zh-TW.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Español](README.es.md) · [Português (Brasil)](README.pt-BR.md) · [Français](README.fr.md) · [Deutsch](README.de.md) · [Italiano](README.it.md) · [Русский](README.ru.md) · [Türkçe](README.tr.md) · [Tiếng Việt](README.vi.md) · [Bahasa Indonesia](README.id.md) · [हिन्दी](README.hi.md) · [العربية](README.ar.md)

</details>

为已有的 Windows 桌面保留智能体和 UI 测试的操作能力：Windows App 是客户端，Microsoft Dev Box 可作主机，也适用于其他 Windows RDP 主机。

<img src="../../assets/keep-desktop-interactive.png" width="320" alt="概念图：断开后继续点击和输入；最小化时，使用经测试的兼容客户端就不必一直盯着远程窗口；复用已登录的桌面，不保存密码。控制台移交后桌面仍未锁定。">

概念图，英文标签，非实测。

- **继续点击、输入、截图。**
- **不用守着连接窗口。**
- **复用已登录的桌面和打开的应用，不保存密码。**

> **断开移交会留下未锁定的远程桌面。** 能操作实体或交互式 VM 控制台的人无需登录 Windows 就能使用会话。不要用于他人可接触的共享电脑或不可信控制台；不支持锁屏后自动化或策略绕过。 [设置与访问风险](../configuration.md).

两台电脑均须运行 Windows；主机已登录、未锁定且不睡眠，策略允许此用途。需要主机管理员批准、Git、Windows PowerShell 5.1 和 VBScript。

已安装的诊断会在配置用户每次 RDP 断开后约 10 秒尝试点击、输入及截图，包括日常断开，可能干扰智能体。

<a id="setup"></a>

## 设置两台电脑

在两台电脑分别克隆到当前用户的私有目录，勿用共享可写目录。随后在文件资源管理器打开 `%LOCALAPPDATA%\KeepDesktopInteractiveSource`，双击各自启动器。

```powershell
git clone https://github.com/yeelam-gordon/KeepDesktopInteractive.git "$env:LOCALAPPDATA\KeepDesktopInteractiveSource"
```

| 远程主机 / 本地客户端 | |
| --- | --- |
| 远程主机 | `start-desktop-session-setup.vbs` — 批准提权 |
| 本地客户端 | `set-local-rdp-minimize-rendering.vbs` — 完全关闭并重开 Windows App/RDP，再连接 |

[安装结果](../configuration.md#quick-setup): 远程主机 `%LOCALAPPDATA%\KeepDesktopInteractive\elevation-result.json` → `%ProgramData%\KeepDesktopInteractive\setup-result.json`: `Installed: true`, `Status: Ready`; 本地客户端 `%LOCALAPPDATA%\KeepDesktopInteractive\local-rdp-minimize-result.json`: `Succeeded: true`.

<a id="proof"></a>

## 验证实际操作

测试前记录开始时间，确保无其他 UI 自动化操作桌面，保存敏感工作并移开机密窗口；断开会自动触发探测。成功须文件修改时间晚于本次开始时间、Passed 和 Mode 正确，再用最终控制台分辨率在无害测试应用中点击、输入、截图；探测通过不代表所有应用正常。

断开 30 秒再重连。在主机查看 `%LOCALAPPDATA%\KeepDesktopInteractive\desktop-proof.json`，须为本次更新，且 `Passed: true`、`Mode: AfterDisconnect`。

最小化有条件：另按[90 秒测试／60 秒探测延迟](../configuration.md#verify-on-each-new-machine)验证 `WhileClientMinimized`；失败时保持窗口可见。

<a id="limits"></a>

- 重启后须自行登录、解锁并重启应用；无自动登录。远程锁屏、睡眠、注销仍会中断。
- 兼容性因客户端及版本而异，不是通用 Dev Box 认证：[证据](../configuration.md#reported-compatibility-evidence)。
- Windows Sandbox 最小化且来宾仍运行：**尚未验证**；见[实验](../configuration.md#sandbox-minimized-window-experiment)，不是 RDP 安装步骤。

## 失败与撤销

失败、缺失或陈旧结果：查看 `Error`、`Stage`，检查安装结果并重新测试。 [排查](../configuration.md#proof-and-setup-troubleshooting) · [配置检查](../configuration.md#configuration-checks)

<a id="undo"></a>

移除主机任务和恢复客户端注册表不会锁定现有控制台。保存并结束自动化后，手动锁定主机并确认须登录，或有意注销以结束应用。

[撤销](../configuration.md#undo) · [英文权威指南](../configuration.md) · [英文 README](../../README.md) · [更新](../configuration.md#updating-the-first-prototype)
