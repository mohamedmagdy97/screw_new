import 'package:screw_calculator/screens/notifications/data/datasources/notification_data_source.dart';
import 'package:screw_calculator/screens/notifications/data/mappers/notification_mapper.dart';
import 'package:screw_calculator/screens/notifications/domain/entities/notification_entity.dart';
import 'package:screw_calculator/screens/notifications/domain/repositories/notification_repository.dart';

/// Implementation of NotificationRepository
class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationDataSource _dataSource;

  NotificationRepositoryImpl({
    required NotificationDataSource dataSource,
  }) : _dataSource = dataSource;

  @override
  Stream<List<NotificationEntity>> getNotifications() {
    return _dataSource.getNotifications().map((models) {
      return models.map((model) => NotificationMapper.toEntity(model)).toList();
    });
  }

  @override
  Future<bool> deleteNotification(String notificationId) async {
    return await _dataSource.deleteNotification(notificationId);
  }

  @override
  Future<bool> markAsRead(String notificationId) async {
    return await _dataSource.markAsRead(notificationId);
  }
}

