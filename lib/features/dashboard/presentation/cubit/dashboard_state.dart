part of 'dashboard_cubit.dart';

enum DashboardStatus { idle, saving, saved, saveError }

class DashboardState extends Equatable {
  const DashboardState({
    required this.players,
    required this.teams,
    this.showTeamsView = false,
    this.marqueeVisible = true,
    this.revision = 0,
    this.edits = const [],
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

  /// سجل تعديلات النتائج بعد إدخالها.
  final List<ScoreEdit> edits;
  final DashboardStatus status;
  final DashboardMessage? message;

  DashboardState copyWith({
    List<PlayerModel>? players,
    List<Team>? teams,
    bool? showTeamsView,
    bool? marqueeVisible,
    int? revision,
    List<ScoreEdit>? edits,
    DashboardStatus? status,
    DashboardMessage? message,
  }) {
    return DashboardState(
      players: players ?? this.players,
      teams: teams ?? this.teams,
      showTeamsView: showTeamsView ?? this.showTeamsView,
      marqueeVisible: marqueeVisible ?? this.marqueeVisible,
      revision: revision ?? this.revision,
      edits: edits ?? this.edits,
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
    edits,
    status,
    message,
  ];
}
