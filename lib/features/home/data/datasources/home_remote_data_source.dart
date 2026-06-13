import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:screw_calculator/core/helpers/device_info.dart';
import 'package:screw_calculator/core/utils/enums.dart';

/// مصدر البيانات البعيد للمستخدم (تسجيل/تحقق/صلاحية دخول الشات) عبر Firestore.
abstract class HomeRemoteDataSource {
  Future<UserValidationResult> validateUser({
    required String name,
    required String phone,
    required String country,
  });

  Future<void> registerUser({
    required String name,
    required String phone,
    required String country,
    required int age,
  });

  Future<bool> canEnterChat({required String phone, required String name});
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  HomeRemoteDataSourceImpl({required this.firestore});

  final FirebaseFirestore firestore;

  CollectionReference<Map<String, dynamic>> get _users =>
      firestore.collection('chats').doc('users').collection('users');

  @override
  Future<UserValidationResult> validateUser({
    required String name,
    required String phone,
    required String country,
  }) async {
    final byName = await _users
        .where('userName', isEqualTo: name)
        .limit(1)
        .get();
    final byPhone = await _users
        .where('userPhone', isEqualTo: phone)
        .limit(1)
        .get();

    if (byName.docs.isEmpty && byPhone.docs.isEmpty) {
      return UserValidationResult.notExists;
    }
    if (byName.docs.isNotEmpty && byPhone.docs.isEmpty) {
      return UserValidationResult.existsName;
    }
    if (byPhone.docs.isNotEmpty && byName.docs.isEmpty) {
      return UserValidationResult.existsNumber;
    }

    final match = await _users
        .where('userPhone', isEqualTo: phone)
        .where('userName', isEqualTo: name)
        .limit(1)
        .get();
    if (match.docs.isEmpty) {
      return UserValidationResult.existsButInvalidCountry;
    }

    final storedCountry = match.docs.first.data()['userCountry']
        ?.toString()
        .trim();
    return storedCountry == country.trim()
        ? UserValidationResult.existsAndValidOwner
        : UserValidationResult.existsButInvalidCountry;
  }

  @override
  Future<void> registerUser({
    required String name,
    required String phone,
    required String country,
    required int age,
  }) async {
    await _users.doc(phone).set({
      'id': phone,
      'userName': name,
      'userPhone': phone,
      'userCountry': country,
      'userAge': age,
      'deviceName': await getDeviceName(),
      'datetime': DateTime.now(),
      'createdAt': FieldValue.serverTimestamp(),
      'isBlocked': false,
    });
  }

  @override
  Future<bool> canEnterChat({
    required String phone,
    required String name,
  }) async {
    final query = await _users
        .where('userPhone', isEqualTo: phone)
        .where('userName', isEqualTo: name)
        .limit(1)
        .get();

    if (query.docs.isEmpty) return true; // مستخدم جديد → مسموح
    final isBlocked = query.docs.first.data()['isBlocked'] as bool? ?? false;
    return !isBlocked;
  }
}
