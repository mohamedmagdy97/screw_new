import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:screw_calculator/my_app.dart';
import 'package:screw_calculator/screens/force_update.dart';
import 'package:screw_calculator/screens/prayer/core/notification_service.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await NotificationService.init();
  await Hive.initFlutter();
  await Hive.openBox('prayerCache');
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const ForceUpdateWrapper(child: MyApp()));
}
