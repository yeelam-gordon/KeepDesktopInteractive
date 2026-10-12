# KeepDesktopInteractive — 원격 연결 해제 후에도 GUI 작업 유지

<a id="languages"></a>

<details>
<summary>Languages (16)</summary>

[English](../../README.md) · [简体中文](README.zh-CN.md) · [繁體中文](README.zh-TW.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Español](README.es.md) · [Português (Brasil)](README.pt-BR.md) · [Français](README.fr.md) · [Deutsch](README.de.md) · [Italiano](README.it.md) · [Русский](README.ru.md) · [Türkçe](README.tr.md) · [Tiếng Việt](README.vi.md) · [Bahasa Indonesia](README.id.md) · [हिन्दी](README.hi.md) · [العربية](README.ar.md)

</details>

기존 Windows 데스크톱에서 에이전트와 UI 테스트의 작업을 유지합니다. Windows App은 클라이언트이고 Microsoft Dev Box는 가능한 호스트의 한 예입니다. 다른 Windows RDP 호스트도 대상입니다.

<img src="../../assets/keep-desktop-interactive.png" width="700" alt="개념도: RDP 클라이언트 닫기, 연결된 상태에서 최소화, 또는 연결 끊기. 앱은 계속 계산하며 설정 전 입력이 막힌 봇은 불행하고 설정 후 Hello를 보낸 봇은 웃습니다. 신뢰할 수 있는 이미 잠금 해제된 호스트가 필요하며 콘솔은 잠금 해제 상태로 유지됩니다. 클라이언트 동작을 검증해야 합니다.">

영어 라벨의 개념도이며 실측이 아닙니다.

- **클릭·입력·캡처 유지.**
- **연결 창을 계속 지켜볼 필요 감소.**
- **이미 로그인한 데스크톱과 열린 앱을 재사용하며 암호를 저장하지 않습니다.**

> **연결 해제 후 원격 데스크톱이 잠금 해제 상태로 남습니다.** 물리 또는 대화형 VM 콘솔을 조작할 수 있는 사람은 Windows에 로그인하지 않고 세션을 사용할 수 있습니다. 공용 PC나 신뢰할 수 없는 콘솔에서는 사용하지 마세요. 잠긴 화면에서 자동화하거나 정책을 우회하지 않습니다. [설정과 접근 위험](../configuration.md).

두 컴퓨터 모두 Windows여야 합니다. 호스트는 로그인·잠금 해제 상태로 절전하지 않아야 하며 정책이 허용해야 합니다. 호스트 관리자 승인, Git, Windows PowerShell 5.1, VBScript가 필요합니다.

설치된 진단은 일상 사용을 포함해 설정된 사용자의 RDP 연결 해제마다 약 10초 뒤 클릭·입력·캡처를 시도해 에이전트와 충돌할 수 있습니다.

<a id="setup"></a>

## 두 컴퓨터 설정

두 컴퓨터에서 현재 사용자의 개인 폴더에 신뢰할 수 있는 새 복제본을 받으세요. 다른 사용자도 쓸 수 있는 공유 폴더는 피하세요. 파일 탐색기에서 `%LOCALAPPDATA%\KeepDesktopInteractiveSource`를 열고 각각의 실행 파일을 두 번 클릭하세요.

```powershell
git clone https://github.com/yeelam-gordon/KeepDesktopInteractive.git "$env:LOCALAPPDATA\KeepDesktopInteractiveSource"
```

| 원격 호스트 / 로컬 클라이언트 | |
| --- | --- |
| 원격 호스트 | `start-desktop-session-setup.vbs` — 관리자 권한 승인 |
| 로컬 클라이언트 | `set-local-rdp-minimize-rendering.vbs` — Windows App/RDP 완전히 종료 후 다시 열고 재연결 |

[설치 결과](../configuration.md#quick-setup): 원격 호스트 `%LOCALAPPDATA%\KeepDesktopInteractive\elevation-result.json` → `%ProgramData%\KeepDesktopInteractive\setup-result.json`: `Installed: true`, `Status: Ready`; 로컬 클라이언트 `%LOCALAPPDATA%\KeepDesktopInteractive\local-rdp-minimize-result.json`: `Succeeded: true`.

<a id="proof"></a>

## 실제 입력 검증

시작 시간을 기록하고 다른 UI 자동화가 없는 상태에서 민감한 작업을 저장하고 기밀 창을 치운 후 테스트하세요. 연결 해제는 자동 진단을 실행합니다. 파일 수정 시간이 시작 이후이며 Passed/Mode가 맞는지 확인한 뒤 최종 콘솔 해상도로 무해한 대표 앱에서 클릭·입력·캡처를 해보세요. 진단 통과는 모든 앱의 성공이 아닙니다.

30초 동안 연결 해제 후 재연결하세요. 호스트의 `%LOCALAPPDATA%\KeepDesktopInteractive\desktop-proof.json`이 이번에 갱신되고 `Passed: true`, `Mode: AfterDisconnect`인지 확인하세요.

최소화는 조건부입니다. 별도로 [90초 테스트／60초 대기](../configuration.md#verify-on-each-new-machine)를 따라 `WhileClientMinimized`를 검증하세요. 실패하면 창을 보이게 유지하세요.

<a id="limits"></a>

- 재부팅 후 직접 로그인·잠금 해제하고 앱을 다시 시작해야 합니다. 자동 로그인은 없습니다. 원격 잠금·절전·로그아웃은 작업을 멈춥니다.
- 지원은 클라이언트와 버전에 따라 다르며 모든 Dev Box를 보장하지 않습니다: [기록](../configuration.md#reported-compatibility-evidence).
- Windows Sandbox 최소화 중 게스트가 실행되는 경우: **미검증** [실험](../configuration.md#sandbox-minimized-window-experiment)이며 RDP 설치 절차가 아닙니다.

## 실패와 되돌리기

결과가 실패·누락·오래된 경우 `Error`, `Stage`와 설치 결과를 확인하고 다시 테스트하세요. [문제 해결](../configuration.md#proof-and-setup-troubleshooting) · [구성 검사](../configuration.md#configuration-checks)

<a id="undo"></a>

호스트 작업 제거와 클라이언트 레지스트리 복원은 현재 콘솔을 잠그지 않습니다. 저장하고 자동화를 마친 뒤 수동으로 잠가 로그인이 필요한지 확인하거나, 앱을 끝내려면 로그아웃하세요.

[되돌리기](../configuration.md#undo) · [영문 기준 가이드](../configuration.md) · [영문 README](../../README.md) · [업데이트](../configuration.md#updating-the-first-prototype)
