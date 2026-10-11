import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:screw_calculator/core/theme/app_palette.dart';
import 'package:screw_calculator/core/theme/app_theme.dart';
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
    final palette = context.palette;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 3),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutBack,
              builder: (context, t, child) => Opacity(
                opacity: t.clamp(0, 1),
                child: Transform.scale(scale: 0.85 + 0.15 * t, child: child),
              ),
              child: Image.asset(Assets.iconsIcon, height: 0.3.sh),
            ),
            const SizedBox(height: 16),
            CustomText(
              text: AppLocalizations.of(context).splashSalawat,
              fontSize: 16,
              color: palette.textSecondary,
            ),
            const Spacer(flex: 3),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 72),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadii.pill),
                child: LinearProgressIndicator(
                  minHeight: 5,
                  backgroundColor: palette.border,
                  color: palette.brand,
                ),
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}
