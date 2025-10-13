import 'package:flutter/material.dart';
import 'package:screw_calculator/components/custom_text.dart';
import 'package:screw_calculator/utility/app_theme.dart';

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
