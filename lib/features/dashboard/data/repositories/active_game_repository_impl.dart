import 'dart:convert';

import 'package:screw_calculator/core/constants/local_storage_keys.dart';
import 'package:screw_calculator/core/models/player_model.dart';
import 'package:screw_calculator/core/utils/local_store.dart';
import 'package:screw_calculator/features/dashboard/domain/entities/active_game.dart';
import 'package:screw_calculator/features/dashboard/domain/repositories/active_game_repository.dart';

class ActiveGameRepositoryImpl implements ActiveGameRepository {
  @override
  Future<void> save(ActiveGame game) {
    final json = jsonEncode(<String, dynamic>{
      'friendly': game.friendly,
      'players': game.players.map((p) => p.toJson()).toList(),
    });
    return AppLocalStore.setString(LocalStoreNames.activeGame, json);
  }

  @override
  Future<ActiveGame?> load() async {
    final raw = await AppLocalStore.getString(LocalStoreNames.activeGame);
    if (raw == null || raw.isEmpty) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final players = (map['players'] as List<dynamic>)
          .map((e) => PlayerModel.fromJson(e as Map<String, dynamic>))
          .toList();
      for (final p in players) {
        p.recomputeTotal();
      }
      return ActiveGame(
        players: players,
        friendly: (map['friendly'] as bool?) ?? false,
      );
    } catch (_) {
      await clear();
      return null;
    }
  }

  @override
  Future<void> clear() async {
    await AppLocalStore.removeString(LocalStoreNames.activeGame);
  }
}
