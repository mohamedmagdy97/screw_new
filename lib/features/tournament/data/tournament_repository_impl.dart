import 'dart:convert';

import 'package:screw_calculator/core/constants/local_storage_keys.dart';
import 'package:screw_calculator/core/utils/local_store.dart';
import 'package:screw_calculator/features/tournament/domain/entities/tournament.dart';
import 'package:screw_calculator/features/tournament/domain/repositories/tournament_repository.dart';

class TournamentRepositoryImpl implements TournamentRepository {
  @override
  Future<Tournament?> load() async {
    final raw = await AppLocalStore.getString(LocalStoreNames.tournament);
    if (raw == null || raw.isEmpty) return null;
    try {
      return Tournament.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      await clear();
      return null;
    }
  }

  @override
  Future<void> save(Tournament tournament) => AppLocalStore.setString(
    LocalStoreNames.tournament,
    jsonEncode(tournament.toJson()),
  );

  @override
  Future<void> clear() async {
    await AppLocalStore.removeString(LocalStoreNames.tournament);
  }
}
