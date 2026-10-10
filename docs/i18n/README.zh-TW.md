# KeepDesktopInteractive — Windows GUI 中斷後繼續操作

<a id="languages"></a>

<details>
<summary>Languages / 语言 / 言語 / اللغات (16)</summary>

[English](../../README.md) · [简体中文](README.zh-CN.md) · [繁體中文](README.zh-TW.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Español](README.es.md) · [Português (Brasil)](README.pt-BR.md) · [Français](README.fr.md) · [Deutsch](README.de.md) · [Italiano](README.it.md) · [Русский](README.ru.md) · [Türkçe](README.tr.md) · [Tiếng Việt](README.vi.md) · [Bahasa Indonesia](README.id.md) · [हिन्दी](README.hi.md) · [العربية](README.ar.md)

</details>

Windows App 用戶端、Microsoft Dev Box 主機或其他 Windows RDP 環境：讓 computer-use 代理程式在偵測到中斷後繼續點擊、輸入、擷取畫面；不必盯著連線視窗（最小化須驗證相容繪製）；重用已登入工作階段，不儲存密碼或自動登入。

主控台保持未鎖定；遵守原則。Windows Sandbox 最小化尚未驗證。

<img src="../../assets/keep-desktop-interactive.png" width="700" alt="RDP 中斷連線或視窗最小化前後：應用程式仍執行，但點擊、輸入及擷取畫面可能停止；主控台移交與相容用戶端設定有助於維持操作。">

- **中斷後繼續代理程式操作：** Windows 偵測到 RDP 中斷後，維持現有桌面的點擊、輸入與畫面擷取；網路中斷偵測可能延遲。
- **不必守著連線視窗：** 可以離開遠端視窗；最小化使用須有相容用戶端繪製，並在你的環境另行通過實際輸入測試。 用戶端須在視窗最小化時持續繪製遠端畫面，並另行驗證點擊、輸入與擷取畫面。
- **重用已登入的工作階段：** 保留目前使用者工作階段與已開啟應用程式，不儲存密碼、不啟用自動登入；重新啟動後不會替你登入。

概念圖使用英文標籤，並非實測結果。支援依用戶端而異；本機筆電鎖定螢幕後能否繼續遠端操作，須在筆電不睡眠且完成用戶端設定時驗證，不代表遠端桌面可鎖定。

> **中斷移交會留下未鎖定的遠端桌面。** 能操作實體或互動式 VM 主控台的人不必登入 Windows 就能使用工作階段。不要用於他人可接近的共用電腦或不可信主控台；無法在鎖定畫面上自動化，也不繞過原則。 [設定與存取風險](../configuration.md).

僅適用於原則允許設定 RDP/主控台移交的環境，須自行驗證，並非所有 Dev Box 組態皆受支援。

[設定與存取風險](#setup) → [驗證實際輸入](#proof) · [限制](#limits) · [復原](#undo) · Windows Sandbox 最小化：尚未驗證。

**[Windows Sandbox](https://learn.microsoft.com/en-us/windows/security/application-security/application-isolation/windows-sandbox/) — 視窗最小化；尚未驗證的候選情境:** 當主機上的 Windows Sandbox 視窗最小化、客體與應用程式仍執行時，能否繼續點擊、輸入與擷取畫面？部署及輸入連續性尚未驗證；本工具可能適用，也可能不適用於 Sandbox 的用戶端繪製或客體移交，須另行測試，並非既有解法。

## Windows App / RDP

已安裝診斷會在設定使用者每次 RDP 中斷後約 10 秒嘗試點擊、輸入與截圖，包括日常中斷，可能干擾代理程式；未提供有文件說明、僅停用診斷而保留移交的啟動選項，移除主機也移除移交。

Windows App/RDP 路線：中斷靠主機移交，最小化靠相容用戶端繪製及主機設定；保留下方已測試的雙電腦設定，兩種情況分別驗證。本工具不原生整合或啟動代理程式、不儲存密碼或自動登入。 [→](../configuration.md#mode-choice)

維護者回報的本機螢幕鎖定通過僅限筆電不睡眠、已設定用戶端的測試組合，不是遠端鎖定；闔蓋或斷網須 Windows 偵測到中斷才移交。

## Windows Sandbox — UNVALIDATED

Sandbox 僅為擬議實驗：先確認獲准且可行的部署/測試方法，否則停止；以非敏感內容建立可見視窗點擊、輸入、截圖基準，再最小化一段記錄的時間，確認客體及應用程式仍執行，重做實際輸入及新截圖，還原視窗檢查。尚未驗證，失敗時保持視窗可見；下方 RDP 雙電腦、中斷及關閉/重開用戶端說明不適用。 [→](../configuration.md#sandbox-minimized-window-experiment)

<a id="setup"></a>

安裝前：主機須保持開機、喚醒且未鎖定，組織原則允許此用途。下方列出 Windows、系統管理員核准、Git、PowerShell 5.1 與 VBScript 要求。

## 兩台電腦

遠端主機是執行自動化的 Windows PC/VM；本機用戶端是執行 RDP/Windows App 的 Windows 電腦。需要 Windows PowerShell 5.1、VBScript，以及用來複製儲存庫的 Git。主機安裝需要系統管理員核准。在兩台電腦上，於目前使用者的私人資料夾取得可信任的新副本；不要使用共用且可寫入的目錄。

<details>
<summary>Windows App / Microsoft Dev Box / Hyper-V</summary>

> **Windows App 是連線用戶端，Microsoft Dev Box 是受管理的雲端工作站。風險來自他人能操作未鎖定的主控台，而非產品本身不安全。若單一開發人員的受管理主機沒有不可信人員的互動式主控台存取途徑，風險低於共用實體電腦；不要假設 Microsoft Dev Box 提供此途徑。遵守組織原則；本工具無法在已鎖定的遠端桌面上執行自動化，也不會繞過鎖定原則。**

</details>


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

<a id="proof"></a>

- Windows 偵測到 RDP 中斷後，將現有工作階段移交主控台，協助維持 GUI 操作。
- 相容用戶端可透過繪製設定改善最小化輸入，須另行驗證。
- 查看與本次測試類型相符的診斷結果，確認實際點擊、輸入與畫面擷取正常，不只是應用程式仍執行。請勿公開診斷記錄。

測試前記錄開始時間，確保沒有其他 UI 自動化操作桌面，儲存敏感工作並移開機密視窗；中斷會自動觸發探測。成功須檔案修改時間晚於本次開始時間且 Passed/Mode 正確，再依最終主控台解析度於無害測試應用程式中點擊、輸入、截圖；探測通過不代表所有應用程式正常。 [→](../configuration.md#reported-compatibility-evidence)

## 首次驗證

正常中斷 RDP 連線，等待 30 秒再連線；診斷會自動執行。另測最小化：在遠端主機執行下列命令，立即將本機的遠端視窗最小化並保持 90 秒，再還原視窗。探測程式等待 60 秒後才進行實際輸入與畫面擷取。

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

<a id="limits"></a>

## 限制

此設定適用於傳統 Remote Desktop Connection；Windows App 的支援取決於版本。維護者回報原始用戶端／主機組合曾在安全強化前通過最小化測試，部署後尚未重新驗證，並非所有用戶端都支援。重新開機後須登入並解除鎖定一次，再啟動應用程式與自動化。無介面桌面不在支援範圍內；遠端鎖定、睡眠、關機及登出仍可能中斷自動化。[完整限制](../configuration.md#requirements-and-limitations)。

`Passed: false`：查看 `Error`、`Stage` 與記錄。證據不存在或過時：檢查安裝結果並重新測試。不支援最小化時，保持視窗可見，或採用另行驗證過的中斷連線流程。[疑難排解](../../README.md#if-the-proof-fails) · [組態檢查](../configuration.md#configuration-checks)。

<a id="undo"></a>

移除主機工作、還原用戶端設定不會自動鎖定現有主控台；儲存並結束自動化後手動鎖定主機，確認主控台須登入，或有意登出以結束應用程式。鎖定會停止 GUI 自動化。

## 復原

從各自複製完成的資料夾執行。第一個命令移除遠端主機的排程工作；第二個命令在原本的本機電腦，以同一使用者還原用戶端設定。

```powershell
wscript.exe .\start-desktop-session-setup.vbs --uninstall
```

```powershell
wscript.exe .\set-local-rdp-minimize-rendering.vbs --restore
```

保留用戶端的 `%LOCALAPPDATA%\KeepDesktopInteractive\local-rdp-minimize-backup.json`，直到不再需要還原。兩項操作互相獨立，且不刪除診斷證據。[復原說明](../configuration.md#undo) · [英文權威指南](../configuration.md) · [英文 README](../../README.md)。

更新使用新的私人目錄，勿重複複製到既有非空目錄；保留舊副本與備份，重新設定並驗證。 [→](../configuration.md#updating-the-first-prototype)
