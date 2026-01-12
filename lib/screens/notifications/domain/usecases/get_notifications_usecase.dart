import 'package:screw_calculator/screens/notifications/domain/entities/notification_entity.dart';
import 'package:screw_calculator/screens/notifications/domain/repositories/notification_repository.dart';

/// Use case for getting notifications stream
class GetNotificationsUseCase {
  final NotificationRepository _repository;

  GetNotificationsUseCase(this._repository);

  /// Executes the use case to get notifications stream
  Stream<List<NotificationEntity>> call() {
    return _repository.getNotifications();
  }
}

