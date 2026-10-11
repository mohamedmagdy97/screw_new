part of 'stats_cubit.dart';

enum StatsStatus { loading, loaded, error }

class StatsState extends Equatable {
  const StatsState({required this.status, this.players = const []});

  const StatsState.loading() : this(status: StatsStatus.loading);

  final StatsStatus status;
  final List<PlayerStats> players;

  /// اللاعب الأكثر خسارة (إن وُجد من خسر مرة على الأقل).
  PlayerStats? get mostLosses {
    final losers = players.where((p) => p.losses > 0).toList()
      ..sort((a, b) => b.losses.compareTo(a.losses));
    return losers.isEmpty ? null : losers.first;
  }

  @override
  List<Object?> get props => [status, players];
}
