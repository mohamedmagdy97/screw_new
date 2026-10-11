import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:screw_calculator/core/theme/app_palette.dart';
import 'package:screw_calculator/core/widgets/custom_button.dart';
import 'package:screw_calculator/core/widgets/custom_text.dart';
import 'package:screw_calculator/l10n/app_localizations.dart';

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
      foregroundColor: Colors.white,
      flexibleSpace: Container(
        decoration: BoxDecoration(gradient: context.palette.brandGradient),
      ),
      leading: fromHistory
          ? const SizedBox()
          : IconButton(
              onPressed: () => _showResetDialog(context),
              icon: const Icon(Icons.refresh, color: Colors.white),
            ),
      actions: [
        IconButton(
          onPressed: () => Navigator.pop(context, true),
          icon: Transform.flip(
            flipX: true,
            child: const Icon(Icons.arrow_back_ios, color: Colors.white),
          ),
        ),
      ],
      title: CustomText(
        text: AppLocalizations.of(context).results,
        fontSize: 22.sp,
        color: Colors.white,
      ),
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
          child: Opacity(
            opacity: anim.value,
            child: _ResetDialog(onConfirm: onResetConfirmed),
          ),
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomText(
              text: AppLocalizations.of(context).warning,
              fontSize: 18.sp,
              color: context.palette.brand,
            ),
            const SizedBox(height: 40),
            CustomText(
              text: AppLocalizations.of(context).confirmResetRound,
              fontSize: 18.sp,
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: CustomText(
                    text: AppLocalizations.of(context).no,
                    fontSize: 18,
                  ),
                ),
                CustomButton(
                  width: 0.25.sw,
                  height: 40,
                  text: AppLocalizations.of(context).yes,
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
