import 'package:screw_calculator/screens/users_screenshoot_sharing/domain/repositories/screenshot_repository.dart';

/// Use case for deleting a screenshot
class DeleteScreenshotUseCase {
  final ScreenshotRepository _repository;

  DeleteScreenshotUseCase(this._repository);

  /// Executes the use case to delete a screenshot
  /// 
  /// [screenshotId] - The ID of the screenshot to delete
  /// Returns true if successful, false otherwise
  Future<bool> call(String screenshotId) async {
    return await _repository.deleteScreenshot(screenshotId);
  }
}

