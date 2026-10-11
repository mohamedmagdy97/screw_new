import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:screw_calculator/core/constants/local_storage_keys.dart';
import 'package:screw_calculator/core/utils/local_store.dart';

/// إشراف الشات: حظر مستخدمين محليًا على الجهاز، وإبلاغ الإدارة عن رسالة.
///
/// مطلوب لسياسة محتوى المستخدمين في Google Play (إبلاغ + حظر داخل التطبيق).
class ChatModerationStore {
  ChatModerationStore({required FirebaseFirestore firestore})
    : _firestore = firestore;

  final FirebaseFirestore _firestore;

  /// خريطة رقم الهاتف → الاسم للمستخدمين المحظورين.
  Future<Map<String, String>> blockedUsers() async {
    final raw = await AppLocalStore.getString(LocalStoreNames.blockedUsers);
    if (raw == null || raw.isEmpty) return {};
    try {
      return (jsonDecode(raw) as Map<String, dynamic>).map(
        (k, v) => MapEntry(k, v.toString()),
      );
    } catch (_) {
      return {};
    }
  }

  Future<void> _save(Map<String, String> map) =>
      AppLocalStore.setString(LocalStoreNames.blockedUsers, jsonEncode(map));

  Future<void> block({required String phone, required String name}) async {
    final map = await blockedUsers();
    map[phone] = name;
    await _save(map);
  }

  Future<void> unblock(String phone) async {
    final map = await blockedUsers();
    map.remove(phone);
    await _save(map);
  }

  /// يرسل بلاغًا لمراجعته (collection `reports`: إنشاء فقط من التطبيق).
  Future<void> reportMessage({
    required String messageId,
    required String reportedPhone,
    required String reportedName,
    required String reporterPhone,
    required bool isImage,
    String? text,
  }) {
    final snippet = (text ?? '');
    return _firestore.collection('reports').add({
      'messageId': messageId,
      'reportedPhone': reportedPhone,
      'reportedName': reportedName,
      'reporterPhone': reporterPhone,
      'isImage': isImage,
      'text': isImage
          ? ''
          : snippet.substring(0, snippet.length > 300 ? 300 : snippet.length),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
