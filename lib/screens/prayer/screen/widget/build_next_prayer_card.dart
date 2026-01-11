import 'package:flutter/material.dart';
import 'package:screw_calculator/components/custom_text.dart';
import 'package:screw_calculator/screens/prayer/data/models/prayer_time_model.dart';
import 'package:screw_calculator/utility/app_theme.dart';

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

    return Container(
      margin: const EdgeInsets.only(right: 16, left: 16, bottom: 12,top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isComingSoon
              ? [const Color(0xFFFF6B6B), const Color(0xFFEE5A6F)]
              : [const Color(0xFF1E88E5), const Color(0xFF1565C0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (isComingSoon ? Colors.red : Colors.blue).withOpacity(0.4),
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
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: CustomText(
              text: info['time'] ?? '--:--',
              fontSize: 28,
              fontFamily: AppFonts.bold,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
