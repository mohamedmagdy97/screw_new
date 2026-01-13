import 'package:screw_calculator/features/history/domain/entities/game_history_entity.dart';
import 'package:screw_calculator/features/history/domain/repositories/history_repository.dart';

class GetGamesUseCase {
  final HistoryRepository _repository;

  GetGamesUseCase(this._repository);

  Future<List<GameHistoryEntity>> call() async {
    return await _repository.getGames();
  }
}
