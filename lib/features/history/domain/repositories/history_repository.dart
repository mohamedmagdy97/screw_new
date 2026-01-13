import 'package:screw_calculator/features/history/domain/entities/game_history_entity.dart';

abstract class HistoryRepository {
  Future<List<GameHistoryEntity>> getGames();

  Future<bool> removeGame(int index);

  Future<bool> clearAllGames();
}
