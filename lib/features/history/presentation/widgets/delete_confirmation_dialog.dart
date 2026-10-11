import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:screw_calculator/core/theme/app_theme.dart';
import 'package:screw_calculator/core/widgets/custom_button.dart';
import 'package:screw_calculator/core/widgets/custom_text.dart';
import 'package:screw_calculator/l10n/app_localizations.dart';

class DeleteGameConfirmationDialog extends StatelessWidget {
  final int gameIndex;

  const DeleteGameConfirmationDialog({super.key, required this.gameIndex});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomText(
              text: AppLocalizations.of(context).warning,
              fontSize: 18.sp,
              color: AppColors.mainColor,
            ),
            const SizedBox(height: 40),
            CustomText(
              text: AppLocalizations.of(
                context,
              ).deleteGameWarning(gameIndex + 1),
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
                  onPressed: () => Navigator.pop(context, true),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
