import 'package:flutter/material.dart';
import 'package:screw_calculator/app/di/service_locator.dart';
import 'package:screw_calculator/core/theme/app_palette.dart';
import 'package:screw_calculator/core/widgets/custom_text.dart';
import 'package:screw_calculator/features/chat/data/datasources/chat_moderation_store.dart';

/// نافذة المستخدمين المحظورين مع إمكانية إلغاء الحظر.
Future<void> showBlockedUsersDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (_) => const _BlockedUsersDialog(),
  );
}

class _BlockedUsersDialog extends StatefulWidget {
  const _BlockedUsersDialog();

  @override
  State<_BlockedUsersDialog> createState() => _BlockedUsersDialogState();
}

class _BlockedUsersDialogState extends State<_BlockedUsersDialog> {
  final ChatModerationStore _store = sl<ChatModerationStore>();
  Map<String, String>? _blocked;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final map = await _store.blockedUsers();
    if (mounted) setState(() => _blocked = map);
  }

  @override
  Widget build(BuildContext context) {
    final blocked = _blocked;
    return AlertDialog(
      title: const CustomText(text: 'المستخدمون المحظورون', fontSize: 18),
      content: SizedBox(
        width: double.maxFinite,
        child: blocked == null
            ? const Center(
                heightFactor: 2,
                child: CircularProgressIndicator.adaptive(),
              )
            : blocked.isEmpty
            ? CustomText(
                text: 'لا يوجد مستخدمون محظورون',
                fontSize: 15,
                color: context.palette.textSecondary,
              )
            : ListView(
                shrinkWrap: true,
                children: [
                  for (final e in blocked.entries)
                    ListTile(
                      title: CustomText(
                        text: e.value,
                        fontSize: 16,
                        textAlign: TextAlign.start,
                      ),
                      trailing: TextButton(
                        onPressed: () async {
                          await _store.unblock(e.key);
                          await _reload();
                        },
                        child: const Text('إلغاء الحظر'),
                      ),
                    ),
                ],
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إغلاق'),
        ),
      ],
    );
  }
}
