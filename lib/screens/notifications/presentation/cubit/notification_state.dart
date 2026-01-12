part of 'notification_cubit.dart';

/// Base state for notification feature
abstract class NotificationState {}

/// Initial state
class NotificationInitial extends NotificationState {}

/// Loading state
class NotificationLoading extends NotificationState {}

/// Success state with notifications
class NotificationLoaded extends NotificationState {
  final List<NotificationEntity> notifications;

  NotificationLoaded(this.notifications);
}

/// Empty state when no notifications are available
class NotificationEmpty extends NotificationState {}

/// Error state
class NotificationError extends NotificationState {
  final String message;

  NotificationError(this.message);
}

/// State when deleting a notification
class NotificationDeleting extends NotificationState {}

/// State when notification is deleted successfully
class NotificationDeleted extends NotificationState {}

