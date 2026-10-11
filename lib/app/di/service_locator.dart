import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:screw_calculator/core/theme/theme_cubit.dart';
import 'package:screw_calculator/features/contact_us/data/datasources/url_launcher_data_source.dart';
import 'package:screw_calculator/features/contact_us/data/repositories/contact_repository_impl.dart';
import 'package:screw_calculator/features/contact_us/domain/repositories/contact_repository.dart';
import 'package:screw_calculator/features/contact_us/domain/usecases/launch_contact_url_usecase.dart';
import 'package:screw_calculator/features/contact_us/presentation/cubit/contact_cubit.dart';
import 'package:screw_calculator/features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import 'package:screw_calculator/features/dashboard/data/repositories/active_game_repository_impl.dart';
import 'package:screw_calculator/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:screw_calculator/features/dashboard/domain/repositories/active_game_repository.dart';
import 'package:screw_calculator/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:screw_calculator/features/dashboard/domain/usecases/save_game_usecase.dart';
import 'package:screw_calculator/features/dashboard/domain/usecases/upload_screenshot_usecase.dart';
import 'package:screw_calculator/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:screw_calculator/features/game_mode/presentation/cubit/game_mode_cubit.dart';
import 'package:screw_calculator/features/history/data/datasources/history_data_source.dart';
import 'package:screw_calculator/features/history/data/repositories/history_repository_impl.dart';
import 'package:screw_calculator/features/history/domain/repositories/history_repository.dart';
import 'package:screw_calculator/features/history/domain/usecases/clear_all_games_usecase.dart';
import 'package:screw_calculator/features/history/domain/usecases/get_games_usecase.dart';
import 'package:screw_calculator/features/history/domain/usecases/remove_game_usecase.dart';
import 'package:screw_calculator/features/history/presentation/cubit/history_cubit.dart';
import 'package:screw_calculator/features/home/data/datasources/home_local_data_source.dart';
import 'package:screw_calculator/features/home/data/datasources/home_remote_data_source.dart';
import 'package:screw_calculator/features/home/data/repositories/home_repository_impl.dart';
import 'package:screw_calculator/features/home/domain/repositories/home_repository.dart';
import 'package:screw_calculator/features/home/presentation/controller/home_controller.dart';
import 'package:screw_calculator/features/notifications/data/datasources/notification_data_source.dart';
import 'package:screw_calculator/features/notifications/data/repositories/notification_repository_impl.dart';
import 'package:screw_calculator/features/notifications/domain/repositories/notification_repository.dart';
import 'package:screw_calculator/features/notifications/domain/usecases/delete_notification_usecase.dart';
import 'package:screw_calculator/features/notifications/domain/usecases/get_notifications_usecase.dart';
import 'package:screw_calculator/features/notifications/domain/usecases/mark_notification_read_usecase.dart';
import 'package:screw_calculator/features/notifications/presentation/cubit/notification_cubit.dart';
import 'package:screw_calculator/features/prayer/data/datasources/prayer_api_service.dart';
import 'package:screw_calculator/features/prayer/presentation/cubit/prayer_cubit.dart';
import 'package:screw_calculator/features/show_video/presentation/cubit/video_cubit.dart';
import 'package:screw_calculator/features/stats/presentation/cubit/stats_cubit.dart';
import 'package:screw_calculator/features/users_screenshoot_sharing/data/datasources/screenshot_data_source.dart';
import 'package:screw_calculator/features/users_screenshoot_sharing/data/repositories/screenshot_repository_impl.dart';
import 'package:screw_calculator/features/users_screenshoot_sharing/domain/repositories/screenshot_repository.dart';
import 'package:screw_calculator/features/users_screenshoot_sharing/domain/usecases/delete_screenshot_usecase.dart';
import 'package:screw_calculator/features/users_screenshoot_sharing/domain/usecases/get_screenshots_usecase.dart';
import 'package:screw_calculator/features/users_screenshoot_sharing/domain/usecases/load_more_screenshots_usecase.dart';
import 'package:screw_calculator/features/users_screenshoot_sharing/presentation/cubit/screenshot_cubit.dart';

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
  _registerHistory();
  _registerStats();
  _registerContact();
  _registerNotifications();
  _registerScreenshots();
  _registerSimpleCubits();
}

/// تبعيات خارجية (SDKs / تخزين) كـ singletons.
void _registerExternals() {
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
  sl.registerLazySingleton<Box<dynamic>>(
    () => Hive.box<dynamic>('userBox'),
    instanceName: 'userBox',
  );
}

/// تبعيات الطبقة المشتركة (core).
void _registerCore() {
  sl.registerLazySingleton<ThemeCubit>(ThemeCubit.new);
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
    ..registerLazySingleton<HistoryDataSource>(HistoryDataSourceImpl.new)
    ..registerLazySingleton<DashboardRemoteDataSource>(
      () => DashboardRemoteDataSourceImpl(firestore: sl()),
    )
    ..registerLazySingleton<DashboardRepository>(
      () => DashboardRepositoryImpl(
        historyDataSource: sl(),
        remoteDataSource: sl(),
      ),
    )
    ..registerLazySingleton<ActiveGameRepository>(ActiveGameRepositoryImpl.new)
    ..registerFactory<DashboardCubit>(
      () => DashboardCubit(
        saveGameUseCase: SaveGameUseCase(sl()),
        uploadScreenshotUseCase: UploadScreenshotUseCase(sl()),
        activeGameRepository: sl(),
      ),
    );
}

/// تبعيات مواقيت الصلاة (prayer).
void _registerPrayer() {
  sl
    ..registerLazySingleton<PrayerApiService>(PrayerApiService.new)
    ..registerFactory<PrayerCubit>(() => PrayerCubit(apiService: sl()));
}

/// تبعيات سجل الألعاب (history). مصدر البيانات مسجّل ضمن لوحة النتائج.
void _registerHistory() {
  sl
    ..registerLazySingleton<HistoryRepository>(
      () => HistoryRepositoryImpl(dataSource: sl()),
    )
    ..registerFactory<HistoryCubit>(
      () => HistoryCubit(
        getGamesUseCase: GetGamesUseCase(sl()),
        removeGameUseCase: RemoveGameUseCase(sl()),
        clearAllGamesUseCase: ClearAllGamesUseCase(sl()),
      ),
    );
}

/// تبعيات التواصل معنا (contact_us).
void _registerContact() {
  sl
    ..registerLazySingleton<UrlLauncherDataSource>(
      UrlLauncherDataSourceImpl.new,
    )
    ..registerLazySingleton<ContactRepository>(
      () => ContactRepositoryImpl(dataSource: sl()),
    )
    ..registerFactory<ContactCubit>(
      () =>
          ContactCubit(launchContactUrlUseCase: LaunchContactUrlUseCase(sl())),
    );
}

/// تبعيات الإشعارات (notifications).
void _registerNotifications() {
  sl
    ..registerLazySingleton<NotificationDataSource>(
      () => NotificationDataSourceImpl(
        firestore: sl(),
        localBox: sl(instanceName: 'userBox'),
      ),
    )
    ..registerLazySingleton<NotificationRepository>(
      () => NotificationRepositoryImpl(dataSource: sl()),
    )
    ..registerFactory<NotificationCubit>(
      () => NotificationCubit(
        getNotificationsUseCase: GetNotificationsUseCase(sl()),
        deleteNotificationUseCase: DeleteNotificationUseCase(sl()),
        markNotificationReadUseCase: MarkNotificationReadUseCase(sl()),
      ),
    );
}

/// تبعيات مشاركة اللقطات (users_screenshoot_sharing).
void _registerScreenshots() {
  sl
    ..registerLazySingleton<ScreenshotDataSource>(
      () => ScreenshotDataSourceImpl(firestore: sl()),
    )
    ..registerLazySingleton<ScreenshotRepository>(
      () => ScreenshotRepositoryImpl(dataSource: sl()),
    )
    ..registerFactory<ScreenshotCubit>(
      () => ScreenshotCubit(
        getScreenshotsUseCase: GetScreenshotsUseCase(sl()),
        loadMoreScreenshotsUseCase: LoadMoreScreenshotsUseCase(sl()),
        deleteScreenshotUseCase: DeleteScreenshotUseCase(sl()),
      ),
    );
}

/// Cubits بلا تبعيات خارجية (game_mode / show_video).
void _registerSimpleCubits() {
  sl
    ..registerFactory<GameModeCubit>(GameModeCubit.new)
    ..registerFactory<VideoCubit>(VideoCubit.new);
}

/// تبعيات إحصائيات اللاعبين (stats) — تعتمد على سجل الجولات.
void _registerStats() {
  sl.registerFactory<StatsCubit>(
    () => StatsCubit(getGamesUseCase: GetGamesUseCase(sl())),
  );
}
