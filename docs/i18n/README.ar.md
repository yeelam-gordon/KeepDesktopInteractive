# KeepDesktopInteractive — استمرار أتمتة واجهة Windows بعد قطع اتصال RDP

[English](../../README.md) · [简体中文](README.zh-CN.md) · [繁體中文](README.zh-TW.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Español](README.es.md) · [Português (Brasil)](README.pt-BR.md) · [Français](README.fr.md) · [Deutsch](README.de.md) · [Italiano](README.it.md) · [Русский](README.ru.md) · [Türkçe](README.tr.md) · [Tiếng Việt](README.vi.md) · [Bahasa Indonesia](README.id.md) · [हिन्दी](README.hi.md) · [العربية](README.ar.md)

> **تحذير: نقل الجلسة إلى وحدة التحكم يترك سطح مكتب Windows البعيد دون قفل. يستطيع من يصل إلى لوحة المفاتيح الفعلية أو وحدة التحكم التفاعلية للآلة الافتراضية استخدام جلستك دون تسجيل الدخول إلى Windows. لا تستخدم هذا على حاسوب مشترك يمكن للآخرين الوصول إليه. يجب أن تثق بمسؤولي Hyper-V وبكل من يستطيع فتح VMConnect. حساب الاختبار أو الآلة الافتراضية السحابية ليس آمناً تلقائياً. التزم بسياسات مؤسستك: لا تتيح الأداة الأتمتة خلف شاشة بعيدة مقفلة ولا تتجاوز سياسات القفل.**

هل تتوقف أتمتة واجهة Windows بعد قطع اتصال RDP؟ احتفظ بجلسة **مسجّل الدخول إليها وغير مقفلة بالفعل** كي يستمر النقر والكتابة والتقاط الشاشة بواسطة وكلاء computer-use أو اختبارات الواجهة الحالية. توقف الإدخال عند تصغير النافذة حالة منفصلة تتطلب عميلاً متوافقاً واختباراً مستقلاً. لا يوجد تكامل أصلي مع الوكلاء أو تشغيل لهم، ولا حفظ لكلمات المرور أو تسجيل دخول تلقائي.

**حاسوبان:** المضيف البعيد هو حاسوب Windows أو آلة افتراضية تشغّل الأتمتة؛ والعميل المحلي هو حاسوب Windows يشغّل RDP/Windows App. تحتاج إلى Windows PowerShell 5.1 وVBScript وGit للاستنساخ. يتطلب تثبيت المضيف موافقة المسؤول. احصل على نسخة جديدة موثوقة في مجلد المستخدم الحالي الخاص على كلا الحاسوبين، وليس في مجلد مشترك قابل للكتابة.

<div dir="ltr">

```powershell
git clone https://github.com/yeelam-gordon/KeepDesktopInteractive.git "$env:LOCALAPPDATA\KeepDesktopInteractiveSource"
Set-Location "$env:LOCALAPPDATA\KeepDesktopInteractiveSource"
```

</div>

افتح المجلد المستنسخ على كل حاسوب ونفّذ الأوامر منه. نفّذ الأمر الأول على المضيف البعيد ووافق على تشغيله بصلاحيات المسؤول؛ ونفّذ الثاني على العميل المحلي. انسخ الأوامر كما هي؛ تُعرض كتل الشيفرة باتجاه من اليسار إلى اليمين.

<div dir="ltr">

```powershell
wscript.exe .\start-desktop-session-setup.vbs
```

</div>

<div dir="ltr">

```powershell
wscript.exe .\set-local-rdp-minimize-rendering.vbs
```

</div>

أغلق تطبيق العميل البعيد تماماً ثم افتحه وأعد الاتصال. [نتائج التثبيت](../configuration.md#quick-setup): على المضيف `Installed: true` و`Status: Ready`، وعلى العميل `Succeeded: true`.

**التحقق الأول:** اقطع اتصال RDP بالطريقة المعتادة، وانتظر 30 ثانية ثم أعد الاتصال؛ يعمل التشخيص تلقائياً. لاختبار التصغير المنفصل، نفّذ الأمر التالي على المضيف البعيد ثم صغّر نافذة الاتصال على العميل فوراً وأبقها مصغّرة 90 ثانية قبل استعادتها. ينتظر الاختبار 60 ثانية قبل الإدخال الفعلي والتقاط الشاشة.

<div dir="ltr">

```powershell
wscript.exe .\test-interactive-desktop-automation.vbs --minimized-test
```

</div>

على المضيف، راجع الملف الجديد `%LOCALAPPDATA%\KeepDesktopInteractive\desktop-proof.json`. هذه أمثلة للحقول المتوقعة لكل اختبار، وليست نتائج قياس أُجري في هذا التحديث:

<div dir="ltr">

```json
{ "Passed": true, "Mode": "AfterDisconnect" }
```

</div>

<div dir="ltr">

```json
{ "Passed": true, "Mode": "WhileClientMinimized" }
```

</div>

لا يُعتد بنجاح اختبار التصغير إلا إذا ظلت النافذة مصغّرة أثناء الإدخال والتقاط الشاشة؛ لا يستطيع المضيف مراقبة حالة العميل. احتفظ بالسجلات والصور بصورة خاصة، فقد تتضمن محتويات أخرى ظاهرة على سطح المكتب. [تفاصيل التحقق](../configuration.md#verify-on-each-new-machine).

**الحدود:** الإعداد موثّق لبرنامج Remote Desktop Connection التقليدي؛ يعتمد دعم Windows App على الإصدار. أفاد مسؤول صيانة المشروع بأن زوج العميل والمضيف الأصلي اجتاز اختبار التصغير قبل تعزيز الأمان، لكنه لم يُختبر مجدداً بعد النشر. هذا لا يثبت دعم جميع العملاء. بعد إعادة التشغيل، سجّل الدخول وافتح القفل مرة واحدة ثم أعد تشغيل التطبيقات والأتمتة. أسطح المكتب دون واجهة رسومية غير مشمولة. قد يوقف القفل البعيد والسكون وإيقاف التشغيل وتسجيل الخروج الأتمتة. [جميع الحدود](../configuration.md#requirements-and-limitations).

إذا ظهر `Passed: false` فاقرأ `Error` و`Stage` والسجلات. إذا كانت النتيجة غائبة أو قديمة، راجع التثبيت وكرّر الاختبار. إذا لم يدعم العميل التصغير، أبق النافذة ظاهرة أو استخدم مسار قطع الاتصال الذي تحققت منه بصورة منفصلة. [استكشاف الأخطاء](../../README.md#if-the-proof-fails) · [فحوص الإعداد](../configuration.md#configuration-checks).

**التراجع:** نفّذ من المجلدين المستنسخين المناسبين. يزيل الأمر الأول المهام المجدولة على المضيف البعيد؛ ويعيد الثاني إعدادات العميل على الحاسوب المحلي نفسه وبحساب المستخدم نفسه.

<div dir="ltr">

```powershell
wscript.exe .\start-desktop-session-setup.vbs --uninstall
```

</div>

<div dir="ltr">

```powershell
wscript.exe .\set-local-rdp-minimize-rendering.vbs --restore
```

</div>

احتفظ بملف العميل `%LOCALAPPDATA%\KeepDesktopInteractive\local-rdp-minimize-backup.json` حتى لا تعود بحاجة إلى الاستعادة. العمليتان مستقلتان ولا تحذفان الأدلة التشخيصية. [التراجع](../configuration.md#undo) · [الدليل المرجعي بالإنجليزية](../configuration.md) · [README بالإنجليزية](../../README.md).
