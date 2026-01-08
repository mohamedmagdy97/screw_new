import 'package:flutter/material.dart';
import 'package:screw_calculator/utility/app_theme.dart';

BoxDecoration customBoxDecoration({
  Color? color,
  Color? shadowColor,
  double? radiusBottom,
  double? spreadRadius,
  double? blurRadius,
  double? borderRadius,
}) {
  return BoxDecoration(
    color: color,
    gradient: color != null
        ? null
        : LinearGradient(
            colors: [
              // Colors.purple.shade400.withOpacity(0.5),
              // Colors.purple.shade800.withOpacity(0.25),
              // AppColors.secondaryColor2,
              AppColors.secondaryColor2.withValues(alpha: 0.5),
              AppColors.mainColor.withOpacity(0.2),
              AppColors.oscarLightColor, AppColors.oscarColor,
              AppColors.mainColor.withOpacity(0.5),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
    borderRadius: BorderRadius.circular(borderRadius ?? 16),
    boxShadow:   [
      BoxShadow(color: shadowColor ?? Colors.black26, blurRadius: 8, offset: Offset(0, -2)),
    ],
  );
}
