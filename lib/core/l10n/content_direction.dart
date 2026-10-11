import 'package:flutter/material.dart';

/// اتجاه المحتوى حسب لغة التطبيق.
///
/// هيكل الواجهة (الأشرطة والصفوف) يبقى LTR كما صُمِّم التطبيق أصلًا، أمّا
/// **المحتوى** فيتبع اللغة: العربي يبدأ من اليمين والإنجليزي من اليسار.
extension ContentDirection on BuildContext {
  bool get isArabicLocale => Localizations.localeOf(this).languageCode == 'ar';

  /// اتجاه محتوى الشاشة/الحقل: RTL للعربي، LTR للإنجليزي.
  TextDirection get contentDirection =>
      isArabicLocale ? TextDirection.rtl : TextDirection.ltr;

  /// محاذاة النص لبداية القراءة (يمين للعربي، يسار للإنجليزي) داخل واجهة LTR.
  TextAlign get readStart => isArabicLocale ? TextAlign.end : TextAlign.start;

  /// نفس الفكرة لـ [CrossAxisAlignment].
  CrossAxisAlignment get readStartCross =>
      isArabicLocale ? CrossAxisAlignment.end : CrossAxisAlignment.start;
}
