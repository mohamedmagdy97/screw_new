import 'package:screw_calculator/screens/notifications/domain/entities/notification_entity.dart';

/// Repository interface for notification-related operations
abstract class NotificationRepository {
  /// Streams all notifications ordered by creation date (descending)
  Stream<List<NotificationEntity>> getNotifications();

  /// Deletes a notification by its ID
  /// Returns true if deletion was successful, false otherwise
  Future<bool> deleteNotification(String notificationId);

  /// Marks a notification as read
  Future<bool> markAsRead(String notificationId);
}

