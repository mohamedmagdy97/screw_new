import 'package:equatable/equatable.dart';

/// إحصائيات لاعب مجمّعة من الجولات المكتملة في السجل.
class PlayerStats extends Equatable {
  const PlayerStats({
    required this.name,
    required this.games,
    required this.wins,
    required this.losses,
    required this.totalPoints,
  });

  final String name;
  final int games;
  final int wins;
  final int losses;
  final int totalPoints;

  /// نسبة الفوز بين 0 و1.
  double get winRate => games == 0 ? 0 : wins / games;

  /// متوسط النقاط في اللعبة (الأقل أفضل في سكرو).
  double get averageScore => games == 0 ? 0 : totalPoints / games;

  @override
  List<Object?> get props => [name, games, wins, losses, totalPoints];
}
