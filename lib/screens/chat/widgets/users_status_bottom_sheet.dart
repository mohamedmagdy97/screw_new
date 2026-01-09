import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:screw_calculator/components/custom_text.dart';
import 'package:screw_calculator/screens/chat/models/user_presence_model.dart';
import 'package:screw_calculator/screens/chat/widgets/users_status_item.dart';
import 'package:screw_calculator/utility/app_theme.dart';

class UsersStatusBottomSheet extends StatelessWidget {
  final String? currentUserName;

  const UsersStatusBottomSheet({super.key, this.currentUserName});

  static void show(BuildContext context, {String? currentUserName}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          UsersStatusBottomSheet(currentUserName: currentUserName),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
                CustomText(
                  text: 'حالة المستخدمين',
                  fontSize: 18,
                  color: AppColors.black,

                  fontFamily: AppFonts.bold,
                ),
                const SizedBox(width: 48), // للتوازن
              ],
            ),
          ),

          const Divider(height: 1),

          // Users list
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users_presence')
                  .orderBy('lastSeen', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final users = snapshot.data!.docs
                    .map(
                      (doc) => UserPresence.fromMap(
                        doc.data() as Map<String, dynamic>,
                      ),
                    )
                    .where((user) => user.name != currentUserName)
                    .toList();

                if (users.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        CustomText(
                          text: 'لا يوجد مستخدمين حالياً',
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  itemCount: users.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1, indent: 72),
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return UserStatusItem(user: user);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
