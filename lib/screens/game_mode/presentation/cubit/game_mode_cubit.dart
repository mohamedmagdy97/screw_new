import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:screw_calculator/screens/game_mode/domain/entities/game_mode_item_entity.dart';

part 'game_mode_state.dart';

/// Cubit for managing game mode screen state
class GameModeCubit extends Cubit<GameModeState> {
  GameModeCubit() : super(GameModeInitial()) {
    _initializeGameModes();
  }

  /// Initializes game modes
  Future<void> _initializeGameModes() async {
    emit(GameModeLoading());
    try {
      // Initialize Firebase notifications
      // Note: This requires BuildContext, so we'll handle it in the screen
      
      final gameModes = [
        GameModeItemEntity(
          key: 0,
          value: 'كلاسيك\n ( فردي )',
          isActive: true,
        ),
        GameModeItemEntity(
          key: 1,
          value: 'صاحب صاحبه\n ( زوجي )',
          isActive: false,
        ),
      ];

      emit(GameModeLoaded(gameModes));
    } catch (e) {
      emit(GameModeError('حدث خطأ أثناء تحميل أوضاع اللعبة'));
    }
  }

  /// Selects a game mode
  void selectGameMode(int index) {
    final currentState = state;
    if (currentState is! GameModeLoaded) return;

    final updatedModes = currentState.gameModes.map((mode) {
      return mode.copyWith(isActive: mode.key == currentState.gameModes[index].key);
    }).toList();

    emit(GameModeLoaded(updatedModes));
  }

  /// Gets the currently selected game mode key
  int? getSelectedModeKey() {
    final currentState = state;
    if (currentState is GameModeLoaded) {
      final selected = currentState.gameModes.firstWhere(
        (mode) => mode.isActive,
        orElse: () => currentState.gameModes.first,
      );
      return selected.key;
    }
    return null;
  }
}

