import 'package:screw_calculator/features/users_screenshoot_sharing/domain/repositories/screenshot_repository.dart';

class DeleteScreenshotUseCase {
  final ScreenshotRepository _repository;

  DeleteScreenshotUseCase(this._repository);

  Future<bool> call(String screenshotId) async {
    return await _repository.deleteScreenshot(screenshotId);
  }
}
