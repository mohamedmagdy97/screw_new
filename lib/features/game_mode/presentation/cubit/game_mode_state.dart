part of 'game_mode_cubit.dart';

abstract class GameModeState {}

class GameModeInitial extends GameModeState {}

class GameModeLoading extends GameModeState {}

class GameModeLoaded extends GameModeState {
  final List<GameModeItemEntity> gameModes;

  GameModeLoaded(this.gameModes);
}

class GameModeError extends GameModeState {
  final String message;

  GameModeError(this.message);
}

