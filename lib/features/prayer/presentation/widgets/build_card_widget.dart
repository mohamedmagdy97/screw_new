import 'package:flutter/material.dart';
import 'package:screw_calculator/core/theme/app_palette.dart';
import 'package:screw_calculator/core/theme/app_theme.dart';
import 'package:screw_calculator/core/widgets/custom_text.dart';

class BuildPrayerCard extends StatelessWidget {
  final String title;
  final String time;
  final IconData icon;
  final bool? isCurrent;
  final bool? isNext;
  final bool? isInfo;

  const BuildPrayerCard({
    super.key,
    this.isCurrent = false,
    this.isNext = false,
    this.isInfo = false,
    required this.title,
    required this.time,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final bool current = isCurrent ?? false;
    final bool next = isNext ?? false;
    final bool info = isInfo ?? false;

    final Color highlight = current ? palette.brand : palette.accent;
    final Color cardColor = current || next
        ? Color.alphaBlend(highlight.withValues(alpha: 0.12), palette.surface)
        : palette.surface;
    final Color iconColor = info
        ? palette.textSecondary
        : (current || next ? highlight : palette.brandSoft);
    final Color textColor = info ? palette.textSecondary : palette.textPrimary;

    Widget? badge;
    if (current || next) {
      badge = Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: highlight,
          borderRadius: BorderRadius.circular(AppRadii.sm),
        ),
        child: CustomText(
          text: current ? 'الآن' : 'القادمة',
          fontFamily: AppFonts.bold,
          fontSize: 10,
          color: Colors.white,
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(
          color: current || next ? highlight : palette.border,
          width: current || next ? 1.6 : 1,
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 8),
          CustomText(
            text: time,
            fontSize: 22,
            fontFamily: AppFonts.bold,
            color: iconColor,
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (badge != null) badge,
                const SizedBox(width: 8),
                CustomText(
                  text: title,
                  fontSize: 16,
                  fontFamily: AppFonts.bold,
                  textAlign: TextAlign.right,
                  color: textColor,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadii.md - 2),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
        ],
      ),
    );
  }
}
