import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:screw_calculator/helpers/app_print.dart';
import 'package:screw_calculator/models/notification_model.dart';
import 'package:uuid/uuid.dart';

NotificationsData notificationsData = NotificationsData();

class NotificationsData {
  Future<void> addNotification({
    required String title,
    required String description,
    required String type,
    required String messageId,
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
      'messageId': messageId,
      'createdAt': FieldValue.serverTimestamp(),
    };
    final CollectionReference notifications = FirebaseFirestore.instance
        .collection('notifications');

    final snapshot = await notifications
        .where('messageId', isEqualTo: messageId)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return Printing.warning('🚫 Duplicate notification found. Not adding.');
    } else {
      await FirebaseFirestore.instance
          .collection('notifications')
          .doc(messageId)
          .set(notification);
    }
  }

  Future<void> addToken({required String token}) async {
    final id = const Uuid().v4();
    final userToken = {
      'id': id,
      'token': token,
      'datetime': DateTime.now(),
      'createdAt': FieldValue.serverTimestamp(),
    };
    Printing.info('🚫 ID : $id');

    final CollectionReference notifications = FirebaseFirestore.instance
        .collection('tokens');

    final snapshot = await notifications.where('token', isEqualTo: token).get();

    if (snapshot.docs.isNotEmpty) {
      return Printing.warning('🚫 Duplicate token found. Not adding.');
    } else {
      await FirebaseFirestore.instance
          .collection('tokens')
          .doc(id)
          .set(userToken);
    }
  }

  Future<void> deleteNotification(
    BuildContext ctx,
    NotificationModel notifyItem,
  ) async {
    Navigator.of(ctx).pop(true);
    final deletedNotify = {
      'id': notifyItem.id,
      'title': notifyItem.title,
      'description': notifyItem.description,
      'datetime': notifyItem.datetime,
      'type': notifyItem.type,
      'image':
          notifyItem.image ?? 'https://i.ibb.co/N2gS7rd9/play-store-512.png',
      'isRead': notifyItem.isRead,
      'priority': notifyItem.priority,
      'actionUrl': notifyItem.actionUrl,
      'messageId': notifyItem.messageId,
      'createdAt': notifyItem.createdAt,
      'token': notifyItem.token,
    };

    final CollectionReference notifications = FirebaseFirestore.instance
        .collection('notifications_deleted');

    final snapshot = await notifications
        .where('messageId', isEqualTo: notifyItem.messageId)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return Printing.warning(
        '🚫 Duplicate notifications_deleted found. Not adding.',
      );
    } else {
      await FirebaseFirestore.instance
          .collection('notifications_deleted')
          .doc(notifyItem.messageId)
          .set(deletedNotify);
    }

    await FirebaseFirestore.instance
        .collection('notifications')
        .doc(notifyItem.id)
        .delete();
  }
}
