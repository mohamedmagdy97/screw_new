import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:screw_calculator/features/notifications/domain/entities/notification_entity.dart';
import 'package:screw_calculator/features/notifications/domain/usecases/delete_notification_usecase.dart';
import 'package:screw_calculator/features/notifications/domain/usecases/get_notifications_usecase.dart';
import 'package:screw_calculator/features/notifications/domain/usecases/mark_notification_read_usecase.dart';

part 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final GetNotificationsUseCase _getNotificationsUseCase;
  final DeleteNotificationUseCase _deleteNotificationUseCase;
  final MarkNotificationReadUseCase _markNotificationReadUseCase;

  NotificationCubit({
    required GetNotificationsUseCase getNotificationsUseCase,
    required DeleteNotificationUseCase deleteNotificationUseCase,
    required MarkNotificationReadUseCase markNotificationReadUseCase,
  }) : _getNotificationsUseCase = getNotificationsUseCase,
       _deleteNotificationUseCase = deleteNotificationUseCase,
       _markNotificationReadUseCase = markNotificationReadUseCase,
       super(NotificationInitial()) {
    _loadNotifications();
  }

  StreamSubscription<List<NotificationEntity>>? _subscription;

  void _loadNotifications() {
    emit(NotificationLoading());
    _subscription?.cancel();
    _subscription = _getNotificationsUseCase.call().listen(
      (notifications) {
        if (notifications.isEmpty) {
          emit(NotificationEmpty());
        } else {
          emit(NotificationLoaded(notifications));
        }
      },
      onError: (error) {
        emit(NotificationError('حدث خطأ أثناء تحميل الإشعارات'));
      },
    );
  }

  Future<void> deleteNotification(String notificationId) async {
    emit(NotificationDeleting());
    try {
      final success = await _deleteNotificationUseCase.call(notificationId);
      if (success) {
        // القائمة تتحدّث تلقائيًا لأن الحالة المحلية تُبثّ على نفس الـ stream.
        emit(NotificationDeleted());
      } else {
        emit(NotificationError('فشل في حذف الإشعار'));
      }
    } catch (e) {
      emit(NotificationError('حدث خطأ أثناء حذف الإشعار'));
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _markNotificationReadUseCase.call(notificationId);
    } catch (e) {
      // Silently fail for mark as read
    }
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
