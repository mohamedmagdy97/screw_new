import 'package:flutter/material.dart';
import 'package:screw_calculator/core/theme/app_palette.dart';
import 'package:screw_calculator/core/theme/app_theme.dart';
import 'package:screw_calculator/core/widgets/custom_text.dart';
import 'package:screw_calculator/l10n/app_localizations.dart';

/// تذكير هادئ أسفل الشاشات: حبّة صغيرة بأيقونة هلال بدل نص بارز.
class BottomNavigationText extends StatelessWidget {
  const BottomNavigationText({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
        child: Center(
          heightFactor: 1,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: palette.surface,
              borderRadius: BorderRadius.circular(AppRadii.pill),
              border: Border.all(color: palette.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.nights_stay_rounded,
                  size: 16,
                  color: Color(0xFFFBBF24),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: CustomText(
                    text: AppLocalizations.of(
                      context,
                    ).dontLetGameDistract.replaceAll('🌙', '').trim(),
                    fontSize: 13,
                    color: palette.textSecondary,
                    maxLines: 1,
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
