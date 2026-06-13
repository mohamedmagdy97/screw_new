import 'package:screw_calculator/core/models/game_model.dart';
import 'package:screw_calculator/features/history/domain/entities/game_history_entity.dart';

class GameHistoryMapper {
  static GameHistoryEntity toEntity(GameModel model) {
    return GameHistoryEntity(players: model.game ?? []);
  }

  static GameModel toModel(GameHistoryEntity entity) {
    return GameModel(game: entity.players);
  }
}
