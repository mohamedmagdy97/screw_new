import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:screw_calculator/core/theme/app_palette.dart';
import 'package:screw_calculator/core/theme/app_theme.dart';
import 'package:screw_calculator/core/widgets/custom_text.dart';
import 'package:screw_calculator/features/users_screenshoot_sharing/domain/entities/screenshot_entity.dart';

class ScreenshotItem extends StatelessWidget {
  final ScreenshotEntity screenshot;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const ScreenshotItem({
    super.key,
    required this.screenshot,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: GestureDetector(
        onTap: onTap,
        onDoubleTap: onDelete,
        child: Container(
          decoration: BoxDecoration(
            color: palette.surface,
            borderRadius: BorderRadius.circular(AppRadii.lg),
            border: Border.all(color: palette.border),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Image.memory(
                base64Decode(screenshot.imageBase64!),
                fit: BoxFit.fitWidth,
                width: double.infinity,
              ),
              PositionedDirectional(
                bottom: 10,
                end: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                  ),
                  child: CustomText(
                    text: DateFormat('hh:mm a').format(screenshot.timestamp),
                    fontSize: 11,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
