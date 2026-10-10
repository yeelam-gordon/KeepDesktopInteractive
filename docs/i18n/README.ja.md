# KeepDesktopInteractive — Windows GUI 切断後も操作

<a id="languages"></a>

<details>
<summary>Languages / 语言 / 言語 / اللغات (16)</summary>

[English](../../README.md) · [简体中文](README.zh-CN.md) · [繁體中文](README.zh-TW.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Español](README.es.md) · [Português (Brasil)](README.pt-BR.md) · [Français](README.fr.md) · [Deutsch](README.de.md) · [Italiano](README.it.md) · [Русский](README.ru.md) · [Türkçe](README.tr.md) · [Tiếng Việt](README.vi.md) · [Bahasa Indonesia](README.id.md) · [हिन्दी](README.hi.md) · [العربية](README.ar.md)

</details>

Windows App クライアントと Microsoft Dev Box ホスト、または別の Windows RDP 環境で、切断を検出した後も computer-use エージェントのクリック・入力・画面取得を継続。接続ウィンドウを見守る必要を減らし（最小化はクライアントの描画継続を要検証）、パスワード保存や自動ログインなしでログイン済みセッションを再利用します。

コンソールは未ロック。ポリシーを遵守。Windows Sandbox 最小化は未検証。

<img src="../../assets/keep-desktop-interactive.png" width="700" alt="RDP 切断や最小化の前後：アプリは動いていてもクリック、入力、画面取得が止まることがあり、コンソール引き継ぎと対応クライアント設定が操作維持を支援します。">

- **切断後もエージェント操作を継続：** Windows が RDP 切断を検出すると既存デスクトップのクリック・入力・画面取得を維持します。ネットワーク切断の検出には時間がかかる場合があります。
- **接続ウィンドウを見守らずに済む：** 遠隔ウィンドウから離れられます。最小化利用には対応するクライアントの描画設定と、その環境での別途実入力テスト成功が必要です。 ウィンドウを最小化してもクライアントが遠隔画面を描画し続ける必要があります。クリック・入力・画面取得は別途検証してください。
- **ログイン済みセッションを再利用：** 既存セッションと開いているアプリを保持し、パスワード保存や自動ログインを追加しません。再起動後にログインする機能ではありません。

英語ラベルの概念図で実測結果ではありません。手元のノート PC の画面をロックしても遠隔操作が続くかは、スリープせずクライアント設定済みの環境で検証してください。遠隔デスクトップのロックとは別です。

> **切断後の引き継ぎで遠隔デスクトップはロックされないままになります。** 物理または対話型 VM コンソールを操作できる人は Windows にサインインせず使用できます。他人が近づける共有 PC や信頼できないコンソールでは使わないでください。ロック画面での自動化やポリシー回避はできません。 [設定とアクセスリスク](../configuration.md).

ポリシーが RDP/コンソール引き継ぎの設定を許可する環境が対象です。すべての Dev Box 構成の対応を保証せず、個別検証が必要です。

[設定とアクセスリスク](#setup) → [実入力を検証](#proof) · [制限](#limits) · [元に戻す](#undo) · Windows Sandbox の最小化：未検証。

**[Windows Sandbox](https://learn.microsoft.com/en-us/windows/security/application-security/application-isolation/windows-sandbox/) — 最小化したウィンドウ・未検証の候補:** ホスト上の Windows Sandbox ウィンドウを最小化し、ゲストとアプリが動き続けているとき、クリック・入力・画面取得は続けられるでしょうか？導入と入力継続は未検証で、本ツールが Sandbox のクライアント描画やゲスト引き継ぎに対応するかは不明です。別途検証が必要で、既存の解決策ではありません。

## Windows App / RDP

導入済み診断は通常利用も含め、設定したユーザーの RDP 切断ごとに約10秒後にクリック・入力・取得を試み、エージェントと競合します。診断だけを無効化する文書化された起動オプションはなく、ホスト削除は引き継ぎも削除します。

Windows App/RDP の手順：切断はホスト引き継ぎ、最小化は対応するクライアントの描画設定とホスト設定を使用します。以下の検証済み2台構成を維持し、各モードを別々に検証してください。エージェント統合・起動、パスワード保存、自動ログインはありません。 [→](../configuration.md#mode-choice)

手元の画面ロックでの成功は、スリープせずクライアント設定済みの組み合わせに対する保守担当者の報告です。遠隔ロックとは別で、ふた閉じや回線断は Windows が切断を検出して初めて引き継ぎます。

## Windows Sandbox — UNVALIDATED

Sandbox は実施前の実験案です。承認された導入・検証方法を確立できなければ中止してください。機密情報を含まない可視ウィンドウでクリック・入力・画面取得の基準を記録し、時間を記録して最小化、ゲストとアプリの稼働を確認しながら実入力と新しい画像取得を繰り返し、戻して確認します。未検証です。失敗時は表示したままにし、以下の RDP 2台設定・切断・クライアント再起動手順を適用しないでください。 [→](../configuration.md#sandbox-minimized-window-experiment)

<a id="setup"></a>

導入前にホストの電源を入れ、スリープせずロック解除した状態を維持し、組織の許可を確認してください。Windows、管理者承認、Git、PowerShell 5.1、VBScript の要件は以下です。

## 2 台を別々に設定

**リモートホスト**は自動化を実行する Windows PC/VM、**ローカルクライアント**は RDP/Windows App を実行する Windows PC です。Windows PowerShell 5.1 と VBScript、取得用の Git が必要です。ホストのインストールには管理者承認が必要です。両方で現在のユーザー専用フォルダーに信頼できる新しいコピーを取得し、共有の書き込み可能フォルダーは避けてください。
<details>
<summary>Windows App / Microsoft Dev Box / Hyper-V</summary>

> **警告：切断後にコンソールへ引き継ぐと、リモート Windows デスクトップはロックされない状態になります。** 物理キーボードや対話型 VM コンソールにアクセスできる人は、Windows にサインインせずにセッションを操作できます。他人が近づける共有 PC では使用しないでください。Hyper-V 管理者と VMConnect を開ける人を信頼できることが必要です。Windows App は接続クライアント、Microsoft Dev Box は管理されたクラウドワークステーションです。問題は製品自体の安全性ではなく、他人がロックされていないコンソールを操作できるかです。信頼できない人の対話型コンソールアクセス経路がない単一開発者用の管理ホストは共有 PC より低リスクです。Microsoft Dev Box にその経路があるとは決めつけないでください。組織のポリシーを守ってください。ロックされたリモート画面での自動化やロックポリシーの回避はできません。

</details>


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

- Windows が RDP 切断を検出すると既存セッションをコンソールへ引き継ぎ、GUI 操作の維持を支援します。
- 対応クライアントの描画設定で最小化時の入力を支援します。別途検証が必要です。
- 実施したテストの種類に対応する診断結果で、クリック・文字入力・画面取得が実際に機能することを確認します。ログや画像は公開しないでください。

開始時刻を記録し、他の UI 自動化を止め、機密作業を保存して機密ウィンドウを除けてから検証します。切断時は自動診断が走ります。ファイル更新時刻が開始後で、Passed/Mode が正しいことを確認し、移行後のコンソール解像度で無害な代表アプリのクリック・入力・取得を試してください。診断成功は全アプリの保証ではありません。 [→](../configuration.md#reported-compatibility-evidence)

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

<a id="limits"></a>

## 制限、失敗、元に戻す方法

設定は従来の Remote Desktop Connection 向けに文書化されています。Windows App の対応はバージョン次第です。元の組み合わせではセキュリティ強化前に最小化テストが成功しましたが、導入後は再検証されていません。再起動後は一度ログインしてロックを解除し、アプリと自動化を再起動してください。ヘッドレス環境は対象外です。リモートのロック、スリープ、シャットダウン、サインアウトは処理を止める可能性があります。[制限](../configuration.md#requirements-and-limitations)。

`Passed: false` なら `Error`、`Stage`、ログを確認します。結果がない・古い場合は設定結果を確認して再テストします。最小化非対応なら表示したままにするか、別途検証した切断手順を使います。[問題の切り分け](../../README.md#if-the-proof-fails) · [構成チェック](../configuration.md#configuration-checks)。

<a id="undo"></a>

タスク削除とクライアント復元は現在のコンソールを自動ロックしません。保存して自動化を終えた後、ホストを手動ロックしコンソールでサインインが必要か確認するか、アプリ終了を意図してサインアウトしてください。ロックは GUI 自動化を止めます。

各クローンフォルダーから、ホストで削除し、同じローカルユーザーでクライアント設定を復元します。
```powershell
wscript.exe .\start-desktop-session-setup.vbs --uninstall
```
```powershell
wscript.exe .\set-local-rdp-minimize-rendering.vbs --restore
```
復元が不要になるまでクライアントの `%LOCALAPPDATA%\KeepDesktopInteractive\local-rdp-minimize-backup.json` を保持します。操作は独立しており診断証拠を削除しません。[元に戻す](../configuration.md#undo) · [正本の英語ガイド](../configuration.md) · [英語 README](../../README.md)。

更新は新しい個人用フォルダーへ取得し、既存の空でないフォルダーに再クローンしないでください。旧版とバックアップを保持し、設定と検証を繰り返します。 [→](../configuration.md#updating-the-first-prototype)
