import 'package:screw_calculator/features/users_screenshoot_sharing/domain/entities/screenshot_entity.dart';
import 'package:screw_calculator/features/users_screenshoot_sharing/domain/repositories/screenshot_repository.dart';

class GetScreenshotsUseCase {
  final ScreenshotRepository _repository;

  GetScreenshotsUseCase(this._repository);

  Stream<List<ScreenshotEntity>> call({required int limit}) {
    return _repository.getScreenshots(limit: limit);
  }
}
