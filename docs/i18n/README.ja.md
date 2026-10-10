# KeepDesktopInteractive — RDP 切断後の Windows GUI 自動化を維持

[English](../../README.md) · [简体中文](README.zh-CN.md) · [日本語](README.ja.md) · [Español](README.es.md) · [Português (Brasil)](README.pt-BR.md) · [Français](README.fr.md) · [Deutsch](README.de.md)

> **警告：切断後にコンソールへ引き継ぐと、リモート Windows デスクトップはロックされない状態になります。** 物理キーボードや対話型 VM コンソールにアクセスできる人は、Windows にサインインせずにセッションを操作できます。他人が近づける共有 PC では使用しないでください。Hyper-V 管理者と VMConnect を開ける人を信頼できることが必要です。テストアカウントやクラウド VM も自動的に安全にはなりません。組織のポリシーを守ってください。ロックされたリモート画面での自動化やロックポリシーの回避はできません。

RDP 切断後に Windows GUI 自動化が停止する場合、**ログイン済みでロックされていない**セッションを維持し、既存の computer-use エージェントや UI テストの入力・クリック・画面取得を支援します。最小化時の入力停止は別の問題で、対応クライアントと個別の検証が必要です。エージェントのネイティブ統合や起動機能、パスワード保存、自動ログインはありません。

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

## 制限、失敗、元に戻す方法

設定は従来の Remote Desktop Connection 向けに文書化されています。Windows App の対応はバージョン次第です。元の組み合わせでは強化前に最小化テストが成功しましたが、導入後は再検証されていません。再起動後は一度ログインしてロックを解除し、アプリと自動化を再起動してください。ヘッドレス環境は対象外です。リモートのロック、スリープ、シャットダウン、サインアウトは処理を止める可能性があります。[制限](../configuration.md#requirements-and-limitations)。

`Passed: false` なら `Error`、`Stage`、ログを確認します。結果がない・古い場合は設定結果を確認して再テストします。最小化非対応なら表示したままにするか、別途検証した切断手順を使います。[問題の切り分け](../../README.md#if-the-proof-fails) · [構成チェック](../configuration.md#configuration-checks)。

各クローンフォルダーから、ホストで削除し、同じローカルユーザーでクライアント設定を復元します。
```powershell
wscript.exe .\start-desktop-session-setup.vbs --uninstall
```
```powershell
wscript.exe .\set-local-rdp-minimize-rendering.vbs --restore
```
復元が不要になるまでクライアントの `%LOCALAPPDATA%\KeepDesktopInteractive\local-rdp-minimize-backup.json` を保持します。操作は独立しており診断証拠を削除しません。[元に戻す](../configuration.md#undo) · [正本の英語ガイド](../configuration.md) · [英語 README](../../README.md)。
