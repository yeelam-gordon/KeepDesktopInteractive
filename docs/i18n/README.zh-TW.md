# KeepDesktopInteractive — 遠端連線中斷後繼續 GUI 操作

<a id="languages"></a>

<details>
<summary>Languages (16)</summary>

[English](../../README.md) · [简体中文](README.zh-CN.md) · [繁體中文](README.zh-TW.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Español](README.es.md) · [Português (Brasil)](README.pt-BR.md) · [Français](README.fr.md) · [Deutsch](README.de.md) · [Italiano](README.it.md) · [Русский](README.ru.md) · [Türkçe](README.tr.md) · [Tiếng Việt](README.vi.md) · [Bahasa Indonesia](README.id.md) · [हिन्दी](README.hi.md) · [العربية](README.ar.md)

</details>

保留既有 Windows 桌面的代理程式與 UI 測試操作能力：Windows App 是用戶端，Microsoft Dev Box 可作主機，也適用於其他 Windows RDP 主機。

<img src="../../assets/keep-desktop-interactive.png" width="320" alt="概念圖：中斷後繼續點擊與輸入；最小化時，使用經測試的相容用戶端便不必一直盯著遠端視窗；重用已登入的桌面，不儲存密碼。主控台移交後桌面仍未鎖定。">

概念圖，英文標籤，非實測。

- **繼續點擊、輸入、擷取畫面。**
- **不必守著連線視窗。**
- **重用已登入的桌面與開啟的應用程式，不儲存密碼。**

> **中斷移交會留下未鎖定的遠端桌面。** 能操作實體或互動式 VM 主控台的人不必登入 Windows 就能使用工作階段。不要用於他人可接近的共用電腦或不可信主控台；無法在鎖定畫面上自動化，也不繞過原則。 [設定與存取風險](../configuration.md).

兩台電腦均須執行 Windows；主機已登入、未鎖定且不睡眠，原則允許此用途。需要主機系統管理員核准、Git、Windows PowerShell 5.1 與 VBScript。

已安裝診斷會在設定使用者每次 RDP 中斷後約 10 秒嘗試點擊、輸入與截圖，包括日常中斷，可能干擾代理程式。

<a id="setup"></a>

## 設定兩台電腦

在兩台電腦分別複製到目前使用者的私人目錄，勿用共用可寫入目錄。接著在檔案總管開啟 `%LOCALAPPDATA%\KeepDesktopInteractiveSource`，按兩下各自啟動器。

```powershell
git clone https://github.com/yeelam-gordon/KeepDesktopInteractive.git "$env:LOCALAPPDATA\KeepDesktopInteractiveSource"
```

| 遠端主機 / 本機用戶端 | |
| --- | --- |
| 遠端主機 | `start-desktop-session-setup.vbs` — 核准權限提升 |
| 本機用戶端 | `set-local-rdp-minimize-rendering.vbs` — 完全關閉並重開 Windows App/RDP，再連線 |

[安裝結果](../configuration.md#quick-setup): 遠端主機 `%LOCALAPPDATA%\KeepDesktopInteractive\elevation-result.json` → `%ProgramData%\KeepDesktopInteractive\setup-result.json`: `Installed: true`, `Status: Ready`; 本機用戶端 `%LOCALAPPDATA%\KeepDesktopInteractive\local-rdp-minimize-result.json`: `Succeeded: true`.

<a id="proof"></a>

## 驗證實際操作

測試前記錄開始時間，確保沒有其他 UI 自動化操作桌面，儲存敏感工作並移開機密視窗；中斷會自動觸發探測。成功須檔案修改時間晚於本次開始時間且 Passed/Mode 正確，再依最終主控台解析度於無害測試應用程式中點擊、輸入、截圖；探測通過不代表所有應用程式正常。

中斷 30 秒再連線。在主機查看 `%LOCALAPPDATA%\KeepDesktopInteractive\desktop-proof.json`，須為本次更新，且 `Passed: true`、`Mode: AfterDisconnect`。

最小化有條件：另依[90 秒測試／60 秒探測延遲](../configuration.md#verify-on-each-new-machine)驗證 `WhileClientMinimized`；失敗時保持視窗可見。

<a id="limits"></a>

- 重啟後須自行登入、解鎖並重啟應用程式；無自動登入。遠端鎖定、睡眠、登出仍會中斷。
- 相容性依用戶端及版本而異，不是通用 Dev Box 認證：[證據](../configuration.md#reported-compatibility-evidence)。
- Windows Sandbox 最小化且客體仍執行：**尚未驗證**；見[實驗](../configuration.md#sandbox-minimized-window-experiment)，不是 RDP 安裝步驟。

## 失敗與復原

結果失敗、缺失或過時：查看 `Error`、`Stage`，檢查安裝結果再測試。 [疑難排解](../configuration.md#proof-and-setup-troubleshooting) · [組態檢查](../configuration.md#configuration-checks)

<a id="undo"></a>

移除主機上的排程工作與還原用戶端登錄值不會鎖定現有主控台。儲存並結束自動化後，手動鎖定主機並確認須登入，或有意登出以結束應用程式。

[復原說明](../configuration.md#undo) · [英文權威指南](../configuration.md) · [英文 README](../../README.md) · [更新](../configuration.md#updating-the-first-prototype)
