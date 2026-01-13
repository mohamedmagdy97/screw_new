part of 'history_cubit.dart';

/// Base state for history feature
abstract class HistoryState {}

/// Initial state
class HistoryInitial extends HistoryState {}

/// Loading state
class HistoryLoading extends HistoryState {}

/// Loaded state with games
class HistoryLoaded extends HistoryState {
  final List<GameHistoryEntity> games;

  HistoryLoaded(this.games);
}

/// Empty state when no games are available
class HistoryEmpty extends HistoryState {}

/// Error state
class HistoryError extends HistoryState {
  final String message;

  HistoryError(this.message);
}

/// State when deleting a game
class HistoryDeleting extends HistoryState {
  final List<GameHistoryEntity> games;

  HistoryDeleting(this.games);
}

/// State when clearing all games
class HistoryClearing extends HistoryState {
  final List<GameHistoryEntity> games;

  HistoryClearing(this.games);
}

