import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:screw_calculator/components/custom_button.dart';
import 'package:screw_calculator/components/custom_text.dart';
import 'package:screw_calculator/utility/app_theme.dart';

class DeleteGameConfirmationDialog extends StatelessWidget {
  final int gameIndex;

  const DeleteGameConfirmationDialog({
    super.key,
    required this.gameIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.bg,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomText(
              text: 'تحذير',
              fontSize: 18.sp,
              color: AppColors.mainColor,
            ),
            const SizedBox(height: 40),
            CustomText(
              text: 'سيتم حذف الجولة رقم ${gameIndex + 1}',
              fontSize: 18.sp,
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const CustomText(text: 'لا', fontSize: 18),
                ),
                CustomButton(
                  width: 0.25.sw,
                  height: 40,
                  text: 'نعم',
                  isButtonBorder: true,
                  onPressed: () => Navigator.pop(context, true),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

