import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../domain/item.dart';
import '../../../../utility/app_theme.dart';
import '../../../../components/custom_text.dart';

class GameModeItem extends StatelessWidget {
  final Item item;
  final VoidCallback onTap;

  const GameModeItem({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      height: 120.h,
      width: 1.sw,
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: item.isActive! ? AppColors.mainColor : Colors.transparent,
        border: Border.all(
          color: item.isActive! ? Colors.transparent : AppColors.mainColor,
        ),
        boxShadow: item.isActive!
            ? [BoxShadow(color: AppColors.mainColor.withOpacity(.3), blurRadius: 8)]
            : [],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Center(
          child: AnimatedDefaultTextStyle(
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.normal,
              color: item.isActive! ? Colors.white : AppColors.black,
            ),
            duration: const Duration(milliseconds: 300),
            child: CustomText(text: item.value, fontSize: 22,),
          ),
        ),
      ),
    );
  }
}
