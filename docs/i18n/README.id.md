# KeepDesktopInteractive — GUI Windows setelah RDP terputus

<a id="languages"></a>

<details>
<summary>Languages / 语言 / 言語 / اللغات (16)</summary>

[English](../../README.md) · [简体中文](README.zh-CN.md) · [繁體中文](README.zh-TW.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Español](README.es.md) · [Português (Brasil)](README.pt-BR.md) · [Français](README.fr.md) · [Deutsch](README.de.md) · [Italiano](README.it.md) · [Русский](README.ru.md) · [Türkçe](README.tr.md) · [Tiếng Việt](README.vi.md) · [Bahasa Indonesia](README.id.md) · [हिन्दी](README.hi.md) · [العربية](README.ar.md)

</details>

Windows App sebagai klien, Microsoft Dev Box sebagai host, atau lingkungan Windows RDP lain: pertahankan klik, pengetikan, dan tangkapan layar agen computer-use setelah koneksi terputus terdeteksi; berhenti mengawasi jendela terhubung (minimisasi perlu rendering kompatibel terverifikasi); gunakan kembali sesi login tanpa menyimpan sandi atau login otomatis.

Konsol tetap tidak terkunci; patuhi kebijakan. Minimisasi Windows Sandbox: belum divalidasi.

<img src="../../assets/keep-desktop-interactive.png" width="700" alt="Sebelum dan sesudah RDP terputus atau jendela diminimalkan: aplikasi berjalan tetapi klik, pengetikan dan tangkapan layar dapat berhenti; pengalihan konsol dan klien kompatibel membantu.">

- **Pertahankan input agen setelah koneksi terputus:** jaga klik, pengetikan, dan tangkapan layar desktop yang ada setelah Windows mendeteksi RDP terputus; deteksi kehilangan jaringan bisa memerlukan waktu.
- **Berhenti mengawasi jendela terhubung:** menjauhlah dari jendela jarak jauh; minimisasi membutuhkan rendering kompatibel dan uji input terpisah yang berhasil di lingkungan Anda.
- **Gunakan kembali pekerjaan yang sudah login:** pertahankan sesi dan aplikasi terbuka tanpa menyimpan sandi atau mengaktifkan login otomatis; alat ini tidak melakukan login setelah reboot.

Konsep berlabel Inggris, bukan uji langsung. Dukungan klien dan penguncian lokal dengan laptop tetap aktif memiliki syarat.

> **Pengalihan membuat desktop jarak jauh tetap tidak terkunci.** Siapa pun yang dapat mengoperasikan konsol fisik atau interaktif VM dapat memakai sesi tanpa masuk ke Windows. Jangan gunakan PC bersama yang mudah diakses atau konsol yang tidak tepercaya. Bukan otomatisasi di balik layar terkunci atau bypass kebijakan. [Penyiapan dan risiko akses](../configuration.md).

Hanya jika kebijakan mengizinkan konfigurasi pengalihan RDP/konsol; verifikasi lingkungan Anda, bukan sertifikasi seluruh konfigurasi Dev Box.

[Penyiapan dan risiko akses](#setup) → [Verifikasi input nyata](#proof) · [Batasan](#limits) · [Batalkan pengaturan](#undo) · Minimisasi Windows Sandbox: belum divalidasi.

**[Windows Sandbox](https://learn.microsoft.com/en-us/windows/security/application-security/application-isolation/windows-sandbox/) — jendela diminimalkan; kandidat BELUM DIVALIDASI:** Ketika jendela Windows Sandbox pada host diminimalkan dan guest beserta aplikasinya tetap berjalan, apakah klik, pengetikan, dan tangkapan layar berlanjut? Penerapan dan kesinambungan input belum divalidasi; alat ini mungkin bekerja atau tidak dengan rendering klien atau pengalihan guest Sandbox, perlu diuji terpisah dan bukan solusi yang sudah terbukti.

## Windows App / RDP

Diagnosis terpasang mencoba klik/ketik/tangkapan sekitar 10 detik setelah setiap pemutusan RDP pengguna yang dikonfigurasi, termasuk penggunaan biasa, dan dapat mengganggu agen. Tidak ada opsi peluncur terdokumentasi untuk menonaktifkan diagnosis saja; penghapusan host juga menghapus pengalihan.

Jalur Windows App/RDP: putus koneksi memakai pengalihan host; minimisasi memakai rendering kompatibel dan penyiapan host. Pertahankan penyiapan dua komputer yang diuji dan verifikasi tiap mode. Tanpa integrasi/peluncuran agen, sandi tersimpan, atau login otomatis. [→](../configuration.md#mode-choice)

Pemelihara melaporkan kunci layar lokal berhasil hanya pada pasangan uji dengan laptop tetap aktif dan klien dikonfigurasi, bukan kunci jarak jauh; tutup laptop/jaringan memerlukan deteksi putus koneksi oleh Windows.

## Windows Sandbox — UNVALIDATED

Sandbox adalah eksperimen usulan: berhenti jika metode penerapan/pengujian yang disetujui dan berfungsi belum ditetapkan. Catat klik/ketik/tangkapan tidak sensitif saat jendela terlihat; minimalkan selama interval tercatat dengan guest/aplikasi berjalan, ulangi input dan tangkapan baru, pulihkan lalu periksa. Belum divalidasi; jika gagal biarkan jendela terlihat. Langkah RDP dua komputer, pemutusan, dan tutup/buka bukan prosedur Sandbox. [→](../configuration.md#sandbox-minimized-window-experiment)

<a id="setup"></a>

Sebelum memasang: host menyala, tidak tidur, dan tidak terkunci; kebijakan mengizinkan penggunaan ini. Persyaratan Windows, persetujuan administrator, Git, PowerShell 5.1, dan VBScript ada di bawah.

## Dua komputer

host jarak jauh adalah PC/VM Windows yang menjalankan otomatisasi; klien lokal adalah PC Windows dengan RDP/Windows App. Diperlukan Windows PowerShell 5.1, VBScript, dan Git untuk kloning. Instalasi host memerlukan persetujuan administrator. Pada keduanya, ambil salinan baru yang tepercaya ke folder pribadi pengguna saat ini, bukan folder bersama yang dapat ditulis orang lain.

<details>
<summary>Windows App / Microsoft Dev Box / Hyper-V</summary>

> **Windows App adalah klien koneksi; Microsoft Dev Box adalah workstation cloud terkelola. Risiko berasal dari akses orang lain ke konsol yang tidak terkunci, bukan ketidakamanan bawaan produk. Host terkelola untuk satu pengembang tanpa jalur akses konsol interaktif bagi orang yang tidak tepercaya lebih rendah risikonya daripada PC bersama. Jangan anggap Microsoft Dev Box menyediakan akses tersebut. Ikuti kebijakan organisasi: alat ini bukan otomatisasi di balik layar jarak jauh yang terkunci dan tidak melewati kebijakan penguncian.**

</details>


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

<a id="proof"></a>

- Setelah Windows mendeteksi koneksi RDP terputus, sesi yang ada dialihkan ke konsol untuk membantu mempertahankan input GUI.
- Pengaturan rendering membantu klien yang kompatibel saat diminimalkan; uji secara terpisah.
- Periksa klik, pengetikan, dan tangkapan nyata melalui hasil privat dengan mode yang sesuai, bukan hanya aplikasi yang berjalan.

Sebelum uji catat waktu mulai, hentikan otomatisasi UI lain, simpan pekerjaan sensitif dan singkirkan jendela rahasia; putus koneksi memicu diagnosis. File harus diperbarui setelah mulai dengan Passed/Mode sesuai; lalu uji klik/ketik/tangkapan aman pada aplikasi representatif di resolusi konsol hasil pengalihan. Diagnosis bukan bukti semua aplikasi. [→](../configuration.md#reported-compatibility-evidence)

## Verifikasi pertama

putuskan RDP seperti biasa, tunggu 30 detik lalu sambungkan kembali; diagnostik berjalan otomatis. Untuk uji minimisasi terpisah, jalankan perintah berikut di host jarak jauh, segera minimalkan jendela jarak jauh di klien selama 90 detik, lalu pulihkan. Pengujian menunggu 60 detik sebelum input nyata dan tangkapan layar.

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

<a id="limits"></a>

## Batasan

pengaturan didokumentasikan untuk Remote Desktop Connection klasik; dukungan Windows App tergantung versinya. Pengelola melaporkan bahwa pasangan klien/host awal lulus uji minimisasi sebelum penguatan keamanan, tetapi belum diuji ulang setelah penerapan. Ini bukan dukungan untuk semua klien. Setelah mulai ulang, masuk dan buka kunci sekali, lalu jalankan lagi aplikasi dan otomatisasi. Desktop tanpa antarmuka tidak tercakup. Penguncian jarak jauh, mode tidur, mematikan komputer, dan keluar dari akun masih dapat menghentikan otomatisasi. [Semua batasan](../configuration.md#requirements-and-limitations).

Jika `Passed: false`, baca `Error`, `Stage`, dan log. Jika bukti hilang atau lama, periksa instalasi dan ulangi pengujian. Jika klien tidak mendukung minimisasi, biarkan jendela terlihat atau gunakan alur pemutusan yang diverifikasi secara terpisah. [Pemecahan masalah](../../README.md#if-the-proof-fails) · [Pemeriksaan konfigurasi](../configuration.md#configuration-checks).

<a id="undo"></a>

Menghapus tugas/memulihkan klien tidak otomatis mengunci konsol saat ini. Simpan dan akhiri otomatisasi; kunci host secara manual dan pastikan login diperlukan, atau sengaja keluar untuk menutup aplikasi. Mengunci menghentikan otomatisasi GUI.

## Batalkan pengaturan

jalankan dari folder kloning masing-masing. Perintah pertama menghapus tugas terjadwal di host jarak jauh; yang kedua memulihkan pengaturan klien pada PC lokal dan pengguna yang sama.

```powershell
wscript.exe .\start-desktop-session-setup.vbs --uninstall
```

```powershell
wscript.exe .\set-local-rdp-minimize-rendering.vbs --restore
```

Simpan `%LOCALAPPDATA%\KeepDesktopInteractive\local-rdp-minimize-backup.json` milik klien sampai pemulihan tidak diperlukan lagi. Kedua tindakan terpisah dan tidak menghapus bukti diagnostik. [Pembatalan](../configuration.md#undo) · [Panduan acuan bahasa Inggris](../configuration.md) · [README bahasa Inggris](../../README.md).

Perbarui ke tujuan privat baru, jangan klon ulang ke folder yang sudah terisi; simpan salinan lama dan cadangan hingga penyiapan/verifikasi berhasil. [→](../configuration.md#updating-the-first-prototype)
