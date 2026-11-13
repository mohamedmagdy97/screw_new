import 'package:screw_calculator/features/more_apps/domain/entities/megtech_app.dart';
import 'package:screw_calculator/features/more_apps/domain/repositories/more_apps_repository.dart';

/// تطبيقات MegTech الأخرى التي يستطيع المستخدم تثبيتها: لا يظهر هذا التطبيق
/// نفسه، ولا يظهر إلا ما له رابط متجر على منصّة المستخدم (بترتيب الكتالوج).
///
/// على iPhone يُستبعد أي تطبيق أندرويد فقط تمامًا: Apple ترفض الإشارة لمنصّات
/// أخرى (البند 2.3.10). أي فشل = قائمة فارغة، فيختفي القسم ببساطة.
class GetMoreAppsUseCase {
  const GetMoreAppsUseCase(this._repository, {required this.selfId});

  final MoreAppsRepository _repository;

  /// معرّف حزمة هذا التطبيق (يُخفى من القائمة).
  final String selfId;

  Future<List<MegTechApp>> call(AppPlatform platform) async {
    try {
      final apps = await _repository.apps();
      final self = selfId.toLowerCase();
      return List.unmodifiable([
        for (final app in apps)
          if (app.id.toLowerCase() != self && app.linkFor(platform) != null)
            app,
      ]);
    } catch (_) {
      return const [];
    }
  }
}
