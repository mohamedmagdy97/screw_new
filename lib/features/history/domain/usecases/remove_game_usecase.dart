import 'package:screw_calculator/features/history/domain/repositories/history_repository.dart';

/// Use case for removing a game
class RemoveGameUseCase {
  final HistoryRepository _repository;

  RemoveGameUseCase(this._repository);

  /// Executes the use case to remove a game
  /// [index] - The index of the game to remove
  Future<bool> call(int index) async {
    return await _repository.removeGame(index);
  }
}

