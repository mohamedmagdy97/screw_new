import 'package:screw_calculator/screens/notifications/domain/repositories/notification_repository.dart';

/// Use case for deleting a notification
class DeleteNotificationUseCase {
  final NotificationRepository _repository;

  DeleteNotificationUseCase(this._repository);

  /// Executes the use case to delete a notification
  /// 
  /// [notificationId] - The ID of the notification to delete
  /// Returns true if successful, false otherwise
  Future<bool> call(String notificationId) async {
    return await _repository.deleteNotification(notificationId);
  }
}

