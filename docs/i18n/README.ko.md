# KeepDesktopInteractive — RDP 연결 해제 후에도 Windows GUI 자동화 유지

[English](../../README.md) · [简体中文](README.zh-CN.md) · [繁體中文](README.zh-TW.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Español](README.es.md) · [Português (Brasil)](README.pt-BR.md) · [Français](README.fr.md) · [Deutsch](README.de.md) · [Italiano](README.it.md) · [Русский](README.ru.md) · [Türkçe](README.tr.md) · [Tiếng Việt](README.vi.md) · [Bahasa Indonesia](README.id.md) · [हिन्दी](README.hi.md) · [العربية](README.ar.md)

> **경고: 연결 해제 후 콘솔로 세션을 넘기면 원격 Windows 데스크톱이 잠금 해제 상태로 남습니다. 물리 키보드나 대화형 VM 콘솔에 접근할 수 있는 사람은 Windows에 로그인하지 않고도 세션을 사용할 수 있습니다. 다른 사람이 접근할 수 있는 공용 PC에서는 사용하지 마세요. Hyper-V 관리자와 VMConnect를 열 수 있는 모든 사람을 신뢰할 수 있어야 합니다. 테스트 계정이나 클라우드 VM이라고 자동으로 안전한 것은 아닙니다. 조직 정책을 따르세요. 잠긴 원격 화면 뒤에서 자동화하거나 잠금 정책을 우회하지 않습니다.**

RDP 연결 해제 후 Windows GUI 자동화가 멈추나요? **이미 로그인되어 있고 잠금이 해제된** 세션을 유지해 기존 computer-use 에이전트나 UI 테스트의 클릭, 입력, 화면 캡처를 지원합니다. 창을 최소화했을 때 입력이 멈추는 문제는 별도로 호환 클라이언트와 검증이 필요합니다. 에이전트와의 기본 통합이나 에이전트 실행 기능, 암호 저장, 자동 로그인은 제공하지 않습니다.

**두 컴퓨터:** 원격 호스트는 자동화를 실행하는 Windows PC/VM이고, 로컬 클라이언트는 RDP/Windows App을 실행하는 Windows PC입니다. Windows PowerShell 5.1, VBScript, 복제용 Git이 필요하며 호스트 설치에는 관리자 승인이 필요합니다. 양쪽에서 현재 사용자의 개인 폴더에 신뢰할 수 있는 새 복사본을 받으세요. 공동으로 쓰기 가능한 폴더는 피하세요.

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

**첫 검증:** RDP를 정상적으로 연결 해제하고 30초 뒤 재연결하면 진단이 자동 실행됩니다. 최소화 검증은 별도입니다. 원격 호스트에서 아래 명령을 실행한 뒤 즉시 로컬의 원격 창을 최소화하고 90초 동안 유지한 다음 복원하세요. 검사는 실제 입력과 캡처 전에 60초를 기다립니다.

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

**제한:** 설정은 기존 Remote Desktop Connection용으로 문서화되어 있으며 Windows App 지원은 버전에 따라 다릅니다. 유지 관리자는 원래 클라이언트/호스트 조합이 보안 강화 전에 최소화 검사를 통과했다고 보고했지만 배포 후에는 재검증하지 않았습니다. 모든 클라이언트의 지원을 보장하지 않습니다. 재부팅 후 한 번 로그인하고 잠금을 해제한 뒤 앱과 자동화를 다시 시작하세요. 대화형 그래픽 데스크톱 세션이 없는 헤드리스 환경은 지원하지 않습니다. 원격 잠금, 절전, 종료, 로그아웃은 자동화를 멈출 수 있습니다. [전체 제한](../configuration.md#requirements-and-limitations).

`Passed: false`이면 `Error`, `Stage`, 로그를 확인하세요. 결과가 없거나 오래되었으면 설치를 확인하고 다시 검사하세요. 최소화를 지원하지 않는 클라이언트에서는 창을 보이게 두거나 별도로 검증한 연결 해제 절차를 사용하세요. [문제 해결](../../README.md#if-the-proof-fails) · [구성 검사](../configuration.md#configuration-checks).

**되돌리기:** 각각의 복제 폴더에서 실행하세요. 첫 번째 명령은 원격 호스트의 예약 작업을 제거하고 두 번째는 원래 로컬 컴퓨터의 동일 사용자 계정에서 클라이언트 설정을 복원합니다.

```powershell
wscript.exe .\start-desktop-session-setup.vbs --uninstall
```

```powershell
wscript.exe .\set-local-rdp-minimize-rendering.vbs --restore
```

복원이 더 이상 필요하지 않을 때까지 클라이언트의 `%LOCALAPPDATA%\KeepDesktopInteractive\local-rdp-minimize-backup.json`을 보관하세요. 두 작업은 독립적이며 진단 증거를 삭제하지 않습니다. [되돌리기](../configuration.md#undo) · [영문 기준 가이드](../configuration.md) · [영문 README](../../README.md).
