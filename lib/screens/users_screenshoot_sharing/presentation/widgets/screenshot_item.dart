import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:screw_calculator/components/dox_decoration.dart';
import 'package:screw_calculator/screens/users_screenshoot_sharing/domain/entities/screenshot_entity.dart';
import 'package:screw_calculator/utility/app_theme.dart';

class ScreenshotItem extends StatelessWidget {
  final ScreenshotEntity screenshot;
  final VoidCallback onDelete;

  const ScreenshotItem({
    super.key,
    required this.screenshot,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      child: GestureDetector(
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
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4.r),
              child: screenshot.imageBase64 != null &&
                      screenshot.imageBase64!.isNotEmpty
                  ? Image.memory(
                      base64Decode(screenshot.imageBase64!),
                      width: 1.sw,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 200.h,
                          color: Colors.grey[200],
                          child: Center(
                            child: Icon(
                              Icons.error_outline,
                              color: Colors.grey[400],
                              size: 48.sp,
                            ),
                          ),
                        );
                      },
                    )
                  : Container(
                      height: 200.h,
                      color: Colors.grey[200],
                      child: Center(
                        child: Icon(
                          Icons.image_not_supported,
                          color: Colors.grey[400],
                          size: 48.sp,
                        ),
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

