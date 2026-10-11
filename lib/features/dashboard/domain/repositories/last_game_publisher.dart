import 'package:screw_calculator/features/dashboard/domain/entities/last_game_summary.dart';

/// ينشر ملخص آخر لعبة خارج التطبيق (مثل ويدجت الشاشة الرئيسية).
abstract class LastGamePublisher {
  Future<void> publish(LastGameSummary summary);
}
