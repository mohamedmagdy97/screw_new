import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:screw_calculator/utility/app_theme.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Center(
        child: SizedBox(
          width: 24.w,
          height: 24.h,
          child: const CircularProgressIndicator.adaptive(
            strokeWidth: 2,
            backgroundColor: AppColors.mainColor,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.bg),
          ),
        ),
      ),
    );
  }
}
