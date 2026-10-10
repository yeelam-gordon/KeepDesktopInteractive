# KeepDesktopInteractive — RDP kesilince Windows GUI

<a id="languages"></a>

<details>
<summary>Languages / 语言 / 言語 / اللغات (16)</summary>

[English](../../README.md) · [简体中文](README.zh-CN.md) · [繁體中文](README.zh-TW.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Español](README.es.md) · [Português (Brasil)](README.pt-BR.md) · [Français](README.fr.md) · [Deutsch](README.de.md) · [Italiano](README.it.md) · [Русский](README.ru.md) · [Türkçe](README.tr.md) · [Tiếng Việt](README.vi.md) · [Bahasa Indonesia](README.id.md) · [हिन्दी](README.hi.md) · [العربية](README.ar.md)

</details>

Windows App istemci, Microsoft Dev Box ana makine veya başka bir Windows RDP ortamı: kesinti algılandıktan sonra computer-use ajanının tıklama, yazma ve ekran görüntülerini koruyun; bağlı pencereyi sürekli izlemeyi bırakın (küçültme, doğrulanmış uyumlu görüntüleme gerektirir); açık oturumu parola saklamadan veya otomatik giriş olmadan yeniden kullanın.

Konsol kilitsiz kalır; ilkelere uyun. Windows Sandbox küçültme: doğrulanmadı.

<img src="../../assets/keep-desktop-interactive.png" width="700" alt="RDP kesilmesi veya k&#252;&#231;&#252;ltme &#246;ncesi ve sonrası: uygulamalar &#231;alışırken tıklama, yazma ve ekran yakalama durabilir; konsola aktarım ve uyumlu istemci yardımcı olur.">

- **Kesintiden sonra ajan girdisini koruyun:** Windows RDP kesintisini algıladığında mevcut masaüstünde tıklama, yazma ve ekran görüntülerini sürdürün; ağ kaybının algılanması zaman alabilir.
- **Bağlı pencereyi sürekli izlemeyi bırakın:** uzak pencereden ayrılın; küçültme uyumlu istemci görüntülemesi ve kendi ortamınızda ayrı bir başarılı girdi testi gerektirir.
- **Oturumu açık işi yeniden kullanın:** mevcut oturumu ve açık uygulamaları parola saklamadan veya otomatik giriş açmadan koruyun; araç yeniden başlatmadan sonra oturum açmaz.

İngilizce etiketli kavramsal görseldir, canlı test değildir. İstemci desteği ve uyanık dizüstünde yerel kilit koşullara bağlıdır.

> **Aktarım uzak masaüstünü kilitsiz bırakır.** Fiziksel veya etkileşimli VM konsolunu kullanabilen biri Windows’ta oturum açmadan oturumu kullanabilir. Başkalarının erişebildiği ortak bilgisayarda veya güvenilmeyen konsolda kullanmayın. Kilitli ekranda otomasyon ya da ilke atlatma sağlamaz. [Kurulum ve erişim riskleri](../configuration.md).

Yalnızca ilkeler RDP/konsol aktarımının yapılandırılmasına izin veriyorsa; kendi ortamınızı doğrulayın. Bu, tüm Dev Box yapılandırmalarının doğrulandığı anlamına gelmez; kendi ortamınızı test edin.

[Kurulum ve erişim riskleri](#setup) → [Gerçek girdiyi doğrula](#proof) · [Sınırlar](#limits) · [Geri alma](#undo) · Windows Sandbox penceresini küçültme: henüz doğrulanmadı.

**[Windows Sandbox](https://learn.microsoft.com/en-us/windows/security/application-security/application-isolation/windows-sandbox/) — küçültülmüş pencere; DOĞRULANMAMIŞ aday:** Ana makinedeki Windows Sandbox penceresi küçültüldüğünde konuk ve uygulamalar çalışmaya devam ederken tıklama, yazma ve ekran görüntüsü de sürdürülebilir mi? Kurulum ve girdi sürekliliği doğrulanmadı; bu araç Sandbox istemci işlemesi veya konuk aktarımıyla çalışabilir de çalışmayabilir de, ayrı test gerekir ve doğrulanmış bir çözüm değildir.

## Windows App / RDP

Kurulu tanılama, günlük kullanım dahil yapılandırılmış kullanıcının her RDP kesilmesinden yaklaşık 10 saniye sonra tıklama/yazma/yakalamayı dener ve ajanla çakışabilir. Yalnız tanılamayı kapatan belgelenmiş başlatıcı seçeneği yoktur; ana makineyi kaldırmak aktarımı da kaldırır.

Windows App/RDP yolu: bağlantı kesilmesi ana makine aktarımını, küçültme uyumlu istemci işlemesini ve ana makine kurulumunu kullanır. Test edilmiş iki bilgisayar kurulumunu koruyup her modu doğrulayın. Ajan entegrasyonu/başlatma, parola kaydı veya otomatik giriş yoktur. [→](../configuration.md#mode-choice)

Bakımcı yerel ekran kilidinin yalnız uyanık dizüstü ve ayarlı istemciden oluşan test çiftinde geçtiğini bildirdi; uzak kilit değildir. Kapak/ağ kaybında Windows kesilmeyi algılamalıdır.

## Windows Sandbox — UNVALIDATED

Sandbox önerilen deneydir: onaylı, çalışır kurulum/test yöntemi belirlenemezse durun. Görünür pencerede hassas olmayan tıklama/yazma/yakalama temelini kaydedin; konuk ve uygulamalar çalışırken kaydedilmiş süre boyunca küçültüp gerçek girdi ve yeni yakalamayı tekrarlayın, geri getirip inceleyin. Doğrulanmadı; hata halinde pencereyi görünür tutun. İki bilgisayarlı RDP, bağlantı kesme ve kapatıp açma adımları Sandbox yöntemi değildir. [→](../configuration.md#sandbox-minimized-window-experiment)

<a id="setup"></a>

Kurulumdan önce ana makine açık, uyanık ve kilitsiz olmalı; ilkeler bu kullanıma izin vermelidir. Windows, yönetici onayı, Git, PowerShell 5.1 ve VBScript gereksinimleri aşağıdadır.

## İki bilgisayar

uzak ana makine, otomasyonu çalıştıran Windows PC/VM’dir; yerel istemci, RDP/Windows App çalıştıran Windows PC’dir. Windows PowerShell 5.1, VBScript ve klonlama için Git gerekir. Ana makinede kurulum yönetici onayı ister. Her iki bilgisayarda geçerli kullanıcının özel klasörüne yeni ve güvenilir bir kopya alın; ortak yazılabilir klasör kullanmayın.

<details>
<summary>Windows App / Microsoft Dev Box / Hyper-V</summary>

> **Windows App bağlantı istemcisidir; Microsoft Dev Box yönetilen bulut iş istasyonudur. Risk ürünün kendisi değil, başkasının kilidi açık konsola erişmesidir. Güvenilmeyen kişiler için etkileşimli konsol erişimi olmayan, tek geliştiricili yönetilen bir ana makine ortak PC’den daha düşük risklidir. Microsoft Dev Box’ın böyle bir erişim sunduğunu varsaymayın. Kurum politikalarına uyun: bu araç kilitli uzak ekranın arkasında otomasyon sağlamaz, kilitleme politikalarını aşmaz.**

</details>


```powershell
git clone https://github.com/yeelam-gordon/KeepDesktopInteractive.git "$env:LOCALAPPDATA\KeepDesktopInteractiveSource"
Set-Location "$env:LOCALAPPDATA\KeepDesktopInteractiveSource"
```

Her bilgisayarda klonlanan klasörü açıp komutları orada çalıştırın. İlk komut uzak ana makinede yönetici yetkisi onaylanarak, ikinci komut yerel istemcide çalıştırılır.

```powershell
wscript.exe .\start-desktop-session-setup.vbs
```

```powershell
wscript.exe .\set-local-rdp-minimize-rendering.vbs
```

Uzak istemciyi tamamen kapatıp yeniden açın ve tekrar bağlanın. [Kurulum sonuçları](../configuration.md#quick-setup): ana makinede `Installed: true`, `Status: Ready`; istemcide `Succeeded: true` olmalıdır.

<a id="proof"></a>

- Windows RDP bağlantısının kesildiğini algıladığında mevcut oturum konsola aktarılır; GUI girdisini sürdürmeye yardımcı olur.
- İşleme ayarı uyumlu istemcilerde küçültülmüş pencereye yardımcı olur; ayrıca test edin.
- Yalnızca açık uygulamalara değil, doğru moddaki özel sonuçlarla gerçek tıklama, yazma ve görüntü yakalamaya bakın.

Test öncesi başlangıç zamanını kaydedin, diğer UI otomasyonunu durdurun, hassas işleri kaydedip gizli pencereleri kaldırın; bağlantı kesilmesi tanılamayı başlatır. Dosya değişimi başlangıçtan sonra olmalı, Passed/Mode eşleşmeli; ardından oluşan konsol çözünürlüğünde zararsız örnek uygulamada tıklama/yazma/yakalama test edin. Tanılama tüm uygulamaları kanıtlamaz. [→](../configuration.md#reported-compatibility-evidence)

## İlk doğrulama

RDP bağlantısını normal şekilde kesin, 30 saniye bekleyip yeniden bağlanın; tanılama otomatik çalışır. Ayrı küçültme testi için aşağıdaki komutu uzak ana makinede çalıştırın, yerel istemcideki uzak pencereyi hemen küçültüp 90 saniye öyle bırakın, sonra geri açın. Test gerçek giriş ve ekran yakalamadan önce 60 saniye bekler.

```powershell
wscript.exe .\test-interactive-desktop-automation.vbs --minimized-test
```

Ana makinede yeni `%LOCALAPPDATA%\KeepDesktopInteractive\desktop-proof.json` dosyasını kontrol edin. Aşağıdakiler her test için beklenen alan örnekleridir; bu güncellemede ölçülmüş sonuçlar değildir:

```json
{ "Passed": true, "Mode": "AfterDisconnect" }
```

```json
{ "Passed": true, "Mode": "WhileClientMinimized" }
```

Küçültme testi yalnızca giriş ve ekran yakalama sırasında pencere küçültülmüş kalırsa geçerlidir; ana makine istemcinin durumunu göremez. Günlükleri ve görüntüleri gizli tutun; yakındaki masaüstü içeriğini gösterebilirler. [Doğrulama ayrıntıları](../configuration.md#verify-on-each-new-machine).

<a id="limits"></a>

## Sınırlar

ayar klasik Remote Desktop Connection için belgelenmiştir; Windows App desteği sürüme bağlıdır. Bakım sorumlusunun bildirdiğine göre özgün istemci/ana makine çifti güvenlik sıkılaştırmasından önce küçültme testini geçmiştir, ancak dağıtımdan sonra tekrar doğrulanmamıştır. Bu, tüm istemcilerin desteklendiği anlamına gelmez. Yeniden başlatmadan sonra bir kez oturum açıp kilidi kaldırın, ardından uygulamaları ve otomasyonu başlatın. Grafik arayüzü olmayan masaüstleri kapsam dışıdır. Uzak kilit, uyku, kapanma ve oturum kapatma otomasyonu durdurabilir. [Tüm sınırlar](../configuration.md#requirements-and-limitations).

`Passed: false` ise `Error`, `Stage` ve günlükleri okuyun. Kanıt yoksa veya eskiyse kurulumu kontrol edip testi tekrarlayın. Küçültmeyi desteklemeyen istemcilerde pencereyi görünür bırakın ya da ayrı doğrulanan bağlantı kesme akışını kullanın. [Sorun giderme](../../README.md#if-the-proof-fails) · [Yapılandırma kontrolleri](../configuration.md#configuration-checks).

<a id="undo"></a>

Görev kaldırma/istemciyi geri yükleme mevcut konsolu otomatik kilitlemez. Kaydedip otomasyonu bitirin; ana makineyi elle kilitleyip giriş istendiğini doğrulayın veya uygulamaları bitirmek için bilerek oturumu kapatın. Kilitleme GUI otomasyonunu durdurur.

## Geri alma

ilgili klon klasörlerinden çalıştırın. İlk komut uzak ana makinedeki zamanlanmış görevleri kaldırır; ikinci komut aynı yerel PC’de aynı kullanıcıyla istemci ayarlarını geri yükler.

```powershell
wscript.exe .\start-desktop-session-setup.vbs --uninstall
```

```powershell
wscript.exe .\set-local-rdp-minimize-rendering.vbs --restore
```

Geri yükleme gerekmeyene kadar istemcideki `%LOCALAPPDATA%\KeepDesktopInteractive\local-rdp-minimize-backup.json` dosyasını saklayın. İşlemler bağımsızdır, tanılama kanıtlarını silmez. [Geri alma](../configuration.md#undo) · [Esas İngilizce kılavuz](../configuration.md) · [İngilizce README](../../README.md).

Güncellemeyi yeni özel klasöre alın, mevcut dolu klasöre yeniden klonlamayın; eski kopya ve yedekleri başarılı kurulum/doğrulamaya kadar saklayın. [→](../configuration.md#updating-the-first-prototype)
