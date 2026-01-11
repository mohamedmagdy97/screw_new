import 'package:flutter/material.dart';
import 'package:screw_calculator/components/custom_text.dart';
import 'package:screw_calculator/utility/app_theme.dart';

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
    Color cardColor = Colors.white;
    Color textColor = AppColors.black;
    Color iconColor = AppColors.mainColor;
    Widget? badge;

    if (isCurrent ?? false) {
      cardColor = AppColors.mainColorAccent.withOpacity(0.15);
      iconColor = AppColors.mainColor;
      textColor = AppColors.white;
      badge = Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.mainColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const CustomText(
          text: 'الآن',
          fontFamily: AppFonts.bold,
          fontSize: 10,
        ),
      );
    } else if (isNext ?? false) {
      cardColor = Colors.blue[50]!;
      iconColor = Colors.blue[700]!;
      badge = Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.blue[700],
          borderRadius: BorderRadius.circular(8),
        ),

        child: const CustomText(
          text: 'القادمة',
          fontFamily: AppFonts.bold,
          fontSize: 10,
        ),
      );
    } else if (isInfo ?? false) {
      cardColor = Colors.grey[100]!;
      iconColor = Colors.grey[600]!;
      textColor = Colors.grey[700]!;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: ((isCurrent ?? false) || (isNext ?? false))
            ? Border.all(
                color: (isCurrent ?? false)
                    ? AppColors.mainColor
                    : Colors.blue[700]!,
                width: 2,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 8),
          CustomText(
            text: time,
            fontSize: 24,
            fontFamily: AppFonts.bold,
            color: (isCurrent ?? false) || (isNext ?? false)
                ? iconColor
                : AppColors.mainColor,
          ),

          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (badge != null) badge,
                const SizedBox(width: 8),

                CustomText(
                  text: title,
                  fontSize: 18,
                  fontFamily: AppFonts.bold,
                  textAlign: TextAlign.right,
                  color: textColor,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
        ],
      ),
    );
  }
}
