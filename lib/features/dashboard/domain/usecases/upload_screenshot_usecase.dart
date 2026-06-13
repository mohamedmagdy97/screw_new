import 'dart:io';

import 'package:screw_calculator/features/dashboard/domain/repositories/dashboard_repository.dart';

/// رفع صورة لوحة النتائج لمشاركتها مع الآخرين.
class UploadScreenshotUseCase {
  UploadScreenshotUseCase(this._repository);

  final DashboardRepository _repository;

  Future<void> call(File file, {required String title}) =>
      _repository.uploadScreenshot(file, title: title);
}
