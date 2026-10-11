import 'package:flutter/foundation.dart';

/// تصنيف بطاقة قاعدة (للتصفية واللون).
enum RuleCategory { basics, power, oscar, ramadan, teams, goal }

/// بطاقة قاعدة/كارت في دليل اللعبة.
@immutable
class RuleEntry {
  const RuleEntry({
    required this.category,
    required this.title,
    required this.body,
  });

  final RuleCategory category;
  final String title;
  final String body;

  /// هل البطاقة تخص كروتًا خاصة (تظهر في المرجع السريع أثناء اللعب)؟
  bool get isCard =>
      category == RuleCategory.power ||
      category == RuleCategory.oscar ||
      category == RuleCategory.ramadan ||
      category == RuleCategory.teams;

  /// تطابق البحث (تجاهل حالة الأحرف والتشكيل البسيط).
  bool matches(String query) {
    final q = _normalize(query);
    if (q.isEmpty) return true;
    return _normalize(title).contains(q) || _normalize(body).contains(q);
  }

  static String _normalize(String text) => text
      .toLowerCase()
      .replaceAll(RegExp('[ً-ٰٟ]'), '')
      .replaceAll(RegExp('[أإآ]'), 'ا')
      .replaceAll('ة', 'ه')
      .replaceAll('ى', 'ي')
      .trim();
}
