# KeepDesktopInteractive — Windows GUI 연결 해제 후에도 작업

<a id="languages"></a>

<details>
<summary>Languages / 语言 / 言語 / اللغات (16)</summary>

[English](../../README.md) · [简体中文](README.zh-CN.md) · [繁體中文](README.zh-TW.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Español](README.es.md) · [Português (Brasil)](README.pt-BR.md) · [Français](README.fr.md) · [Deutsch](README.de.md) · [Italiano](README.it.md) · [Русский](README.ru.md) · [Türkçe](README.tr.md) · [Tiếng Việt](README.vi.md) · [Bahasa Indonesia](README.id.md) · [हिन्दी](README.hi.md) · [العربية](README.ar.md)

</details>

Windows App 클라이언트와 Microsoft Dev Box 호스트 또는 다른 Windows RDP 환경에서, 연결 해제 감지 후에도 computer-use 에이전트의 클릭·입력·캡처를 유지하세요. 연결 창을 계속 지켜보지 않아도 되고(최소화는 호환 렌더링 검증 필요), 암호 저장이나 자동 로그인 없이 로그인된 세션을 재사용합니다.

콘솔은 잠금 해제 상태입니다. 정책을 준수하세요. Windows Sandbox 최소화는 미검증입니다.

<img src="../../assets/keep-desktop-interactive.png" width="700" alt="RDP 연결 해제와 최소화 전후: 앱은 실행 중이어도 클릭, 입력, 캡처가 멈출 수 있으며 콘솔 전환과 호환 클라이언트 설정이 작업 유지를 돕습니다.">

- **연결 해제 후에도 에이전트 작업 유지:** Windows가 RDP 연결 해제를 감지한 뒤 기존 데스크톱의 클릭·입력·캡처를 유지합니다. 네트워크 연결 해제 감지에는 시간이 걸릴 수 있습니다.
- **연결 창을 계속 지켜볼 필요 감소:** 원격 창에서 벗어날 수 있습니다. 최소화하려면 호환 클라이언트 렌더링과 해당 환경에서의 별도 실제 입력 테스트 성공이 필요합니다.
- **로그인된 작업 재사용:** 기존 사용자 세션과 열린 앱을 유지하며 암호를 저장하거나 자동 로그인을 설정하지 않습니다. 재부팅 후 로그인해 주는 기능이 아닙니다.

영어 라벨의 개념도이며 실제 측정 결과가 아닙니다. 로컬 노트북 화면을 잠근 뒤에도 원격 작업이 계속되는지는 절전하지 않고 클라이언트 설정을 마친 환경에서 검증하세요. 원격 데스크톱 잠금과는 다릅니다.

> **연결 해제 후 원격 데스크톱이 잠금 해제 상태로 남습니다.** 물리 또는 대화형 VM 콘솔을 조작할 수 있는 사람은 Windows에 로그인하지 않고 세션을 사용할 수 있습니다. 공용 PC나 신뢰할 수 없는 콘솔에서는 사용하지 마세요. 잠긴 화면에서 자동화하거나 정책을 우회하지 않습니다. [설정과 접근 위험](../configuration.md).

정책이 RDP/콘솔 전환 설정을 허용하는 환경에서만 적용하며, 모든 Dev Box 구성의 지원을 보장하지 않으므로 직접 검증해야 합니다.

[설정과 접근 위험](#setup) → [실제 입력 검증](#proof) · [제한](#limits) · [되돌리기](#undo) · Windows Sandbox 최소화: 아직 검증되지 않음.

**[Windows Sandbox](https://learn.microsoft.com/en-us/windows/security/application-security/application-isolation/windows-sandbox/) — 최소화된 창; 검증되지 않은 후보:** 호스트의 Windows Sandbox 창이 최소화되고 게스트와 앱이 계속 실행될 때 클릭·입력·캡처도 이어질 수 있을까요? 배포와 입력 지속성은 검증되지 않았으며, 이 도구가 Sandbox 클라이언트 렌더링이나 게스트 전환에 작동할지는 알 수 없으므로 별도로 테스트해야 하고 이미 검증된 해결책이 아닙니다.

## Windows App / RDP

설치된 진단은 일상 사용을 포함해 설정 사용자의 RDP 연결 해제마다 약 10초 뒤 클릭·입력·캡처를 시도해 에이전트와 충돌할 수 있습니다. 진단만 끄는 문서화된 실행 옵션은 없으며 호스트 제거는 전환도 제거합니다.

Windows App/RDP 경로: 연결 해제는 호스트 전환, 최소화는 호환 클라이언트 렌더링과 호스트 설정을 사용합니다. 아래의 검증된 두 컴퓨터 설정을 유지하고 모드별로 검증하세요. 에이전트 통합·시작, 암호 저장, 자동 로그인 기능은 없습니다. [→](../configuration.md#mode-choice)

로컬 화면 잠금 통과는 노트북이 절전하지 않고 클라이언트를 설정한 조합에 대한 유지 관리자의 보고입니다. 원격 잠금과 다르며 덮개 닫기·네트워크 손실은 Windows가 연결 해제를 감지해야 전환됩니다.

## Windows Sandbox — UNVALIDATED

Sandbox는 제안된 실험입니다. 승인된 배포·테스트 방법을 확립하지 못하면 중단하세요. 민감하지 않은 내용으로 보이는 창의 클릭·입력·캡처 기준을 기록하고, 기록한 시간 동안 최소화하여 게스트와 앱이 계속 실행되는지 확인하며 실제 입력·새 캡처를 반복한 뒤 창을 복원해 확인합니다. 미검증이며 실패하면 창을 보이게 유지하세요. 아래 RDP 두 컴퓨터·연결 해제·클라이언트 재시작 절차는 적용되지 않습니다. [→](../configuration.md#sandbox-minimized-window-experiment)

<a id="setup"></a>

설치 전에 호스트 전원을 켜고 절전 없이 잠금 해제 상태를 유지하며 조직 정책의 허용 여부를 확인하세요. Windows, 관리자 승인, Git, PowerShell 5.1, VBScript 요건은 아래와 같습니다.

## 두 컴퓨터

원격 호스트는 자동화를 실행하는 Windows PC/VM이고, 로컬 클라이언트는 RDP/Windows App을 실행하는 Windows PC입니다. Windows PowerShell 5.1, VBScript, 복제용 Git이 필요하며 호스트 설치에는 관리자 승인이 필요합니다. 양쪽에서 현재 사용자의 개인 폴더에 신뢰할 수 있는 새 복사본을 받으세요. 공동으로 쓰기 가능한 폴더는 피하세요.

<details>
<summary>Windows App / Microsoft Dev Box / Hyper-V</summary>

> **경고: 연결 해제 후 콘솔로 세션을 넘기면 원격 Windows 데스크톱이 잠금 해제 상태로 남습니다. 물리 키보드나 대화형 VM 콘솔에 접근할 수 있는 사람은 Windows에 로그인하지 않고도 세션을 사용할 수 있습니다. 다른 사람이 접근할 수 있는 공용 PC에서는 사용하지 마세요. Hyper-V 관리자와 VMConnect를 열 수 있는 모든 사람을 신뢰할 수 있어야 합니다. Windows App은 연결 클라이언트이고 Microsoft Dev Box는 관리형 클라우드 워크스테이션입니다. 위험은 제품 자체가 아니라 다른 사람이 잠금 해제된 콘솔을 조작할 수 있는지에 달려 있습니다. 신뢰하지 않는 사람의 대화형 콘솔 접근 경로가 없는 1인 개발자용 관리 호스트는 공용 PC보다 위험이 낮습니다. Microsoft Dev Box에 그런 경로가 있다고 가정하지 마세요. 조직 정책을 따르세요. 잠긴 원격 화면 뒤에서 자동화하거나 잠금 정책을 우회하지 않습니다.**

</details>


```powershell
git clone https://github.com/yeelam-gordon/KeepDesktopInteractive.git "$env:LOCALAPPDATA\KeepDesktopInteractiveSource"
Set-Location "$env:LOCALAPPDATA\KeepDesktopInteractiveSource"
```

각 컴퓨터에서 복제한 폴더를 열고 그 안에서 명령을 실행하세요. 첫 번째 명령은 원격 호스트에서 실행하고 관리자 권한 승인을 합니다. 두 번째는 로컬 클라이언트에서 실행합니다.

```powershell
wscript.exe .\start-desktop-session-setup.vbs
```

```powershell
wscript.exe .\set-local-rdp-minimize-rendering.vbs
```

원격 클라이언트를 완전히 종료한 뒤 다시 열고 재연결하세요. [설치 결과](../configuration.md#quick-setup): 호스트는 `Installed: true`, `Status: Ready`, 클라이언트는 `Succeeded: true`여야 합니다.

<a id="proof"></a>

- Windows가 RDP 연결 해제를 감지하면 기존 세션을 콘솔로 넘겨 GUI 작업 유지를 돕습니다.
- 호환 클라이언트의 렌더링 설정으로 최소화 입력을 돕습니다. 별도로 검증해야 합니다.
- 실행한 테스트 종류에 맞는 진단 결과로 실제 클릭·입력·캡처를 확인하세요. 앱 실행만으로는 부족하며 로그와 캡처는 비공개로 보관하세요.

시작 시간을 기록하고 다른 UI 자동화가 없는 상태에서 민감한 작업을 저장하고 기밀 창을 치운 후 테스트하세요. 연결 해제는 자동 진단을 실행합니다. 파일 수정 시간이 시작 이후이며 Passed/Mode가 맞는지 확인한 뒤 최종 콘솔 해상도로 무해한 대표 앱에서 클릭·입력·캡처를 해보세요. 진단 통과는 모든 앱의 성공이 아닙니다. [→](../configuration.md#reported-compatibility-evidence)

## 첫 검증

RDP를 정상적으로 연결 해제하고 30초 뒤 재연결하면 진단이 자동 실행됩니다. 최소화 검증은 별도입니다. 원격 호스트에서 아래 명령을 실행한 뒤 즉시 로컬의 원격 창을 최소화하고 90초 동안 유지한 다음 복원하세요. 검사는 실제 입력과 캡처 전에 60초를 기다립니다.

```powershell
wscript.exe .\test-interactive-desktop-automation.vbs --minimized-test
```

호스트의 최신 `%LOCALAPPDATA%\KeepDesktopInteractive\desktop-proof.json`을 확인하세요. 다음은 각 검사에서 기대하는 필드의 예이며 이번 작업에서 측정한 결과가 아닙니다.

```json
{ "Passed": true, "Mode": "AfterDisconnect" }
```

```json
{ "Passed": true, "Mode": "WhileClientMinimized" }
```

입력과 화면 캡처 동안 창이 계속 최소화되어 있어야 최소화 검증이 유효합니다. 호스트는 클라이언트 상태를 관찰할 수 없습니다. 로그와 캡처에는 주변 데스크톱 내용이 포함될 수 있으므로 비공개로 보관하세요. [검증 설명](../configuration.md#verify-on-each-new-machine).

<a id="limits"></a>

## 제한

설정은 기존 Remote Desktop Connection용으로 문서화되어 있으며 Windows App 지원은 버전에 따라 다릅니다. 유지 관리자는 원래 클라이언트/호스트 조합이 보안 강화 전에 최소화 검사를 통과했다고 보고했지만 배포 후에는 재검증하지 않았습니다. 모든 클라이언트의 지원을 보장하지 않습니다. 재부팅 후 한 번 로그인하고 잠금을 해제한 뒤 앱과 자동화를 다시 시작하세요. 대화형 그래픽 데스크톱 세션이 없는 헤드리스 환경은 지원하지 않습니다. 원격 잠금, 절전, 종료, 로그아웃은 자동화를 멈출 수 있습니다. [전체 제한](../configuration.md#requirements-and-limitations).

`Passed: false`이면 `Error`, `Stage`, 로그를 확인하세요. 결과가 없거나 오래되었으면 설치를 확인하고 다시 검사하세요. 최소화를 지원하지 않는 클라이언트에서는 창을 보이게 두거나 별도로 검증한 연결 해제 절차를 사용하세요. [문제 해결](../../README.md#if-the-proof-fails) · [구성 검사](../configuration.md#configuration-checks).

<a id="undo"></a>

호스트 작업 제거와 클라이언트 복원은 현재 콘솔을 자동으로 잠그지 않습니다. 저장하고 자동화를 끝낸 뒤 호스트를 수동으로 잠가 콘솔에서 로그인이 필요한지 확인하거나, 앱을 종료하려는 경우 로그아웃하세요. 잠금은 GUI 자동화를 중단합니다.

## 되돌리기

각각의 복제 폴더에서 실행하세요. 첫 번째 명령은 원격 호스트의 예약 작업을 제거하고 두 번째는 원래 로컬 컴퓨터의 동일 사용자 계정에서 클라이언트 설정을 복원합니다.

```powershell
wscript.exe .\start-desktop-session-setup.vbs --uninstall
```

```powershell
wscript.exe .\set-local-rdp-minimize-rendering.vbs --restore
```

복원이 더 이상 필요하지 않을 때까지 클라이언트의 `%LOCALAPPDATA%\KeepDesktopInteractive\local-rdp-minimize-backup.json`을 보관하세요. 두 작업은 독립적이며 진단 증거를 삭제하지 않습니다. [되돌리기](../configuration.md#undo) · [영문 기준 가이드](../configuration.md) · [영문 README](../../README.md).

업데이트는 새 개인 폴더에 받으세요. 기존의 비어 있지 않은 폴더에 다시 복제하지 말고 이전 복사본과 백업을 보관하며 설정과 검증을 반복하세요. [→](../configuration.md#updating-the-first-prototype)
