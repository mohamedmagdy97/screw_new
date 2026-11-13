# إشعار تحديث 2.2.0: جاهز للإرسال

كل الأجهزة مشتركة في topic اسمه `allUsers`، فالإرسال يكون من
Firebase Console ← Messaging ← New campaign ← Notifications.

## الخطوات
1. Target: **Topic** ← `allUsers` (مش User segment).
2. الصق العنوان والنص أدناه.
3. Scheduling: اختار ميعاد بالليل بتوقيت **Africa/Cairo** (مثلًا 10:15 مساءً = 22:15).
4. (اختياري) Additional options ← Custom data:
   - `type` = `update`
   - `priority` = `high`
   - `actionUrl` = `https://play.google.com/store/apps/details?id=com.megTech.screw_calculator`
5. Review ← Publish. لا تضغط Publish قبل ما النسخة 2.2.0 (versionCode 16) تظهر على Google Play.

## اللي جديد في النسخة دي
- صفحة «عن التطبيق»: إيه هو التطبيق، مين المطوّر، تواصل على واتساب برسالة جاهزة، اقتراح فكرة، نسخ الإيميل، تقييم ومشاركة، وتراخيص المكتبات.
- «تطبيقات تانية من MegTech»: باقي تطبيقاتنا (محكمة، الحقيقة المجهولة، Clenova) بلينك المتجر.
- صفحة «تواصل معنا» اتشالت، وكل طرق التواصل بقت في «عن التطبيق».
- نافذة تقييم المتجر بتظهر لوحدها بعد حفظ جولة كاملة (3 مرات بالكتير، ومرة كل 90 يوم).
- هوية MegTech الجديدة في القائمة الجانبية وصفحة «عن التطبيق».

## النسخة العربية (الأساسية)
**العنوان:** سكرو حاسبة 2.2: شوف مين ورا التطبيق 👋

**النص:** صفحة «عن التطبيق» الجديدة: كلّمنا على واتساب واقترح أفكارك، واكتشف تطبيقات تانية من MegTech. حدّث الآن!

## بديل أقصر
**العنوان:** تحديث جديد لسكرو حاسبة 🎴

**النص:** صفحة «عن التطبيق» وتطبيقات جديدة من MegTech. حدّث من جوجل بلاي.

## English (لو حبيت حملة منفصلة للإنجليزي)
**Title:** Screw Calculator 2.2 👋

**Body:** New About page: message us on WhatsApp, suggest ideas, and discover more apps from MegTech. Update now!

## «ما الجديد» في Google Play (Release notes)
```
<ar>
• صفحة «عن التطبيق» جديدة: تواصل معانا على واتساب واقترح أفكارك
• تطبيقات تانية من MegTech
• تحسينات وإصلاحات
</ar>
<en-US>
• New About page: reach us on WhatsApp and suggest ideas
• More apps from MegTech
• Improvements and fixes
</en-US>
```

## ملاحظات
- لازم الإصدار يكون منشور فعلًا (versionCode 16) قبل الموعد، وإلا الضغط على الإشعار هيودّي لنسخة قديمة.
- الإشعار هيظهر كمان جوّه شاشة «الإشعارات» في التطبيق لأن التطبيق بيحفظ رسائل FCM محليًا.
- إشعارات `type = contact` القديمة بقت بتفتح «عن التطبيق».
