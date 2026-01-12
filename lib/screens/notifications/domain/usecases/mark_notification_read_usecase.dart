import 'package:screw_calculator/screens/notifications/domain/repositories/notification_repository.dart';

/// Use case for marking a notification as read
class MarkNotificationReadUseCase {
  final NotificationRepository _repository;

  MarkNotificationReadUseCase(this._repository);

  /// Executes the use case to mark a notification as read
  /// 
  /// [notificationId] - The ID of the notification to mark as read
  /// Returns true if successful, false otherwise
  Future<bool> call(String notificationId) async {
    return await _repository.markAsRead(notificationId);
  }
}

