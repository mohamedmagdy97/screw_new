import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:screw_calculator/core/theme/app_palette.dart';
import 'package:screw_calculator/core/theme/app_theme.dart';
import 'package:screw_calculator/core/widgets/custom_text.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final double? height;
  final double? width;
  final double? borderRadius;
  final double? horizontalPadding;
  final Function? onPressed;
  final double? fontSize;
  final String? fontFamily;
  final Color? color;
  final Color? colorFont;
  final bool isButtonBorder;
  final bool isSecondButton;

  final Color? borderColor;

  const CustomButton({
    super.key,
    this.height,
    this.width,
    this.onPressed,
    this.horizontalPadding,
    this.fontSize,
    this.fontFamily,
    required this.text,
    this.colorFont,
    this.borderRadius,
    this.isButtonBorder = false,
    this.isSecondButton = false,
    this.color,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final bool flat = isSecondButton || isButtonBorder;
    return Container(
      height: height ?? 52,
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius ?? 14.sp),
        gradient: flat
            ? null
            : (color != null
                  ? LinearGradient(
                      colors: [color!, color!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : palette.brandGradient),
        boxShadow: flat
            ? null
            : [
                BoxShadow(
                  color: (color ?? palette.brand).withValues(alpha: 0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
        border: isButtonBorder
            ? Border.all(color: borderColor ?? palette.accent, width: 1.5)
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12.sp),
          onTap: () =>
              onPressed == null ? Navigator.pop(context) : onPressed!(),
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding ?? 4.0,
              ),
              child: CustomText(
                text: text,
                fontSize: fontSize ?? 20.sp,
                fontFamily: isSecondButton
                    ? fontFamily == AppFonts.regular
                          ? AppFonts.regular
                          : AppFonts.bold
                    : fontFamily ?? AppFonts.regular,
                fontWeight: AppFonts.w400,
                height: 1,
                //  .8.h,
                color: isSecondButton
                    ? palette.accent
                    : isButtonBorder
                    ? (borderColor ?? palette.accent)
                    : colorFont ?? Colors.white,
                maxLines: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
