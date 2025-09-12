import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:screw_calculator/components/custom_button.dart';
import 'package:screw_calculator/components/custom_text.dart';
import 'package:screw_calculator/utility/app_theme.dart';

customAlertOptional({
  required BuildContext context,
  required String title,
  required String alertType,
  required Function onTap,
  required Function onCancel,
  String? textButton,
  String? textSecondButton,
  bool barrierDismissible = false,
  double? buttonWidth,
  bool willPopScope = true,
}) {
  return showDialog(
    barrierDismissible: barrierDismissible,
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return WillPopScope(
            onWillPop: () async {
              return willPopScope;
            },
            child: SimpleDialog(
              insetPadding: EdgeInsets.all(20.sp),
              contentPadding: EdgeInsets.all(18.sp),
              clipBehavior: Clip.antiAliasWithSaveLayer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(30.sp)),
              ),
              children: [
                SizedBox(
                  width: 1.sw,
                  child: Padding(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        SizedBox(height: 6.h),
                        CustomText(
                          text: alertType,
                          maxLines: 1,
                          fontSize: 22.sp,
                          textAlign: TextAlign.center,
                          color: AppColors.mainColor,
                          fontFamily: AppFonts.bold,
                        ),
                        SizedBox(height: 18.h),
                        CustomText(
                          text: title,
                          fontSize: 16.sp,
                          textAlign: TextAlign.center,
                          color: AppColors.black,
                          fontFamily: AppFonts.bold,
                          height: 1.5,
                        ),
                        SizedBox(height: 24.h),
                        CustomButton(
                          width: buttonWidth ?? 150.w,
                          onPressed: () => onTap(),
                          text: "موافق",
                        ),
                        SizedBox(height: 16.h),
                        CustomButton(
                          width: 100.w,
                          isButtonBorder: true,
                          colorFont: AppColors.black,
                          onPressed: () => onCancel(),
                          text: "رجوع",
                        ),
                        SizedBox(height: 8.h),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
