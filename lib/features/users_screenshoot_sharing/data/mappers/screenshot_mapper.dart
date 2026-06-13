import 'package:screw_calculator/core/models/screenshoot_model.dart';
import 'package:screw_calculator/features/users_screenshoot_sharing/domain/entities/screenshot_entity.dart';

class ScreenshotMapper {
  static ScreenshotEntity toEntity(ScreenShootModel model) {
    return ScreenshotEntity(
      id: model.id,
      title: model.title,
      description: model.description,
      datetime: model.datetime,
      timestamp: model.timestamp,
      imageBase64: model.imageBase64,
    );
  }

  static ScreenShootModel toModel(ScreenshotEntity entity) {
    return ScreenShootModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      datetime: entity.datetime,
      timestamp: entity.timestamp,
      imageBase64: entity.imageBase64,
    );
  }
}
