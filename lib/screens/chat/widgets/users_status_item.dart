import 'package:flutter/material.dart';
import 'package:screw_calculator/components/custom_text.dart';
import 'package:screw_calculator/screens/chat/models/user_presence_model.dart';
import 'package:screw_calculator/utility/app_theme.dart';

class UserStatusItem extends StatelessWidget {
  const UserStatusItem({super.key, required this.user});

  final UserPresence user;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: user.isActiveOnline
                ? Colors.green[100]
                : Colors.grey[300],
            child: CustomText(
              text: user.name.isNotEmpty ? user.name[0] : '?',
              fontSize: 18,
              fontFamily: AppFonts.bold,
              color: user.isActiveOnline ? Colors.green : Colors.grey,
            ),
          ),
          if (user.isActiveOnline)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
        ],
      ),
      title: CustomText(
        text: user.name,
        color: AppColors.black,
        fontSize: 16,
        textAlign: TextAlign.right,
      ),
      subtitle: CustomText(
        text: user.lastSeenText,
        fontSize: 12,
        color: user.isActiveOnline ? Colors.green : Colors.grey,
        textAlign: TextAlign.right,
      ),
      trailing: Icon(
        user.isActiveOnline ? Icons.circle : Icons.circle_outlined,
        color: user.isActiveOnline ? Colors.green : Colors.grey,
        size: 12,
      ),
    );
  }
}
