import 'package:flutter/material.dart';
import 'package:screw_calculator/core/theme/app_theme.dart';

class CustomText extends StatelessWidget {
  final String text;
  final String? fontFamily;
  final Color? color;
  final double fontSize;
  final FontWeight? fontWeight;

  final int? maxLines;
  final double? height;
  final TextAlign? textAlign;
  final bool? underline;

  const CustomText({
    super.key,
    required this.text,
    this.color,
    this.fontWeight = FontWeight.normal,
    required this.fontSize,
    this.fontFamily,
    this.textAlign,
    this.height,
    this.underline = false,
    this.maxLines = 20,
  });

  @override
  Widget build(BuildContext context) {
    // عند عدم تمرير لون، يُشتق من الثيم ليتكيّف مع الوضع الفاتح/الداكن.
    final resolvedColor = color ?? Theme.of(context).colorScheme.onSurface;
    return Text(
      text.toString(),
      textAlign: textAlign ?? TextAlign.center,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        height: height ?? 1.4,
        fontSize: fontSize,
        fontFamily: fontFamily ?? AppFonts.regular,
        color: resolvedColor,
        decoration: underline! ? TextDecoration.underline : TextDecoration.none,
        decorationColor: resolvedColor,
      ),
      maxLines: maxLines,
    );
  }
}
