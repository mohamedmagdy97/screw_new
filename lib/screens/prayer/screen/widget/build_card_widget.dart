import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:screw_calculator/components/custom_text.dart';
import 'package:screw_calculator/utility/app_theme.dart';

class BuildCardWidget extends StatelessWidget {
  final String title;
  final String time;
  final IconData? icon;

  const BuildCardWidget(this.title, this.time, [this.icon, Key? key])
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.grey,
        borderRadius: BorderRadius.circular(12),
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
          CustomText(
            text: time,
            fontSize: 24,
            fontFamily: AppFonts.bold,
            color: AppColors.mainColor,
          ),

          const SizedBox(width: 16),
          Expanded(
            child: CustomText(
              text: title,
              fontSize: 20,
              fontFamily: AppFonts.bold,
              textAlign: TextAlign.right,
              color: AppColors.black,
            ),
          ),
          const SizedBox(width: 8),

          if (icon != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.mainColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.mainColor, size: 24),
            ),
        ],
      ),
    );
  }
}
