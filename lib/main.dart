import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:screw_calculator/my_app.dart';
import 'package:screw_calculator/screens/force_update.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(ForceUpdateWrapper(child: const MyApp()));
}
