part of 'history_cubit.dart';

abstract class HistoryState {}

class HistoryInitial extends HistoryState {}

class HistoryLoading extends HistoryState {}

class HistoryLoaded extends HistoryState {
  final List<GameHistoryEntity> games;

  HistoryLoaded(this.games);
}

class HistoryEmpty extends HistoryState {}

class HistoryError extends HistoryState {
  final String message;

  HistoryError(this.message);
}

class HistoryDeleting extends HistoryState {
  final List<GameHistoryEntity> games;

  HistoryDeleting(this.games);
}

class HistoryClearing extends HistoryState {
  final List<GameHistoryEntity> games;

  HistoryClearing(this.games);
}
