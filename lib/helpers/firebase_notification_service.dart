import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:app_settings/app_settings.dart';
import 'package:screw_calculator/components/custom_dialog.dart';
import 'package:screw_calculator/helpers/firbase_handling.dart';

/// Plugin Instance
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

/// Background Handler
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  await FirebaseNotificationService.setupLocalNotifications();
  debugPrint("🔔 Handling a background message: ${message.messageId}");

  if (message.notification != null) {
    FirebaseNotificationService.showNotification(
      message.notification!.title ?? "No Title",
      message.notification!.body ?? "No Body",
    );
  }
}

class FirebaseNotificationService {
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;

  /// Init Service
  static Future<void> init(BuildContext context) async {
    // Setup Local Notifications
    await setupLocalNotifications();

    // Check + Request Permissions
    await _checkNotificationPermissions(context);

    // Background handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint("📩 Foreground: ${message.notification?.title}");
      debugPrint("📩 Foreground body: ${message.notification?.body}");
      debugPrint("📩 Foreground data: ${message.data}");

      if (message.notification != null) {
        showNotification(
          message.notification!.title ?? "No Title",
          message.notification!.body ?? "No Body",
        );

        // Optional UI feedback
        final snackBar = SnackBar(
          content: Text(message.notification?.body ?? "No body"),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    });

    // On Notification Tap (App in background/terminated)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint("👉 User tapped notification: ${message.data}");
      FireBaseHandling.setupInteractedMessage();
    });

    // Print Device Token
    String? token = await _firebaseMessaging.getToken();
    debugPrint("📱 Device FCM Token: $token");
    subscribeToAllUsers();
    debugPrint("Dddddddddddddddd== fcmToken=>>>>>>>>>>>>> $token");
  }

  // static Future<void> init(BuildContext context) async {
  //   const AndroidInitializationSettings initializationSettingsAndroid =
  //   AndroidInitializationSettings('@mipmap/ic_launcher');
  //
  //   const InitializationSettings initializationSettings =
  //   InitializationSettings(android: initializationSettingsAndroid);
  //
  //   await _flutterLocalNotificationsPlugin.initialize(
  //     initializationSettings,
  //     onDidReceiveNotificationResponse: (NotificationResponse response) {
  //       // لما المستخدم يضغط على الإشعار وهو في foreground
  //       print("👉 User tapped notification (foreground/local)");
  //     },
  //   );
  //
  //   // Create Notification Channel
  //   const AndroidNotificationChannel channel = AndroidNotificationChannel(
  //     'high_importance_channel',
  //     'High Importance Notifications',
  //     description: 'This channel is used for important notifications.',
  //     importance: Importance.high,
  //   );
  //
  //   await _flutterLocalNotificationsPlugin
  //       .resolvePlatformSpecificImplementation<
  //       AndroidFlutterLocalNotificationsPlugin
  //   >()
  //       ?.createNotificationChannel(channel);
  //
  //   // Foreground listener
  //   FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  //     print("📩 Got a message in foreground: ${message.notification?.title}");
  //
  //     if (message.notification != null) {
  //       _showNotification(
  //         message.notification!.title ?? "No Title",
  //         message.notification!.body ?? "No Body",
  //       );
  //     }
  //   });
  //
  //   // Background / terminated click listener
  //   FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
  //     handleNotificationClick(message, context);
  //   });
  //
  //   // Terminated state (app closed completely)
  //   FirebaseMessaging.instance.getInitialMessage().then((message) {
  //     if (message != null) {
  //       handleNotificationClick(message, context);
  //     }
  //   });
  // }


  /// Setup Local Notification Channel
  static Future<void> setupLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: androidSettings);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.high,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  /// Show Local Notification
  static Future<void> showNotification(String title, String body) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'high_importance_channel',
          'High Importance Notifications',
          channelDescription:
              'This channel is used for important notifications.',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          icon: '@mipmap/ic_launcher', // ← customized app icon
        );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
    );

    await flutterLocalNotificationsPlugin.show(0, title, body, platformDetails);
  }

  /// Check & Request Notification Permissions
  static Future<void> _checkNotificationPermissions(
    BuildContext context,
  ) async {
    NotificationSettings settings = await _firebaseMessaging
        .getNotificationSettings();

    if (settings.authorizationStatus != AuthorizationStatus.authorized) {
      settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: true,
      );

      debugPrint("🔔 User permission: ${settings.authorizationStatus}");

      if (settings.authorizationStatus != AuthorizationStatus.authorized) {
        await customAlertOptional(
          alertType: "Warning",
          title:
              "صديقي, الإشعارات مغلقة لديك ولن تتمكن من إستقبال آخر الاشعارات والتحديثات, من فضلك قم بالسماح للتطبيق بإستقبال الإشعارات",
          barrierDismissible: true,
          textButton: "السماح بالإشعارات",
          textSecondButton: "ليس الآن",
          onTap: () {
            Navigator.pop(context);
            AppSettings.openAppSettings(type: AppSettingsType.notification);
          },
          onCancel: () => Navigator.pop(context),
          context: context,
        );
      }
    }
  }

   static subscribeToAllUsers() async {

    await FirebaseMessaging.instance.subscribeToTopic("all");
    debugPrint("👉👉👉👉👉 subscribeToAllUsers");

   }

  /// لما المستخدم يفتح الإشعار (من الـ background أو terminated)
  static void handleNotificationClick(RemoteMessage message, BuildContext context) {
    if (message.data.isNotEmpty) {
      debugPrint("👉 User clicked notification with data: ${message.data}");

      final String? screen = message.data['screen'];
      if (screen == "dashboard") {
        Navigator.pushNamed(context, "/dashboard");
      }
    }
  }

}
