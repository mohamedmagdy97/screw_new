import 'package:screw_calculator/screens/history/domain/entities/game_history_entity.dart';
import 'package:screw_calculator/screens/history/domain/repositories/history_repository.dart';

/// Use case for getting saved games
class GetGamesUseCase {
  final HistoryRepository _repository;

  GetGamesUseCase(this._repository);

  /// Executes the use case to get all saved games
  Future<List<GameHistoryEntity>> call() async {
    return await _repository.getGames();
  }
}

