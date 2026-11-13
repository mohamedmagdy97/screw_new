import 'package:equatable/equatable.dart';

/// المنصّة التي يعمل عليها التطبيق؛ تحدّد رابط المتجر المستخدم.
enum AppPlatform { android, ios }

/// تطبيق من تطبيقات MegTech في قائمة «تطبيقات تانية من MegTech».
class MegTechApp extends Equatable {
  const MegTechApp({
    required this.id,
    required this.name,
    required this.tagline,
    required this.icon,
    this.playUrl,
    this.appStoreUrl,
  });

  /// معرّف الحزمة على أندرويد؛ به يتعرّف التطبيق على نفسه ليخفيها.
  final String id;
  final String name;
  final String tagline;

  /// مسار asset مضمّن أو رابط https.
  final String icon;
  final String? playUrl;
  final String? appStoreUrl;

  /// رابط المتجر المناسب لـ [platform]، أو null لو التطبيق غير متاح عليها.
  String? linkFor(AppPlatform platform) =>
      platform == AppPlatform.ios ? appStoreUrl : playUrl;

  @override
  List<Object?> get props => [id, name, tagline, icon, playUrl, appStoreUrl];
}
