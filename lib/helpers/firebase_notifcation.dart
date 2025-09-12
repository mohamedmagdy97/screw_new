import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:screw_calculator/utility/local_store.dart';
import 'package:screw_calculator/utility/local_storge_key.dart';

class FireBaseNotification {
  getfirebaseDeviceId() async {
    String? fcmToken = "";

    // await FirebaseMessaging.instance.deleteToken();
    // await FirebaseMessaging.instance.setAutoInitEnabled(false);
    fcmToken = await FirebaseMessaging.instance.getToken();

    FirebaseMessaging.instance.onTokenRefresh
        .listen((token) async {
          fcmToken = token;
          debugPrint("Dddddddddddddddd== token=$token");
        })
        .onError((error) async {
          debugPrint("Dddddddddddddddd==error=$error");
        });

    String? fbi = fcmToken ?? '';
    return fbi;
  }

  static getFirebaseDeviceIdOnFirst() async {
    await AppLocalStore.removeString(LocalStoreNames.firebaseDeviceId);

    String? fcmToken = "";
    // await FirebaseMessaging.instance.deleteToken();
    // await FirebaseMessaging.instance.setAutoInitEnabled(false);

    FirebaseMessaging.instance.onTokenRefresh
        .listen((token) async {
          fcmToken = token;
        })
        .onError((error) async {
          debugPrint("Dddddddddddddddd==error=$error");
        });

    fcmToken = await FirebaseMessaging.instance.getToken();
    debugPrint("Dddddddddddddddd== fcmToken=>>>>>>>>>>>>> $fcmToken");
    String? fbi = fcmToken ?? '';
    return fbi;
  }
}
