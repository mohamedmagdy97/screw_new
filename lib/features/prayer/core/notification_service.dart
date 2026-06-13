import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final _notifications = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  // تهيئة الإشعارات
  static Future<void> init() async {
    if (_initialized) return;

    try {
      // طلب الأذونات أولاً
      await requestNotificationPermission();

      // إعدادات Android
      const android = AndroidInitializationSettings('@mipmap/ic_launcher');

      // إعدادات iOS — طلب صلاحيات التنبيه/الصوت/الشارة.
      const iOS = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const settings = InitializationSettings(android: android, iOS: iOS);

      await _notifications.initialize(
        settings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      // تهيئة المناطق الزمنية
      tz.initializeTimeZones();

      // تعيين المنطقة الزمنية لمصر
      tz.setLocalLocation(tz.getLocation('Africa/Cairo'));

      _initialized = true;
      debugPrint('✅ Notification Service initialized successfully');
    } catch (e) {
      debugPrint('❌ Error initializing notifications: $e');
    }
  }

  // معالجة النقر على الإشعار
  static void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
    // يمكنك إضافة navigation هنا إذا أردت
  }

  // جدولة إشعار الصلاة
  static Future<void> schedulePrayerNotification({
    required String prayerName,
    required DateTime time,
  }) async {
    try {
      // التحقق من الأذونات
      if (!await Permission.notification.isGranted) {
        debugPrint('⚠️ Notification permission not granted');
        return;
      }

      // إلغاء الإشعار السابق لنفس الصلاة
      await _notifications.cancel(prayerName.hashCode);

      final now = DateTime.now();
      var scheduled = DateTime(
        now.year,
        now.month,
        now.day,
        time.hour,
        time.minute,
      );

      // إذا كان الوقت قد مضى اليوم، جدوله لليوم التالي
      if (scheduled.isBefore(now)) {
        scheduled = scheduled.add(const Duration(days: 1));
      }

      final tzScheduled = tz.TZDateTime.from(scheduled, tz.local);

      debugPrint('📅 Scheduling $prayerName at $scheduled');

      await _notifications.zonedSchedule(
        prayerName.hashCode, // معرف فريد لكل صلاة
        'موعد صلاة $prayerName',
        'حان الآن وقت صلاة $prayerName 🕌',
        tzScheduled,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'prayer_channel',
            'Prayer Notifications',
            channelDescription: 'إشعارات مواقيت الصلاة',
            importance: Importance.max,
            priority: Priority.high,
            sound: RawResourceAndroidNotificationSound('azan'),
            //   ملف azan.mp3 في android/app/src/main/res/raw/
            icon: '@mipmap/ic_launcher',
            color: Color(0xFF2196F3),
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            // الصوت الافتراضي — لا يوجد ملف azan.aiff مضمّن في حزمة iOS.
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,

        // uiLocalNotificationDateInterpretation:
        // UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: prayerName,
      );

      debugPrint('✅ $prayerName notification scheduled successfully');
    } catch (e) {
      debugPrint('❌ Error scheduling $prayerName notification: $e');
    }
  }

  // طلب الأذونات
  static Future<bool> requestNotificationPermission() async {
    try {
      // أذونات الإشعارات العادية
      if (await Permission.notification.isDenied) {
        final status = await Permission.notification.request();
        if (!status.isGranted) {
          debugPrint('⚠️ Notification permission denied');
          return false;
        }
      }

      // أذونات الإشعارات المجدولة بدقة (Android 12+ فقط).
      if (Platform.isAndroid &&
          await Permission.scheduleExactAlarm.isDenied) {
        await Permission.scheduleExactAlarm.request();
      }

      debugPrint('✅ All permissions granted');
      return true;
    } catch (e) {
      debugPrint('❌ Error requesting permissions: $e');
      return false;
    }
  }

  // إلغاء جميع الإشعارات
  static Future<void> cancelAllNotifications() async {
    try {
      await _notifications.cancelAll();
      debugPrint('✅ All notifications cancelled');
    } catch (e) {
      debugPrint('❌ Error cancelling notifications: $e');
    }
  }

  // إلغاء إشعار محدد
  static Future<void> cancelNotification(String prayerName) async {
    try {
      await _notifications.cancel(prayerName.hashCode);
      debugPrint('✅ $prayerName notification cancelled');
    } catch (e) {
      debugPrint('❌ Error cancelling $prayerName notification: $e');
    }
  }

  // الحصول على الإشعارات المجدولة
  static Future<List<PendingNotificationRequest>>
  getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  // عرض إشعار فوري (للاختبار)
  static Future<void> showInstantNotification({
    required String title,
    required String body,
  }) async {
    try {
      await _notifications.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title,
        body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'instant_channel',
            'Instant Notifications',
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
      );
    } catch (e) {
      debugPrint('❌ Error showing instant notification: $e');
    }
  }
}
