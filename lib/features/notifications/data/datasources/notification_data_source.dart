import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:screw_calculator/core/models/notification_model.dart';

abstract class NotificationDataSource {
  Stream<List<NotificationModel>> getNotifications();

  Future<bool> deleteNotification(String notificationId);

  Future<bool> markAsRead(String notificationId);
}

class NotificationDataSourceImpl implements NotificationDataSource {
  NotificationDataSourceImpl({
    required FirebaseFirestore firestore,
    required Box<dynamic> localBox,
  }) : _firestore = firestore,
       _box = localBox;

  static const String _readKey = 'readNotificationIds';
  static const String _deletedKey = 'deletedNotificationIds';

  final FirebaseFirestore _firestore;
  final Box<dynamic> _box;

  /// يُطلق عند تغيّر حالة (مقروء/محذوف) المحلية لإعادة إسقاطها على القائمة.
  final StreamController<void> _localChanges =
      StreamController<void>.broadcast();

  Set<String> _ids(String key) =>
      ((_box.get(key) as List<dynamic>?) ?? const <dynamic>[])
          .cast<String>()
          .toSet();

  Future<void> _addId(String key, String id) async {
    final ids = _ids(key)..add(id);
    await _box.put(key, ids.toList());
    _localChanges.add(null);
  }

  /// الإشعارات مشتركة بين كل المستخدمين على السيرفر (للقراءة فقط)، أمّا حالة
  /// "مقروء" و"محذوف" فمحلية لكل جهاز حتى لا يؤثر مستخدم على الآخرين.
  List<NotificationModel> _applyLocalState(List<NotificationModel> remote) {
    final deleted = _ids(_deletedKey);
    final read = _ids(_readKey);
    return remote
        .where((n) => !deleted.contains(n.id))
        .map((n) => read.contains(n.id) ? n.copyWith(isRead: true) : n)
        .toList();
  }

  @override
  Stream<List<NotificationModel>> getNotifications() {
    late final StreamController<List<NotificationModel>> controller;
    StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? remoteSub;
    StreamSubscription<void>? localSub;
    var latest = <NotificationModel>[];

    void emit() => controller.add(_applyLocalState(latest));

    controller = StreamController<List<NotificationModel>>(
      onListen: () {
        remoteSub = _firestore
            .collection('notifications')
            .orderBy('createdAt', descending: true)
            .snapshots()
            .listen((snapshot) {
              latest = snapshot.docs
                  .map((doc) => NotificationModel.fromJson(doc.data(), doc.id))
                  .toList();
              emit();
            }, onError: controller.addError);
        localSub = _localChanges.stream.listen((_) => emit());
      },
      onCancel: () async {
        await remoteSub?.cancel();
        await localSub?.cancel();
      },
    );
    return controller.stream;
  }

  @override
  Future<bool> deleteNotification(String notificationId) async {
    await _addId(_deletedKey, notificationId);
    return true;
  }

  @override
  Future<bool> markAsRead(String notificationId) async {
    await _addId(_readKey, notificationId);
    return true;
  }
}
