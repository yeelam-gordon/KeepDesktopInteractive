# KeepDesktopInteractive — Duy trì tự động hóa GUI Windows sau khi ngắt RDP

Tự động hóa GUI Windows dừng sau khi ngắt RDP? Giữ phiên **đã đăng nhập và không khóa** để các tác nhân computer-use hoặc bài kiểm thử UI hiện có tiếp tục nhấp chuột, nhập văn bản và chụp màn hình. Lỗi nhập khi thu nhỏ cửa sổ là trường hợp riêng, cần máy khách tương thích và kiểm chứng riêng. Không tích hợp trực tiếp với tác nhân hay khởi chạy tác nhân, không lưu mật khẩu hoặc bật đăng nhập tự động.

> **Chuyển phiên để màn hình từ xa ở trạng thái mở khóa.** Ai có thể thao tác bảng điều khiển vật lý hoặc tương tác của VM có thể dùng phiên mà không đăng nhập Windows. Không dùng máy chung dễ tiếp cận hoặc bảng điều khiển không đáng tin. Không tự động hóa trên màn hình bị khóa hay vượt chính sách. [Thiết lập và rủi ro truy cập](../configuration.md).

[Thiết lập và rủi ro truy cập](#setup) → [Kiểm tra thao tác thực tế](#proof) · [Giới hạn](#limits) · [Hoàn tác](#undo)

- Khi Windows phát hiện RDP ngắt kết nối, phiên hiện có được chuyển sang bảng điều khiển để hỗ trợ duy trì thao tác GUI.
- Thiết lập kết xuất hỗ trợ máy khách tương thích khi thu nhỏ; cần kiểm tra riêng.
- Kiểm tra nhấp chuột, gõ và chụp thực tế bằng kết quả riêng tư đúng chế độ, không chỉ nhìn ứng dụng còn chạy.

<details>
<summary>Languages</summary>

[English](../../README.md) · [简体中文](README.zh-CN.md) · [繁體中文](README.zh-TW.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Español](README.es.md) · [Português (Brasil)](README.pt-BR.md) · [Français](README.fr.md) · [Deutsch](README.de.md) · [Italiano](README.it.md) · [Русский](README.ru.md) · [Türkçe](README.tr.md) · [Tiếng Việt](README.vi.md) · [Bahasa Indonesia](README.id.md) · [हिन्दी](README.hi.md) · [العربية](README.ar.md)

</details>

<a id="setup"></a>

Trước khi cài: máy chủ bật, không ngủ và đã mở khóa; chính sách phải cho phép. Yêu cầu Windows, quyền quản trị, Git, PowerShell 5.1 và VBScript ở dưới.

## Hai máy tính

máy chủ từ xa là PC/máy ảo Windows chạy tự động hóa; máy khách cục bộ là PC Windows chạy RDP/Windows App. Cần Windows PowerShell 5.1, VBScript và Git để sao chép kho mã. Cài đặt trên máy chủ cần quản trị viên chấp thuận. Trên cả hai máy, lấy bản sao mới từ nguồn tin cậy vào thư mục riêng của người dùng hiện tại, không dùng thư mục chia sẻ cho phép ghi.

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

<a id="proof"></a>

## Kiểm chứng lần đầu

ngắt RDP bình thường, đợi 30 giây rồi kết nối lại; chẩn đoán chạy tự động. Để kiểm tra thu nhỏ riêng biệt, chạy lệnh bên dưới trên máy chủ từ xa, lập tức thu nhỏ cửa sổ từ xa trên máy khách trong 90 giây rồi mở lại. Phép thử đợi 60 giây trước khi thực hiện nhập liệu thật và chụp màn hình.

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

<img src="../../assets/keep-desktop-interactive.png" width="700" alt="Trước v&#224; sau khi ngắt RDP hoặc thu nhỏ: ứng dụng vẫn chạy nhưng nhấp chuột, g&#245; v&#224; chụp m&#224;n h&#236;nh c&#243; thể dừng; chuyển sang console v&#224; m&#225;y kh&#225;ch tương th&#237;ch gi&#250;p duy tr&#236; thao t&#225;c.">

Hình minh họa khái niệm: bên trái ứng dụng chạy nhưng tự động hóa bị kẹt; bên phải là nhấp chuột, gõ và chụp ảnh mong đợi sau cấu hình. Nhãn trong hình bằng tiếng Anh, không phải giao diện đã dịch hay phép thử trực tiếp. Thu nhỏ tùy máy khách; đóng máy tính xách tay hoặc mất mạng cần Windows phát hiện ngắt RDP. Console vẫn không khóa; hãy kiểm chứng máy của bạn. Khóa máy cục bộ chỉ đã qua trên cặp do người bảo trì báo cáo, khi laptop không ngủ và đã thiết lập máy khách. Thử nghiệm thu nhỏ diễn ra trước gia cố bảo mật, chưa kiểm tra lại sau triển khai.

<a id="limits"></a>

## Giới hạn

thiết lập được tài liệu hóa cho Remote Desktop Connection cổ điển; hỗ trợ Windows App tùy phiên bản. Người bảo trì báo cáo cặp máy khách/máy chủ ban đầu đã đạt phép thử thu nhỏ trước khi tăng cường bảo mật, nhưng chưa được kiểm tra lại sau triển khai. Không có nghĩa là mọi máy khách đều được hỗ trợ. Sau khi khởi động lại, đăng nhập và mở khóa một lần, rồi khởi chạy ứng dụng và tự động hóa. Không hỗ trợ môi trường headless không có phiên làm việc đồ họa tương tác. Khóa máy từ xa, ngủ, tắt máy và đăng xuất vẫn có thể ngắt tự động hóa. [Đầy đủ giới hạn](../configuration.md#requirements-and-limitations).

Nếu `Passed: false`, đọc `Error`, `Stage` và nhật ký. Nếu thiếu hoặc cũ, kiểm tra cài đặt và thử lại. Khi máy khách không hỗ trợ thu nhỏ, giữ cửa sổ hiển thị hoặc dùng quy trình ngắt kết nối đã kiểm chứng riêng. [Khắc phục sự cố](../../README.md#if-the-proof-fails) · [Kiểm tra cấu hình](../configuration.md#configuration-checks).

<a id="undo"></a>

## Hoàn tác

chạy từ các thư mục sao chép tương ứng. Lệnh đầu xóa tác vụ theo lịch trên máy chủ từ xa; lệnh thứ hai khôi phục thiết lập máy khách trên cùng PC cục bộ với cùng người dùng.

```powershell
wscript.exe .\start-desktop-session-setup.vbs --uninstall
```

```powershell
wscript.exe .\set-local-rdp-minimize-rendering.vbs --restore
```

Giữ `%LOCALAPPDATA%\KeepDesktopInteractive\local-rdp-minimize-backup.json` của máy khách cho đến khi không cần khôi phục nữa. Hai thao tác độc lập và không xóa bằng chứng chẩn đoán. [Hoàn tác](../configuration.md#undo) · [Hướng dẫn chuẩn tiếng Anh](../configuration.md) · [README tiếng Anh](../../README.md).

<details>
<summary>Windows App / Microsoft Dev Box / Hyper-V</summary>

> **Cảnh báo: chuyển phiên sang console sẽ để màn hình Windows từ xa ở trạng thái không khóa. Người có quyền tiếp cận bàn phím vật lý hoặc console tương tác của máy ảo có thể dùng phiên của bạn mà không cần đăng nhập Windows. Không dùng trên PC dùng chung mà người khác có thể tiếp cận. Bạn phải tin cậy quản trị viên Hyper-V và mọi người có thể mở VMConnect. Windows App là máy khách kết nối; Microsoft Dev Box là máy trạm đám mây được quản lý. Rủi ro là người khác truy cập console không khóa, không phải bản thân sản phẩm thiếu an toàn. Máy chủ được quản lý cho một nhà phát triển, không có đường truy cập console tương tác cho người không tin cậy, ít rủi ro hơn PC dùng chung. Không mặc định Microsoft Dev Box cung cấp đường truy cập đó. Tuân thủ chính sách tổ chức: công cụ không chạy tự động hóa sau màn hình từ xa đã khóa và không vượt qua chính sách khóa.**

</details>
