import 'package:flutter_test/flutter_test.dart';
import 'package:screw_calculator/features/tournament/domain/entities/tournament.dart';

void main() {
  test('standings award 3/2/1/0 by lowest score and sort by points', () {
    final t = const Tournament(
      name: 'T',
      players: ['A', 'B', 'C', 'D'],
      games: [
        TournamentGame({'A': 10, 'B': 20, 'C': 30, 'D': 40}), // A3 B2 C1 D0
        TournamentGame({'A': 50, 'B': 5, 'C': 30, 'D': 40}), // B3 C2 D1 A0
      ],
    );

    final s = computeStandings(t);
    expect(s.map((e) => e.name).toList(), ['B', 'A', 'C', 'D']);
    expect(s.first.points, 5); // B: 2 + 3
    expect(s.first.wins, 1);
    expect(s[1].points, 3); // A: 3 + 0
    expect(s.last.points, 1); // D: 0 + 1
  });

  test('ties share the same place and points', () {
    final t = const Tournament(
      name: 'T',
      players: ['A', 'B', 'C'],
      games: [
        TournamentGame({'A': 10, 'B': 10, 'C': 30}),
      ],
    );
    final s = computeStandings(t);
    expect(s.firstWhere((e) => e.name == 'A').points, 3);
    expect(s.firstWhere((e) => e.name == 'B').points, 3);
    expect(s.firstWhere((e) => e.name == 'C').points, 2);
  });

  test('json round trip', () {
    final t = const Tournament(
      name: 'T',
      players: ['A', 'B'],
      games: [
        TournamentGame({'A': 1, 'B': 2}),
      ],
    );
    expect(Tournament.fromJson(t.toJson()), t);
  });
}
