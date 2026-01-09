import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserPresenceManager {
  static final UserPresenceManager _instance = UserPresenceManager._internal();

  factory UserPresenceManager() => _instance;

  UserPresenceManager._internal();

  Timer? _heartbeatTimer;
  String? _currentUserName;
  String? _currentUserPhone;

  // بدء تتبع حالة المستخدم
  void startTracking({required String userName, required String userPhone}) {
    _currentUserName = userName;
    _currentUserPhone = userPhone;

    // تحديث الحالة إلى أونلاين
    _updatePresence(isOnline: true);

    // إرسال heartbeat كل 30 ثانية
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _updatePresence(isOnline: true),
    );
  }

  // إيقاف التتبع
  void stopTracking() {
    _heartbeatTimer?.cancel();
    _updatePresence(isOnline: false);
  }

  // تحديث حالة المستخدم في Firestore
  Future<void> _updatePresence({required bool isOnline}) async {
    if (_currentUserName == null || _currentUserPhone == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('chats')
          .doc('users_presence')
          .collection('users_presence')
          .doc(_currentUserPhone)
          .set({
            'name': _currentUserName,
            'phone': _currentUserPhone,
            'isOnline': isOnline,
            'lastSeen': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error updating presence: $e');
    }
  }
}
