import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:screw_calculator/components/custom_text.dart';
import 'package:screw_calculator/utility/app_theme.dart';

class BuildCardWidget extends StatelessWidget {
  final String name, time;

  const BuildCardWidget(this.name, this.time, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      width: 1.sw,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [
            AppColors.mainColor.withOpacity(0.6),
            AppColors.mainColor.withOpacity(0.4),
            AppColors.mainColor.withOpacity(0.2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: ListTile(
        leading: CustomText(
          text: time,
          fontWeight: FontWeight.bold,
          fontSize: 20,
          textAlign: TextAlign.end,
        ),
        title: CustomText(
          text: name,
          fontWeight: FontWeight.bold,
          fontSize: 20,
          textAlign: TextAlign.end,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        trailing: const Icon(Icons.access_time, color: AppColors.white),
      ),
    );
  }
}
