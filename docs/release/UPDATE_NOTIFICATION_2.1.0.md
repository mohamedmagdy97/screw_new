# إشعار تحديث 2.1.0 — جاهز للإرسال

كل الأجهزة مشتركة في topic اسمه `allUsers`، فالإرسال يكون من
Firebase Console ← Messaging ← New campaign ← Notifications.

## الخطوات
1. Target: **Topic** ← `allUsers` (مش User segment).
2. الصق العنوان والنص أدناه.
3. Scheduling: **Schedule ← Once ← اليوم 10:15** وتأكد من المنطقة الزمنية **Africa/Cairo** (غالبًا 10:15 مساءً = 22:15).
4. (اختياري) Additional options ← Custom data:
   - `type` = `update`
   - `priority` = `high`
   - `actionUrl` = `https://play.google.com/store/apps/details?id=com.megTech.screw_calculator`
5. Review ← Publish. لا تضغط Publish قبل ما النسخة تظهر على Google Play.

## النسخة العربية (الأساسية)
**العنوان:** سكرو حاسبة 2.1 — تصميم جديد كليًا ✨

**النص:** تحديث كبير: ألوان وتصميم عصري، اختيار الكروت بلمسة، تعديل أي جولة، إحصائيات اللاعبين، بطولة الأصدقاء، ووضع فاتح/داكن. حدّث الآن!

## بديل أقصر
**العنوان:** تحديث جديد لسكرو حاسبة 🎴

**النص:** شكل جديد وميزات أكتر. حدّث التطبيق من جوجل بلاي الآن.

## English (لو حبيت حملة منفصلة للإنجليزي)
**Title:** Screw Calculator 2.1 — all new ✨

**Body:** Fresh design, tap-to-pick cards, edit any round, player stats and friends tournaments. Update now!

## ملاحظات
- لازم الإصدار يكون منشور فعلًا (versionCode أعلى من الحالي) قبل الموعد، وإلا الضغط على الإشعار هيودّي لنسخة قديمة.
- الإشعار هيظهر كمان داخل شاشة "الإشعارات" في التطبيق لأن التطبيق بيحفظ رسائل FCM محليًا.
