import 'package:screw_calculator/screens/users_screenshoot_sharing/domain/entities/screenshot_entity.dart';
import 'package:screw_calculator/screens/users_screenshoot_sharing/domain/repositories/screenshot_repository.dart';

/// Use case for loading more screenshots
class LoadMoreScreenshotsUseCase {
  final ScreenshotRepository _repository;

  LoadMoreScreenshotsUseCase(this._repository);

  /// Executes the use case to load more screenshots
  /// [lastDocumentId] - ID of the last document from previous page
  /// [limit] - Number of items to load
  Future<List<ScreenshotEntity>> call({
    required String lastDocumentId,
    required int limit,
  }) async {
    return await _repository.loadMoreScreenshots(
      lastDocumentId: lastDocumentId,
      limit: limit,
    );
  }
}

