import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:screw_calculator/core/constants/app_links.dart';
import 'package:screw_calculator/core/l10n/content_direction.dart';
import 'package:screw_calculator/core/theme/app_palette.dart';
import 'package:screw_calculator/core/theme/app_theme.dart';
import 'package:screw_calculator/core/utils/utilities.dart';
import 'package:screw_calculator/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:screw_calculator/features/dashboard/presentation/widgets/screenshot_preview_dialog.dart';
import 'package:screw_calculator/features/dashboard/presentation/widgets/share_result_card.dart';
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

  /// يبني قالب النتيجة الجاهز للمشاركة (لاعبون أو فرق) مرتّبًا بالأفضل أولًا.
  Widget _buildCard(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = cubit.state;
    final entries = state.showTeamsView && state.teams.isNotEmpty
        ? state.teams
              .map((t) => ShareResultEntry(name: t.name, total: t.totalScore))
              .toList()
        : state.players
              .map(
                (p) => ShareResultEntry(
                  name: p.name ?? '',
                  total: int.tryParse(p.total ?? '') ?? 0,
                ),
              )
              .toList();
    entries.sort((a, b) => a.total.compareTo(b.total));
    return Directionality(
      textDirection: context.contentDirection,
      child: Theme(
        data: Theme.of(context),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ShareResultCard(
            entries: entries,
            palette: context.palette,
            title: l10n.shareCardTitle,
            footer: l10n.appName,
            downloadLabel: l10n.shareCardDownload,
            downloadUrl: AppLinks.playStore,
          ),
        ),
      ),
    );
  }

  Future<void> _captureAndShare(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    if (!cubit.canShare) {
      Utilities().showCustomSnack(context, txt: l10n.shareNeed4);
      return;
    }

    try {
      final Uint8List bytes = await screenshotController.captureFromWidget(
        _buildCard(context),
        pixelRatio: 3,
        context: context,
        delay: const Duration(milliseconds: 50),
      );
      if (!context.mounted) return;

      final dir = await getTemporaryDirectory();
      final filePath =
          '${dir.path}/screenshot${DateTime.now().toIso8601String().replaceAll(' ', '_')}.png';
      final file = File(filePath);
      await file.writeAsBytes(bytes);

      if (!context.mounted) return;
      await showDialog<void>(
        context: context,
        builder: (_) => ScreenshotPreviewDialog(
          imageBytes: bytes,
          onShare: () => cubit.uploadScreenshot(file, title: filePath),
        ),
      );

      await SharePlus.instance.share(
        ShareParams(files: [XFile(filePath)], text: l10n.shareText),
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
