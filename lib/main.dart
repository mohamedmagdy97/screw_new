import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:screw_calculator/app/app.dart';
import 'package:screw_calculator/app/di/service_locator.dart';
import 'package:screw_calculator/features/prayer/core/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await NotificationService.init();
  await Hive.initFlutter();
  await Hive.openBox<dynamic>('prayerCache');
  await Hive.openBox<dynamic>('userBox');
  await Hive.openBox<dynamic>('cachedMessages');

  await setupLocator();

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const MyApp());
}
