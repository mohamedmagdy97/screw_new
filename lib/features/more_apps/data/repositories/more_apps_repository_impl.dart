import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:screw_calculator/features/more_apps/data/more_apps_json.dart';
import 'package:screw_calculator/features/more_apps/domain/entities/megtech_app.dart';
import 'package:screw_calculator/features/more_apps/domain/repositories/more_apps_repository.dart';

/// يجلب نص ملف من الإنترنت؛ يرمي استثناءً عند أي فشل.
typedef TextFetcher = Future<String> Function(Uri url);

/// الكتالوج الأونلاين أولًا (فيظهر أي تطبيق جديد أو رابط App Store بدون
/// تحديث)، والنسخة المضمّنة لو المستخدم أوفلاين أو الملف الأونلاين تالف.
class MoreAppsRepositoryImpl implements MoreAppsRepository {
  MoreAppsRepositoryImpl({AssetBundle? bundle, this.fetch, Uri? remoteUrl})
    : _bundle = bundle ?? rootBundle,
      remoteUrl = remoteUrl ?? defaultUrl;

  static const String bundledJson = 'assets/megtech/apps.json';
  static const String bundledIcons = 'assets/megtech/icons/';
  static final Uri defaultUrl = Uri.parse(
    'https://el-mahkama.web.app/megtech/apps.json',
  );

  final AssetBundle _bundle;

  /// null = النسخة المضمّنة فقط (اختبارات / بدون إنترنت).
  final TextFetcher? fetch;
  final Uri remoteUrl;

  /// آخر نسخة أونلاين ناجحة؛ النسخة المضمّنة لا تُخزَّن حتى نعيد المحاولة.
  List<MegTechApp>? _online;

  @override
  Future<List<MegTechApp>> apps() async {
    final cached = _online;
    if (cached != null) return cached;
    final fetch = this.fetch;
    if (fetch != null) {
      try {
        final online = MoreAppsJson.parse(
          await fetch(remoteUrl),
          iconPath: (name) => remoteUrl.resolve('icons/$name').toString(),
        );
        if (online.isNotEmpty) return _online = online;
      } catch (_) {
        // نكمل بالنسخة المضمّنة بالأسفل.
      }
    }
    return MoreAppsJson.parse(
      await _bundle.loadString(bundledJson),
      iconPath: (name) => '$bundledIcons$name',
    );
  }
}

/// جلب آمن لملف الكتالوج: https فقط، مهلة 10 ثوانٍ، وحد أقصى للحجم.
Future<String> fetchCatalogueText(
  Uri url, {
  http.Client? client,
  Duration timeout = const Duration(seconds: 10),
  int maxBytes = 256 * 1024,
}) {
  if (url.scheme != 'https') {
    throw const FormatException('catalogue: https only');
  }
  final c = client ?? http.Client();
  Future<String> download() async {
    final response = await c.send(http.Request('GET', url));
    if (response.statusCode != 200) {
      throw http.ClientException('catalogue: ${response.statusCode}', url);
    }
    final bytes = <int>[];
    await for (final chunk in response.stream) {
      bytes.addAll(chunk);
      if (bytes.length > maxBytes) {
        throw const FormatException('catalogue: too large');
      }
    }
    return utf8.decode(bytes);
  }

  return download().timeout(timeout).whenComplete(() {
    if (client == null) c.close();
  });
}
