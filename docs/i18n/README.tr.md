# KeepDesktopInteractive — RDP kesilince GUI girdisini sürdürün

<a id="languages"></a>

<details>
<summary>Languages (16)</summary>

[English](../../README.md) · [简体中文](README.zh-CN.md) · [繁體中文](README.zh-TW.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Español](README.es.md) · [Português (Brasil)](README.pt-BR.md) · [Français](README.fr.md) · [Deutsch](README.de.md) · [Italiano](README.it.md) · [Русский](README.ru.md) · [Türkçe](README.tr.md) · [Tiếng Việt](README.vi.md) · [Bahasa Indonesia](README.id.md) · [हिन्दी](README.hi.md) · [العربية](README.ar.md)

</details>

Mevcut Windows masaüstünde ajanlar ve UI testleri için: Windows App istemcidir; Microsoft Dev Box veya RDP kullanan başka bir Windows bilgisayar ana makine olabilir.

<img src="../../assets/keep-desktop-interactive.png" width="320" alt="Kavramsal görsel: bağlantı kesilince tıklama ve yazmayı sürdürün; küçültürken test edilmiş uyumlu istemciyle uzak pencereyi sürekli izlemeyin; zaten oturum açtığınız masaüstünü parola saklamadan yeniden kullanın. Konsola aktarım masaüstünü kilitsiz bırakır.">

İngilizce etiketli kavramsal görsel, test kanıtı değildir.

- **Tıklama, yazma ve yakalamayı sürdürün.**
- **Bağlantıyı sürekli izlemeyin.**
- **Zaten oturum açtığınız masaüstünü ve açık uygulamaları yeniden kullanın; parola saklanmaz.**

> **Aktarım uzak masaüstünü kilitsiz bırakır.** Fiziksel veya etkileşimli VM konsolunu kullanabilen biri Windows’ta oturum açmadan oturumu kullanabilir. Başkalarının erişebildiği ortak bilgisayarda veya güvenilmeyen konsolda kullanmayın. Kilitli ekranda otomasyon ya da ilke atlatma sağlamaz. [Kurulum ve erişim riskleri](../configuration.md).

İki bilgisayarda da Windows gerekir. Ana makinede oturum açık ve ekran kilitsiz olmalı; kullanım sırasında bilgisayar uykuya geçmemeli ve kurum ilkeleri bu kullanıma izin vermelidir. Ana makine yönetici onayı, Git, Windows PowerShell 5.1 ve VBScript gerekir.

Kurulu tanılama, günlük kullanım dahil yapılandırılmış kullanıcının her RDP kesilmesinden yaklaşık 10 saniye sonra tıklama/yazma/yakalamayı dener ve ajanla çakışabilir.

<a id="setup"></a>

## İki bilgisayarı kurun

İkisinde de geçerli kullanıcının özel klasörüne yeni ve güvenilir kopya klonlayın; ortak yazılabilir klasör kullanmayın. Dosya Gezgini’nde `%LOCALAPPDATA%\KeepDesktopInteractiveSource` klasörünü açıp ilgili başlatıcıya çift tıklayın.

```powershell
git clone https://github.com/yeelam-gordon/KeepDesktopInteractive.git "$env:LOCALAPPDATA\KeepDesktopInteractiveSource"
```

| Uzak ana makine / Yerel istemci | |
| --- | --- |
| Uzak ana makine | `start-desktop-session-setup.vbs` — yetki yükseltmeyi onaylayın |
| Yerel istemci | `set-local-rdp-minimize-rendering.vbs` — Windows App/RDP’yi tamamen kapatın, açıp yeniden bağlanın |

[Kurulum sonuçları](../configuration.md#quick-setup): Uzak ana makine `%LOCALAPPDATA%\KeepDesktopInteractive\elevation-result.json` → `%ProgramData%\KeepDesktopInteractive\setup-result.json`: `Installed: true`, `Status: Ready`; Yerel istemci `%LOCALAPPDATA%\KeepDesktopInteractive\local-rdp-minimize-result.json`: `Succeeded: true`.

<a id="proof"></a>

## Gerçek girdiyi doğrulayın

Test öncesi başlangıç zamanını kaydedin, diğer UI otomasyonunu durdurun, hassas işleri kaydedip gizli pencereleri kaldırın; bağlantı kesilmesi tanılamayı başlatır. Dosyanın değiştirilme zamanı testin başlangıcından sonra olmalı; `Passed` ve `Mode` değerleri bu teste uygun olmalıdır. Ardından oluşan konsol çözünürlüğünde güvenli bir örnek uygulamada tıklama, metin girişi ve ekran görüntüsü alma işlemlerini test edin. Tanılama tüm uygulamaları kanıtlamaz.

30 saniye bağlantıyı kesip yeniden bağlanın. Ana makinede bu testte güncellenen `%LOCALAPPDATA%\KeepDesktopInteractive\desktop-proof.json` dosyasında `Passed: true` ve `Mode: AfterDisconnect` arayın.

Küçültme koşulludur: `WhileClientMinimized` için ayrı [90 saniyelik test / 60 saniyelik bekleme](../configuration.md#verify-on-each-new-machine) uygulayın. Başarısızsa pencereyi görünür tutun.

<a id="limits"></a>

- Yeniden başlatınca elle giriş yapın, kilidi açın ve uygulamaları başlatın; otomatik giriş yok. Uzak kilit, uyku ve çıkış çalışmayı durdurabilir.
- Uyumluluk istemci ve sürüme bağlıdır; genel Dev Box sertifikası değildir: [kanıt](../configuration.md#reported-compatibility-evidence).
- Konuk çalışırken küçültülmüş Windows Sandbox: **DOĞRULANMADI**; [deney](../configuration.md#sandbox-minimized-window-experiment), RDP talimatı değil.

## Hatalar ve geri alma

Kanıt başarısız, eksik veya eskiyse `Error`, `Stage` ve kurulumu kontrol edip yeniden test edin. [Sorun giderme](../configuration.md#proof-and-setup-troubleshooting) · [Yapılandırma kontrolleri](../configuration.md#configuration-checks)

<a id="undo"></a>

Ana makine görevlerini kaldırmak ve istemci kayıt defterini geri yüklemek konsolu kilitlemez. Kaydedip otomasyonu bitirin; ana makineyi kilitleyip giriş istendiğini doğrulayın veya uygulamaları bitirmek için oturumu kapatın.

[Geri alma](../configuration.md#undo) · [Esas İngilizce kılavuz](../configuration.md) · [İngilizce README](../../README.md) · [Güncelleme](../configuration.md#updating-the-first-prototype)
