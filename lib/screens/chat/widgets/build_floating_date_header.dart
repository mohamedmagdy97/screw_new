import 'package:flutter/material.dart';
import 'package:screw_calculator/utility/app_theme.dart';

class BuildFloatingDateHeader extends StatelessWidget {
  final String dateText;

  const BuildFloatingDateHeader({super.key, required this.dateText});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.grayy.withOpacity(0.8),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          dateText,
          style: const TextStyle(color: Colors.white, fontSize: 11),
        ),
      ),
    );
  }
}
