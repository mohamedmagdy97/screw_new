import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:screw_calculator/core/theme/theme_cubit.dart';
import 'package:screw_calculator/features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import 'package:screw_calculator/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:screw_calculator/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:screw_calculator/features/dashboard/domain/usecases/save_game_usecase.dart';
import 'package:screw_calculator/features/dashboard/domain/usecases/upload_screenshot_usecase.dart';
import 'package:screw_calculator/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:screw_calculator/features/history/data/datasources/history_data_source.dart';
import 'package:screw_calculator/features/home/data/datasources/home_local_data_source.dart';
import 'package:screw_calculator/features/home/data/datasources/home_remote_data_source.dart';
import 'package:screw_calculator/features/home/data/repositories/home_repository_impl.dart';
import 'package:screw_calculator/features/home/domain/repositories/home_repository.dart';
import 'package:screw_calculator/features/home/presentation/controller/home_controller.dart';
import 'package:screw_calculator/features/prayer/data/datasources/prayer_api_service.dart';
import 'package:screw_calculator/features/prayer/presentation/cubit/prayer_cubit.dart';

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
  _registerHome();
  _registerDashboard();
  _registerPrayer();
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

/// تبعيات الشاشة الرئيسية (home).
void _registerHome() {
  sl
    ..registerLazySingleton<HomeRemoteDataSource>(
      () => HomeRemoteDataSourceImpl(firestore: sl()),
    )
    ..registerLazySingleton<HomeLocalDataSource>(
      () => HomeLocalDataSourceImpl(userBox: sl(instanceName: 'userBox')),
    )
    ..registerLazySingleton<HomeRepository>(
      () => HomeRepositoryImpl(remoteDataSource: sl(), localDataSource: sl()),
    )
    ..registerLazySingleton<HomeController>(
      () => HomeController(repository: sl()),
    );
}

/// تبعيات لوحة النتائج (dashboard).
void _registerDashboard() {
  sl
    ..registerLazySingleton<HistoryDataSource>(() => HistoryDataSourceImpl())
    ..registerLazySingleton<DashboardRemoteDataSource>(
      () => DashboardRemoteDataSourceImpl(firestore: sl()),
    )
    ..registerLazySingleton<DashboardRepository>(
      () => DashboardRepositoryImpl(
        historyDataSource: sl(),
        remoteDataSource: sl(),
      ),
    )
    ..registerFactory<DashboardCubit>(
      () => DashboardCubit(
        saveGameUseCase: SaveGameUseCase(sl()),
        uploadScreenshotUseCase: UploadScreenshotUseCase(sl()),
      ),
    );
}

/// تبعيات مواقيت الصلاة (prayer).
void _registerPrayer() {
  sl
    ..registerLazySingleton<PrayerApiService>(() => PrayerApiService())
    ..registerFactory<PrayerCubit>(() => PrayerCubit(apiService: sl()));
}
