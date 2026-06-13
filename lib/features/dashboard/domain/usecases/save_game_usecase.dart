import 'package:screw_calculator/core/models/player_model.dart';
import 'package:screw_calculator/features/dashboard/domain/repositories/dashboard_repository.dart';

/// حفظ الجولة الحالية ضمن السجل.
class SaveGameUseCase {
  SaveGameUseCase(this._repository);

  final DashboardRepository _repository;

  Future<void> call(List<PlayerModel> players) => _repository.saveGame(players);
}
