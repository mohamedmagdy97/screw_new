import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:screw_calculator/components/custom_text.dart';
import 'package:screw_calculator/utility/app_theme.dart';

class DeleteConfirmationDialog extends StatelessWidget {
  const DeleteConfirmationDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.textColorTitle,
      title: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: Colors.orange,
            size: 24.sp,
          ),
          SizedBox(width: 8.w),
          CustomText(
            text: 'تأكيد الحذف',
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ],
      ),
      content: CustomText(
        text: 'هل أنت متأكد أنك تريد حذف هذه المشاركة؟',
        fontSize: 16.sp,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: CustomText(
            text: 'إلغاء',
            fontSize: 16.sp,
            color: Colors.grey[600],
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
          child: CustomText(
            text: 'حذف',
            fontSize: 16.sp,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

