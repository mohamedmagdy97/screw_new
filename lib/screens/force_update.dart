import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:screw_calculator/components/custom_text.dart';
import 'package:screw_calculator/utility/app_theme.dart';
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
    if (_forceUpdate) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.purple,
          fontFamily: 'JannaLT-Regular', // لو عندك خط عربي مخصص
        ),
        home: Scaffold(
          backgroundColor: Colors.blueGrey.shade50,
          body: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
              margin: const EdgeInsets.all(24),
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.system_update,
                        size: 80,
                        color: AppColors.mainColor,
                      ),
                      const SizedBox(height: 16),
                      const CustomText(
                        text: 'تحديث إجباري',
                        fontSize: 22,
                        color: AppColors.black,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      CustomText(
                        text:
                            'يرجى تحديث التطبيق للإصدار $_latestVersion '
                            'للاستمرار في استخدام جميع المميزات.',
                        textAlign: TextAlign.center,
                        fontSize: 16,
                        color: AppColors.black,
                      ),
                      const SizedBox(height: 28),
                      ElevatedButton.icon(
                        icon: const Icon(
                          Icons.download,
                          size: 22,
                          color: AppColors.white,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.mainColor,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _openStore,
                        label: const CustomText(
                          text: 'تحديث الآن',
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(fontFamily: 'JannaLT-Regular'),
        home: Stack(
          children: [
            widget.child,
            if (_optionalUpdate)
              Padding(
                padding: const EdgeInsets.only(bottom: 28),
                child: SlideTransition(
                  position: _slide,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      margin: const EdgeInsets.all(12),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.purple.shade600,
                            Colors.purple.shade800,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 8,
                            offset: Offset(0, -2),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.celebration,
                            color: Colors.white,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CustomText(
                              textAlign: TextAlign.start,
                              text:
                                  'إصدار جديد ($_latestVersion) متاح 🎉\n'
                                  'جرّب أحدث المميزات الآن!',
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: _openStore,
                            icon: const Icon(Icons.arrow_back_ios, size: 16),
                            label: CustomText(
                              text: 'تحديث',
                              fontSize: 14,
                              color: AppColors.mainColor,
                              fontFamily: AppFonts.bold,
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppColors.mainColor,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    }
  }
}
