import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screw_calculator/core/constants/app_links.dart';
import 'package:screw_calculator/core/l10n/content_direction.dart';
import 'package:screw_calculator/core/theme/app_palette.dart';
import 'package:screw_calculator/core/theme/app_theme.dart';
import 'package:screw_calculator/core/widgets/custom_text.dart';
import 'package:screw_calculator/features/live/domain/live_code.dart';
import 'package:screw_calculator/l10n/app_localizations.dart';
import 'package:share_plus/share_plus.dart';

/// شيت «تابعوا لايف»: QR وكود اللعبة، مشاركة الكود، وإيقاف البث.
Future<void> showLiveHostSheet(
  BuildContext context, {
  required String code,
  required Future<void> Function() onStop,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => Directionality(
      textDirection: context.contentDirection,
      child: LiveHostSheet(code: code, onStop: onStop),
    ),
  );
}

class LiveHostSheet extends StatelessWidget {
  const LiveHostSheet({super.key, required this.code, required this.onStop});

  final String code;
  final Future<void> Function() onStop;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = context.palette;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: palette.lose,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                CustomText(
                  text: l10n.liveHostTitle,
                  fontSize: 19,
                  fontFamily: AppFonts.bold,
                ),
              ],
            ),
            const SizedBox(height: 6),
            CustomText(
              text: l10n.liveHostHint,
              fontSize: 14,
              color: palette.textSecondary,
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppRadii.lg),
              ),
              child: QrImageView(
                key: const ValueKey('live-qr'),
                data: LiveCode.qrData(code),
                size: 200,
                padding: EdgeInsets.zero,
                eyeStyle: const QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: Color(0xFF2E1065),
                ),
                dataModuleStyle: const QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: Color(0xFF2E1065),
                ),
              ),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () {
                Clipboard.setData(ClipboardData(text: code));
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(l10n.liveCodeCopied)));
              },
              borderRadius: BorderRadius.circular(AppRadii.md),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                child: Text(
                  code,
                  key: const ValueKey('live-code'),
                  textDirection: TextDirection.ltr,
                  style: TextStyle(
                    fontSize: 34,
                    letterSpacing: 6,
                    fontFamily: AppFonts.bold,
                    color: palette.gold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton.icon(
                onPressed: () => SharePlus.instance.share(
                  ShareParams(
                    text: l10n.liveShareText(code, AppLinks.playStore),
                  ),
                ),
                icon: const Icon(Icons.share_rounded, size: 20),
                label: Text(l10n.liveShareCode),
                style: FilledButton.styleFrom(
                  backgroundColor: palette.brand,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadii.md),
                  ),
                  textStyle: const TextStyle(
                    fontFamily: AppFonts.bold,
                    fontSize: 15.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: TextButton.icon(
                key: const ValueKey('live-stop'),
                onPressed: () async {
                  Navigator.pop(context);
                  await onStop();
                },
                icon: Icon(Icons.stop_circle_rounded, color: palette.lose),
                label: Text(
                  l10n.liveStop,
                  style: TextStyle(color: palette.lose),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
