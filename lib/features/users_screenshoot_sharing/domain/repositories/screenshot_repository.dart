import 'package:screw_calculator/features/users_screenshoot_sharing/domain/entities/screenshot_entity.dart';

abstract class ScreenshotRepository {
  Stream<List<ScreenshotEntity>> getScreenshots({required int limit});

  Future<List<ScreenshotEntity>> loadMoreScreenshots({
    required String lastDocumentId,
    required int limit,
  });

  Future<bool> deleteScreenshot(String screenshotId);
}
