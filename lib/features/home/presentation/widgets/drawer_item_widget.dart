import 'package:flutter/material.dart';
import 'package:screw_calculator/core/theme/app_theme.dart';
import 'package:screw_calculator/core/widgets/custom_text.dart';

class DrawerItemWidget extends StatelessWidget {
  final String title;
  final void Function()? onTap;

  const DrawerItemWidget({super.key, required this.title, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          minTileHeight: 0,
          onTap: onTap,
          title: CustomText(
            text: title,
            fontSize: 16,
            textAlign: TextAlign.end,
          ),
        ),

        const Divider(height: 2, color: AppColors.opacity_1),
      ],
    );
  }
}
