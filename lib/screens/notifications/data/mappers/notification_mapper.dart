import 'package:screw_calculator/models/notification_model.dart';
import 'package:screw_calculator/screens/notifications/domain/entities/notification_entity.dart';

class NotificationMapper {
  static NotificationEntity toEntity(NotificationModel model) {
    return NotificationEntity(
      id: model.id,
      title: model.title,
      description: model.description,
      datetime: model.datetime,
      type: model.type,
      image: model.image,
      isRead: model.isRead,
      priority: model.priority,
      actionUrl: model.actionUrl,
      createdAt: model.createdAt,
      token: model.token,
      messageId: model.messageId,
    );
  }

  static NotificationModel toModel(NotificationEntity entity) {
    return NotificationModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      datetime: entity.datetime,
      type: entity.type,
      image: entity.image,
      isRead: entity.isRead,
      priority: entity.priority,
      actionUrl: entity.actionUrl,
      createdAt: entity.createdAt,
      token: entity.token,
      messageId: entity.messageId,
    );
  }
}

