import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:screw_calculator/components/custom_text.dart';
import 'package:screw_calculator/screens/chat/models/user_presence_model.dart';
import 'package:screw_calculator/screens/chat/widgets/online_user_avatar.dart';

class OnlineUsersList extends StatelessWidget {
  final String? currentUserName;

  const OnlineUsersList({super.key, this.currentUserName});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chats')
          .doc('users_presence')
          .collection('users_presence')
          .orderBy('lastSeen', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final users = snapshot.data!.docs
            .map(
              (doc) => UserPresence.fromMap(doc.data() as Map<String, dynamic>),
            )
            .where((user) => user.name != currentUserName)
            .toList();

        final onlineUsers = users.where((u) => u.isActiveOnline).toList();

        if (onlineUsers.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          height: 85,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: CustomText(
                  text: 'المتصلون الآن (${onlineUsers.length})',
                  fontSize: 12,
                  height: 1.5,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  reverse: true,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  itemCount: onlineUsers.length,
                  itemBuilder: (context, index) {
                    final user = onlineUsers[index];
                    return OnlineUserAvatar(user: user);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
