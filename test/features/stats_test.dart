import 'package:flutter_test/flutter_test.dart';
import 'package:screw_calculator/core/models/player_model.dart';
import 'package:screw_calculator/features/history/domain/entities/game_history_entity.dart';
import 'package:screw_calculator/features/stats/domain/usecases/compute_player_stats.dart';

PlayerModel _player(String name, List<int> rounds) {
  final p = PlayerModel(name: name);
  rounds.forEach(p.addRoundScore);
  return p;
}

void main() {
  test('winner has the lowest total, loser the highest', () {
    final games = [
      GameHistoryEntity(
        players: [
          _player('Ali', [1, 2, 3, 4, 5]), // 15
          _player('Omar', [10, 10, 10, 10, 10]), // 50
        ],
      ),
      GameHistoryEntity(
        players: [
          _player('ali', [20, 0, 0, 0, 0]), // 20 (name matched case-insens.)
          _player('Omar', [5, 5, 5, 5, 5]), // 25
        ],
      ),
    ];

    final stats = computePlayerStats(games);
    final ali = stats.firstWhere((s) => s.name == 'Ali');
    final omar = stats.firstWhere((s) => s.name == 'Omar');

    expect(ali.games, 2);
    expect(ali.wins, 2);
    expect(ali.losses, 0);
    expect(ali.averageScore, 17.5);
    expect(omar.losses, 2);
    expect(omar.winRate, 0);
    expect(stats.first.name, 'Ali'); // sorted by win rate
  });

  test('ignores incomplete games and full ties', () {
    final games = [
      GameHistoryEntity(
        players: [
          _player('A', [1, 2]),
          _player('B', [3, 4]),
        ],
      ),
      GameHistoryEntity(
        players: [
          _player('A', [1, 1, 1, 1, 1]),
          _player('B', [1, 1, 1, 1, 1]),
        ],
      ),
    ];

    expect(computePlayerStats(games), isEmpty);
  });
}
