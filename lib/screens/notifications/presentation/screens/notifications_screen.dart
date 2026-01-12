import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:screw_calculator/components/bottom_nav_text.dart';
import 'package:screw_calculator/components/custom_appbar.dart';
import 'package:screw_calculator/components/custom_text.dart';
import 'package:screw_calculator/screens/notifications/data/datasources/notification_data_source.dart';
import 'package:screw_calculator/screens/notifications/data/repositories/notification_repository_impl.dart';
import 'package:screw_calculator/screens/notifications/domain/usecases/delete_notification_usecase.dart';
import 'package:screw_calculator/screens/notifications/domain/usecases/get_notifications_usecase.dart';
import 'package:screw_calculator/screens/notifications/domain/usecases/mark_notification_read_usecase.dart';
import 'package:screw_calculator/screens/notifications/presentation/cubit/notification_cubit.dart';
import 'package:screw_calculator/screens/notifications/presentation/widgets/notify_item.dart';
import 'package:screw_calculator/utility/app_theme.dart';

/// Notifications screen following clean architecture
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => _createNotificationCubit(),
      child: const _NotificationsView(),
    );
  }

  /// Creates and configures NotificationCubit with all dependencies
  NotificationCubit _createNotificationCubit() {
    final dataSource = NotificationDataSourceImpl();
    final repository = NotificationRepositoryImpl(dataSource: dataSource);
    final getNotificationsUseCase = GetNotificationsUseCase(repository);
    final deleteNotificationUseCase = DeleteNotificationUseCase(repository);
    final markNotificationReadUseCase = MarkNotificationReadUseCase(repository);
    return NotificationCubit(
      getNotificationsUseCase: getNotificationsUseCase,
      deleteNotificationUseCase: deleteNotificationUseCase,
      markNotificationReadUseCase: markNotificationReadUseCase,
    );
  }
}

class _NotificationsView extends StatelessWidget {
  const _NotificationsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'الإشعارات'),
      backgroundColor: AppColors.bg,
      bottomNavigationBar: const BottomNavigationText(),
      body: BlocBuilder<NotificationCubit, NotificationState>(
        builder: (context, state) {
          if (state is NotificationLoading || state is NotificationInitial) {
            return const Center(
              child: CircularProgressIndicator.adaptive(
                strokeWidth: 4,
                backgroundColor: AppColors.mainColor,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.bg),
              ),
            );
          }

          if (state is NotificationEmpty) {
            return const Center(
              child: CustomText(text: 'لا توجد إشعارات حالياً', fontSize: 16),
            );
          }

          if (state is NotificationError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  CustomText(text: state.message, fontSize: 16),
                ],
              ),
            );
          }

          if (state is NotificationLoaded) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ListView.builder(
                itemCount: state.notifications.length,
                itemBuilder: (context, index) {
                  final notification = state.notifications[index];
                  return NotificationsItem(
                    notification: notification,
                    onDelete: () {
                      context.read<NotificationCubit>().deleteNotification(
                        notification.id,
                      );
                    },
                  );
                },
              ),
            );
          }

          if (state is NotificationDeleting) {
            return const Center(
              child: CircularProgressIndicator.adaptive(
                strokeWidth: 4,
                backgroundColor: AppColors.mainColor,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.bg),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
