import 'package:shared_preferences/shared_preferences.dart';

/// أكواد الألعاب اللايف اللي الموبايل ده بدأها ولسه ما اتمسحتش من السيرفر.
///
/// لو التطبيق اتقفل فجأة وهو لايف، الكود بيفضل هنا ويتمسح أول ما التطبيق
/// يفتح تاني (من غير ما نحتاج TTL في Firestore).
abstract class PendingLiveCodes {
  Future<List<String>> load();

  Future<void> add(String code);

  Future<void> remove(String code);
}

class PrefsPendingLiveCodes implements PendingLiveCodes {
  static const String _key = 'live.pending_codes.v1';

  @override
  Future<List<String>> load() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? const [];
  }

  @override
  Future<void> add(String code) async {
    final prefs = await SharedPreferences.getInstance();
    final codes = {...?prefs.getStringList(_key), code};
    await prefs.setStringList(_key, codes.toList());
  }

  @override
  Future<void> remove(String code) async {
    final prefs = await SharedPreferences.getInstance();
    final codes = [...?prefs.getStringList(_key)]..remove(code);
    await prefs.setStringList(_key, codes);
  }
}
