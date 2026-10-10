# KeepDesktopInteractive — RDP 切断後の Windows GUI 自動化を維持

RDP 切断後に Windows GUI 自動化が停止する場合、**ログイン済みでロックされていない**セッションを維持し、既存の computer-use エージェントや UI テストの入力・クリック・画面取得を支援します。最小化時の入力停止は別の問題で、対応クライアントと個別の検証が必要です。エージェントのネイティブ統合や起動機能、パスワード保存、自動ログインはありません。

> **切断後の引き継ぎで遠隔デスクトップはロックされないままになります。** 物理または対話型 VM コンソールを操作できる人は Windows にサインインせず使用できます。他人が近づける共有 PC や信頼できないコンソールでは使わないでください。ロック画面での自動化やポリシー回避はできません。 [設定とアクセスリスク](../configuration.md).

[設定とアクセスリスク](#setup) → [実入力を検証](#proof) · [制限](#limits) · [元に戻す](#undo)

- Windows が RDP 切断を検出すると既存セッションをコンソールへ引き継ぎ、GUI 操作の維持を支援します。
- 対応クライアントの描画設定で最小化時の入力を支援します。別途検証が必要です。
- モードが一致する非公開の結果で実際のクリック、入力、画面取得を確認します。アプリの稼働だけでは証明になりません。

<details>
<summary>Languages</summary>

[English](../../README.md) · [简体中文](README.zh-CN.md) · [繁體中文](README.zh-TW.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Español](README.es.md) · [Português (Brasil)](README.pt-BR.md) · [Français](README.fr.md) · [Deutsch](README.de.md) · [Italiano](README.it.md) · [Русский](README.ru.md) · [Türkçe](README.tr.md) · [Tiếng Việt](README.vi.md) · [Bahasa Indonesia](README.id.md) · [हिन्दी](README.hi.md) · [العربية](README.ar.md)

</details>

<a id="setup"></a>

導入前にホストの電源を入れ、スリープせずロック解除した状態を維持し、組織の許可を確認してください。Windows、管理者承認、Git、PowerShell 5.1、VBScript の要件は以下です。

## 2 台を別々に設定

**リモートホスト**は自動化を実行する Windows PC/VM、**ローカルクライアント**は RDP/Windows App を実行する Windows PC です。Windows PowerShell 5.1 と VBScript、取得用の Git が必要です。ホストのインストールには管理者承認が必要です。両方で現在のユーザー専用フォルダーに信頼できる新しいコピーを取得し、共有の書き込み可能フォルダーは避けてください。
```powershell
git clone https://github.com/yeelam-gordon/KeepDesktopInteractive.git "$env:LOCALAPPDATA\KeepDesktopInteractiveSource"
Set-Location "$env:LOCALAPPDATA\KeepDesktopInteractiveSource"
```
各 PC でクローンしたフォルダーを開き、そこから実行します。最初のコマンドはホストで管理者承認、次はローカルクライアントで実行します。
```powershell
wscript.exe .\start-desktop-session-setup.vbs
```
```powershell
wscript.exe .\set-local-rdp-minimize-rendering.vbs
```
クライアントを完全に終了して再起動し、再接続します。[設定結果](../configuration.md#quick-setup)はホストが `Installed: true` / `Status: Ready`、クライアントが `Succeeded: true` です。

## 最初の検証

<a id="proof"></a>

**切断：** 通常どおり RDP を切断し、30 秒待って再接続します。診断は自動実行されます。**最小化：** ホストで次を実行し、直ちにローカルのリモートウィンドウを最小化して 90 秒間維持します。その後戻します。実入力と画面取得は 60 秒待ってから始まります。
```powershell
wscript.exe .\test-interactive-desktop-automation.vbs --minimized-test
```
ホストの新しい `%LOCALAPPDATA%\KeepDesktopInteractive\desktop-proof.json` で対応するフィールドを確認します。以下は期待値の例で、今回の実測結果ではありません。
```json
{ "Passed": true, "Mode": "AfterDisconnect" }
```
```json
{ "Passed": true, "Mode": "WhileClientMinimized" }
```
最小化の成功は入力と画面取得中ずっと最小化していた場合のみ有効です。ホストはクライアントの状態を観測できません。周囲の画面内容を含む可能性があるログと画像は非公開にしてください。[詳細](../configuration.md#verify-on-each-new-machine)。

<img src="../../assets/keep-desktop-interactive.png" width="700" alt="RDP 切断や最小化の前後：アプリは動いていてもクリック、入力、画面取得が止まることがあり、コンソール引き継ぎと対応クライアント設定が操作維持を支援します。">

概念図です。左は設定なしでアプリが動いても自動化が止まる状態、右は設定後に期待するクリック、入力、画面取得を示します。画像のラベルは英語で、日本語化されたアプリ画面や実測結果ではありません。最小化対応はクライアント次第です。ふたを閉じる・ネットワークを失う場合は Windows が RDP 切断を検出する必要があり、コンソール引き継ぎ後もデスクトップはロックされません。 ローカルのロックは、保守担当者が報告した組み合わせで、クライアント設定済みかつノートブックが起きている場合の結果です。最小化テストはセキュリティ強化前で、導入後は再検証されていません。

<a id="limits"></a>

## 制限、失敗、元に戻す方法

設定は従来の Remote Desktop Connection 向けに文書化されています。Windows App の対応はバージョン次第です。元の組み合わせではセキュリティ強化前に最小化テストが成功しましたが、導入後は再検証されていません。再起動後は一度ログインしてロックを解除し、アプリと自動化を再起動してください。ヘッドレス環境は対象外です。リモートのロック、スリープ、シャットダウン、サインアウトは処理を止める可能性があります。[制限](../configuration.md#requirements-and-limitations)。

`Passed: false` なら `Error`、`Stage`、ログを確認します。結果がない・古い場合は設定結果を確認して再テストします。最小化非対応なら表示したままにするか、別途検証した切断手順を使います。[問題の切り分け](../../README.md#if-the-proof-fails) · [構成チェック](../configuration.md#configuration-checks)。

<a id="undo"></a>

各クローンフォルダーから、ホストで削除し、同じローカルユーザーでクライアント設定を復元します。
```powershell
wscript.exe .\start-desktop-session-setup.vbs --uninstall
```
```powershell
wscript.exe .\set-local-rdp-minimize-rendering.vbs --restore
```
復元が不要になるまでクライアントの `%LOCALAPPDATA%\KeepDesktopInteractive\local-rdp-minimize-backup.json` を保持します。操作は独立しており診断証拠を削除しません。[元に戻す](../configuration.md#undo) · [正本の英語ガイド](../configuration.md) · [英語 README](../../README.md)。

<details>
<summary>Windows App / Microsoft Dev Box / Hyper-V</summary>

> **警告：切断後にコンソールへ引き継ぐと、リモート Windows デスクトップはロックされない状態になります。** 物理キーボードや対話型 VM コンソールにアクセスできる人は、Windows にサインインせずにセッションを操作できます。他人が近づける共有 PC では使用しないでください。Hyper-V 管理者と VMConnect を開ける人を信頼できることが必要です。Windows App は接続クライアント、Microsoft Dev Box は管理されたクラウドワークステーションです。問題は製品自体の安全性ではなく、他人がロックされていないコンソールを操作できるかです。信頼できない人の対話型コンソールアクセス経路がない単一開発者用の管理ホストは共有 PC より低リスクです。Microsoft Dev Box にその経路があるとは決めつけないでください。組織のポリシーを守ってください。ロックされたリモート画面での自動化やロックポリシーの回避はできません。

</details>
