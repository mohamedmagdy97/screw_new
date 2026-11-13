import 'package:equatable/equatable.dart';

/// الألقاب المحسوبة من سجل الجولات.
enum PlayerTitleKind {
  /// أكتر واحد كسب: «ملك السكرو».
  king,

  /// أعلى نقط في جولة واحدة: «أكبر سكرو».
  biggestScrew,

  /// أقل مجموع في لعبة كاملة: «أنضف لعبة».
  cleanestGame,

  /// أكتر واحد لعب: «ابن الترابيزة».
  mostGames,
}

/// لقب واحد: مين خده وبكام.
class PlayerTitle extends Equatable {
  const PlayerTitle({
    required this.kind,
    required this.name,
    required this.value,
  });

  final PlayerTitleKind kind;
  final String name;

  /// عدد المكاسب / النقط / عدد الألعاب حسب [kind].
  final int value;

  @override
  List<Object?> get props => [kind, name, value];
}
