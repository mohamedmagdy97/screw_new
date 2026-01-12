import 'package:screw_calculator/screens/users_screenshoot_sharing/domain/entities/screenshot_entity.dart';

/// Repository interface for screenshot-related operations
abstract class ScreenshotRepository {
  /// Streams screenshots with pagination
  /// [limit] - Number of items per page
  Stream<List<ScreenshotEntity>> getScreenshots({required int limit});

  /// Loads more screenshots for pagination
  /// [lastDocumentId] - ID of the last document from previous page
  /// [limit] - Number of items to load
  Future<List<ScreenshotEntity>> loadMoreScreenshots({
    required String lastDocumentId,
    required int limit,
  });

  /// Deletes a screenshot by its ID
  /// Returns true if deletion was successful, false otherwise
  Future<bool> deleteScreenshot(String screenshotId);
}

