import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:screw_calculator/app/app.dart';
import 'package:screw_calculator/app/di/service_locator.dart';
import 'package:screw_calculator/features/prayer/core/notification_service.dart';
import 'package:screw_calculator/features/force_update/presentation/screens/force_update.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await NotificationService.init();
  await Hive.initFlutter();
  await Hive.openBox('prayerCache');
  await Hive.openBox('userBox');
  await Hive.openBox('cachedMessages');

  await setupLocator();

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const ForceUpdateWrapper(child: MyApp()));
}
