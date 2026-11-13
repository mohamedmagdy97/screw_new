import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:screw_calculator/core/constants/app_links.dart';
import 'package:screw_calculator/core/l10n/content_direction.dart';
import 'package:screw_calculator/core/theme/app_palette.dart';
import 'package:screw_calculator/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:screw_calculator/features/dashboard/presentation/widgets/share_result_card.dart';
import 'package:screw_calculator/l10n/app_localizations.dart';
import 'package:share_plus/share_plus.dart';

/// صفوف كارت النتيجة (لاعبين أو فرق) مرتبة: الأقل مجموعًا (الفايز) الأول.
List<ShareResultEntry> resultEntries(DashboardState state) {
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
  return entries;
}

/// كارت النتيجة الجاهز للمشاركة (بنفس اتجاه ولغة الشاشة).
Widget buildResultCard(BuildContext context, DashboardState state) {
  final l10n = AppLocalizations.of(context);
  final entries = resultEntries(state);
  final best = entries.isEmpty ? null : entries.first.total;
  final worst = entries.isEmpty ? null : entries.last.total;
  final winners = best == null || best == worst
      ? const <String>[]
      : entries.where((e) => e.total == best).map((e) => e.name).toList();
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
          winnerBanner: winners.isEmpty
              ? null
              : l10n.shareCardWinner(winners.join(l10n.andJoin)),
          footer: l10n.appName,
          downloadLabel: l10n.shareCardDownload,
          downloadUrl: AppLinks.playStore,
          madeByLabel: l10n.aboutMadeBy,
        ),
      ),
    ),
  );
}

/// يصوّر كارت النتيجة ويحفظه في ملف مؤقت. يرجّع البايتات ومسار الملف.
Future<(Uint8List, String)> captureResultCard(
  BuildContext context,
  DashboardState state,
) async {
  final bytes = await ScreenshotController().captureFromWidget(
    buildResultCard(context, state),
    pixelRatio: 3,
    context: context,
    delay: const Duration(milliseconds: 50),
  );
  final dir = await getTemporaryDirectory();
  final stamp = DateTime.now().millisecondsSinceEpoch;
  final path = '${dir.path}/screw_result_$stamp.png';
  await File(path).writeAsBytes(bytes);
  return (bytes, path);
}

/// يشارك كارت النتيجة على طول (واتساب أو أي تطبيق من قائمة المشاركة) مع
/// لينك تحميل التطبيق في الرسالة.
Future<void> shareResultCard(BuildContext context, DashboardCubit cubit) async {
  final text = AppLocalizations.of(
    context,
  ).shareResultMessage(AppLinks.playStore);
  try {
    final (_, path) = await captureResultCard(context, cubit.state);
    await SharePlus.instance.share(
      ShareParams(files: [XFile(path)], text: text),
    );
  } catch (e) {
    debugPrint('خطأ أثناء مشاركة النتيجة: $e');
  }
}
