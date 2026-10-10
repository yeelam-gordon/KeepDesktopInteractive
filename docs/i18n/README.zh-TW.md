# KeepDesktopInteractive — RDP 中斷連線後繼續 Windows 介面自動化

[English](../../README.md) · [简体中文](README.zh-CN.md) · [繁體中文](README.zh-TW.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Español](README.es.md) · [Português (Brasil)](README.pt-BR.md) · [Français](README.fr.md) · [Deutsch](README.de.md) · [Italiano](README.it.md) · [Русский](README.ru.md) · [Türkçe](README.tr.md) · [Tiếng Việt](README.vi.md) · [Bahasa Indonesia](README.id.md) · [हिन्दी](README.hi.md) · [العربية](README.ar.md)

> **警告：中斷連線後移交至主控台，會讓遠端 Windows 桌面保持未鎖定。能接觸實體鍵盤或互動式虛擬機器主控台的人，不必登入 Windows 就能使用您的工作階段。不要用於他人可接近的共用電腦。必須信任 Hyper-V 管理員及所有可開啟 VMConnect 的人。雲端 VM 或測試帳戶並非自動安全。遵守組織原則；本工具無法在已鎖定的遠端桌面上執行自動化，也不會繞過鎖定原則。**

RDP 中斷連線後 Windows 介面自動化停止？本工具維持**已登入且未鎖定**的工作階段，讓現有的 computer-use 代理程式或 UI 測試繼續點擊、輸入與擷取畫面。最小化後無法輸入是另一種情況，需要相容的用戶端並另行驗證。本工具不提供代理程式原生整合、不啟動代理程式、不儲存密碼，也不啟用自動登入。

**兩台電腦：**遠端主機是執行自動化的 Windows PC/VM；本機用戶端是執行 RDP/Windows App 的 Windows 電腦。需要 Windows PowerShell 5.1、VBScript，以及用來複製儲存庫的 Git。主機安裝需要系統管理員核准。在兩台電腦上，於目前使用者的私人資料夾取得可信任的新副本；不要使用共用且可寫入的目錄。

```powershell
git clone https://github.com/yeelam-gordon/KeepDesktopInteractive.git "$env:LOCALAPPDATA\KeepDesktopInteractiveSource"
Set-Location "$env:LOCALAPPDATA\KeepDesktopInteractiveSource"
```

在兩台電腦分別開啟複製完成的資料夾，並從該資料夾執行命令。第一個命令在遠端主機執行，核准系統管理員權限提升；第二個命令在本機用戶端執行。

```powershell
wscript.exe .\start-desktop-session-setup.vbs
```

```powershell
wscript.exe .\set-local-rdp-minimize-rendering.vbs
```

完全關閉並重新開啟遠端用戶端，再重新連線。[安裝結果](../configuration.md#quick-setup)：主機應有 `Installed: true`、`Status: Ready`；用戶端應有 `Succeeded: true`。

**首次驗證：**正常中斷 RDP 連線，等待 30 秒再連線；診斷會自動執行。另測最小化：在遠端主機執行下列命令，立即將本機的遠端視窗最小化並保持 90 秒，再還原視窗。探測程式等待 60 秒後才進行實際輸入與畫面擷取。

```powershell
wscript.exe .\test-interactive-desktop-automation.vbs --minimized-test
```

在主機查看最新的 `%LOCALAPPDATA%\KeepDesktopInteractive\desktop-proof.json`。下列是兩種測試各自的預期欄位範例，不是本次實測結果：

```json
{ "Passed": true, "Mode": "AfterDisconnect" }
```

```json
{ "Passed": true, "Mode": "WhileClientMinimized" }
```

最小化測試只有在輸入及擷取畫面期間始終保持最小化，才算有效；主機無法觀察用戶端視窗狀態。記錄與螢幕擷取畫面可能包含附近的桌面內容，請勿公開。[驗證詳情](../configuration.md#verify-on-each-new-machine)。

**限制：**此設定適用於傳統 Remote Desktop Connection；Windows App 的支援取決於版本。維護者回報原始用戶端／主機組合曾在安全強化前通過最小化測試，部署後尚未重新驗證，並非所有用戶端都支援。重新開機後須登入並解除鎖定一次，再啟動應用程式與自動化。無介面桌面不在支援範圍內；遠端鎖定、睡眠、關機及登出仍可能中斷自動化。[完整限制](../configuration.md#requirements-and-limitations)。

`Passed: false`：查看 `Error`、`Stage` 與記錄。證據不存在或過時：檢查安裝結果並重新測試。不支援最小化時，保持視窗可見，或採用另行驗證過的中斷連線流程。[疑難排解](../../README.md#if-the-proof-fails) · [組態檢查](../configuration.md#configuration-checks)。

**復原：**從各自複製完成的資料夾執行。第一個命令移除遠端主機的排程工作；第二個命令在原本的本機電腦，以同一使用者還原用戶端設定。

```powershell
wscript.exe .\start-desktop-session-setup.vbs --uninstall
```

```powershell
wscript.exe .\set-local-rdp-minimize-rendering.vbs --restore
```

保留用戶端的 `%LOCALAPPDATA%\KeepDesktopInteractive\local-rdp-minimize-backup.json`，直到不再需要還原。兩項操作互相獨立，且不刪除診斷證據。[復原說明](../configuration.md#undo) · [英文權威指南](../configuration.md) · [英文 README](../../README.md)。
