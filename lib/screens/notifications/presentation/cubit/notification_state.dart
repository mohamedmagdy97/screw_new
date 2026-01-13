part of 'notification_cubit.dart';

abstract class NotificationState {}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationLoaded extends NotificationState {
  final List<NotificationEntity> notifications;

  NotificationLoaded(this.notifications);
}

class NotificationEmpty extends NotificationState {}

class NotificationError extends NotificationState {
  final String message;

  NotificationError(this.message);
}

class NotificationDeleting extends NotificationState {}

class NotificationDeleted extends NotificationState {}
