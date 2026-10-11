import 'package:flutter/material.dart';
import 'package:screw_calculator/core/theme/app_palette.dart';
import 'package:screw_calculator/core/theme/app_theme.dart';
import 'package:screw_calculator/generated/assets.dart';

/// صف في بطاقة المشاركة (لاعب أو فريق) مع مجموعه.
class ShareResultEntry {
  const ShareResultEntry({required this.name, required this.total});

  final String name;
  final int total;
}

/// قالب نتيجة اللعبة الجاهز للمشاركة كصورة (بدل لقطة الشاشة الخام).
///
/// مستقل عن ScreenUtil حتى يمكن تصييره خارج شجرة الواجهة عبر
/// `ScreenshotController.captureFromWidget`.
class ShareResultCard extends StatelessWidget {
  const ShareResultCard({
    super.key,
    required this.entries,
    required this.palette,
    required this.title,
    required this.footer,
  });

  /// مرتّبة تصاعديًا: الأقل مجموعًا (الفائز) أولًا.
  final List<ShareResultEntry> entries;
  final AppPalette palette;
  final String title;
  final String footer;

  @override
  Widget build(BuildContext context) {
    final best = entries.isEmpty ? null : entries.first.total;
    return Container(
      width: 360,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: palette.brandGradient,
        borderRadius: BorderRadius.circular(AppRadii.xl),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(Assets.iconsMark, height: 64),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontFamily: AppFonts.bold,
            ),
          ),
          const SizedBox(height: 16),
          for (var i = 0; i < entries.length; i++)
            _Row(
              rank: i + 1,
              entry: entries[i],
              isWinner: entries[i].total == best,
            ),
          const SizedBox(height: 12),
          Text(
            footer,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 14,
              fontFamily: AppFonts.regular,
            ),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.rank, required this.entry, required this.isWinner});

  final int rank;
  final ShareResultEntry entry;
  final bool isWinner;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: isWinner ? 0.26 : 0.14),
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: isWinner
            ? Border.all(color: Colors.white.withValues(alpha: 0.8))
            : null,
      ),
      child: Row(
        children: [
          Text(
            isWinner ? '👑' : '$rank',
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              entry.name,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontFamily: AppFonts.bold,
              ),
            ),
          ),
          Text(
            '${entry.total}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontFamily: AppFonts.bold,
            ),
          ),
        ],
      ),
    );
  }
}
