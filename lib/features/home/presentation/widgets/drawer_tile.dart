import 'package:flutter/material.dart';
import 'package:screw_calculator/core/l10n/content_direction.dart';
import 'package:screw_calculator/core/theme/app_palette.dart';
import 'package:screw_calculator/core/theme/app_theme.dart';
import 'package:screw_calculator/core/widgets/custom_text.dart';

/// عنصر قائمة جانبية حديث: أيقونة ملوّنة داخل مربع دائري الزوايا + عنوان
/// (+ وصف اختياري) + عنصر نهائي (سهم أو مفتاح تبديل).
class DrawerTile extends StatelessWidget {
  const DrawerTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.color,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Color? color;

  /// يحلّ محل سهم التنقل الافتراضي (مثل [Switch]).
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final accent = color ?? palette.brand;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadii.md),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(AppRadii.sm + 4),
                  ),
                  child: Icon(icon, color: accent, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: title,
                        fontSize: 15.5,
                        textAlign: context.readStart,
                        height: 1.2,
                      ),
                      if (subtitle != null)
                        CustomText(
                          text: subtitle!,
                          fontSize: 12,
                          color: palette.textSecondary,
                          textAlign: context.readStart,
                          height: 1.3,
                        ),
                    ],
                  ),
                ),
                trailing ??
                    // الأيقونة تنعكس تلقائيًا مع اتجاه النص (RTL ← تشير لليسار).
                    Icon(
                      Icons.chevron_right_rounded,
                      color: palette.textSecondary,
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// عنوان قسم داخل القائمة الجانبية.
class DrawerSectionLabel extends StatelessWidget {
  const DrawerSectionLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 16, 22, 4),
      child: Align(
        alignment: context.isArabicLocale
            ? Alignment.centerRight
            : Alignment.centerLeft,
        child: CustomText(
          text: text,
          fontSize: 12.5,
          color: context.palette.textSecondary,
          textAlign: context.readStart,
        ),
      ),
    );
  }
}
