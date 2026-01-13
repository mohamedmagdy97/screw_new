import 'package:screw_calculator/features/history/domain/repositories/history_repository.dart';

class ClearAllGamesUseCase {
  final HistoryRepository _repository;

  ClearAllGamesUseCase(this._repository);

  Future<bool> call() async {
    return await _repository.clearAllGames();
  }
}
