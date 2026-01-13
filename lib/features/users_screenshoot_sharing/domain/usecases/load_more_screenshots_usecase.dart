import 'package:screw_calculator/features/users_screenshoot_sharing/domain/entities/screenshot_entity.dart';
import 'package:screw_calculator/features/users_screenshoot_sharing/domain/repositories/screenshot_repository.dart';

class LoadMoreScreenshotsUseCase {
  final ScreenshotRepository _repository;

  LoadMoreScreenshotsUseCase(this._repository);

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
