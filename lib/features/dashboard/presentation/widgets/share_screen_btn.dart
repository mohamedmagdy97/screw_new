import 'dart:io';

import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:screw_calculator/core/constants/app_links.dart';
import 'package:screw_calculator/core/theme/app_palette.dart';
import 'package:screw_calculator/core/theme/app_theme.dart';
import 'package:screw_calculator/core/utils/utilities.dart';
import 'package:screw_calculator/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:screw_calculator/features/dashboard/presentation/widgets/result_share.dart';
import 'package:screw_calculator/features/dashboard/presentation/widgets/screenshot_preview_dialog.dart';
import 'package:screw_calculator/l10n/app_localizations.dart';
import 'package:share_plus/share_plus.dart';

/// زر مشاركة لوحة النتائج: يلتقط صورة، يعرض معاينة، يرفعها، ثم يشاركها.
class ShareScreenBtn extends StatelessWidget {
  const ShareScreenBtn({
    super.key,
    required this.cubit,
    required this.screenshotController,
  });

  final DashboardCubit cubit;
  final ScreenshotController screenshotController;

  Future<void> _captureAndShare(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    if (!cubit.canShare) {
      Utilities().showCustomSnack(context, txt: l10n.shareNeed4);
      return;
    }

    try {
      final (bytes, filePath) = await captureResultCard(context, cubit.state);
      final file = File(filePath);
      if (!context.mounted) return;
      await showDialog<void>(
        context: context,
        builder: (_) => ScreenshotPreviewDialog(
          imageBytes: bytes,
          onShare: () => cubit.uploadScreenshot(file, title: filePath),
        ),
      );

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(filePath)],
          text: l10n.shareResultMessage(AppLinks.playStore),
        ),
      );
    } catch (e) {
      debugPrint('خطأ أثناء مشاركة الصورة: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return SizedBox(
      height: 52,
      child: OutlinedButton.icon(
        onPressed: () => _captureAndShare(context),
        icon: const Icon(Icons.ios_share_rounded, size: 20),
        label: FittedBox(child: Text(AppLocalizations.of(context).shareResult)),
        style: OutlinedButton.styleFrom(
          foregroundColor: palette.brandSoft,
          side: BorderSide(color: palette.brand.withValues(alpha: 0.6)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
          textStyle: const TextStyle(fontFamily: AppFonts.bold, fontSize: 16),
        ),
      ),
    );
  }
}
