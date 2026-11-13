import 'package:flutter/material.dart';
import 'package:screw_calculator/core/constants/developer_info.dart';
import 'package:screw_calculator/core/theme/app_palette.dart';
import 'package:screw_calculator/core/theme/app_theme.dart';

/// علامة MegTech + الاسم، من الشمال لليمين زي اللوجو.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key});

  static const double _markSize = 20;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      textDirection: TextDirection.ltr,
      children: [
        Image.asset(
          DeveloperInfo.mark,
          key: const ValueKey('megtech-mark'),
          width: _markSize,
          height: _markSize,
          semanticLabel: DeveloperInfo.brand,
        ),
        const SizedBox(width: 6),
        Text(
          DeveloperInfo.brand,
          textDirection: TextDirection.ltr,
          style: TextStyle(
            fontSize: 13.5,
            fontFamily: AppFonts.bold,
            color: context.palette.textPrimary,
          ),
        ),
      ],
    );
  }
}
