import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:screw_calculator/components/custom_button.dart';
import 'package:screw_calculator/components/custom_text.dart';
import 'package:screw_calculator/models/notification_model.dart';
import 'package:screw_calculator/screens/contact_us/contact_us.dart';
import 'package:screw_calculator/utility/app_theme.dart';
import 'package:screw_calculator/utility/format_date_to_String.dart';
import 'package:screw_calculator/utility/utilities.dart';
import 'package:url_launcher/url_launcher.dart';

class NotificationsItem extends StatelessWidget {
  final NotificationModel notifyItem;

  const NotificationsItem({super.key, required this.notifyItem});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.purple.shade400.withOpacity(0.5),
            Colors.purple.shade800.withOpacity(0.25),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () async {
          if (notifyItem.type == 'contact') {
            Navigator.of(context).push(
              PageRouteBuilder(
                transitionDuration: const Duration(milliseconds: 750),
                pageBuilder: (_, _, _) => const ContactUS(),
              ),
            );
          } else if (notifyItem.type == 'action') {
            if (await canLaunchUrl(Uri.parse(notifyItem.actionUrl!))) {
              await launchUrl(
                Uri.parse(notifyItem.actionUrl!),
                mode: LaunchMode.externalApplication,
              );
            }
          }
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomText(
                        text: notifyItem.datetime.toSmartFormat(),
                        fontSize: 12,
                        textAlign: TextAlign.end,
                      ),
                      Expanded(
                        child: CustomText(
                          text: notifyItem.title,
                          fontSize: 20,
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  CustomText(
                    text: notifyItem.description,
                    fontSize: 16,
                    textAlign: TextAlign.end,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            notifyItem.image != null
                ? Image.network(notifyItem.image!, width: 50, height: 50)
                : const Icon(Icons.notifications),
          ],
        ),
      ),
    );

    /// with Dismissible widget
    //   Dismissible(
    //   key: Key(notifyItem.id),
    //   direction: DismissDirection.endToStart,
    //   background: Container(
    //     alignment: Alignment.centerRight,
    //     margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
    //     decoration: BoxDecoration(
    //       gradient: LinearGradient(
    //         colors: [Colors.red.shade800.withOpacity(0.3), Colors.red],
    //         begin: Alignment.topLeft,
    //         end: Alignment.bottomRight,
    //       ),
    //       borderRadius: BorderRadius.circular(16),
    //       boxShadow: const [
    //         BoxShadow(
    //           color: Colors.black26,
    //           blurRadius: 8,
    //           offset: Offset(0, -2),
    //         ),
    //       ],
    //     ),
    //     padding: const EdgeInsets.symmetric(horizontal: 20),
    //     child: const Icon(Icons.delete, color: Colors.white),
    //   ),
    //   onDismissed: (direction) async {
    //     await FirebaseFirestore.instance
    //         .collection('notifications')
    //         .doc(notifyItem.id)
    //         .delete();
    //
    //     Utilities().showCustomSnack(context, txt: ' ✅ تم حذف الاشعار ');
    //   },
    //   confirmDismiss: (direction) async {
    // add it ontop
    // final CollectionReference archivedRef =
    //       FirebaseFirestore.instance.collection('archived_notifications');
    //
    // if (direction == DismissDirection.startToEnd) {
    //                   // 🟦 أرشفة
    //                   await archivedRef.doc(doc.id).set(data);
    //                   await notificationsRef.doc(doc.id).delete();
    //                   ScaffoldMessenger.of(context).showSnackBar(
    //                     SnackBar(content: Text("Notification archived")),
    //                   );
    //                   return false; // مش هنمسحه من الواجهة (هنعمله يدويًا)
    //                 }
    //     return await showGeneralDialog(
    //       context: context,
    //       barrierDismissible: false,
    //       barrierColor: Colors.black54,
    //       transitionDuration: const Duration(milliseconds: 450),
    //       pageBuilder: (_, _, _) => const SizedBox.shrink(),
    //       transitionBuilder: (ctx, anim, _, child) {
    //         //       final curvedValue = Curves.easeInOut.transform(anim.value);
    //         //       return Transform.scale(
    //         //        scale: curvedValue,
    //
    //         return SlideTransition(
    //           position:
    //               Tween<Offset>(
    //                 begin: const Offset(0, 1),
    //                 end: Offset.zero,
    //               ).animate(
    //                 CurvedAnimation(parent: anim, curve: Curves.easeOutCubic),
    //               ),
    //           child: Opacity(
    //             opacity: anim.value,
    //             child: Dialog(
    //               backgroundColor: AppColors.bg,
    //               child: Padding(
    //                 padding: const EdgeInsets.symmetric(
    //                   horizontal: 16.0,
    //                   vertical: 32,
    //                 ),
    //                 child: Column(
    //                   mainAxisSize: MainAxisSize.min,
    //                   children: [
    //                     CustomText(
    //                       text: 'تحذير',
    //                       fontSize: 18.sp,
    //                       color: AppColors.mainColor,
    //                     ),
    //                     const SizedBox(height: 40),
    //                     CustomText(
    //                       text: 'هل تريد اعادة بدأ الجولة',
    //                       fontSize: 18.sp,
    //                     ),
    //                     const SizedBox(height: 40),
    //                     Row(
    //                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    //                       children: [
    //                         TextButton(
    //                           onPressed: () => Navigator.of(ctx).pop(false),
    //                           child: const CustomText(text: 'لا', fontSize: 18),
    //                         ),
    //                         CustomButton(
    //                           width: 0.25.sw,
    //                           height: 40,
    //                           text: 'نعم',
    //                           isButtonBorder: true,
    //                           onPressed: () => Navigator.of(ctx).pop(true),
    //                         ),
    //                       ],
    //                     ),
    //                   ],
    //                 ),
    //               ),
    //             ),
    //             // _buildDialog(ctx),
    //           ),
    //         );
    //       },
    //     );
    //   },
    //   child: Container(
    //     padding: const EdgeInsets.all(8),
    //     margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
    //     decoration: BoxDecoration(
    //       gradient: LinearGradient(
    //         colors: [
    //           Colors.purple.shade600.withOpacity(0.3),
    //           Colors.purple.shade800.withOpacity(0.3),
    //         ],
    //         begin: Alignment.topLeft,
    //         end: Alignment.bottomRight,
    //       ),
    //       borderRadius: BorderRadius.circular(16),
    //       boxShadow: const [
    //         BoxShadow(
    //           color: Colors.black26,
    //           blurRadius: 8,
    //           offset: Offset(0, -2),
    //         ),
    //       ],
    //     ),
    //     child: Row(
    //       crossAxisAlignment: CrossAxisAlignment.start,
    //
    //       children: [
    //         Expanded(
    //           child: Column(
    //             crossAxisAlignment: CrossAxisAlignment.end,
    //
    //             children: [
    //               Row(
    //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //                 children: [
    //                   CustomText(
    //                     text: notifyItem.datetime.toSmartFormat(),
    //                     fontSize: 12,
    //                     textAlign: TextAlign.end,
    //                   ),
    //                   Expanded(
    //                     child: CustomText(
    //                       text: notifyItem.title,
    //                       fontSize: 20,
    //                       textAlign: TextAlign.end,
    //                     ),
    //                   ),
    //                 ],
    //               ),
    //               const SizedBox(height: 8),
    //
    //               CustomText(
    //                 text: notifyItem.description,
    //                 fontSize: 16,
    //                 textAlign: TextAlign.end,
    //               ),
    //             ],
    //           ),
    //         ),
    //         const SizedBox(width: 8),
    //         notifyItem.image != null
    //             ? Image.network(notifyItem.image!, width: 40, height: 40)
    //             : const Icon(Icons.notifications),
    //       ],
    //     ),
    //   ),
    // );
  }
}
