import 'package:equatable/equatable.dart';

/// نتيجة لعبة واحدة داخل البطولة: مجموع نقاط كل لاعب (الأقل يفوز).
class TournamentGame extends Equatable {
  const TournamentGame(this.totals);

  /// اسم اللاعب → مجموع نقاطه في اللعبة.
  final Map<String, int> totals;

  Map<String, dynamic> toJson() => totals;

  factory TournamentGame.fromJson(Map<String, dynamic> json) =>
      TournamentGame(json.map((k, v) => MapEntry(k, (v as num).toInt())));

  @override
  List<Object?> get props => [totals];
}

/// بطولة بين مجموعة أصدقاء: لاعبون ثابتون وسلسلة ألعاب بنقاط تراكمية.
class Tournament extends Equatable {
  const Tournament({
    required this.name,
    required this.players,
    this.games = const [],
  });

  final String name;
  final List<String> players;
  final List<TournamentGame> games;

  Tournament copyWith({List<TournamentGame>? games}) =>
      Tournament(name: name, players: players, games: games ?? this.games);

  Map<String, dynamic> toJson() => {
    'name': name,
    'players': players,
    'games': games.map((g) => g.toJson()).toList(),
  };

  factory Tournament.fromJson(Map<String, dynamic> json) => Tournament(
    name: json['name'] as String,
    players: (json['players'] as List<dynamic>).cast<String>(),
    games: (json['games'] as List<dynamic>)
        .map((g) => TournamentGame.fromJson(g as Map<String, dynamic>))
        .toList(),
  );

  @override
  List<Object?> get props => [name, players, games];
}

/// ترتيب لاعب في البطولة.
class Standing extends Equatable {
  const Standing({
    required this.name,
    required this.points,
    required this.wins,
    required this.games,
    required this.totalScore,
  });

  final String name;
  final int points;
  final int wins;
  final int games;
  final int totalScore;

  @override
  List<Object?> get props => [name, points, wins, games, totalScore];
}

/// نقاط البطولة حسب المركز في كل لعبة: 3 للأول، 2 للثاني، 1 للثالث، 0 للباقي.
const List<int> kPlacePoints = [3, 2, 1];

/// يحسب ترتيب البطولة. في اللعبة الواحدة، اللاعبون المتعادلون يتشاركون
/// نفس المركز (وبالتالي نفس النقاط). الترتيب النهائي: النقاط ثم الانتصارات ثم
/// أقل مجموع نقاط.
List<Standing> computeStandings(Tournament t) {
  final points = {for (final p in t.players) p: 0};
  final wins = {for (final p in t.players) p: 0};
  final games = {for (final p in t.players) p: 0};
  final scores = {for (final p in t.players) p: 0};

  for (final game in t.games) {
    final distinct = game.totals.values.toSet().toList()..sort();
    for (final entry in game.totals.entries) {
      if (!points.containsKey(entry.key)) continue;
      final place = distinct.indexOf(entry.value); // 0 = الأقل (الفائز)
      points[entry.key] =
          points[entry.key]! +
          (place < kPlacePoints.length ? kPlacePoints[place] : 0);
      if (place == 0) wins[entry.key] = wins[entry.key]! + 1;
      games[entry.key] = games[entry.key]! + 1;
      scores[entry.key] = scores[entry.key]! + entry.value;
    }
  }

  return [
    for (final p in t.players)
      Standing(
        name: p,
        points: points[p]!,
        wins: wins[p]!,
        games: games[p]!,
        totalScore: scores[p]!,
      ),
  ]..sort((a, b) {
    final byPoints = b.points.compareTo(a.points);
    if (byPoints != 0) return byPoints;
    final byWins = b.wins.compareTo(a.wins);
    return byWins != 0 ? byWins : a.totalScore.compareTo(b.totalScore);
  });
}
