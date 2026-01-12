import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:screw_calculator/components/custom_text.dart';
import 'package:screw_calculator/cubits/generic_cubit/generic_cubit.dart';
import 'package:screw_calculator/helpers/phone_mask_helper.dart';
import 'package:screw_calculator/utility/app_theme.dart';
import 'package:screw_calculator/utility/utilities.dart';

class PinnedMessage extends StatelessWidget {
  const PinnedMessage({
    super.key,
    required this.userName,
    required this.userPhone,
    required this.messageKeys,
    required this.highlightedMessageIdCubitCubit,
  });

  final String? userName;
  final String? userPhone;
  final Map<String, GlobalKey> messageKeys;
  final GenericCubit<String?> highlightedMessageIdCubitCubit;

  @override
  Widget build(BuildContext context) {
    // final Map<String, GlobalKey> _messageKeys = {};

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chats')
          .doc('pinned')
          .snapshots(),
      builder: (context, snap) {
        if (!snap.hasData || !snap.data!.exists) return const SizedBox();
        var data = snap.data!;
        return InkWell(
          onTap: () async {
            final key = messageKeys[snap.data!['id']];

            print("ddddddddddd=1=${key}");
            print("ddddddddddd=2=${snap.data!}");
            print("ddddddddddd=4=${highlightedMessageIdCubitCubit.state.data}");
            print("ddddddddddd=3=${snap.data!['id']}");
            if (key == null || key.currentContext == null) {
              Utilities().showCustomSnack(
                context,
                txt: 'الرسالة قديمة جداً، يرجى التمرير للأعلى للوصول إليها ',
              );

              return;
            }
            highlightedMessageIdCubitCubit.update(
              data: snap.data!['id'].toString(),
            );

            try {
              await Scrollable.ensureVisible(
                key.currentContext!,
                duration: const Duration(milliseconds: 600),
                curve: Curves.fastOutSlowIn,
                alignment: 0.5, // وضع الرسالة في منتصف الشاشة بالضبط
              );
            } catch (e) {
              debugPrint('Scroll error: $e');
            }

            Future.delayed(const Duration(seconds: 2), () {
              highlightedMessageIdCubitCubit.update(data: null);
            });
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            color: AppColors.mainColor,
            child: Row(
              children: [
                const Icon(Icons.push_pin, size: 20, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: CustomText(
                    text: data['text'].toString().length > 1000
                        ? 'صورة مثبتة'
                        : PhoneMaskHelper.maskPhoneNumbers(
                            data['text'].toString(),
                          ),
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
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: () => data.reference.delete(),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
