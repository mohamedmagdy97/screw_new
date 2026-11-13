import 'package:screw_calculator/core/models/player_model.dart';
import 'package:screw_calculator/features/history/domain/entities/game_history_entity.dart';
import 'package:screw_calculator/features/stats/domain/entities/player_stats.dart';
import 'package:screw_calculator/features/stats/domain/entities/player_title.dart';

/// يحسب الألقاب من سجل الجولات المكتملة (نفس قواعد [computePlayerStats]).
///
/// كل لقب بيروح لواحد بس؛ عند التعادل بيكسب اللي ظهر الأول في السجل. أي لقب
/// مالوش صاحب (مثلًا مفيش حد كسب) مش بيظهر.
List<PlayerTitle> computePlayerTitles(
  List<GameHistoryEntity> games,
  List<PlayerStats> stats,
) {
  final titles = <PlayerTitle>[];

  PlayerStats? king;
  for (final s in stats) {
    if (s.wins == 0) continue;
    if (king == null ||
        s.wins > king.wins ||
        (s.wins == king.wins && s.winRate > king.winRate)) {
      king = s;
    }
  }
  if (king != null) {
    titles.add(
      PlayerTitle(
        kind: PlayerTitleKind.king,
        name: king.name,
        value: king.wins,
      ),
    );
  }

  PlayerTitle? biggest;
  PlayerTitle? cleanest;
  for (final game in games) {
    final players = game.players;
    if (players.length < 2 || !players.every((p) => p.isComplete)) continue;
    for (final p in players) {
      final name = (p.name ?? '').trim();
      if (name.isEmpty) continue;
      for (final raw in p.roundValues) {
        final v = int.tryParse(raw);
        if (v != null && (biggest == null || v > biggest.value)) {
          biggest = PlayerTitle(
            kind: PlayerTitleKind.biggestScrew,
            name: name,
            value: v,
          );
        }
      }
      final total = _total(p);
      if (cleanest == null || total < cleanest.value) {
        cleanest = PlayerTitle(
          kind: PlayerTitleKind.cleanestGame,
          name: name,
          value: total,
        );
      }
    }
  }
  if (biggest != null && biggest.value > 0) titles.add(biggest);
  if (cleanest != null) titles.add(cleanest);

  PlayerStats? regular;
  for (final s in stats) {
    if (regular == null || s.games > regular.games) regular = s;
  }
  if (regular != null && regular.games > 1) {
    titles.add(
      PlayerTitle(
        kind: PlayerTitleKind.mostGames,
        name: regular.name,
        value: regular.games,
      ),
    );
  }
  return titles;
}

int _total(PlayerModel p) => int.tryParse(p.total ?? '') ?? 0;
