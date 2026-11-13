import 'package:screw_calculator/features/review/domain/entities/review_state.dart';

/// إمتى نطلب تقييم المتجر (نافذة المنصّة نفسها جوّه التطبيق): بعد ما المستخدم
/// يحفظ جولة كاملة (يعني استمتع بالتطبيق فعلًا)، [maxAsks] مرات بالكتير، ومش
/// أقل من [cooldown] بين كل مرة. المتجر نفسه ممكن ما يعرضهاش (بيحدد عدد المرات،
/// ومش بيعرضها لحد قيّم قبل كده).
class ReviewPolicy {
  const ReviewPolicy();

  static const int minFinishedGames = 1;
  static const int maxAsks = 3;
  static const Duration cooldown = Duration(days: 90);

  bool shouldAsk(ReviewState s, DateTime now) {
    if (s.finishedGames < minFinishedGames) return false;
    if (s.timesAsked >= maxAsks) return false;
    final last = s.lastAskedAt;
    return last == null || now.difference(last) >= cooldown;
  }
}
