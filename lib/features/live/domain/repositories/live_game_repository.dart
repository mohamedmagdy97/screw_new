import 'package:screw_calculator/features/live/domain/entities/live_game.dart';

/// تخزين ومتابعة الألعاب اللايف.
abstract class LiveGameRepository {
  /// ينشئ لعبة جديدة بكود فاضي ويرجّع الكود.
  Future<String> create(LiveGame Function(String code) build);

  Future<void> update(LiveGame game);

  /// يوقّف البث ويمسح اللعبة من السيرفر (اللي بيتابعوا بيشوفوا «وقّف اللايف»).
  Future<void> end(String code);

  /// يمسح أي لعبة بدأها الموبايل ده وما اتمسحتش (مثلًا التطبيق اتقفل فجأة).
  Future<void> cleanupLeftovers();

  /// يتابع اللعبة؛ null لو الكود مش موجود.
  Stream<LiveGame?> watch(String code);
}
