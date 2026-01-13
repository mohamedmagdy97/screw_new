import 'package:screw_calculator/screens/notifications/domain/entities/notification_entity.dart';

abstract class NotificationRepository {
  Stream<List<NotificationEntity>> getNotifications();

  Future<bool> deleteNotification(String notificationId);

  Future<bool> markAsRead(String notificationId);
}
