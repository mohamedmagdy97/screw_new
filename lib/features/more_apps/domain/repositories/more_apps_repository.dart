import 'package:screw_calculator/features/more_apps/domain/entities/megtech_app.dart';

/// كتالوج تطبيقات MegTech: النسخة الأونلاين لو متاحة، وإلا النسخة المضمّنة.
abstract class MoreAppsRepository {
  /// يرمي استثناءً لو تعذّر قراءة النسختين معًا.
  Future<List<MegTechApp>> apps();
}
