import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:screw_calculator/models/notification_model.dart';

/// Data source interface for notification operations
abstract class NotificationDataSource {
  /// Streams all notifications from Firestore
  Stream<List<NotificationModel>> getNotifications();

  /// Deletes a notification from Firestore
  Future<bool> deleteNotification(String notificationId);

  /// Marks a notification as read in Firestore
  Future<bool> markAsRead(String notificationId);
}

/// Implementation of NotificationDataSource using Firestore
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
        return NotificationModel.fromJson(
          doc.data(),
          doc.id,
        );
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

      // Move to deleted collection
      final messageId = notificationData['messageId'] as String?;
      await _firestore
          .collection('notifications_deleted')
          .doc(messageId ?? notificationId)
          .set(notificationData);

      // Delete from notifications collection
      await _firestore.collection('notifications').doc(notificationId).delete();

      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> markAsRead(String notificationId) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true});
      return true;
    } catch (e) {
      return false;
    }
  }
}

