import 'package:screw_calculator/features/users_screenshoot_sharing/domain/entities/screenshot_entity.dart';
import 'package:screw_calculator/features/users_screenshoot_sharing/domain/repositories/screenshot_repository.dart';

/// Use case for getting screenshots stream
class GetScreenshotsUseCase {
  final ScreenshotRepository _repository;

  GetScreenshotsUseCase(this._repository);

  /// Executes the use case to get screenshots stream
  /// [limit] - Number of items per page
  Stream<List<ScreenshotEntity>> call({required int limit}) {
    return _repository.getScreenshots(limit: limit);
  }
}

