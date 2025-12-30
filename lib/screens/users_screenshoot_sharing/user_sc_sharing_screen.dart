import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:screw_calculator/components/bottom_nav_text.dart';
import 'package:screw_calculator/components/custom_text.dart';
import 'package:screw_calculator/components/dox_decoration.dart';
import 'package:screw_calculator/models/screenshoot_model.dart';
import 'package:screw_calculator/utility/app_theme.dart';

class UserScSharingScreen extends StatelessWidget {
  const UserScSharingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.grayy,
        title: CustomText(text: 'مشاركات الاخرين', fontSize: 22.sp),
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
      bottomNavigationBar: const BottomNavigationText(),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('user_screenshoot_sharing')
            .orderBy('timestamp', descending: true)
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

          final items = snapshot.data!.docs.map((doc) {
            return ScreenShootModel.fromJson(
              doc.data() as Map<String, dynamic>,
              doc.id,
            );
          }).toList();

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (contextBuilder, index) {
                final notif = items[index];
                return Column(
                  children: [
                    // CustomText(text: notif.title.toString(), fontSize: 22),
                    Container(
                      padding: const EdgeInsets.all(4),
                      margin: const EdgeInsets.all(4),
                      decoration: customBoxDecoration(borderRadius: 0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        color: AppColors.opacity_1.withOpacity(0.75),
                        child: Image.memory(
                          base64Decode(notif.imageBase64.toString()),
                          width: 1.sw,
                        ),
                      ),
                    ),
                  ],
                );
                // NotificationsItem(notifyItem: notif);
              },
            ),
          );
        },
      ),
    );
  }
}
