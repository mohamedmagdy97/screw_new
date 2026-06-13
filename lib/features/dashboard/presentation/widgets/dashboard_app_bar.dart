import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:screw_calculator/core/theme/app_theme.dart';
import 'package:screw_calculator/core/widgets/custom_button.dart';
import 'package:screw_calculator/core/widgets/custom_text.dart';

/// شريط علوي للوحة النتائج مع زر إعادة بدء الجولة (مع تأكيد) وزر رجوع.
class DashboardAppBar extends StatelessWidget implements PreferredSizeWidget {
  const DashboardAppBar({
    super.key,
    required this.fromHistory,
    this.onResetConfirmed,
  });

  final bool fromHistory;
  final VoidCallback? onResetConfirmed;

  @override
  Size get preferredSize => const Size.fromHeight(80);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      automaticallyImplyLeading: false,
      backgroundColor: AppColors.grayy,
      leading: fromHistory
          ? const SizedBox()
          : IconButton(
              onPressed: () => _showResetDialog(context),
              icon: const Icon(Icons.refresh, color: AppColors.white),
            ),
      actions: [
        IconButton(
          onPressed: () => Navigator.pop(context, true),
          icon: Transform.flip(
            flipX: true,
            child: const Icon(Icons.arrow_back_ios, color: AppColors.white),
          ),
        ),
      ],
      title: CustomText(text: 'النتائج', fontSize: 22.sp),
    );
  }

  void _showResetDialog(BuildContext context) {
    showGeneralDialog<void>(
      context: context,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 450),
      pageBuilder: (_, _, _) => const SizedBox.shrink(),
      transitionBuilder: (ctx, anim, _, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
          child: Opacity(opacity: anim.value, child: _ResetDialog(onConfirm: onResetConfirmed)),
        );
      },
    );
  }
}

class _ResetDialog extends StatelessWidget {
  const _ResetDialog({this.onConfirm});

  final VoidCallback? onConfirm;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.bg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomText(text: 'تحذير', fontSize: 18.sp, color: AppColors.mainColor),
            const SizedBox(height: 40),
            CustomText(text: 'هل تريد إعادة بدأ الجولة؟', fontSize: 18.sp),
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
                  onPressed: () {
                    Navigator.pop(context);
                    onConfirm?.call();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
