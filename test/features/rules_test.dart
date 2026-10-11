import 'package:flutter_test/flutter_test.dart';
import 'package:screw_calculator/features/rules/data/rules_data.dart';
import 'package:screw_calculator/features/rules/domain/rule_entry.dart';

void main() {
  test('Arabic and English rules are in sync (same count and categories)', () {
    final ar = rulesFor('ar');
    final en = rulesFor('en');
    expect(en.length, ar.length);
    expect(
      en.map((e) => e.category).toList(),
      ar.map((e) => e.category).toList(),
    );
    expect(ar.every((e) => e.title.isNotEmpty && e.body.isNotEmpty), isTrue);
    expect(en.every((e) => e.title.isNotEmpty && e.body.isNotEmpty), isTrue);
  });

  test('search ignores Arabic diacritics/alef variants and case', () {
    const entry = RuleEntry(
      category: RuleCategory.power,
      title: 'كارت الحرامي',
      body: 'إذا كان معاك',
    );
    expect(entry.matches('حرامي'), isTrue);
    expect(entry.matches('اذا'), isTrue); // إ == ا
    expect(entry.matches(''), isTrue);
    expect(entry.matches('بونج'), isFalse);

    const en = RuleEntry(
      category: RuleCategory.power,
      title: 'Thief card',
      body: 'Keep it',
    );
    expect(en.matches('THIEF'), isTrue);
  });

  test('isCard is true only for card categories', () {
    for (final c in RuleCategory.values) {
      final e = RuleEntry(category: c, title: 't', body: 'b');
      final expected = c != RuleCategory.basics && c != RuleCategory.goal;
      expect(e.isCard, expected, reason: c.name);
    }
  });
}
