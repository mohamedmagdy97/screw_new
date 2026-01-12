import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:screw_calculator/components/custom_text.dart';
import 'package:screw_calculator/utility/app_theme.dart';

class TitleWithValue extends StatelessWidget {
  final String title;
  final String value;
  final bool? highlight;
  final bool? isSmaller;
  final bool? isOscar;
  final bool? isRamadan;

  const TitleWithValue({
    super.key,
    required this.title,
    this.highlight = false,
    this.isSmaller = false,
    this.isOscar = false,
    this.isRamadan = false,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomText(
          text: title,
          fontSize: 16,
          textAlign: TextAlign.center,
          color: isOscar!
              ? AppColors.oscarLightColor
              : isRamadan!
              ? AppColors.secondaryColor2
              : AppColors.mainColor,
        ),
        SizedBox(
          height: isOscar!
              ? 6
              : highlight!
              ? 4
              : 0,
        ),
        Container(
          padding: const EdgeInsets.all(8),
          width: 1.sw,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: (highlight! && isOscar!)
                  ? [AppColors.oscarLightColor, AppColors.oscarColor]
                  : highlight! && isRamadan!
                  ? [
                      AppColors.secondaryColor2,
                      AppColors.secondaryColor2.withValues(alpha: 0.5),
                    ]
                  : highlight!
                  ? [
                      AppColors.mainColor.withOpacity(0.5),
                      AppColors.mainColor.withOpacity(0.1),
                    ]
                  : [Colors.transparent, Colors.transparent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: CustomText(
            text: value,
            fontSize: isSmaller! ? 12 : 14,
            textAlign: isSmaller! ? TextAlign.end : TextAlign.center,
          ),
        ),
        SizedBox(height: highlight! ? 16 : 8),
      ],
    );
  }
}
