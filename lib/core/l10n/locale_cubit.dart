import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

/// يدير لغة التطبيق (عربي/إنجليزي) ويحفظ اختيار المستخدم في Hive.
class LocaleCubit extends Cubit<Locale> {
  LocaleCubit({Box<dynamic>? box})
    : _box = box ?? Hive.box<dynamic>('userBox'),
      super(_read(box ?? Hive.box<dynamic>('userBox')));

  static const String _key = 'localeCode';
  static const Locale arabic = Locale('ar');
  static const Locale english = Locale('en');

  final Box<dynamic> _box;

  static Locale _read(Box<dynamic> box) {
    final saved = box.get(_key) as String?;
    return saved == 'en' ? english : arabic; // الافتراضي عربي
  }

  void toggle() {
    final next = state.languageCode == 'ar' ? english : arabic;
    _box.put(_key, next.languageCode);
    emit(next);
  }
}
