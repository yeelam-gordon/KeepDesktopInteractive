# KeepDesktopInteractive — RDP डिस्कनेक्ट होने के बाद Windows GUI ऑटोमेशन जारी रखें

[English](../../README.md) · [简体中文](README.zh-CN.md) · [繁體中文](README.zh-TW.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Español](README.es.md) · [Português (Brasil)](README.pt-BR.md) · [Français](README.fr.md) · [Deutsch](README.de.md) · [Italiano](README.it.md) · [Русский](README.ru.md) · [Türkçe](README.tr.md) · [Tiếng Việt](README.vi.md) · [Bahasa Indonesia](README.id.md) · [हिन्दी](README.hi.md) · [العربية](README.ar.md)

> **चेतावनी: सत्र को कंसोल पर सौंपने के बाद रिमोट Windows डेस्कटॉप अनलॉक रहता है। भौतिक कीबोर्ड या VM के इंटरैक्टिव कंसोल तक पहुँच रखने वाला व्यक्ति Windows में साइन इन किए बिना आपका सत्र इस्तेमाल कर सकता है। ऐसे साझा PC पर उपयोग न करें जिसके पास अन्य लोग पहुँच सकते हों। Hyper-V प्रशासकों और VMConnect खोल सकने वाले सभी लोगों पर भरोसा होना ज़रूरी है। टेस्ट खाता या क्लाउड VM अपने आप सुरक्षित नहीं होता। संगठन की नीतियाँ मानें: यह लॉक की हुई रिमोट स्क्रीन के पीछे ऑटोमेशन नहीं चलाता और लॉक नीतियों को दरकिनार नहीं करता।**

RDP डिस्कनेक्ट होने पर Windows GUI ऑटोमेशन रुकता है? मौजूदा computer-use एजेंट या UI टेस्ट के क्लिक, टाइपिंग और स्क्रीनशॉट के लिए **पहले से साइन इन किया हुआ, अनलॉक सत्र** बनाए रखें। विंडो मिनिमाइज़ करने पर इनपुट रुकना अलग मामला है; उसके लिए संगत क्लाइंट और अलग जाँच चाहिए। एजेंट के साथ बिल्ट-इन एकीकरण या उसे शुरू करने की सुविधा नहीं है; पासवर्ड सहेजना या ऑटोमैटिक लॉगिन भी नहीं है।

**दो कंप्यूटर:** रिमोट होस्ट वह Windows PC/VM है जिस पर ऑटोमेशन चलता है; लोकल क्लाइंट वह Windows PC है जिस पर RDP/Windows App चलता है। Windows PowerShell 5.1, VBScript और क्लोन करने के लिए Git चाहिए। होस्ट पर इंस्टॉलेशन के लिए प्रशासक की मंज़ूरी चाहिए। दोनों पर मौजूदा उपयोगकर्ता के निजी फ़ोल्डर में नया भरोसेमंद क्लोन लें, न कि साझा लिखने योग्य फ़ोल्डर में।

```powershell
git clone https://github.com/yeelam-gordon/KeepDesktopInteractive.git "$env:LOCALAPPDATA\KeepDesktopInteractiveSource"
Set-Location "$env:LOCALAPPDATA\KeepDesktopInteractiveSource"
```

दोनों कंप्यूटरों पर क्लोन किया फ़ोल्डर खोलें और उसी से कमांड चलाएँ। पहला कमांड रिमोट होस्ट पर चलाकर प्रशासक अधिकार की मंज़ूरी दें; दूसरा लोकल क्लाइंट पर चलाएँ।

```powershell
wscript.exe .\start-desktop-session-setup.vbs
```

```powershell
wscript.exe .\set-local-rdp-minimize-rendering.vbs
```

लोकल कंप्यूटर पर RDP/Windows App को पूरी तरह बंद करें, फिर खोलकर रिमोट होस्ट से दोबारा जुड़ें। [इंस्टॉलेशन परिणाम](../configuration.md#quick-setup): होस्ट पर `Installed: true`, `Status: Ready`; क्लाइंट पर `Succeeded: true` होना चाहिए।

**पहली जाँच:** सामान्य रूप से RDP डिस्कनेक्ट करें, 30 सेकंड प्रतीक्षा करके दोबारा जुड़ें; डायग्नोस्टिक अपने आप चलता है। मिनिमाइज़ की अलग जाँच के लिए नीचे का कमांड रिमोट होस्ट पर चलाएँ, तुरंत लोकल क्लाइंट की रिमोट विंडो मिनिमाइज़ करके 90 सेकंड तक रखें, फिर वापस खोलें। जाँच वास्तविक इनपुट और स्क्रीनशॉट से पहले 60 सेकंड प्रतीक्षा करती है।

```powershell
wscript.exe .\test-interactive-desktop-automation.vbs --minimized-test
```

होस्ट पर नई `%LOCALAPPDATA%\KeepDesktopInteractive\desktop-proof.json` देखें। ये प्रत्येक जाँच के अपेक्षित फ़ील्ड के उदाहरण हैं, इस अपडेट में मापे गए परिणाम नहीं:

```json
{ "Passed": true, "Mode": "AfterDisconnect" }
```

```json
{ "Passed": true, "Mode": "WhileClientMinimized" }
```

मिनिमाइज़ जाँच तभी मान्य है जब इनपुट और स्क्रीनशॉट के दौरान विंडो लगातार मिनिमाइज़ रही हो; होस्ट क्लाइंट की स्थिति नहीं देख सकता। लॉग और तस्वीरें निजी रखें, क्योंकि उनमें आसपास का डेस्कटॉप भी दिख सकता है। [जाँच का विवरण](../configuration.md#verify-on-each-new-machine)।

**सीमाएँ:** सेटिंग क्लासिक Remote Desktop Connection के लिए दस्तावेज़ित है; Windows App का समर्थन संस्करण पर निर्भर है। रखरखावकर्ता के अनुसार मूल क्लाइंट/होस्ट जोड़ी ने सुरक्षा मज़बूत करने से पहले मिनिमाइज़ जाँच पास की थी, लेकिन तैनाती के बाद दोबारा जाँच नहीं हुई। सभी क्लाइंट का समर्थन सिद्ध नहीं होता। रीबूट के बाद एक बार साइन इन करके अनलॉक करें, फिर ऐप और ऑटोमेशन शुरू करें। बिना ग्राफ़िकल इंटरफ़ेस वाले डेस्कटॉप शामिल नहीं हैं। रिमोट लॉक, स्लीप, शटडाउन और साइन आउट ऑटोमेशन रोक सकते हैं। [सभी सीमाएँ](../configuration.md#requirements-and-limitations)।

`Passed: false` होने पर `Error`, `Stage` और लॉग पढ़ें। परिणाम गायब या पुराना हो तो इंस्टॉलेशन जाँचकर टेस्ट दोहराएँ। क्लाइंट मिनिमाइज़ का समर्थन न करे तो विंडो दिखाई देती रहने दें, उसे मिनिमाइज़ न करें या अलग से सत्यापित डिस्कनेक्ट प्रक्रिया अपनाएँ। [समस्या निवारण](../../README.md#if-the-proof-fails) · [कॉन्फ़िगरेशन जाँच](../configuration.md#configuration-checks)।

**सेटिंग वापस करना:** संबंधित क्लोन फ़ोल्डर से चलाएँ। पहला कमांड रिमोट होस्ट के शेड्यूल किए गए टास्क हटाता है; दूसरा उसी लोकल PC और उसी उपयोगकर्ता से क्लाइंट सेटिंग बहाल करता है।

```powershell
wscript.exe .\start-desktop-session-setup.vbs --uninstall
```

```powershell
wscript.exe .\set-local-rdp-minimize-rendering.vbs --restore
```

क्लाइंट की `%LOCALAPPDATA%\KeepDesktopInteractive\local-rdp-minimize-backup.json` तब तक रखें जब तक बहाली की ज़रूरत खत्म न हो जाए। दोनों काम अलग हैं और डायग्नोस्टिक सबूत नहीं मिटाते। [वापस करना](../configuration.md#undo) · [मुख्य अंग्रेज़ी गाइड](../configuration.md) · [अंग्रेज़ी README](../../README.md)।
