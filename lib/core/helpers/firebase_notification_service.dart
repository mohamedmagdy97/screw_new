import 'package:app_settings/app_settings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:screw_calculator/core/helpers/app_print.dart';
import 'package:screw_calculator/core/helpers/device_info.dart';
import 'package:screw_calculator/core/helpers/firbase_handling.dart';
import 'package:screw_calculator/core/widgets/custom_dialog.dart';
import 'package:uuid/uuid.dart';

/// Plugin Instance
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

/// Background Handler
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('🔔 Background message received: ${message.messageId}');

  if (message.notification != null) {
    await FirebaseNotificationService._saveNotificationToFirestore(message);
  }
}

class FirebaseNotificationService {
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;
  static const String _notificationsCollection = 'notifications';
  static const String _tokensCollection = 'tokens';
  static const String _channelId = 'high_importance_channel';
  static const String _channelName = 'High Importance Notifications';
  static const String _channelDescription =
      'This channel is used for important notifications.';
  static const String _defaultImageUrl =
      'https://i.ibb.co/N2gS7rd9/play-store-512.png';

  /// Initialize Firebase Messaging Service
  static Future<void> init(BuildContext context) async {
    try {
      await setupLocalNotifications();
      await _checkNotificationPermissions(context);
      await _registerForegroundHandler();
      await _registerBackgroundHandlers();
      await _subscribeTopic();
      await _saveDeviceToken();
    } catch (e) {
      Printing.error('❌ Error initializing Firebase Messaging: $e');
    }
  }

  /// Setup Local Notification Channel
  static Future<void> setupLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: androidSettings);

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.high,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  /// Handle notification tap
  static void _onNotificationTapped(NotificationResponse response) {
    debugPrint('👉 Notification tapped: ${response.payload}');
    // Handle navigation based on payload
  }

  /// Register Foreground Message Handler
  static Future<void> _registerForegroundHandler() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      Printing.info(
        '📩 Foreground notification: ${message.notification?.title}',
      );

      if (message.notification != null) {
        await _saveNotificationToFirestore(message);
        await showNotification(
          message.notification!.title ?? 'No Title',
          message.notification!.body ?? 'No Body',
        );
      }
    });
  }

  /// Register Background Handlers
  static Future<void> _registerBackgroundHandlers() async {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('👉 Notification opened: ${message.data}');
      FireBaseHandling.setupInteractedMessage();
      // Handle navigation based on message.data
    });

    // Handle notification when app is terminated
    final initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      debugPrint('👉 App opened from terminated state: ${initialMessage.data}');
      FireBaseHandling.setupInteractedMessage();
    }
  }

  /// Save notification to Firestore (only first device)
  static Future<void> _saveNotificationToFirestore(
    RemoteMessage message,
  ) async {
    try {
      final String messageId = message.messageId ?? const Uuid().v4();
      final String imageUrl = _extractImageUrl(message);

      final DocumentReference notificationRef = FirebaseFirestore.instance
          .collection(_notificationsCollection)
          .doc(messageId);

      // Use Firestore transaction to ensure only one device saves the notification
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(notificationRef);

        if (!snapshot.exists) {
          // Only the first device will successfully write this
          transaction.set(notificationRef, {
            'id': messageId,
            'title': message.notification?.title ?? '',
            'body': message.notification?.body ?? '',
            'imageUrl': imageUrl,
            'data': message.data,
            'type': message.data['type'] ?? 'general',
            'isRead': false,
            'sentTime': message.sentTime ?? DateTime.now(),
            'createdAt': FieldValue.serverTimestamp(),
          });

          Printing.info('✅ Notification saved: $messageId');
        } else {
          Printing.warning('⚠️ Notification already exists: $messageId');
        }
      });
    } catch (e) {
      Printing.error('❌ Error saving notification: $e');
    }
  }

  /// Extract image URL from notification
  static String _extractImageUrl(RemoteMessage message) {
    return message.notification?.android?.imageUrl.toString() ??
        (message.notification?.apple?.imageUrl.toString() ??
            (message.data['imageUrl'] != null
                ? message.data['imageUrl'].toString()
                : _defaultImageUrl.toString()));
  }

  /// Show Local Notification
  static Future<void> showNotification(String title, String body) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      platformDetails,
    );
  }

  /// Save device token to Firestore
  static Future<void> _saveDeviceToken() async {
    try {
      final String? token = await _firebaseMessaging.getToken();

      if (token == null || token.isEmpty) {
        Printing.warning('⚠️ No FCM token available');
        return;
      }

      Printing.info('📱 FCM Token: $token');
      await _addTokenToFirestore(token: token);
    } catch (e) {
      Printing.error('❌ Error saving device token: $e');
    }
  }

  /// Add token to Firestore (avoid duplicates)
  static Future<void> _addTokenToFirestore({required String token}) async {
    try {
      final String deviceName = await getDeviceName();
      Printing.info('📱 Device: $deviceName');

      final CollectionReference tokensRef = FirebaseFirestore.instance
          .collection(_tokensCollection);

      // Check if token already exists
      final snapshot = await tokensRef
          .where('token', isEqualTo: token)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        // Update existing token
        final docId = snapshot.docs.first.id;
        await tokensRef.doc(docId).update({
          'deviceName': deviceName,
          'lastUpdated': FieldValue.serverTimestamp(),
        });
        Printing.info('🔄 Token updated: $docId');
      } else {
        // Add new token
        final String id = const Uuid().v4();
        await tokensRef.doc(id).set({
          'id': id,
          'token': token,
          'deviceName': deviceName,
          'createdAt': FieldValue.serverTimestamp(),
          'lastUpdated': FieldValue.serverTimestamp(),
          'isActive': true,
        });
        Printing.info('✅ Token added: $id');
      }
    } catch (e) {
      Printing.error('❌ Error adding token: $e');
    }
  }

  /// Subscribe to topic
  static Future<void> _subscribeTopic() async {
    try {
      await _firebaseMessaging.subscribeToTopic('allUsers');
      Printing.info('✅ Subscribed to topic: allUsers');
    } catch (e) {
      Printing.error('❌ Error subscribing to topic: $e');
    }
  }

  /// Check & Request Notification Permissions
  static Future<void> _checkNotificationPermissions(
    BuildContext context,
  ) async {
    NotificationSettings settings = await _firebaseMessaging
        .getNotificationSettings();

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      Printing.info('✅ Notifications authorized');
      return;
    }

    // Request permission
    settings = await _firebaseMessaging.requestPermission(
      
    );

    Printing.info('🔔 Permission status: ${settings.authorizationStatus}');

    if (settings.authorizationStatus != AuthorizationStatus.authorized) {
      await _showPermissionDialog(context);
    }
  }

  /// Show permission dialog
  static Future<void> _showPermissionDialog(BuildContext context) async {
    await customAlertAnimation(
      alertType: 'تحذير',
      title:
          'الإشعارات مغلقة لديك ولن تتمكن من استقبال آخر التحديثات. من فضلك قم بالسماح للتطبيق باستقبال الإشعارات',
      textButton: 'السماح بالإشعارات',
      textSecondButton: 'ليس الآن',
      onTap: () =>
          AppSettings.openAppSettings(type: AppSettingsType.notification),
      context: context,
    );
  }

  /// Delete device token (call on logout)
  static Future<void> deleteDeviceToken() async {
    try {
      final String? token = await _firebaseMessaging.getToken();

      if (token != null) {
        final snapshot = await FirebaseFirestore.instance
            .collection(_tokensCollection)
            .where('token', isEqualTo: token)
            .get();

        for (var doc in snapshot.docs) {
          await doc.reference.delete();
        }

        await _firebaseMessaging.deleteToken();
        Printing.info('✅ Token deleted');
      }
    } catch (e) {
      Printing.error('❌ Error deleting token: $e');
    }
  }

  /// Unsubscribe from topic
  static Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      Printing.info('✅ Unsubscribed from: $topic');
    } catch (e) {
      Printing.error('❌ Error unsubscribing: $e');
    }
  }
}
