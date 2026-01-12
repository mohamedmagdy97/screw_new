import 'package:screw_calculator/screens/history/domain/entities/game_history_entity.dart';

/// Repository interface for game history operations
abstract class HistoryRepository {
  /// Gets all saved games
  Future<List<GameHistoryEntity>> getGames();

  /// Removes a game by index
  Future<bool> removeGame(int index);

  /// Clears all games
  Future<bool> clearAllGames();
}

