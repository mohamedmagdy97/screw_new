import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:screw_calculator/components/custom_text.dart';
import 'package:screw_calculator/utility/app_theme.dart';

class Utilities {
  void showCustomSnack(BuildContext context, {String? txt}) {
    late OverlayEntry entry;
    final controller = AnimationController(
      vsync: Navigator.of(context),
      duration: const Duration(milliseconds: 300),
    );

    final animation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero, // on-screen
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));

    final overlay = Overlay.of(context);
    entry = OverlayEntry(
      builder: (_) => Positioned(
        bottom: 20,
        left: 16,
        right: 16,
        child: SlideTransition(
          position: animation,
          child: Material(
            elevation: 6,
            color: AppColors.mainColor,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: CustomText(
                text: txt ?? "",
                fontSize: 16.sp,
                color: AppColors.white,
                textAlign: TextAlign.end,
              ), // here you may safely put Hero
            ),
          ),
        ),
      ),
    );

    overlay.insert(entry);
    controller.forward(); // animate in

    Future.delayed(const Duration(seconds: 3), () async {
      await controller.reverse(); // animate out
      entry.remove();
      controller.dispose();
    });
  }

  // customSnackBarTerms(BuildContext context, {String? txt}) {
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: CustomText(
  //         text: txt ?? "",
  //         fontSize: 16.sp,
  //         color: AppColors.white,
  //         textAlign: TextAlign.end,
  //       ),
  //       // padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
  //       backgroundColor: AppColors.mainColor,
  //     ),
  //   );
  // }
}
