import 'package:equatable/equatable.dart';

/// لاعب (أو فريق) في لعبة بتتعرض لايف.
class LivePlayer extends Equatable {
  const LivePlayer({
    required this.name,
    required this.total,
    this.rounds = const [],
  });

  final String name;
  final int total;

  /// قيم الجولات الخمسة كنص ('' = لسه ما اتلعبتش). فاضية للفرق.
  final List<String> rounds;

  Map<String, Object?> toMap() => {
    'name': name,
    'total': total,
    'rounds': rounds,
  };

  factory LivePlayer.fromMap(Map<String, dynamic> m) => LivePlayer(
    name: (m['name'] as String?) ?? '',
    total: (m['total'] as num?)?.toInt() ?? 0,
    rounds: [
      for (final r in (m['rounds'] as List<dynamic>?) ?? const <dynamic>[])
        '$r',
    ],
  );

  @override
  List<Object?> get props => [name, total, rounds];
}

/// لقطة من لعبة شغالة، بيكتبها موبايل اللي بيسجّل ويقراها صحابه.
class LiveGame extends Equatable {
  const LiveGame({
    required this.code,
    required this.players,
    this.teams = const [],
    this.round = 1,
    this.finished = false,
    this.ended = false,
    this.updatedAt,
  });

  final String code;
  final List<LivePlayer> players;

  /// في وضع «صاحب صاحبه»: الفرق ومجموع كل فريق.
  final List<LivePlayer> teams;

  /// الجولة الحالية (1..5)، أو 6 لو الجولات خلصت.
  final int round;
  final bool finished;

  /// صاحب اللعبة وقّف البث.
  final bool ended;
  final DateTime? updatedAt;

  /// الترتيب: الأقل مجموعًا (الفايز في سكرو) الأول.
  List<LivePlayer> get ranking {
    final list = teams.isNotEmpty ? [...teams] : [...players];
    list.sort((a, b) => a.total.compareTo(b.total));
    return list;
  }

  Map<String, Object?> toMap() => {
    'code': code,
    'players': [for (final p in players) p.toMap()],
    'teams': [for (final t in teams) t.toMap()],
    'round': round,
    'finished': finished,
    'ended': ended,
  };

  factory LiveGame.fromMap(Map<String, dynamic> m, {DateTime? updatedAt}) {
    List<LivePlayer> list(Object? raw) => [
      for (final e in (raw as List<dynamic>?) ?? const <dynamic>[])
        if (e is Map<String, dynamic>) LivePlayer.fromMap(e),
    ];
    return LiveGame(
      code: (m['code'] as String?) ?? '',
      players: list(m['players']),
      teams: list(m['teams']),
      round: (m['round'] as num?)?.toInt() ?? 1,
      finished: (m['finished'] as bool?) ?? false,
      ended: (m['ended'] as bool?) ?? false,
      updatedAt: updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    code,
    players,
    teams,
    round,
    finished,
    ended,
    updatedAt,
  ];
}
