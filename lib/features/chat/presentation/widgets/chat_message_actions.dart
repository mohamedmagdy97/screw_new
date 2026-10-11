import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:screw_calculator/app/di/service_locator.dart';
import 'package:screw_calculator/core/theme/app_theme.dart';
import 'package:screw_calculator/core/utils/utilities.dart';
import 'package:screw_calculator/core/widgets/custom_text.dart';
import 'package:screw_calculator/features/chat/data/datasources/chat_moderation_store.dart';
import 'package:screw_calculator/features/chat/data/models/chat_msg_model.dart';

/// أرقام المشرفين المسموح لهم بحذف أي رسالة (إدارة الشات).
const List<String> kChatAdminPhones = ['01149504892', '01556464892'];

/// يرسل بلاغًا عن رسالة بعد تأكيد المستخدم.
Future<void> reportChatMessage(
  BuildContext context,
  ChatMessage msg, {
  required String reporterPhone,
}) async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('إبلاغ عن الرسالة'),
      content: const Text('سيتم إرسال بلاغ للإدارة لمراجعة هذه الرسالة.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('إلغاء'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('إبلاغ'),
        ),
      ],
    ),
  );
  if (confirm != true || !context.mounted) return;
  try {
    await sl<ChatModerationStore>().reportMessage(
      messageId: msg.id,
      reportedPhone: msg.phoneNumber,
      reportedName: msg.name,
      reporterPhone: reporterPhone,
      isImage: msg.type == 'image',
      text: msg.message,
    );
    if (context.mounted) {
      Utilities().showCustomSnack(context, txt: 'تم إرسال البلاغ');
    }
  } catch (_) {
    if (context.mounted) {
      Utilities().showCustomSnack(context, txt: 'تعذّر إرسال البلاغ');
    }
  }
}

/// يطلب تأكيد حظر مرسل الرسالة؛ يعيد `true` لو تم الحظر فعلًا.
Future<bool> confirmBlockChatUser(BuildContext context, ChatMessage msg) async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text('حظر ${msg.name}؟'),
      content: const Text(
        'لن تظهر لك رسائله بعد الآن. يمكنك إلغاء الحظر من القائمة الجانبية.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('إلغاء'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('حظر'),
        ),
      ],
    ),
  );
  if (confirm != true) return false;
  await sl<ChatModerationStore>().block(phone: msg.phoneNumber, name: msg.name);
  return true;
}

/// قائمة إجراءات الرسالة (تثبيت/تعديل/رد/إبلاغ/حظر/حذف).
void showChatMessageOptions(
  BuildContext context, {
  required ChatMessage msg,
  required String? userName,
  required String? userPhone,
  required VoidCallback onEdit,
  required VoidCallback onReply,
  required VoidCallback onDelete,
  required VoidCallback onReport,
  required VoidCallback onBlock,
}) {
  Widget tile(IconData icon, String text, VoidCallback onTap) => ListTile(
    leading: Icon(icon),
    title: CustomText(text: text, fontSize: 14.sp, textAlign: TextAlign.start),
    onTap: onTap,
  );

  final canDelete =
      msg.phoneNumber == userPhone || kChatAdminPhones.contains(userPhone);

  showModalBottomSheet<void>(
    context: context,
    builder: (sheetContext) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        tile(Icons.push_pin, 'تثبيت الرسالة', () {
          FirebaseFirestore.instance.collection('chats').doc('pinned').set({
            'text': msg.message,
            'sender': msg.name,
            'phone': msg.phoneNumber,
            'id': msg.id,
          });
          Navigator.pop(sheetContext);
        }),
        if (msg.name == userName && msg.type != 'image')
          tile(Icons.edit, 'تعديل الرسالة', () {
            Navigator.pop(sheetContext);
            onEdit();
          }),
        tile(Icons.reply, 'الرد على الرسالة', () {
          Navigator.pop(sheetContext);
          onReply();
        }),
        if (msg.phoneNumber != userPhone) ...[
          tile(Icons.flag_outlined, 'إبلاغ عن الرسالة', () {
            Navigator.pop(sheetContext);
            onReport();
          }),
          tile(Icons.block, 'حظر ${msg.name}', () {
            Navigator.pop(sheetContext);
            onBlock();
          }),
        ],
        if (canDelete)
          tile(Icons.delete, 'حذف الرسالة', () async {
            Navigator.pop(sheetContext);
            final confirm = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Confirm Delete'),
                content: const Text('Do you want to delete this message?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: CustomText(
                      text: 'إلغاء',
                      fontSize: 15.sp,
                      fontFamily: AppFonts.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: CustomText(
                      text: 'حذف',
                      fontSize: 15.sp,
                      color: AppColors.red,
                    ),
                  ),
                ],
              ),
            );
            if (confirm == true) onDelete();
          }),
      ],
    ),
  );
}
