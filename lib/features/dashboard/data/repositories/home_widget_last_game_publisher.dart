import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import 'package:screw_calculator/features/dashboard/domain/entities/last_game_summary.dart';
import 'package:screw_calculator/features/dashboard/domain/repositories/last_game_publisher.dart';

/// ينشر آخر لعبة إلى ويدجت أندرويد `ScrewWidgetProvider`.
class HomeWidgetLastGamePublisher implements LastGamePublisher {
  static const String _provider =
      'com.megTech.screw_calculator.ScrewWidgetProvider';

  @override
  Future<void> publish(LastGameSummary summary) async {
    try {
      await HomeWidget.saveWidgetData<String>('last_winner', summary.winners);
      await HomeWidget.saveWidgetData<String>(
        'last_winner_total',
        '${summary.winnerTotal}',
      );
      await HomeWidget.saveWidgetData<String>('last_loser', summary.losers);
      await HomeWidget.saveWidgetData<String>(
        'last_loser_total',
        '${summary.loserTotal}',
      );
      await HomeWidget.updateWidget(qualifiedAndroidName: _provider);
    } catch (e) {
      // الويدجت اختياري: لا نُفشل اللعبة بسبب خطأ في تحديثه.
      debugPrint('Home widget update failed: $e');
    }
  }
}
