import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart' as intl;

class UserPresence {
  final String name;
  final String phone;
  final bool isOnline;
  final DateTime lastSeen;

  UserPresence({
    required this.name,
    required this.phone,
    required this.isOnline,
    required this.lastSeen,
  });

  factory UserPresence.fromMap(Map<String, dynamic> map) {
    return UserPresence(
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      isOnline: map['isOnline'] ?? false,
      lastSeen: (map['lastSeen'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // حساب هل المستخدم أونلاين (آخر تحديث خلال دقيقة)
  bool get isActiveOnline {
    return isOnline && DateTime.now().difference(lastSeen).inMinutes < 2;
  }

  // نص آخر ظهور
  String get lastSeenText {
    if (isActiveOnline) return 'متصل الآن';

    final diff = DateTime.now().difference(lastSeen);

    if (diff.inMinutes < 1) return 'منذ لحظات';
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
    if (diff.inDays == 1) return 'أمس';
    if (diff.inDays < 7) return 'منذ ${diff.inDays} يوم';

    return intl.DateFormat('d MMM').format(lastSeen);
  }
}
