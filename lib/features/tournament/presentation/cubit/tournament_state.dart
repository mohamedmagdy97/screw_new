part of 'tournament_cubit.dart';

class TournamentState extends Equatable {
  const TournamentState({required this.loading, this.tournament});

  const TournamentState.loading() : this(loading: true);

  final bool loading;
  final Tournament? tournament;

  @override
  List<Object?> get props => [loading, tournament];
}
