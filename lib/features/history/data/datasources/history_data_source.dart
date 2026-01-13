import 'dart:convert';

import 'package:screw_calculator/models/game_model.dart';
import 'package:screw_calculator/utility/local_store.dart';
import 'package:screw_calculator/utility/local_storge_key.dart';

abstract class HistoryDataSource {
  Future<List<GameModel>> getGames();

  Future<bool> saveGames(List<GameModel> games);

  Future<bool> clearAllGames();
}

class HistoryDataSourceImpl implements HistoryDataSource {
  @override
  Future<List<GameModel>> getGames() async {
    try {
      final String? res = await AppLocalStore.getString(
        LocalStoreNames.gamesHistory,
      );

      if (res != null && res.isNotEmpty) {
        final dynamic decoded = jsonDecode(res);

        if (decoded is List) {
          final List<Map<String, dynamic>> jsonData = decoded
              .map<Map<String, dynamic>>((e) {
                if (e is Map<String, dynamic>) {
                  return e;
                } else {
                  return <String, dynamic>{};
                }
              })
              .toList();

          return jsonData
              .map<GameModel>((json) => GameModel.fromJson(json))
              .toList();
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  Future<bool> saveGames(List<GameModel> games) async {
    try {
      final jsonString = jsonEncode(games.map((e) => e.toJson()).toList());
      await AppLocalStore.setString(LocalStoreNames.gamesHistory, jsonString);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> clearAllGames() async {
    try {
      await AppLocalStore.removeString(LocalStoreNames.gamesHistory);
      return true;
    } catch (e) {
      return false;
    }
  }
}

