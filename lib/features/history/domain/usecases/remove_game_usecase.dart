import 'package:screw_calculator/features/history/domain/repositories/history_repository.dart';

class RemoveGameUseCase {
  final HistoryRepository _repository;

  RemoveGameUseCase(this._repository);

  Future<bool> call(int index) async {
    return await _repository.removeGame(index);
  }
}
