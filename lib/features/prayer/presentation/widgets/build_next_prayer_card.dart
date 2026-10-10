import 'package:flutter/material.dart';
import 'package:screw_calculator/core/theme/app_palette.dart';
import 'package:screw_calculator/core/theme/app_theme.dart';
import 'package:screw_calculator/core/widgets/custom_text.dart';
import 'package:screw_calculator/features/prayer/data/models/prayer_time_model.dart';

class BuildNextPrayerCard extends StatelessWidget {
  final PrayerTimeModel data;

  const BuildNextPrayerCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final info = data.getNextPrayerInfo();
    final remaining = info['remaining']!;

    final bool isComingSoon =
        !remaining.contains('ساعة') &&
        (remaining.contains('دقيقة') || remaining.contains('ثانية'));

    final palette = context.palette;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(right: 16, left: 16, bottom: 12, top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: isComingSoon
            ? LinearGradient(
                colors: [palette.lose, palette.lose.withValues(alpha: 0.78)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : palette.brandGradient,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        boxShadow: [
          BoxShadow(
            color: (isComingSoon ? palette.lose : palette.brand).withValues(
              alpha: 0.35,
            ),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isComingSoon ? Icons.notifications_active : Icons.access_time,
                color: Colors.white,
                size: 16,
              ),
              const SizedBox(width: 8),
              const CustomText(
                text: 'الصلاة القادمة',
                fontSize: 14,
                color: Colors.white70,
              ),
            ],
          ),
          const SizedBox(height: 8),
          CustomText(
            text: info['name'] ?? '--',
            fontSize: 28,
            fontFamily: AppFonts.bold,
            color: Colors.white,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: CustomText(
              text: info['time'] ?? '--:--',
              fontSize: 28,
              fontFamily: AppFonts.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isComingSoon
                      ? Icons.warning_amber_rounded
                      : Icons.timer_outlined,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 6),
                CustomText(
                  text: remaining,
                  fontSize: 14,
                  fontFamily: AppFonts.bold,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
