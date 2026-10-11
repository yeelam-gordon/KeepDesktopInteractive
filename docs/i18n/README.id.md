# KeepDesktopInteractive — Pertahankan input GUI setelah RDP terputus

<a id="languages"></a>

<details>
<summary>Languages (16)</summary>

[English](../../README.md) · [简体中文](README.zh-CN.md) · [繁體中文](README.zh-TW.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Español](README.es.md) · [Português (Brasil)](README.pt-BR.md) · [Français](README.fr.md) · [Deutsch](README.de.md) · [Italiano](README.it.md) · [Русский](README.ru.md) · [Türkçe](README.tr.md) · [Tiếng Việt](README.vi.md) · [Bahasa Indonesia](README.id.md) · [हिन्दी](README.hi.md) · [العربية](README.ar.md)

</details>

Untuk agen dan pengujian UI pada desktop Windows yang sudah ada: Windows App adalah klien; Microsoft Dev Box atau komputer Windows lain dengan RDP dapat menjadi host.

<img src="../../assets/keep-desktop-interactive.png" width="320" alt="Ilustrasi konsep: pertahankan klik dan ketik setelah koneksi terputus; tak perlu mengawasi jendela jarak jauh saat diminimalkan dengan klien kompatibel yang telah diuji; gunakan kembali desktop yang sudah login tanpa menyimpan sandi. Pengalihan konsol membiarkannya tidak terkunci.">

Ilustrasi konsep berlabel Inggris, bukan bukti uji.

- **Pertahankan klik, ketik, dan tangkapan layar.**
- **Tak perlu terus mengawasi koneksi.**
- **Gunakan kembali desktop yang sudah login dan aplikasi terbuka, tanpa menyimpan sandi.**

> **Pengalihan membuat desktop jarak jauh tetap tidak terkunci.** Siapa pun yang dapat mengoperasikan konsol fisik atau interaktif VM dapat memakai sesi tanpa masuk ke Windows. Jangan gunakan PC bersama yang mudah diakses atau konsol yang tidak tepercaya. Bukan otomatisasi di balik layar terkunci atau bypass kebijakan. [Penyiapan dan risiko akses](../configuration.md).

Kedua komputer memerlukan Windows. Host sudah login, tidak terkunci, tidak tidur, dan diizinkan kebijakan. Diperlukan persetujuan administrator host, Git, Windows PowerShell 5.1, dan VBScript.

Alat diagnostik yang terpasang mencoba klik/ketik/tangkapan sekitar 10 detik setelah setiap pemutusan RDP pengguna yang dikonfigurasi, termasuk penggunaan biasa, dan dapat mengganggu agen.

<a id="setup"></a>

## Siapkan kedua komputer

Klon salinan baru yang tepercaya ke folder pribadi pengguna saat ini pada keduanya, bukan folder bersama yang dapat ditulis. Buka `%LOCALAPPDATA%\KeepDesktopInteractiveSource` di File Explorer lalu klik dua kali peluncur yang sesuai.

```powershell
git clone https://github.com/yeelam-gordon/KeepDesktopInteractive.git "$env:LOCALAPPDATA\KeepDesktopInteractiveSource"
```

| Host jarak jauh / Klien lokal | |
| --- | --- |
| Host jarak jauh | `start-desktop-session-setup.vbs` — setujui peningkatan hak |
| Klien lokal | `set-local-rdp-minimize-rendering.vbs` — tutup sepenuhnya Windows App/RDP, buka lagi dan sambungkan |

[Hasil instalasi](../configuration.md#quick-setup): Host jarak jauh `%LOCALAPPDATA%\KeepDesktopInteractive\elevation-result.json` → `%ProgramData%\KeepDesktopInteractive\setup-result.json`: `Installed: true`, `Status: Ready`; Klien lokal `%LOCALAPPDATA%\KeepDesktopInteractive\local-rdp-minimize-result.json`: `Succeeded: true`.

<a id="proof"></a>

## Uji input nyata

Sebelum pengujian, catat waktu mulai, hentikan otomatisasi UI lain, simpan pekerjaan sensitif dan singkirkan jendela rahasia; putus koneksi memicu diagnosis. File harus diperbarui setelah mulai dengan Passed/Mode sesuai; lalu uji klik/ketik/tangkapan aman pada aplikasi representatif di resolusi konsol hasil pengalihan. Diagnosis bukan bukti semua aplikasi.

Putuskan koneksi selama 30 detik lalu sambungkan kembali. Pada host, periksa `%LOCALAPPDATA%\KeepDesktopInteractive\desktop-proof.json` yang diperbarui untuk uji ini: `Passed: true`, `Mode: AfterDisconnect`.

Minimisasi bersyarat: ikuti secara terpisah [uji 90 detik / jeda 60 detik](../configuration.md#verify-on-each-new-machine) untuk `WhileClientMinimized`. Jika gagal, biarkan jendela terlihat.

<a id="limits"></a>

- Setelah reboot, login, buka kunci, dan jalankan aplikasi sendiri; tanpa login otomatis. Kunci jarak jauh, tidur, dan logout dapat menghentikan otomatisasi.
- Kompatibilitas bergantung klien dan versi, bukan sertifikasi semua Dev Box: [bukti](../configuration.md#reported-compatibility-evidence).
- Windows Sandbox diminimalkan saat guest berjalan: **BELUM DIVALIDASI**; [eksperimen](../configuration.md#sandbox-minimized-window-experiment), bukan langkah RDP.

## Kegagalan dan pembatalan

Bukti gagal, hilang, atau lama? Periksa `Error`, `Stage`, dan instalasi, lalu uji ulang. [Pemecahan masalah](../configuration.md#proof-and-setup-troubleshooting) · [Pemeriksaan konfigurasi](../configuration.md#configuration-checks)

<a id="undo"></a>

Menghapus tugas host dan memulihkan registri klien tidak mengunci konsol. Simpan dan akhiri otomatisasi; kunci host dan pastikan login diperlukan, atau sengaja logout untuk menutup aplikasi.

[Pembatalan](../configuration.md#undo) · [Panduan acuan bahasa Inggris](../configuration.md) · [README bahasa Inggris](../../README.md) · [Pembaruan](../configuration.md#updating-the-first-prototype)
