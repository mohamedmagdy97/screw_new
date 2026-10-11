import 'package:flutter/material.dart';
import 'package:screw_calculator/core/l10n/content_direction.dart';
import 'package:screw_calculator/core/widgets/app_header.dart';

/// شريط علوي قياسي للشاشات الفرعية: زر الرجوع في جهة بداية القراءة (يمين
/// للعربي ويسار للإنجليزي) و[leading] (إجراء إضافي اختياري) في الجهة المقابلة.
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    required this.title,
    this.leading,
    this.backResult,
  });

  final String title;

  /// إجراء إضافي اختياري في الجهة المقابلة لزر الرجوع.
  final Widget? leading;

  /// القيمة المُعادة عند الرجوع (مثل `true` لإعلام الشاشة السابقة).
  final Object? backResult;

  @override
  Size get preferredSize => const Size.fromHeight(AppHeader.height);

  @override
  Widget build(BuildContext context) {
    final back = HeaderBackButton(result: backResult);
    final arabic = context.isArabicLocale;
    return AppHeader(
      title: title,
      left: arabic ? leading : back,
      right: arabic ? back : leading,
    );
  }
}
