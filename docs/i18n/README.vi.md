# KeepDesktopInteractive — Duy trì tự động hóa GUI Windows sau khi ngắt RDP

[English](../../README.md) · [简体中文](README.zh-CN.md) · [繁體中文](README.zh-TW.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Español](README.es.md) · [Português (Brasil)](README.pt-BR.md) · [Français](README.fr.md) · [Deutsch](README.de.md) · [Italiano](README.it.md) · [Русский](README.ru.md) · [Türkçe](README.tr.md) · [Tiếng Việt](README.vi.md) · [Bahasa Indonesia](README.id.md) · [हिन्दी](README.hi.md) · [العربية](README.ar.md)

> **Cảnh báo: chuyển phiên sang console sẽ để màn hình Windows từ xa ở trạng thái không khóa. Người có quyền tiếp cận bàn phím vật lý hoặc console tương tác của máy ảo có thể dùng phiên của bạn mà không cần đăng nhập Windows. Không dùng trên PC dùng chung mà người khác có thể tiếp cận. Bạn phải tin cậy quản trị viên Hyper-V và mọi người có thể mở VMConnect. Tài khoản thử nghiệm hoặc máy ảo đám mây không tự động an toàn. Tuân thủ chính sách tổ chức: công cụ không chạy tự động hóa sau màn hình từ xa đã khóa và không vượt qua chính sách khóa.**

Tự động hóa GUI Windows dừng sau khi ngắt RDP? Giữ phiên **đã đăng nhập và không khóa** để các tác nhân computer-use hoặc bài kiểm thử UI hiện có tiếp tục nhấp chuột, nhập văn bản và chụp màn hình. Lỗi nhập khi thu nhỏ cửa sổ là trường hợp riêng, cần máy khách tương thích và kiểm chứng riêng. Không tích hợp trực tiếp với tác nhân hay khởi chạy tác nhân, không lưu mật khẩu hoặc bật đăng nhập tự động.

**Hai máy tính:** máy chủ từ xa là PC/máy ảo Windows chạy tự động hóa; máy khách cục bộ là PC Windows chạy RDP/Windows App. Cần Windows PowerShell 5.1, VBScript và Git để sao chép kho mã. Cài đặt trên máy chủ cần quản trị viên chấp thuận. Trên cả hai máy, lấy bản sao mới từ nguồn tin cậy vào thư mục riêng của người dùng hiện tại, không dùng thư mục chia sẻ cho phép ghi.

```powershell
git clone https://github.com/yeelam-gordon/KeepDesktopInteractive.git "$env:LOCALAPPDATA\KeepDesktopInteractiveSource"
Set-Location "$env:LOCALAPPDATA\KeepDesktopInteractiveSource"
```

Mở thư mục vừa sao chép trên từng máy và chạy lệnh từ đó. Lệnh đầu chạy trên máy chủ từ xa, chấp thuận nâng quyền quản trị; lệnh thứ hai chạy trên máy khách cục bộ.

```powershell
wscript.exe .\start-desktop-session-setup.vbs
```

```powershell
wscript.exe .\set-local-rdp-minimize-rendering.vbs
```

Đóng hoàn toàn ứng dụng máy khách từ xa, mở lại rồi kết nối lại. [Kết quả cài đặt](../configuration.md#quick-setup): máy chủ có `Installed: true`, `Status: Ready`; máy khách có `Succeeded: true`.

**Kiểm chứng lần đầu:** ngắt RDP bình thường, đợi 30 giây rồi kết nối lại; chẩn đoán chạy tự động. Để kiểm tra thu nhỏ riêng biệt, chạy lệnh bên dưới trên máy chủ từ xa, lập tức thu nhỏ cửa sổ từ xa trên máy khách trong 90 giây rồi mở lại. Phép thử đợi 60 giây trước khi thực hiện nhập liệu thật và chụp màn hình.

```powershell
wscript.exe .\test-interactive-desktop-automation.vbs --minimized-test
```

Trên máy chủ, xem bản mới của `%LOCALAPPDATA%\KeepDesktopInteractive\desktop-proof.json`. Đây là ví dụ các trường mong đợi cho từng phép thử, không phải kết quả đo trong lần cập nhật này:

```json
{ "Passed": true, "Mode": "AfterDisconnect" }
```

```json
{ "Passed": true, "Mode": "WhileClientMinimized" }
```

Phép thử thu nhỏ chỉ hợp lệ nếu cửa sổ luôn được thu nhỏ trong lúc nhập liệu và chụp ảnh; máy chủ không quan sát được trạng thái máy khách. Giữ nhật ký và ảnh riêng tư vì chúng có thể chứa nội dung gần cửa sổ thử nghiệm. [Chi tiết kiểm chứng](../configuration.md#verify-on-each-new-machine).

**Giới hạn:** thiết lập được tài liệu hóa cho Remote Desktop Connection cổ điển; hỗ trợ Windows App tùy phiên bản. Người bảo trì báo cáo cặp máy khách/máy chủ ban đầu đã đạt phép thử thu nhỏ trước khi tăng cường bảo mật, nhưng chưa được kiểm tra lại sau triển khai. Không có nghĩa là mọi máy khách đều được hỗ trợ. Sau khi khởi động lại, đăng nhập và mở khóa một lần, rồi khởi chạy ứng dụng và tự động hóa. Không hỗ trợ môi trường headless không có phiên làm việc đồ họa tương tác. Khóa máy từ xa, ngủ, tắt máy và đăng xuất vẫn có thể ngắt tự động hóa. [Đầy đủ giới hạn](../configuration.md#requirements-and-limitations).

Nếu `Passed: false`, đọc `Error`, `Stage` và nhật ký. Nếu thiếu hoặc cũ, kiểm tra cài đặt và thử lại. Khi máy khách không hỗ trợ thu nhỏ, giữ cửa sổ hiển thị hoặc dùng quy trình ngắt kết nối đã kiểm chứng riêng. [Khắc phục sự cố](../../README.md#if-the-proof-fails) · [Kiểm tra cấu hình](../configuration.md#configuration-checks).

**Hoàn tác:** chạy từ các thư mục sao chép tương ứng. Lệnh đầu xóa tác vụ theo lịch trên máy chủ từ xa; lệnh thứ hai khôi phục thiết lập máy khách trên cùng PC cục bộ với cùng người dùng.

```powershell
wscript.exe .\start-desktop-session-setup.vbs --uninstall
```

```powershell
wscript.exe .\set-local-rdp-minimize-rendering.vbs --restore
```

Giữ `%LOCALAPPDATA%\KeepDesktopInteractive\local-rdp-minimize-backup.json` của máy khách cho đến khi không cần khôi phục nữa. Hai thao tác độc lập và không xóa bằng chứng chẩn đoán. [Hoàn tác](../configuration.md#undo) · [Hướng dẫn chuẩn tiếng Anh](../configuration.md) · [README tiếng Anh](../../README.md).
