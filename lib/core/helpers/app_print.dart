import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

class Printing {
  static void log(String message, {String tag = 'MyApp-Log'}) {
    if (kDebugMode) {
      developer.log('[$tag] $message', time: DateTime.now());
    }
  }

  static void info(String message, {String tag = 'MyApp-Info'}) {
    if (kDebugMode) {
      developer.log(
        '[$tag] $message',
        time: DateTime.now(),
        level: 800, // info level
      );
    }
  }


  static void warning(String message, {String tag = 'MyApp-Warning'}) {
    if (kDebugMode) {
      developer.log(
        '[$tag] $message',
        time: DateTime.now(),
        level: 900, // warning level
      );
    }
  }

  static void error(String message, {String tag = 'MyApp-Error'}) {
    if (kDebugMode) {
      developer.log(
        '[$tag] $message',
        time: DateTime.now(),
        level: 1000, // higher level for error
      );
    }
  }
}
