import 'package:screw_calculator/features/dashboard/domain/entities/active_game.dart';

/// عقد حفظ واستعادة اللعبة الجارية.
abstract class ActiveGameRepository {
  Future<void> save(ActiveGame game);

  Future<ActiveGame?> load();

  Future<void> clear();
}
