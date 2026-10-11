import 'package:screw_calculator/core/models/player_model.dart';
import 'package:screw_calculator/features/history/domain/entities/game_history_entity.dart';
import 'package:screw_calculator/features/stats/domain/entities/player_stats.dart';

/// يحسب إحصائيات اللاعبين من سجل الجولات.
///
/// - تُحتسب الجولات المكتملة فقط (كل اللاعبين أكملوا الجولات الخمس).
/// - الفائز في سكرو هو صاحب **أقل** مجموع، والخاسر صاحب **أعلى** مجموع
///   (ويفوز/يخسر الجميع عند التعادل).
/// - تُطابق الأسماء دون حساسية لحالة الأحرف أو المسافات الزائدة.
List<PlayerStats> computePlayerStats(List<GameHistoryEntity> games) {
  final acc = <String, _Acc>{};

  for (final game in games) {
    final players = game.players;
    if (players.length < 2 || !players.every((p) => p.isComplete)) continue;

    final totals = players.map(_total).toList();
    final best = totals.reduce((a, b) => a < b ? a : b);
    final worst = totals.reduce((a, b) => a > b ? a : b);
    if (best == worst) continue; // تعادل تام: لا فائز ولا خاسر.

    for (final p in players) {
      final name = (p.name ?? '').trim();
      if (name.isEmpty) continue;
      final total = _total(p);
      final entry = acc.putIfAbsent(name.toLowerCase(), () => _Acc(name));
      entry
        ..games += 1
        ..points += total;
      if (total == best) entry.wins += 1;
      if (total == worst) entry.losses += 1;
    }
  }

  final result =
      acc.values
          .map(
            (a) => PlayerStats(
              name: a.name,
              games: a.games,
              wins: a.wins,
              losses: a.losses,
              totalPoints: a.points,
            ),
          )
          .toList()
        ..sort((a, b) {
          final byRate = b.winRate.compareTo(a.winRate);
          return byRate != 0 ? byRate : b.games.compareTo(a.games);
        });
  return result;
}

int _total(PlayerModel p) => int.tryParse(p.total ?? '') ?? 0;

class _Acc {
  _Acc(this.name);

  final String name;
  int games = 0;
  int wins = 0;
  int losses = 0;
  int points = 0;
}
