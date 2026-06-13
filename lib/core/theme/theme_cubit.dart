import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

/// يدير وضع الثيم (فاتح/داكن/تلقائي) ويحفظ اختيار المستخدم في Hive.
class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit({Box? box})
    : _box = box ?? Hive.box('userBox'),
      super(_read(box ?? Hive.box('userBox')));

  static const String _key = 'themeMode';

  final Box _box;

  static ThemeMode _read(Box box) {
    final String? saved = box.get(_key) as String?;
    return switch (saved) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.dark, // الوضع الافتراضي الحالي للتطبيق داكن
    };
  }

  void setMode(ThemeMode mode) {
    _box.put(_key, mode.name);
    emit(mode);
  }

  /// يبدّل بين الفاتح والداكن.
  void toggle() {
    setMode(state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);
  }

  bool get isDark => state == ThemeMode.dark;
}
