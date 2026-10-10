import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:screw_calculator/app/di/service_locator.dart';
import 'package:screw_calculator/core/widgets/bottom_nav_text.dart';
import 'package:screw_calculator/core/widgets/custom_appbar.dart';
import 'package:screw_calculator/core/widgets/custom_text.dart';
import 'package:screw_calculator/features/notifications/presentation/cubit/notification_cubit.dart';
import 'package:screw_calculator/features/notifications/presentation/widgets/notify_item.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<NotificationCubit>(),
      child: const _NotificationsView(),
    );
  }

  /// Creates and configures NotificationCubit with all dependencies
}

class _NotificationsView extends StatelessWidget {
  const _NotificationsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'الإشعارات'),
      bottomNavigationBar: const BottomNavigationText(),
      body: BlocBuilder<NotificationCubit, NotificationState>(
        builder: (context, state) {
          if (state is NotificationLoading || state is NotificationInitial) {
            return const Center(
              child: CircularProgressIndicator.adaptive(strokeWidth: 4),
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
              child: CircularProgressIndicator.adaptive(strokeWidth: 4),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
