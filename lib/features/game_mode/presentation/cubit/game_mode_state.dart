part of 'game_mode_cubit.dart';

/// Base state for game mode feature
abstract class GameModeState {}

/// Initial state
class GameModeInitial extends GameModeState {}

/// Loading state
class GameModeLoading extends GameModeState {}

/// Loaded state with game modes
class GameModeLoaded extends GameModeState {
  final List<GameModeItemEntity> gameModes;

  GameModeLoaded(this.gameModes);
}

/// Error state
class GameModeError extends GameModeState {
  final String message;

  GameModeError(this.message);
}

