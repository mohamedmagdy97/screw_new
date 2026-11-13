import 'dart:convert';

import 'package:screw_calculator/features/more_apps/domain/entities/megtech_app.dart';

/// يقرأ `apps.json` =
/// `{"version": 1, "apps": [{id, name, tagline, icon, play?, appStore?}]}`.
///
/// نفس الملف يخدم كل تطبيقات MegTech (كل تطبيق يخفي نفسه). روابط المتاجر لازم
/// تكون https على المتجر الحقيقي؛ والأيقونة اسم ملف بجوار الـ JSON أو رابط https.
abstract final class MoreAppsJson {
  static const int maxApps = 20;

  /// يرمي [FormatException] لو الملف تالف. العناصر غير الصالحة تُتجاهل.
  static List<MegTechApp> parse(
    String text, {
    required String Function(String name) iconPath,
  }) {
    final Object? json = jsonDecode(text);
    if (json is! Map<String, dynamic> || json['apps'] is! List) {
      throw const FormatException('apps.json: no apps');
    }
    final apps = <MegTechApp>[];
    for (final Object? item in (json['apps'] as List<dynamic>).take(maxApps)) {
      if (item is! Map<String, dynamic>) continue;
      final app = _app(item, iconPath);
      if (app != null) apps.add(app);
    }
    return List.unmodifiable(apps);
  }

  static MegTechApp? _app(
    Map<String, dynamic> j,
    String Function(String name) iconPath,
  ) {
    final Object? id = j['id'];
    final Object? name = j['name'];
    final Object? tagline = j['tagline'];
    final Object? icon = j['icon'];
    if (id is! String ||
        name is! String ||
        tagline is! String ||
        icon is! String) {
      return null;
    }
    if (id.isEmpty || name.isEmpty) return null;
    final play = _store(j['play'], 'play.google.com');
    final appStore = _store(j['appStore'], 'apps.apple.com');
    if (play == null && appStore == null) return null;
    return MegTechApp(
      id: id,
      name: name,
      tagline: tagline,
      icon: icon.startsWith('https://') ? icon : iconPath(icon),
      playUrl: play,
      appStoreUrl: appStore,
    );
  }

  static String? _store(Object? value, String host) {
    if (value is! String) return null;
    final uri = Uri.tryParse(value);
    return uri != null && uri.scheme == 'https' && uri.host == host
        ? value
        : null;
  }
}
