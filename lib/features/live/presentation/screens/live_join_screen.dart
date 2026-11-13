import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:screw_calculator/core/l10n/content_direction.dart';
import 'package:screw_calculator/core/theme/app_palette.dart';
import 'package:screw_calculator/core/theme/app_theme.dart';
import 'package:screw_calculator/core/widgets/custom_appbar.dart';
import 'package:screw_calculator/core/widgets/custom_text.dart';
import 'package:screw_calculator/features/live/domain/live_code.dart';
import 'package:screw_calculator/features/live/presentation/screens/live_scan_screen.dart';
import 'package:screw_calculator/features/live/presentation/screens/live_viewer_screen.dart';
import 'package:screw_calculator/l10n/app_localizations.dart';

/// «تابع لعبة لايف»: اكتب الكود أو امسح الـ QR من موبايل صاحبك.
class LiveJoinScreen extends StatefulWidget {
  const LiveJoinScreen({super.key, this.scan});

  /// بديل الماسح في الاختبارات.
  final Future<String?> Function(BuildContext context)? scan;

  @override
  State<LiveJoinScreen> createState() => _LiveJoinScreenState();
}

class _LiveJoinScreenState extends State<LiveJoinScreen> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _open(String? input) {
    final code = LiveCode.parse(input);
    if (code == null) {
      setState(() => _error = AppLocalizations.of(context).liveCodeInvalid);
      return;
    }
    setState(() => _error = null);
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => LiveViewerScreen(code: code)),
    );
  }

  Future<void> _scan() async {
    final scan = widget.scan;
    final code = scan != null
        ? await scan(context)
        : await Navigator.of(context).push<String>(
            MaterialPageRoute(builder: (_) => const LiveScanScreen()),
          );
    if (!mounted || code == null) return;
    _controller.text = code;
    _open(code);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = context.palette;
    return Scaffold(
      appBar: CustomAppBar(title: l10n.liveJoinTitle),
      body: Directionality(
        textDirection: context.contentDirection,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          children: [
            Center(
              child: Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: palette.brandGradient,
                ),
                child: const Icon(
                  Icons.live_tv_rounded,
                  color: Colors.white,
                  size: 42,
                ),
              ),
            ),
            const SizedBox(height: 18),
            CustomText(
              text: l10n.liveJoinHint,
              fontSize: 15,
              color: palette.textSecondary,
              height: 1.6,
            ),
            const SizedBox(height: 24),
            TextField(
              key: const ValueKey('live-code-field'),
              controller: _controller,
              textAlign: TextAlign.center,
              textDirection: TextDirection.ltr,
              textCapitalization: TextCapitalization.characters,
              maxLength: LiveCode.length,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp('[A-Za-z0-9]')),
              ],
              style: const TextStyle(
                fontSize: 28,
                letterSpacing: 6,
                fontFamily: AppFonts.bold,
              ),
              decoration: InputDecoration(
                hintText: 'ABC234',
                counterText: '',
                errorText: _error,
              ),
              onSubmitted: _open,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 52,
              child: FilledButton(
                key: const ValueKey('live-join'),
                onPressed: () => _open(_controller.text),
                style: FilledButton.styleFrom(
                  backgroundColor: palette.brand,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadii.md),
                  ),
                  textStyle: const TextStyle(
                    fontFamily: AppFonts.bold,
                    fontSize: 16,
                  ),
                ),
                child: Text(l10n.liveJoinButton),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 52,
              child: OutlinedButton.icon(
                key: const ValueKey('live-scan'),
                onPressed: _scan,
                icon: const Icon(Icons.qr_code_scanner_rounded),
                label: Text(l10n.liveScanButton),
                style: OutlinedButton.styleFrom(
                  foregroundColor: palette.brandSoft,
                  side: BorderSide(color: palette.brand.withValues(alpha: 0.6)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadii.md),
                  ),
                  textStyle: const TextStyle(
                    fontFamily: AppFonts.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
