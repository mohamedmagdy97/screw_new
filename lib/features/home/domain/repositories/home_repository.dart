import 'package:screw_calculator/core/utils/enums.dart';
import 'package:screw_calculator/features/home/data/datasources/home_local_data_source.dart';

/// عقد بيانات الشاشة الرئيسية: تسجيل/تحقق المستخدم وصلاحية دخول الشات.
abstract class HomeRepository {
  CachedUser getCachedUser();

  Future<UserValidationResult> validateUser({
    required String name,
    required String phone,
    required String country,
  });

  /// يسجّل المستخدم (بعيد) ويخزّنه محليًا.
  Future<void> registerUser({
    required String name,
    required String phone,
    required String country,
    required String age,
  });

  Future<bool> canEnterChat({required String phone, required String name});
}
