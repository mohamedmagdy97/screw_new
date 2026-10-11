import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:screw_calculator/core/theme/app_palette.dart';
import 'package:screw_calculator/core/widgets/custom_text.dart';
import 'package:screw_calculator/l10n/app_localizations.dart';

class DeleteConfirmationDialog extends StatelessWidget {
  const DeleteConfirmationDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 24.sp),
          SizedBox(width: 8.w),
          CustomText(
            text: AppLocalizations.of(context).confirmDelete,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ],
      ),
      content: CustomText(
        text: AppLocalizations.of(context).confirmDeleteShare,
        fontSize: 16.sp,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: CustomText(
            text: AppLocalizations.of(context).cancel,
            fontSize: 16.sp,
            color: context.palette.textSecondary,
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
            text: AppLocalizations.of(context).delete,
            fontSize: 16.sp,
          ),
        ),
      ],
    );
  }
}
