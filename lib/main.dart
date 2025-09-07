import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:screw_calculator/my_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const MyApp());
}
