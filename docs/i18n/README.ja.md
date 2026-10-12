# KeepDesktopInteractive — リモート接続の切断後も GUI 操作を継続

<a id="languages"></a>

<details>
<summary>Languages (16)</summary>

[English](../../README.md) · [简体中文](README.zh-CN.md) · [繁體中文](README.zh-TW.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Español](README.es.md) · [Português (Brasil)](README.pt-BR.md) · [Français](README.fr.md) · [Deutsch](README.de.md) · [Italiano](README.it.md) · [Русский](README.ru.md) · [Türkçe](README.tr.md) · [Tiếng Việt](README.vi.md) · [Bahasa Indonesia](README.id.md) · [हिन्दी](README.hi.md) · [العربية](README.ar.md)

</details>

既存の Windows デスクトップでエージェントや UI テストの操作を維持します。Windows App はクライアント、Microsoft Dev Box はホストの一例です。他の Windows RDP ホストも対象です。

<img src="../../assets/keep-desktop-interactive.png" width="700" alt="概念図：RDP クライアントを閉じる、接続中に最小化する、または切断する。アプリの処理は継続し、設定前は入力できず困ったボットが、設定後は Hello を送って笑顔になる。信頼できるロック解除済みホストが必要。コンソールはロック解除のまま。クライアント動作を検証する。">

英語ラベルの概念図。実測ではありません。

- **クリック・入力・スクリーンショットを継続。**
- **接続ウィンドウの見守りを減らす。**
- **ログイン済みのデスクトップと開いているアプリを再利用。パスワード保存なし。**

> **切断後の引き継ぎで遠隔デスクトップはロックされないままになります。** 物理または対話型 VM コンソールを操作できる人は Windows にサインインせず使用できます。他人が近づける共有 PC や信頼できないコンソールでは使わないでください。ロック画面での自動化やポリシー回避はできません。 [設定とアクセスリスク](../configuration.md).

両方の PC が Windows で、ホストはログイン済み・ロック解除・スリープしない状態が必要です。組織の許可、ホストの管理者承認、Git、Windows PowerShell 5.1、VBScript が必要です。

導入済み診断は通常利用も含め、設定したユーザーの RDP 切断ごとに約10秒後にクリック・入力・スクリーンショットを試み、エージェントと競合する可能性があります。診断だけを無効化する文書化された起動オプションはなく、ホスト側の設定を削除すると、引き継ぎも無効になります。

<a id="setup"></a>

## 2 台を設定

両方の PC で現在のユーザー専用フォルダーに新しい信頼できるクローンを作成します。共有の書き込み可能フォルダーは避けてください。エクスプローラーで `%LOCALAPPDATA%\KeepDesktopInteractiveSource` を開き、それぞれの起動ファイルをダブルクリックします。

```powershell
git clone https://github.com/yeelam-gordon/KeepDesktopInteractive.git "$env:LOCALAPPDATA\KeepDesktopInteractiveSource"
```

| リモートホスト / ローカルクライアント | |
| --- | --- |
| リモートホスト | `start-desktop-session-setup.vbs` — 管理者権限を承認 |
| ローカルクライアント | `set-local-rdp-minimize-rendering.vbs` — Windows App/RDP を完全終了して開き直し、再接続 |

[設定結果](../configuration.md#quick-setup): リモートホスト `%LOCALAPPDATA%\KeepDesktopInteractive\elevation-result.json` → `%ProgramData%\KeepDesktopInteractive\setup-result.json`: `Installed: true`, `Status: Ready`; ローカルクライアント `%LOCALAPPDATA%\KeepDesktopInteractive\local-rdp-minimize-result.json`: `Succeeded: true`.

<a id="proof"></a>

## 実入力を確認

開始時刻を記録し、他の UI 自動化を止め、機密作業を保存して機密ウィンドウを除けてから検証します。切断時は自動診断が走ります。ファイル更新時刻が開始後で、Passed/Mode が正しいことを確認し、移行後のコンソール解像度で無害な代表アプリのクリック・入力・スクリーンショットを試してください。診断成功は全アプリの保証ではありません。

30 秒間切断して再接続します。ホストの `%LOCALAPPDATA%\KeepDesktopInteractive\desktop-proof.json` が今回更新され、`Passed: true`、`Mode: AfterDisconnect` であることを確認します。

最小化は条件付きです。[90 秒のテスト／60 秒の待機](../configuration.md#verify-on-each-new-machine)で `WhileClientMinimized` を別途検証してください。失敗時はウィンドウを表示したままにします。

<a id="limits"></a>

- 再起動後のログイン・ロック解除・アプリ起動は手動です。自動ログインなし。遠隔ロック、スリープ、サインアウトは処理を止めます。
- 対応はクライアントとバージョン次第で、すべての Dev Box の保証ではありません：[実績](../configuration.md#reported-compatibility-evidence)。
- Windows Sandbox の最小化中、ゲスト稼働時の操作は**未検証**。[実験案](../configuration.md#sandbox-minimized-window-experiment)は RDP 導入手順ではありません。

## 失敗と元に戻す方法

失敗・未更新・結果なしの場合は `Error`、`Stage` と設定結果を確認し、再テストします。 [問題の切り分け](../configuration.md#proof-and-setup-troubleshooting) · [構成チェック](../configuration.md#configuration-checks)

<a id="undo"></a>

ホストのタスク削除とクライアントのレジストリ復元は、現在のコンソールをロックしません。保存して自動化を終えたら、手動ロックしてサインイン要求を確認するか、アプリ終了を意図してサインアウトしてください。

[元に戻す](../configuration.md#undo) · [正本の英語ガイド](../configuration.md) · [英語 README](../../README.md) · [更新](../configuration.md#updating-the-first-prototype)
