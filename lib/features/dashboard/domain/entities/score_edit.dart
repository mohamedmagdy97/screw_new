import 'package:equatable/equatable.dart';

/// سجل تعديل نتيجة جولة بعد إدخالها (للشفافية بين اللاعبين).
class ScoreEdit extends Equatable {
  const ScoreEdit({
    required this.playerName,
    required this.playerId,
    required this.round,
    required this.oldValue,
    required this.newValue,
    required this.at,
  });

  final String playerName;
  final int? playerId;

  /// رقم الجولة (1..5).
  final int round;
  final String oldValue;
  final String newValue;
  final DateTime at;

  Map<String, dynamic> toJson() => {
    'playerName': playerName,
    'playerId': playerId,
    'round': round,
    'oldValue': oldValue,
    'newValue': newValue,
    'at': at.toIso8601String(),
  };

  factory ScoreEdit.fromJson(Map<String, dynamic> json) => ScoreEdit(
    playerName: json['playerName'] as String,
    playerId: json['playerId'] as int?,
    round: json['round'] as int,
    oldValue: json['oldValue'] as String,
    newValue: json['newValue'] as String,
    at: DateTime.parse(json['at'] as String),
  );

  @override
  List<Object?> get props => [
    playerName,
    playerId,
    round,
    oldValue,
    newValue,
    at,
  ];
}
