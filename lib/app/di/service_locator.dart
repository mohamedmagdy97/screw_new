import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:screw_calculator/core/theme/theme_cubit.dart';

/// مُحدِّد الخدمات (Dependency Injection) للتطبيق بالكامل.
///
/// يُستدعى [setupLocator] مرة واحدة عند الإقلاع في `main.dart` بعد تهيئة
/// Firebase و Hive. كل feature تُسجّل تبعياتها هنا (datasources → repositories
/// → usecases → cubits) حتى تعتمد طبقة العرض على abstractions تُحقَن، تحقيقًا
/// لمبدأ Dependency Inversion (DIP).
final GetIt sl = GetIt.instance;

Future<void> setupLocator() async {
  _registerExternals();
  _registerCore();
  // تُضاف تسجيلات الـ features هنا تباعًا مع إعادة هيكلتها.
}

/// تبعيات خارجية (SDKs / تخزين) كـ singletons.
void _registerExternals() {
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
  sl.registerLazySingleton<Box>(() => Hive.box('userBox'), instanceName: 'userBox');
}

/// تبعيات الطبقة المشتركة (core).
void _registerCore() {
  sl.registerLazySingleton<ThemeCubit>(() => ThemeCubit());
}
