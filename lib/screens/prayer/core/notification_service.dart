// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:timezone/timezone.dart' as tz;
//
// class NotificationService {
//   static final FlutterLocalNotificationsPlugin _notifications =
//   FlutterLocalNotificationsPlugin();
//
//   static Future<void> init() async {
//     const AndroidInitializationSettings androidSettings =
//     AndroidInitializationSettings('@mipmap/ic_launcher');
//
//     const InitializationSettings settings =
//     InitializationSettings(android: androidSettings);
//
//     await _notifications.initialize(settings);
//   }
//
//   static Future<void> schedulePrayerNotification({
//     required String title,
//     required String body,
//     required DateTime scheduledTime,
//   }) async {
//     // تأكد من تهيئة المنطقة الزمنية الصحيحة
//     final tz.TZDateTime tzTime = tz.TZDateTime.from(scheduledTime, tz.local);
//
//     const AndroidNotificationDetails androidDetails =
//     AndroidNotificationDetails(
//       'prayer_channel_id',
//       'Prayer Notifications',
//       channelDescription: 'Notifications for prayer times',
//       importance: Importance.max,
//       priority: Priority.high,
//     );
//
//     const NotificationDetails notificationDetails =
//     NotificationDetails(android: androidDetails);
//
//     await _notifications.zonedSchedule(
//       scheduledTime.hashCode, // unique ID
//       title,
//       body,
//       tzTime,
//       notificationDetails,
//       matchDateTimeComponents: DateTimeComponents.time, // بديل UILocalNotificationDateInterpretation
//       // uiLocalNotificationDateInterpretation:
//       // UILocalNotificationDateInterpretation.wallClockTime, // اختياري فقط للإصدارات القديمة
//       androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, // بديل androidAllowWhileIdle
//
//     );
//   }
// }

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final _notifications = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    await requestNotificationPermission();
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _notifications.initialize(settings);
    tz.initializeTimeZones();
  }

  static Future<void> schedulePrayerNotification({
    required String prayerName,
    required DateTime time,

    // required String title,
    // required String body,
    // required DateTime scheduledTime,
  }) async {
    final scheduled = tz.TZDateTime.from(time, tz.local);

    if (await Permission.scheduleExactAlarm.isGranted) {
      await _notifications.zonedSchedule(
        prayerName.hashCode,
        'موعد صلاة $prayerName',
        'حان الآن وقت صلاة $prayerName 🌙',
        scheduled,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'prayer_channel',
            'Prayer Notifications',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        // androidAllowWhileIdle: true,
        // uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
    // else {
    //   await _notifications.show(
    //     id,
    //     title,
    //     body,
    //     dateTime,
    //     details,
    //   );
    // }
  }

  static Future<void> requestNotificationPermission() async {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }

    if (await Permission.scheduleExactAlarm.isDenied) {
      await Permission.scheduleExactAlarm.request();
    }
  }
}
