import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:screw_calculator/components/custom_text.dart';

class EmptyData extends StatelessWidget {
  const EmptyData({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_search, size: 64.sp, color: Colors.grey[400]),
          SizedBox(height: 16.h),
          CustomText(
            text: 'لا توجد مشاركات حالياً',
            fontSize: 16.sp,
            color: Colors.grey[600],
          ),
        ],
      ),
    );
  }
}
