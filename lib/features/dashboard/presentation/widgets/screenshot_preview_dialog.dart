import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:screw_calculator/core/theme/app_palette.dart';
import 'package:screw_calculator/core/theme/app_theme.dart';
import 'package:screw_calculator/core/widgets/app_dialog.dart';
import 'package:screw_calculator/l10n/app_localizations.dart';

/// معاينة صورة النتيجة قبل المشاركة (إلغاء / مشاركة).
class ScreenshotPreviewDialog extends StatelessWidget {
  final Uint8List imageBytes;
  final VoidCallback onShare;

  const ScreenshotPreviewDialog({
    super.key,
    required this.imageBytes,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppDialog(
      icon: Icons.ios_share_rounded,
      title: l10n.previewTitle,
      content: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.5,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: context.palette.border),
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadii.md),
          child: Image.memory(imageBytes, fit: BoxFit.contain),
        ),
      ),
      actions: [
        Expanded(
          child: AppDialogButton(
            label: l10n.cancel,
            onPressed: () => Navigator.pop(context),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: AppDialogButton(
            label: l10n.share,
            primary: true,
            onPressed: () {
              onShare();
              Navigator.pop(context, true);
            },
          ),
        ),
      ],
    );
  }
}
