import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

NotificationsData notificationsData = NotificationsData();

class NotificationsData {
  Future<void> addNotification({
    required String title,
    required String description,
    required String type,
    String? image,
  }) async {
    final id = const Uuid().v4();
    final notification = {
      'id': id,
      'title': title,
      'description': description,
      'datetime': DateTime.now(),
      'type': type,
      // update | reminder | promo | alert | contact | action | general
      'image': image ?? 'https://i.ibb.co/N2gS7rd9/play-store-512.png',
      'isRead': false,
      'priority': 'high',
      // low | medium | high
      'actionUrl': '',
      'createdAt': FieldValue.serverTimestamp(),
    };

    await FirebaseFirestore.instance
        .collection('notifications')
        .doc(id)
        .set(notification);
  }
}
