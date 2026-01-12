import 'package:screw_calculator/screens/users_screenshoot_sharing/data/datasources/screenshot_data_source.dart';
import 'package:screw_calculator/screens/users_screenshoot_sharing/data/mappers/screenshot_mapper.dart';
import 'package:screw_calculator/screens/users_screenshoot_sharing/domain/entities/screenshot_entity.dart';
import 'package:screw_calculator/screens/users_screenshoot_sharing/domain/repositories/screenshot_repository.dart';

/// Implementation of ScreenshotRepository
class ScreenshotRepositoryImpl implements ScreenshotRepository {
  final ScreenshotDataSource _dataSource;

  ScreenshotRepositoryImpl({
    required ScreenshotDataSource dataSource,
  }) : _dataSource = dataSource;

  @override
  Stream<List<ScreenshotEntity>> getScreenshots({required int limit}) {
    return _dataSource.getScreenshots(limit: limit).map((models) {
      return models.map((model) => ScreenshotMapper.toEntity(model)).toList();
    });
  }

  @override
  Future<List<ScreenshotEntity>> loadMoreScreenshots({
    required String lastDocumentId,
    required int limit,
  }) async {
    final models = await _dataSource.loadMoreScreenshots(
      lastDocumentId: lastDocumentId,
      limit: limit,
    );
    return models.map((model) => ScreenshotMapper.toEntity(model)).toList();
  }

  @override
  Future<bool> deleteScreenshot(String screenshotId) async {
    return await _dataSource.deleteScreenshot(screenshotId);
  }
}

