import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:screw_calculator/core/widgets/custom_text.dart';

class BottomNavigationText extends StatelessWidget {
  const BottomNavigationText({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16, left: 16, bottom: 16, top: 4),
      child: CustomText(
        text: '🌙 لا تجعل اللعبة تلهيك عن الصلاة 🌙',
        fontSize: 16.sp,
        textAlign: TextAlign.center,
      ),
    );
  }
}
