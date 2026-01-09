import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:screw_calculator/components/custom_text.dart';
import 'package:screw_calculator/helpers/phone_mask_helper.dart';
import 'package:screw_calculator/utility/app_theme.dart';

class PinnedMessage extends StatelessWidget {
  const PinnedMessage({
    super.key,
    required this.userName,
    required this.userPhone,
  });

  final String? userName;
  final String? userPhone;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chats')
          .doc('pinned')
          .snapshots(),
      builder: (context, snap) {
        if (!snap.hasData || !snap.data!.exists) return const SizedBox();
        var data = snap.data!;
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          color: AppColors.mainColor,
          child: Row(
            children: [
              const Icon(Icons.push_pin, size: 20, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: CustomText(
                  text: PhoneMaskHelper.maskPhoneNumbers(data['text']),
                  fontSize: 16.sp,
                  maxLines: 1,
                  textAlign: TextAlign.end,
                ),

                // Column(
                //                         crossAxisAlignment: CrossAxisAlignment.start,
                //                         children: [
                //                           Text("رسالة مثبتة من ${data['sender']}",
                //                               style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                //                           Text(data['text'],
                //                               maxLines: 1, overflow: TextOverflow.ellipsis,
                //                               style: const TextStyle(fontSize: 13)),
                //                         ],
                //                       ),
              ),
              if (userName == 'الآدمن' ||
                  userPhone == '01149504892' ||
                  userPhone == '01556464892') // خيار الإلغاء للآدمن فقط
                IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.close, color: Colors.white, size: 20),
                  onPressed: () => data.reference.delete(),
                ),
            ],
          ),
        );
      },
    );
  }
}
