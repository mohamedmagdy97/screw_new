import 'package:screw_calculator/features/live/domain/entities/live_game.dart';

/// تخزين ومتابعة الألعاب اللايف.
abstract class LiveGameRepository {
  /// ينشئ لعبة جديدة بكود فاضي ويرجّع الكود.
  Future<String> create(LiveGame Function(String code) build);

  Future<void> update(LiveGame game);

  /// يوقّف البث (اللي بيتابعوا بيشوفوا «اللعبة خلصت»).
  Future<void> end(String code);

  /// يتابع اللعبة؛ null لو الكود مش موجود.
  Stream<LiveGame?> watch(String code);
}
