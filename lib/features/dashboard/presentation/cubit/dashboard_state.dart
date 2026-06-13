part of 'dashboard_cubit.dart';

enum DashboardStatus { idle, saving, saved, saveError }

class DashboardState extends Equatable {
  const DashboardState({
    required this.players,
    required this.teams,
    this.showTeamsView = false,
    this.marqueeVisible = true,
    this.revision = 0,
    this.status = DashboardStatus.idle,
    this.message,
  });

  final List<PlayerModel> players;
  final List<Team> teams;
  final bool showTeamsView;
  final bool marqueeVisible;

  /// عدّاد يتغيّر مع كل تعديل داخلي على اللاعبين (الموديل قابل للتغيير) لإجبار
  /// إعادة البناء.
  final int revision;
  final DashboardStatus status;
  final String? message;

  DashboardState copyWith({
    List<PlayerModel>? players,
    List<Team>? teams,
    bool? showTeamsView,
    bool? marqueeVisible,
    int? revision,
    DashboardStatus? status,
    String? message,
  }) {
    return DashboardState(
      players: players ?? this.players,
      teams: teams ?? this.teams,
      showTeamsView: showTeamsView ?? this.showTeamsView,
      marqueeVisible: marqueeVisible ?? this.marqueeVisible,
      revision: revision ?? this.revision,
      status: status ?? this.status,
      message: message,
    );
  }

  @override
  List<Object?> get props => [
    players,
    teams,
    showTeamsView,
    marqueeVisible,
    revision,
    status,
    message,
  ];
}
