import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

/// مصدر البيانات البعيد للوحة النتائج: رفع صورة الـ scoreboard إلى Firestore
/// لمشاركتها في صفحة "مشاركات الآخرين".
abstract class DashboardRemoteDataSource {
  Future<void> uploadScreenshot(File file, {required String title});
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  DashboardRemoteDataSourceImpl({required this.firestore});

  final FirebaseFirestore firestore;

  static const String _collection = 'user_screenshoot_sharing';

  @override
  Future<void> uploadScreenshot(File file, {required String title}) async {
    final String id = const Uuid().v4();
    final bytes = await file.readAsBytes();
    final String base64Image = base64Encode(bytes);

    await firestore.collection(_collection).doc(id).set({
      'id': id,
      'title': title,
      'imageBase64': base64Image,
      'timestamp': DateTime.now().toIso8601String(),
      'datetime': FieldValue.serverTimestamp(),
    });
  }
}
