import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:screw_calculator/models/notification_model.dart';

abstract class NotificationDataSource {
  Stream<List<NotificationModel>> getNotifications();

  Future<bool> deleteNotification(String notificationId);

  Future<bool> markAsRead(String notificationId);
}

class NotificationDataSourceImpl implements NotificationDataSource {
  final FirebaseFirestore _firestore;

  NotificationDataSourceImpl({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<NotificationModel>> getNotifications() {
    return _firestore
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return NotificationModel.fromJson(doc.data(), doc.id);
          }).toList();
        });
  }

  @override
  Future<bool> deleteNotification(String notificationId) async {
    try {
      // Get the notification before deleting
      final doc = await _firestore
          .collection('notifications')
          .doc(notificationId)
          .get();

      if (!doc.exists) {
        return false;
      }

      final notificationData = doc.data() as Map<String, dynamic>;

      final messageId = notificationData['messageId'] as String?;
      await _firestore
          .collection('notifications_deleted')
          .doc(messageId ?? notificationId)
          .set(notificationData);

      await _firestore.collection('notifications').doc(notificationId).delete();

      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> markAsRead(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).update({
        'isRead': true,
      });
      return true;
    } catch (e) {
      return false;
    }
  }
}
