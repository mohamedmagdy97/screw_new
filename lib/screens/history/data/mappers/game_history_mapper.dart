import 'package:screw_calculator/models/game_model.dart';
import 'package:screw_calculator/screens/history/domain/entities/game_history_entity.dart';

/// Mapper for converting between GameModel and GameHistoryEntity
class GameHistoryMapper {
  /// Converts GameModel to GameHistoryEntity
  static GameHistoryEntity toEntity(GameModel model) {
    return GameHistoryEntity(
      players: model.game ?? [],
    );
  }

  /// Converts GameHistoryEntity to GameModel
  static GameModel toModel(GameHistoryEntity entity) {
    return GameModel(game: entity.players);
  }
}

