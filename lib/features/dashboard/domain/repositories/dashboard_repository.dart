import 'dart:io';

import 'package:screw_calculator/core/models/player_model.dart';

/// عقد طبقة البيانات للوحة النتائج (يخفي مصادر التخزين عن طبقة العرض).
abstract class DashboardRepository {
  /// يحفظ جولة جديدة ضمن سجل الجولات المحفوظة.
  Future<void> saveGame(List<PlayerModel> players);

  /// يرفع صورة لوحة النتائج لمشاركتها مع الآخرين.
  Future<void> uploadScreenshot(File file, {required String title});
}
