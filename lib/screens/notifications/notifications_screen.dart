import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:screw_calculator/components/custom_text.dart';
import 'package:screw_calculator/models/notification_model.dart';
import 'package:screw_calculator/screens/notifications/widgets/notify_item.dart';
import 'package:screw_calculator/utility/app_theme.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.grayy,
        title: CustomText(text: 'الإشعارات', fontSize: 22.sp),
        actions: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Transform.flip(
              flipX: true,
              child: const Icon(
                Icons.arrow_back_ios_sharp,
                color: AppColors.white,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: AppColors.bg,

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .orderBy('createdAt', descending: true)
            .snapshots(),

        //     .orderBy("dateTime", descending: true)
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator.adaptive(
                strokeWidth: 4,
                backgroundColor: AppColors.mainColor,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.bg),
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('لا توجد إشعارات حالياً'));
          }

          final notifications = snapshot.data!.docs.map((doc) {
            return NotificationModel.fromJson(
              doc.data() as Map<String, dynamic>,
              doc.id,
            );
          }).toList();

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (contextBuilder, index) {
                final notif = notifications[index];
                return NotificationsItem(notifyItem: notif);
              },
            ),
          );
        },
      ),
    );
  }
}
