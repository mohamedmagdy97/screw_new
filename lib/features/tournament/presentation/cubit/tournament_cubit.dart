import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:screw_calculator/features/tournament/domain/entities/tournament.dart';
import 'package:screw_calculator/features/tournament/domain/repositories/tournament_repository.dart';

part 'tournament_state.dart';

class TournamentCubit extends Cubit<TournamentState> {
  TournamentCubit({required TournamentRepository repository})
    : _repository = repository,
      super(const TournamentState.loading()) {
    load();
  }

  final TournamentRepository _repository;

  static const int minPlayers = 2;
  static const int maxPlayers = 8;

  Future<void> load() async {
    emit(TournamentState(loading: false, tournament: await _repository.load()));
  }

  /// يُنشئ بطولة جديدة. يعيد `false` لو عدد اللاعبين خارج 2–8 بعد التنظيف.
  Future<bool> create(String name, String playersText) async {
    final players = <String>[];
    for (final raw in playersText.split(RegExp('[,،\n]'))) {
      final p = raw.trim();
      if (p.isNotEmpty &&
          !players.any((e) => e.toLowerCase() == p.toLowerCase())) {
        players.add(p);
      }
    }
    if (players.length < minPlayers || players.length > maxPlayers) {
      return false;
    }
    final t = Tournament(name: name.trim(), players: players);
    await _repository.save(t);
    emit(TournamentState(loading: false, tournament: t));
    return true;
  }

  Future<void> addGame(Map<String, int> totals) async {
    final t = state.tournament;
    if (t == null) return;
    final updated = t.copyWith(games: [...t.games, TournamentGame(totals)]);
    await _repository.save(updated);
    emit(TournamentState(loading: false, tournament: updated));
  }

  Future<void> removeLastGame() async {
    final t = state.tournament;
    if (t == null || t.games.isEmpty) return;
    final updated = t.copyWith(games: t.games.sublist(0, t.games.length - 1));
    await _repository.save(updated);
    emit(TournamentState(loading: false, tournament: updated));
  }

  Future<void> end() async {
    await _repository.clear();
    emit(const TournamentState(loading: false));
  }
}
