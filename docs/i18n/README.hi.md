# KeepDesktopInteractive — RDP टूटने के बाद GUI इनपुट बनाए रखें

<a id="languages"></a>

<details>
<summary>Languages (16)</summary>

[English](../../README.md) · [简体中文](README.zh-CN.md) · [繁體中文](README.zh-TW.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Español](README.es.md) · [Português (Brasil)](README.pt-BR.md) · [Français](README.fr.md) · [Deutsch](README.de.md) · [Italiano](README.it.md) · [Русский](README.ru.md) · [Türkçe](README.tr.md) · [Tiếng Việt](README.vi.md) · [Bahasa Indonesia](README.id.md) · [हिन्दी](README.hi.md) · [العربية](README.ar.md)

</details>

मौजूदा Windows डेस्कटॉप पर एजेंट और UI टेस्ट के लिए: Windows App क्लाइंट है; Microsoft Dev Box या RDP वाला अन्य Windows कंप्यूटर होस्ट हो सकता है।

<img src="../../assets/keep-desktop-interactive.png" width="700" alt="अवधारणा: RDP क्लाइंट बंद करें, जुड़े रहते हुए छोटा करें या डिस्कनेक्ट करें। ऐप गणना जारी रखते हैं; पहले बॉट का इनपुट रुका है, बाद में वह Hello भेजकर मुस्कुराता है। भरोसेमंद और पहले से अनलॉक होस्ट आवश्यक; कंसोल अनलॉक रहता है। क्लाइंट का व्यवहार जाँचें।">

अंग्रेज़ी लेबल वाला अवधारणा चित्र, परीक्षण प्रमाण नहीं।

- **क्लिक, टाइपिंग और स्क्रीनशॉट जारी रखें।**
- **कनेक्शन पर लगातार नज़र न रखें।**
- **पहले से साइन इन किए हुए डेस्कटॉप और खुले ऐप का फिर उपयोग करें; पासवर्ड सहेजे नहीं जाते।**

> **हस्तांतरण के बाद दूरस्थ डेस्कटॉप अनलॉक रहता है।** भौतिक या इंटरैक्टिव VM कंसोल चला सकने वाला व्यक्ति Windows में साइन इन किए बिना सत्र का उपयोग कर सकता है। दूसरों की पहुँच वाले साझा PC या अविश्वसनीय कंसोल पर उपयोग न करें। यह लॉक स्क्रीन पर ऑटोमेशन या नीति को दरकिनार करने का तरीका नहीं है। [सेटअप और पहुँच जोखिम](../configuration.md).

दोनों कंप्यूटरों पर Windows चाहिए। होस्ट पर पहले से लॉगिन किया गया हो, वह अनलॉक हो और स्लीप मोड में न हो; नीतियाँ अनुमति दें। होस्ट प्रशासक की मंज़ूरी, Git, Windows PowerShell 5.1 और VBScript चाहिए।

स्थापित निदान कॉन्फ़िगर किए गए उपयोगकर्ता के हर RDP डिस्कनेक्ट के लगभग 10 सेकंड बाद क्लिक/टाइप/कैप्चर का प्रयास करता है, सामान्य उपयोग में भी, और एजेंट से टकरा सकता है। केवल निदान बंद करने का दस्तावेज़ित लॉन्चर विकल्प नहीं है; होस्ट हटाने से हस्तांतरण भी हटता है।

<a id="setup"></a>

## दोनों कंप्यूटर तैयार करें

दोनों पर वर्तमान उपयोगकर्ता के निजी फ़ोल्डर में नया भरोसेमंद क्लोन लें, साझा लिखने योग्य फ़ोल्डर में नहीं। File Explorer में `%LOCALAPPDATA%\KeepDesktopInteractiveSource` खोलकर संबंधित लॉन्चर पर डबल-क्लिक करें।

```powershell
git clone https://github.com/yeelam-gordon/KeepDesktopInteractive.git "$env:LOCALAPPDATA\KeepDesktopInteractiveSource"
```

| रिमोट होस्ट / लोकल क्लाइंट | |
| --- | --- |
| रिमोट होस्ट | `start-desktop-session-setup.vbs` — प्रशासक अधिकार की मंज़ूरी दें |
| लोकल क्लाइंट | `set-local-rdp-minimize-rendering.vbs` — Windows App/RDP पूरी तरह बंद करें, खोलें और फिर जुड़ें |

[इंस्टॉलेशन परिणाम](../configuration.md#quick-setup): रिमोट होस्ट `%LOCALAPPDATA%\KeepDesktopInteractive\elevation-result.json` → `%ProgramData%\KeepDesktopInteractive\setup-result.json`: `Installed: true`, `Status: Ready`; लोकल क्लाइंट `%LOCALAPPDATA%\KeepDesktopInteractive\local-rdp-minimize-result.json`: `Succeeded: true`.

<a id="proof"></a>

## वास्तविक इनपुट जाँचें

जाँच से पहले आरंभ समय दर्ज करें, अन्य UI ऑटोमेशन रोकें, संवेदनशील काम सहेजें और गोपनीय विंडो हटाएँ; डिस्कनेक्ट पर निदान स्वतः चलता है। फ़ाइल आरंभ के बाद बदली हो और Passed/Mode सही हों; फिर परिणामी कंसोल रिज़ॉल्यूशन में हानिरहित प्रतिनिधि ऐप पर क्लिक/टाइप/कैप्चर जाँचें। निदान सभी ऐप का प्रमाण नहीं है।

30 सेकंड डिस्कनेक्ट करके फिर जुड़ें। होस्ट पर इस टेस्ट में अपडेट हुई `%LOCALAPPDATA%\KeepDesktopInteractive\desktop-proof.json` में `Passed: true` और `Mode: AfterDisconnect` जाँचें।

मिनिमाइज़ करना सशर्त है: `WhileClientMinimized` के लिए अलग [90 सेकंड का टेस्ट / 60 सेकंड की देरी](../configuration.md#verify-on-each-new-machine) अपनाएँ। विफल हो तो विंडो दिखाई देती रहने दें।

<a id="limits"></a>

- रीबूट के बाद स्वयं लॉगिन, अनलॉक और ऐप शुरू करें; ऑटो लॉगिन नहीं। रिमोट लॉक, स्लीप और साइन आउट काम रोक सकते हैं।
- समर्थन क्लाइंट और संस्करण पर निर्भर है, सभी Dev Box का प्रमाणन नहीं: [प्रमाण](../configuration.md#reported-compatibility-evidence)।
- अतिथि चालू रहते हुए Windows Sandbox मिनिमाइज़: **असत्यापित**; [प्रयोग](../configuration.md#sandbox-minimized-window-experiment), RDP निर्देश नहीं।

## विफलता और वापस करना

परिणाम विफल, गायब या पुराना हो तो `Error`, `Stage` और इंस्टॉलेशन जाँचकर फिर टेस्ट करें। [समस्या निवारण](../configuration.md#proof-and-setup-troubleshooting) · [कॉन्फ़िगरेशन जाँच](../configuration.md#configuration-checks)

<a id="undo"></a>

होस्ट टास्क हटाना और क्लाइंट रजिस्ट्री बहाल करना कंसोल को लॉक नहीं करता। काम सहेजकर ऑटोमेशन समाप्त करें; होस्ट लॉक कर साइन इन की आवश्यकता जाँचें, या ऐप बंद करने के लिए जानबूझकर साइन आउट करें।

[वापस करना](../configuration.md#undo) · [मुख्य अंग्रेज़ी गाइड](../configuration.md) · [अंग्रेज़ी README](../../README.md) · [अपडेट](../configuration.md#updating-the-first-prototype)
