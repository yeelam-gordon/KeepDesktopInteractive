# KeepDesktopInteractive — Duy trì thao tác GUI sau ngắt RDP

<a id="languages"></a>

<details>
<summary>Languages (16)</summary>

[English](../../README.md) · [简体中文](README.zh-CN.md) · [繁體中文](README.zh-TW.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Español](README.es.md) · [Português (Brasil)](README.pt-BR.md) · [Français](README.fr.md) · [Deutsch](README.de.md) · [Italiano](README.it.md) · [Русский](README.ru.md) · [Türkçe](README.tr.md) · [Tiếng Việt](README.vi.md) · [Bahasa Indonesia](README.id.md) · [हिन्दी](README.hi.md) · [العربية](README.ar.md)

</details>

Cho tác nhân và kiểm thử UI trên desktop Windows hiện có: Windows App là máy khách; Microsoft Dev Box hoặc máy Windows khác có RDP có thể là máy chủ.

<img src="../../assets/keep-desktop-interactive.png" width="320" alt="Hình khái niệm: duy trì nhấp chuột và nhập sau ngắt kết nối; không phải canh cửa sổ từ xa khi thu nhỏ với máy khách tương thích đã kiểm thử; dùng lại desktop đã đăng nhập mà không lưu mật khẩu. Chuyển sang console để desktop ở trạng thái mở khóa.">

Hình khái niệm, nhãn tiếng Anh, không phải bằng chứng.

- **Duy trì nhấp, nhập và chụp màn hình.**
- **Không phải canh kết nối.**
- **Dùng lại desktop đã đăng nhập và các ứng dụng đang mở, không lưu mật khẩu.**

> **Chuyển phiên để màn hình từ xa ở trạng thái mở khóa.** Ai có thể thao tác bảng điều khiển vật lý hoặc tương tác của VM có thể dùng phiên mà không đăng nhập Windows. Không dùng máy chung dễ tiếp cận hoặc bảng điều khiển không đáng tin. Không tự động hóa trên màn hình bị khóa hay vượt chính sách. [Thiết lập và rủi ro truy cập](../configuration.md).

Cả hai máy cần Windows. Máy chủ đã đăng nhập, mở khóa, không ngủ và được chính sách cho phép. Cần quản trị viên máy chủ chấp thuận, Git, Windows PowerShell 5.1 và VBScript.

Công cụ chẩn đoán đã cài đặt thử nhấp chuột, nhập liệu và chụp màn hình khoảng 10 giây sau mỗi lần ngắt RDP của người dùng đã cấu hình, kể cả sử dụng thường ngày, nên có thể tranh chấp với tác nhân.

<a id="setup"></a>

## Thiết lập cả hai máy

Trên cả hai máy, lấy bản sao mới đáng tin cậy vào thư mục riêng của người dùng hiện tại, không dùng thư mục chia sẻ có thể ghi. Mở `%LOCALAPPDATA%\KeepDesktopInteractiveSource` trong File Explorer và nhấp đúp trình chạy tương ứng.

```powershell
git clone https://github.com/yeelam-gordon/KeepDesktopInteractive.git "$env:LOCALAPPDATA\KeepDesktopInteractiveSource"
```

| Máy chủ từ xa / Máy khách cục bộ | |
| --- | --- |
| Máy chủ từ xa | `start-desktop-session-setup.vbs` — chấp thuận nâng quyền |
| Máy khách cục bộ | `set-local-rdp-minimize-rendering.vbs` — đóng hoàn toàn Windows App/RDP, mở lại rồi kết nối |

[Kết quả cài đặt](../configuration.md#quick-setup): Máy chủ từ xa `%LOCALAPPDATA%\KeepDesktopInteractive\elevation-result.json` → `%ProgramData%\KeepDesktopInteractive\setup-result.json`: `Installed: true`, `Status: Ready`; Máy khách cục bộ `%LOCALAPPDATA%\KeepDesktopInteractive\local-rdp-minimize-result.json`: `Succeeded: true`.

<a id="proof"></a>

## Kiểm tra thao tác thật

Trước khi thử nghiệm, hãy ghi thời điểm bắt đầu, dừng tự động hóa UI khác, lưu việc nhạy cảm và ẩn các cửa sổ chứa thông tin bí mật; ngắt kết nối kích hoạt chẩn đoán. Thời gian sửa đổi tệp phải sau thời điểm bắt đầu thử nghiệm, với Passed/Mode phù hợp; sau đó thử nhấp chuột, nhập liệu và chụp màn hình an toàn trong một ứng dụng đại diện của bạn ở độ phân giải console sau chuyển phiên. Kết quả chẩn đoán không chứng minh rằng mọi ứng dụng đều hoạt động đúng.

Ngắt 30 giây rồi kết nối lại. Trên máy chủ, kiểm tra `%LOCALAPPDATA%\KeepDesktopInteractive\desktop-proof.json` mới cập nhật cho lần thử này: `Passed: true`, `Mode: AfterDisconnect`.

Thu nhỏ có điều kiện: làm riêng [thử nghiệm 90 giây / chờ 60 giây](../configuration.md#verify-on-each-new-machine) cho `WhileClientMinimized`. Nếu thất bại, giữ cửa sổ hiển thị.

<a id="limits"></a>

- Sau khởi động lại, tự đăng nhập, mở khóa và chạy ứng dụng; không tự đăng nhập. Khóa từ xa, ngủ và đăng xuất có thể dừng thao tác.
- Tương thích tùy máy khách và phiên bản, không chứng nhận mọi Dev Box: [bằng chứng](../configuration.md#reported-compatibility-evidence).
- Windows Sandbox thu nhỏ trong khi khách vẫn chạy: **CHƯA KIỂM CHỨNG**; [thử nghiệm](../configuration.md#sandbox-minimized-window-experiment), không phải bước RDP.

## Sự cố và hoàn tác

Kết quả lỗi, thiếu hoặc cũ? Xem `Error`, `Stage`, kiểm tra cài đặt rồi thử lại. [Khắc phục sự cố](../configuration.md#proof-and-setup-troubleshooting) · [Kiểm tra cấu hình](../configuration.md#configuration-checks)

<a id="undo"></a>

Xóa tác vụ máy chủ và khôi phục registry máy khách không khóa console. Lưu và kết thúc tự động hóa; khóa máy chủ rồi xác nhận cần đăng nhập, hoặc chủ ý đăng xuất để kết thúc ứng dụng.

[Hoàn tác](../configuration.md#undo) · [Hướng dẫn chuẩn tiếng Anh](../configuration.md) · [README tiếng Anh](../../README.md) · [Cập nhật](../configuration.md#updating-the-first-prototype)
