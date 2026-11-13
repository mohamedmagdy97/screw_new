import 'package:flutter_test/flutter_test.dart';
import 'package:screw_calculator/core/models/player_model.dart';
import 'package:screw_calculator/features/history/domain/entities/game_history_entity.dart';
import 'package:screw_calculator/features/stats/domain/entities/player_title.dart';
import 'package:screw_calculator/features/stats/domain/usecases/compute_player_stats.dart';
import 'package:screw_calculator/features/stats/domain/usecases/compute_player_titles.dart';

PlayerModel _player(String name, List<int> rounds) {
  final p = PlayerModel(name: name);
  rounds.forEach(p.addRoundScore);
  return p;
}

List<PlayerTitle> _titles(List<GameHistoryEntity> games) =>
    computePlayerTitles(games, computePlayerStats(games));

void main() {
  test('king, biggest screw, cleanest game and table regular', () {
    final games = [
      GameHistoryEntity(
        players: [
          _player('Ali', [1, 2, 3, 4, 0]), // 10: wins
          _player('Omar', [10, 10, 10, 10, 10]), // 50
          _player('Sara', [5, 5, 5, 5, 5]), // 25
        ],
      ),
      GameHistoryEntity(
        players: [
          _player('Ali', [2, 2, 2, 2, 2]), // 10: wins
          _player('Omar', [40, 0, 0, 0, 0]), // 40: biggest round
        ],
      ),
      GameHistoryEntity(
        players: [
          _player('Sara', [0, 0, 1, 0, 0]), // 1: wins, cleanest
          _player('Omar', [3, 3, 3, 3, 3]), // 15
        ],
      ),
    ];
    final byKind = {for (final t in _titles(games)) t.kind: t};

    expect(
      byKind[PlayerTitleKind.king],
      const PlayerTitle(kind: PlayerTitleKind.king, name: 'Ali', value: 2),
    );
    expect(byKind[PlayerTitleKind.biggestScrew]?.name, 'Omar');
    expect(byKind[PlayerTitleKind.biggestScrew]?.value, 40);
    expect(byKind[PlayerTitleKind.cleanestGame]?.name, 'Sara');
    expect(byKind[PlayerTitleKind.cleanestGame]?.value, 1);
    expect(byKind[PlayerTitleKind.mostGames]?.name, 'Omar');
    expect(byKind[PlayerTitleKind.mostGames]?.value, 3);
  });

  test('unfinished games and empty history give no titles', () {
    final unfinished = PlayerModel(name: 'Ali')..addRoundScore(50);
    expect(_titles([]), isEmpty);
    expect(
      _titles([
        GameHistoryEntity(
          players: [
            unfinished,
            _player('Omar', [1, 1]),
          ],
        ),
      ]),
      isEmpty,
    );
  });
}
