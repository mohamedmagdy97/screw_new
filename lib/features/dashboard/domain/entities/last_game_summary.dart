/// ملخص آخر لعبة منتهية يُعرض في ويدجت الشاشة الرئيسية.
class LastGameSummary {
  const LastGameSummary({
    required this.winners,
    required this.winnerTotal,
    required this.losers,
    required this.loserTotal,
  });

  /// أسماء الفائزين (مفصولة بفاصلة عند التعادل).
  final String winners;
  final int winnerTotal;
  final String losers;
  final int loserTotal;
}
