import 'package:screw_calculator/models/player_model.dart';

class GameModel {
  List<PlayerModel>? game;

  GameModel({this.game});

  factory GameModel.fromJson(Map<String, dynamic> json) {
    return GameModel(
      game: json['game'] != null
          ? (json['game'] as List)
                .map((v) => PlayerModel.fromJson(v as Map<String, dynamic>))
                .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (game != null) {
      data['game'] = game!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
