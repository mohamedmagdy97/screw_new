import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';

class FireBaseHandling {
  static Future<void> setupInteractedMessage() async {
    // Get any messages which caused the application to open from
    // a terminated state.
    final RemoteMessage? initialMessage = await FirebaseMessaging.instance
        .getInitialMessage();

    // If the message also contains a data property with a "type" of "chat",
    // navigate to a chat screen
    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }
  }

  static void _handleMessage(RemoteMessage? message) {
    log('>>>>>>>>>>>>>>>>>>>>>> object ==>>RemoteMessage>=${message!}');
  }
}
