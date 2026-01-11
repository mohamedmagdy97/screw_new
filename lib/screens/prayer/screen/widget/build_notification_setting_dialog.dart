import 'package:flutter/material.dart';
import 'package:screw_calculator/components/custom_text.dart';
import 'package:screw_calculator/screens/prayer/controllers/prayer_controller.dart';
import 'package:screw_calculator/screens/prayer/core/notification_service.dart';
import 'package:screw_calculator/utility/app_theme.dart';

class BuildNotificationSettingsDialog extends StatelessWidget {
  const BuildNotificationSettingsDialog({super.key, required this.controller});

  final PrayerController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CustomText(
            text: 'إعدادات الإشعارات',
            fontSize: 20,
            fontFamily: AppFonts.bold,
            color: AppColors.black,
          ),
          const SizedBox(height: 24),
          ListTile(
            leading: const Icon(Icons.notification_add),
            title: const CustomText(
              text: 'اختبار الإشعار',
              fontSize: 14,
              color: AppColors.black,
              textAlign: TextAlign.end,
            ),
            onTap: () {
              NotificationService.showInstantNotification(
                title: 'إشعار تجريبي',
                body: 'هذا إشعار تجريبي للتأكد من عمل الإشعارات',
              );
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.refresh),
            title: const CustomText(
              text: 'إعادة جدولة الإشعارات',
              fontSize: 14,
              color: AppColors.black,
              textAlign: TextAlign.end,
            ),
            onTap: () {
              controller.loadPrayerTimes();
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.cancel),
            title: const CustomText(
              text: 'إلغاء جميع الإشعارات',
              fontSize: 14,
              color: AppColors.black,
              textAlign: TextAlign.end,
            ),
            onTap: () async {
              await NotificationService.cancelAllNotifications();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
