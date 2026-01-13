import 'package:screw_calculator/features/history/domain/repositories/history_repository.dart';

/// Use case for clearing all games
class ClearAllGamesUseCase {
  final HistoryRepository _repository;

  ClearAllGamesUseCase(this._repository);

  /// Executes the use case to clear all games
  Future<bool> call() async {
    return await _repository.clearAllGames();
  }
}

