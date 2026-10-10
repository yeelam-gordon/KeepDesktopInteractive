# KeepDesktopInteractive — Otomatisasi GUI Windows setelah RDP terputus

[English](../../README.md) · [简体中文](README.zh-CN.md) · [繁體中文](README.zh-TW.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Español](README.es.md) · [Português (Brasil)](README.pt-BR.md) · [Français](README.fr.md) · [Deutsch](README.de.md) · [Italiano](README.it.md) · [Русский](README.ru.md) · [Türkçe](README.tr.md) · [Tiếng Việt](README.vi.md) · [Bahasa Indonesia](README.id.md) · [हिन्दी](README.hi.md) · [العربية](README.ar.md)

> **Peringatan: pengalihan sesi ke konsol membuat desktop Windows jarak jauh tetap tidak terkunci. Siapa pun yang dapat mengakses keyboard fisik atau konsol interaktif VM dapat memakai sesi tanpa masuk ke Windows. Jangan gunakan pada PC bersama yang bisa didekati orang lain. Anda harus memercayai administrator Hyper-V dan semua orang yang dapat membuka VMConnect. Akun pengujian atau VM cloud tidak otomatis aman. Ikuti kebijakan organisasi: alat ini bukan otomatisasi di balik layar jarak jauh yang terkunci dan tidak melewati kebijakan penguncian.**

Otomatisasi GUI Windows berhenti setelah RDP terputus? Pertahankan sesi pengguna **yang sudah login dan tidak terkunci** agar agen computer-use atau pengujian UI yang ada dapat terus mengeklik, mengetik, dan mengambil tangkapan layar. Kegagalan input saat jendela diminimalkan merupakan kasus terpisah yang memerlukan klien kompatibel dan verifikasi tersendiri. Tidak ada integrasi bawaan atau peluncuran agen, penyimpanan kata sandi, maupun login otomatis.

**Dua komputer:** host jarak jauh adalah PC/VM Windows yang menjalankan otomatisasi; klien lokal adalah PC Windows dengan RDP/Windows App. Diperlukan Windows PowerShell 5.1, VBScript, dan Git untuk kloning. Instalasi host memerlukan persetujuan administrator. Pada keduanya, ambil salinan baru yang tepercaya ke folder pribadi pengguna saat ini, bukan folder bersama yang dapat ditulis orang lain.

```powershell
git clone https://github.com/yeelam-gordon/KeepDesktopInteractive.git "$env:LOCALAPPDATA\KeepDesktopInteractiveSource"
Set-Location "$env:LOCALAPPDATA\KeepDesktopInteractiveSource"
```

Buka folder hasil kloning pada setiap komputer dan jalankan perintah dari sana. Perintah pertama dijalankan di host jarak jauh dengan persetujuan peningkatan hak administrator; yang kedua di klien lokal.

```powershell
wscript.exe .\start-desktop-session-setup.vbs
```

```powershell
wscript.exe .\set-local-rdp-minimize-rendering.vbs
```

Tutup sepenuhnya aplikasi klien jarak jauh, buka lagi, lalu sambungkan kembali. [Hasil instalasi](../configuration.md#quick-setup): host `Installed: true`, `Status: Ready`; klien `Succeeded: true`.

**Verifikasi pertama:** putuskan RDP seperti biasa, tunggu 30 detik lalu sambungkan kembali; diagnostik berjalan otomatis. Untuk uji minimisasi terpisah, jalankan perintah berikut di host jarak jauh, segera minimalkan jendela jarak jauh di klien selama 90 detik, lalu pulihkan. Pengujian menunggu 60 detik sebelum input nyata dan tangkapan layar.

```powershell
wscript.exe .\test-interactive-desktop-automation.vbs --minimized-test
```

Di host, periksa `%LOCALAPPDATA%\KeepDesktopInteractive\desktop-proof.json` yang baru. Berikut contoh bidang yang diharapkan untuk setiap pengujian, bukan hasil pengukuran dalam pembaruan ini:

```json
{ "Passed": true, "Mode": "AfterDisconnect" }
```

```json
{ "Passed": true, "Mode": "WhileClientMinimized" }
```

Uji minimisasi hanya sah jika jendela tetap diminimalkan selama input dan pengambilan gambar; host tidak dapat mengamati keadaan klien. Simpan log dan gambar secara privat karena bisa memuat konten desktop di sekitarnya. [Rincian verifikasi](../configuration.md#verify-on-each-new-machine).

**Batasan:** pengaturan didokumentasikan untuk Remote Desktop Connection klasik; dukungan Windows App tergantung versinya. Pengelola melaporkan bahwa pasangan klien/host awal lulus uji minimisasi sebelum penguatan keamanan, tetapi belum diuji ulang setelah penerapan. Ini bukan dukungan untuk semua klien. Setelah mulai ulang, masuk dan buka kunci sekali, lalu jalankan lagi aplikasi dan otomatisasi. Desktop tanpa antarmuka tidak tercakup. Penguncian jarak jauh, mode tidur, mematikan komputer, dan keluar dari akun masih dapat menghentikan otomatisasi. [Semua batasan](../configuration.md#requirements-and-limitations).

Jika `Passed: false`, baca `Error`, `Stage`, dan log. Jika bukti hilang atau lama, periksa instalasi dan ulangi pengujian. Jika klien tidak mendukung minimisasi, biarkan jendela terlihat atau gunakan alur pemutusan yang diverifikasi secara terpisah. [Pemecahan masalah](../../README.md#if-the-proof-fails) · [Pemeriksaan konfigurasi](../configuration.md#configuration-checks).

**Batalkan pengaturan:** jalankan dari folder kloning masing-masing. Perintah pertama menghapus tugas terjadwal di host jarak jauh; yang kedua memulihkan pengaturan klien pada PC lokal dan pengguna yang sama.

```powershell
wscript.exe .\start-desktop-session-setup.vbs --uninstall
```

```powershell
wscript.exe .\set-local-rdp-minimize-rendering.vbs --restore
```

Simpan `%LOCALAPPDATA%\KeepDesktopInteractive\local-rdp-minimize-backup.json` milik klien sampai pemulihan tidak diperlukan lagi. Kedua tindakan terpisah dan tidak menghapus bukti diagnostik. [Pembatalan](../configuration.md#undo) · [Panduan acuan bahasa Inggris](../configuration.md) · [README bahasa Inggris](../../README.md).
