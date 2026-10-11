import 'package:screw_calculator/core/models/player_model.dart';
import 'package:screw_calculator/features/dashboard/domain/entities/score_edit.dart';

/// لعبة جارية لم تُحفظ بعد في السجل، تُستعاد بعد إغلاق التطبيق.
class ActiveGame {
  const ActiveGame({
    required this.players,
    required this.friendly,
    this.edits = const [],
  });

  final List<PlayerModel> players;

  /// `true` لوضع الفرق (friendly)، و`false` للوضع الكلاسيكي.
  final bool friendly;

  /// سجل تعديلات النتائج في هذه اللعبة.
  final List<ScoreEdit> edits;

  /// هل أُدخلت أي نتيجة؟ (لا فائدة من استعادة لعبة فارغة).
  bool get hasProgress => players.any((p) => p.filledRoundsCount > 0);
}
