import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:screw_calculator/features/history/domain/entities/game_history_entity.dart';
import 'package:screw_calculator/features/history/domain/usecases/clear_all_games_usecase.dart';
import 'package:screw_calculator/features/history/domain/usecases/get_games_usecase.dart';
import 'package:screw_calculator/features/history/domain/usecases/remove_game_usecase.dart';

part 'history_state.dart';

/// Cubit for managing history screen state
class HistoryCubit extends Cubit<HistoryState> {
  final GetGamesUseCase _getGamesUseCase;
  final RemoveGameUseCase _removeGameUseCase;
  final ClearAllGamesUseCase _clearAllGamesUseCase;

  HistoryCubit({
    required GetGamesUseCase getGamesUseCase,
    required RemoveGameUseCase removeGameUseCase,
    required ClearAllGamesUseCase clearAllGamesUseCase,
  })  : _getGamesUseCase = getGamesUseCase,
        _removeGameUseCase = removeGameUseCase,
        _clearAllGamesUseCase = clearAllGamesUseCase,
        super(HistoryInitial()) {
    loadGames();
  }

  /// Loads games from local storage
  Future<void> loadGames() async {
    emit(HistoryLoading());
    try {
      final games = await _getGamesUseCase.call();
      if (games.isEmpty) {
        emit(HistoryEmpty());
      } else {
        emit(HistoryLoaded(games));
      }
    } catch (e) {
      emit(HistoryError('حدث خطأ أثناء تحميل السجلات'));
    }
  }

  /// Removes a game by index
  Future<void> removeGame(int index) async {
    final currentState = state;
    if (currentState is! HistoryLoaded) return;

    emit(HistoryDeleting(currentState.games));

    try {
      final success = await _removeGameUseCase.call(index);
      if (success) {
        await loadGames(); // Reload to get updated list
      } else {
        emit(HistoryError('فشل في حذف الجولة'));
      }
    } catch (e) {
      emit(HistoryError('حدث خطأ أثناء حذف الجولة'));
    }
  }

  /// Clears all games
  Future<void> clearAllGames() async {
    final currentState = state;
    if (currentState is! HistoryLoaded) return;

    emit(HistoryClearing(currentState.games));

    try {
      final success = await _clearAllGamesUseCase.call();
      if (success) {
        emit(HistoryEmpty());
      } else {
        emit(HistoryError('فشل في حذف جميع السجلات'));
      }
    } catch (e) {
      emit(HistoryError('حدث خطأ أثناء حذف جميع السجلات'));
    }
  }
}

