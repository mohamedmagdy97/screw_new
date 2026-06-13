import 'package:shared_preferences/shared_preferences.dart';

class AppLocalStore {
  static Future<String?> getString(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  static Future<int?> getIntNotifications(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final int? num=prefs.getInt(key);
    if (num== null) {
      return -1;
    }
    return num;
  }

  static Future<bool?> getBool(String key) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(key) == null) {
      return null;
    }
    return prefs.getBool(key);
  }

  static Future<void> setString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value);
  }
  static Future<void> setBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(key, value);
  }

  static Future<bool> removeString(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.remove(key);
  }
}


