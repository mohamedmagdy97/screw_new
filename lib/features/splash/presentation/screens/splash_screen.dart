import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:screw_calculator/core/widgets/custom_text.dart';
import 'package:screw_calculator/features/game_mode/presentation/screens/game_mode_screen.dart';
import 'package:screw_calculator/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:screw_calculator/generated/assets.dart';
import 'package:screw_calculator/l10n/app_localizations.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Future<void> getNextPage() async {
    Future.delayed(const Duration(milliseconds: 2000), () async {
      if (!mounted) {
        return;
      }
      final bool seenOnboarding = await OnboardingScreen.wasSeen();
      if (!mounted) {
        return;
      }

      Widget gameMode() => const GameMode();
      await Navigator.of(context).pushAndRemoveUntil(
        PageRouteBuilder<void>(
          transitionDuration: const Duration(milliseconds: 400),
          // reverseTransitionDuration: const Duration(milliseconds: 300),
          pageBuilder: (context, animation, secondaryAnimation) =>
              FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position:
                      Tween<Offset>(
                        begin: const Offset(0, 0.1),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOutCubic,
                        ),
                      ),
                  child: seenOnboarding
                      ? gameMode()
                      : OnboardingScreen(
                          onDone: () => Navigator.of(context).pushReplacement(
                            MaterialPageRoute<void>(builder: (_) => gameMode()),
                          ),
                        ),
                ),
              ),
        ),
        (route) => false,
      );
    });
  }

  @override
  void initState() {
    getNextPage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 80.h),
            Padding(
              padding: EdgeInsets.all(24.sp),
              child: Image.asset(Assets.iconsIcon, height: 0.15.sh),
            ),
            SizedBox(height: 25.h),
            CustomText(
              text: AppLocalizations.of(context).splashSalawat,
              fontSize: 16,
            ),

            SizedBox(height: 0.45.sh),
            const CircularProgressIndicator.adaptive(strokeWidth: 4),
          ],
        ),
      ),
    );
  }
}
