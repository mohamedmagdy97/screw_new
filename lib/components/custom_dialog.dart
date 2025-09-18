import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:screw_calculator/components/custom_button.dart';
import 'package:screw_calculator/components/custom_text.dart';
import 'package:screw_calculator/utility/app_theme.dart';

Future<Object?> customAlertAnimation({
  required BuildContext context,
  required String title,
  required String alertType,
  required Function onTap,
  String? textButton,
  String? textSecondButton,
  bool barrierDismissible = false,
  double? buttonWidth,
  bool willPopScope = true,
}) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 450),
    pageBuilder: (_, _, _) => const SizedBox.shrink(),
    transitionBuilder: (ctx, anim, _, child) {
      final curvedValue = Curves.easeInOut.transform(anim.value);
      return Transform.scale(
        scale: curvedValue,
        child: Opacity(
          opacity: anim.value,
          child: Dialog(
            backgroundColor: AppColors.bg,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 32,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomText(
                    text: alertType,
                    fontSize: 18.sp,
                    color: AppColors.mainColor,
                  ),
                  const SizedBox(height: 40),
                  CustomText(text: title, fontSize: 18.sp),
                  const SizedBox(height: 40),
                  Column(
                    // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CustomButton(
                        // width: 0.25.sw,
                        height: 40,
                        text: textButton ?? "موافق",
                        onPressed: () {
                          Navigator.pop(ctx);
                          onTap();
                        },
                      ),
                      const SizedBox(height: 16),

                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: CustomText(
                          text: textSecondButton ?? "رجوع",
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}
