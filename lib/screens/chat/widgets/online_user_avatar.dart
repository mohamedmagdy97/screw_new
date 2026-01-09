import 'package:flutter/material.dart';
import 'package:screw_calculator/components/custom_text.dart';
import 'package:screw_calculator/screens/chat/models/user_presence_model.dart';
import 'package:screw_calculator/utility/app_theme.dart';

class OnlineUserAvatar extends StatelessWidget {
  final UserPresence user;

  const OnlineUserAvatar({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.blue[100],
                child: CustomText(
                  text: user.name.isNotEmpty ? user.name[0] : '?',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
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
          // const SizedBox(height: 4),
          SizedBox(
            width: 60,
            child: CustomText(
              text: user.name,
              maxLines: 1,
              height: 2,
              color: AppColors.grey,
              // overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
