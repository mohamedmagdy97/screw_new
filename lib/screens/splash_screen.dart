import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:screw_calculator/components/custom_text.dart';
import 'package:screw_calculator/generated/assets.dart';
import 'package:screw_calculator/screens/game_mode/game_mode.dart';
import 'package:screw_calculator/utility/app_theme.dart';

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

      await Navigator.of(context).pushAndRemoveUntil(
        PageRouteBuilder(
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
                  child: const GameMode(),
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
      backgroundColor: AppColors.bg,
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
            const CustomText(text: 'صلي على النبي', fontSize: 16),

            SizedBox(height: 0.45.sh),
            const CircularProgressIndicator.adaptive(
              strokeWidth: 4,
              backgroundColor: AppColors.mainColor,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.bg),
            ),
          ],
        ),
      ),
    );
  }
}
