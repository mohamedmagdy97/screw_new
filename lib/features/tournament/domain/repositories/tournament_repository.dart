import 'package:screw_calculator/features/tournament/domain/entities/tournament.dart';

abstract class TournamentRepository {
  Future<Tournament?> load();

  Future<void> save(Tournament tournament);

  Future<void> clear();
}
