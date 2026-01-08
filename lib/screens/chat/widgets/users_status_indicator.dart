import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:screw_calculator/screens/chat/models/user_presence_model.dart';

class UserStatusIndicator extends StatelessWidget {
  final String userName;
  final String? userPhone;
  final double size;

  const UserStatusIndicator({
    super.key,
    required this.userName,
    this.userPhone,
    this.size = 10,
  });

  @override
  Widget build(BuildContext context) {
    if (userPhone == null) {
      return SizedBox(width: size);
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users_presence')
          .doc(userPhone)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return SizedBox(width: size);
        }

        final presence = UserPresence.fromMap(
          snapshot.data!.data() as Map<String, dynamic>,
        );

        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: presence.isActiveOnline ? Colors.green : Colors.grey,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 1.5),
          ),
        );
      },
    );
  }
}
