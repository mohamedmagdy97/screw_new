import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:screw_calculator/components/custom_text.dart';
import 'package:screw_calculator/helpers/phone_mask_helper.dart';
import 'package:screw_calculator/utility/app_theme.dart';

class NewMsgIndicator extends StatelessWidget {
  final bool showNewMsgIndicator;
  final int unreadNewMessages;
  final String unreadNewMessagesText;
  final Function()? jumpToLatest;

  const NewMsgIndicator({
    super.key,
    required this.showNewMsgIndicator,
    required this.unreadNewMessagesText,
    required this.unreadNewMessages,
    this.jumpToLatest,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      duration: const Duration(milliseconds: 250),
      scale: showNewMsgIndicator ? 1 : 0,
      child: GestureDetector(
        onTap: jumpToLatest,
        child: Container(
          width: 0.85.sw,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.blue.shade600,
            borderRadius: BorderRadius.circular(30),
            boxShadow: const [BoxShadow(blurRadius: 10, color: Colors.black26)],
          ),
          child: Row(
            children: [
              const Icon(Icons.arrow_downward, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    CustomText(
                      text: 'ـ$unreadNewMessages رسالة جديـدة ',
                      fontFamily: AppFonts.bold,
                      maxLines: 1,
                      fontSize: 15.sp,
                    ),

                    CustomText(
                      text: unreadNewMessagesText.length > 1000
                          ? 'صورة جديدة'
                          : PhoneMaskHelper.maskPhoneNumbers(
                              unreadNewMessagesText,
                            ),
                      maxLines: 2,
                      fontSize: 14.sp,
                      textAlign: TextAlign.end,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
