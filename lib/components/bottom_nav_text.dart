import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:screw_calculator/components/custom_text.dart';

class BottomNavigationText extends StatelessWidget {
  const BottomNavigationText({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: CustomText(
        text: '🌙 لا تجعل اللعبة تلهيك عن الصلاة 🌙',
        fontSize: 16.sp,
        textAlign: TextAlign.center,
      ),
    );
  }
}
