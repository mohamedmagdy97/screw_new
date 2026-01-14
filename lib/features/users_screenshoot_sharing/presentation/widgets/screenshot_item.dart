import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:screw_calculator/components/custom_text.dart';
import 'package:screw_calculator/components/dox_decoration.dart';
import 'package:screw_calculator/features/users_screenshoot_sharing/domain/entities/screenshot_entity.dart';
import 'package:screw_calculator/utility/app_theme.dart';

class ScreenshotItem extends StatelessWidget {
  final ScreenshotEntity screenshot;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const ScreenshotItem({
    super.key,
    required this.screenshot,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: GestureDetector(
        onTap: onTap,
        onDoubleTap: onDelete,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: EdgeInsets.all(4.w),
          decoration: customBoxDecoration(
            borderRadius: 8.r,
            shadowColor: Colors.black.withOpacity(0.1),
          ),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            decoration: BoxDecoration(
              color: AppColors.opacity_1.withOpacity(0.75),
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: Image.memory(
                    base64Decode(screenshot.imageBase64!),
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),

                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.all(4.h),
                    width: 1.sw,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.black54, Colors.transparent],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                    child: CustomText(
                      text: DateFormat('hh:mm a').format(screenshot.timestamp),
                      fontSize: 10.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
