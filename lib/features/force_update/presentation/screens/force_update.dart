import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:screw_calculator/core/theme/app_palette.dart';
import 'package:screw_calculator/core/theme/app_theme.dart';
import 'package:screw_calculator/core/widgets/custom_text.dart';
import 'package:screw_calculator/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class ForceUpdateWrapper extends StatefulWidget {
  final Widget child;

  const ForceUpdateWrapper({required this.child, super.key});

  @override
  State<ForceUpdateWrapper> createState() => _ForceUpdateWrapperState();
}

class _ForceUpdateWrapperState extends State<ForceUpdateWrapper>
    with SingleTickerProviderStateMixin {
  bool _forceUpdateConfig = false;
  bool _forceUpdate = false;
  bool _optionalUpdate = false;
  String _storeUrl = '';
  String _latestVersion = '';
  late AnimationController _controller;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _checkUpdate();
  }

  Future<void> _checkUpdate() async {
    final rc = FirebaseRemoteConfig.instance;
    await rc.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: Duration.zero,
      ),
    );
    await rc.setDefaults({
      'min_supported_version': '1.0.0',
      'latest_version': '1.0.1',
      'store_url':
          'https://play.google.com/store/apps/details?id=com.megTech.screw_calculator',
    });
    await rc.fetchAndActivate();

    // print('>>>>>>>>>>>>>>>>> min: ${rc.getString('min_supported_version')}');
    // print('>>>>>>>>>>>>>>>>> latest: ${rc.getString('latest_version')}');
    // print('>>>>>>>>>>>>>>>>> url: ${rc.getString('store_url')}');

    final minVersion = rc.getString('min_supported_version');
    _latestVersion = rc.getString('latest_version');
    _storeUrl = rc.getString('store_url');
    _forceUpdateConfig = rc.getBool('force_update');

    final info = await PackageInfo.fromPlatform();
    final current = info.version;

    if (_isLower(current, _latestVersion)) {
      if (_forceUpdateConfig) {
        setState(() => _forceUpdate = true);
      } else {
        setState(() {
          _optionalUpdate = true;
          _controller.forward();
        });
      }
    } else if (_isLower(current, minVersion)) {
      setState(() {
        _optionalUpdate = true;
        _controller.forward();
      });
    } else if (_isLower(current, _latestVersion)) {
      setState(() {
        _optionalUpdate = true;
        _controller.forward();
      });
    }
  }

  bool _isLower(String current, String other) {
    final c = current.split('.').map(int.parse).toList();
    final o = other.split('.').map(int.parse).toList();
    for (var i = 0; i < 3; i++) {
      if (c[i] < o[i]) return true;
      if (c[i] > o[i]) return false;
    }
    return false;
  }

  void _openStore() async {
    if (await canLaunchUrl(Uri.parse(_storeUrl))) {
      await launchUrl(
        Uri.parse(_storeUrl),
        mode: LaunchMode.externalApplication,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_forceUpdate) return _buildForcedPage(context);

    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        if (_optionalUpdate)
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: SlideTransition(
                position: _slide,
                child: _buildOptionalBanner(context),
              ),
            ),
          ),
      ],
    );
  }

  /// صفحة التحديث الإجباري (تملأ الشاشة).
  Widget _buildForcedPage(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = context.palette;
    return Scaffold(
      backgroundColor: palette.screen,
      body: SafeArea(
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: palette.surface,
              borderRadius: BorderRadius.circular(AppRadii.xl),
              border: Border.all(color: palette.border),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: palette.brand.withValues(alpha: 0.14),
                  ),
                  child: Icon(
                    Icons.system_update_rounded,
                    size: 44,
                    color: palette.brand,
                  ),
                ),
                const SizedBox(height: 20),
                CustomText(
                  text: l10n.forceUpdateTitle,
                  fontSize: 22,
                  fontFamily: AppFonts.bold,
                ),
                const SizedBox(height: 12),
                CustomText(
                  text: l10n.forceUpdateBody(_latestVersion),
                  fontSize: 16,
                  color: palette.textSecondary,
                  height: 1.6,
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton.icon(
                    onPressed: _openStore,
                    icon: const Icon(Icons.download_rounded),
                    label: Text(l10n.updateNow),
                    style: FilledButton.styleFrom(
                      backgroundColor: palette.brand,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadii.md),
                      ),
                      textStyle: const TextStyle(
                        fontFamily: AppFonts.bold,
                        fontSize: 17,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// شريط التحديث الاختياري أسفل الشاشة.
  Widget _buildOptionalBanner(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = context.palette;
    return Material(
      color: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          gradient: palette.brandGradient,
          borderRadius: BorderRadius.circular(AppRadii.lg),
          boxShadow: [
            BoxShadow(
              color: palette.brand.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(
              Icons.celebration_rounded,
              color: Colors.white,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomText(
                textAlign: TextAlign.start,
                text: l10n.newVersionAvailable(_latestVersion),
                fontSize: 14,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: _openStore,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: palette.brand,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadii.sm + 2),
                ),
              ),
              child: Text(
                l10n.update,
                style: const TextStyle(fontFamily: AppFonts.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
