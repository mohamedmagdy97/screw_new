import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:screw_calculator/features/history/domain/usecases/get_games_usecase.dart';
import 'package:screw_calculator/features/stats/domain/entities/player_stats.dart';
import 'package:screw_calculator/features/stats/domain/entities/player_title.dart';
import 'package:screw_calculator/features/stats/domain/usecases/compute_player_stats.dart';
import 'package:screw_calculator/features/stats/domain/usecases/compute_player_titles.dart';

part 'stats_state.dart';

class StatsCubit extends Cubit<StatsState> {
  StatsCubit({required GetGamesUseCase getGamesUseCase})
    : _getGames = getGamesUseCase,
      super(const StatsState.loading()) {
    load();
  }

  final GetGamesUseCase _getGames;

  Future<void> load() async {
    emit(const StatsState.loading());
    try {
      final games = await _getGames();
      final stats = computePlayerStats(games);
      emit(
        StatsState(
          status: StatsStatus.loaded,
          players: stats,
          titles: computePlayerTitles(games, stats),
        ),
      );
    } catch (_) {
      emit(const StatsState(status: StatsStatus.error));
    }
  }
}
