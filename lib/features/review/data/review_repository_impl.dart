import 'package:in_app_review/in_app_review.dart';
import 'package:screw_calculator/features/review/domain/entities/review_state.dart';
import 'package:screw_calculator/features/review/domain/repositories/review_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrefsReviewRepository implements ReviewRepository {
  static const String _finished = 'review.finished_games.v1';
  static const String _asked = 'review.times_asked.v1';
  static const String _last = 'review.last_asked_ms.v1';

  @override
  Future<ReviewState> load() async {
    final prefs = await SharedPreferences.getInstance();
    final last = prefs.getInt(_last);
    return ReviewState(
      finishedGames: prefs.getInt(_finished) ?? 0,
      timesAsked: prefs.getInt(_asked) ?? 0,
      lastAskedAt: last == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(last),
    );
  }

  @override
  Future<void> save(ReviewState state) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_finished, state.finishedGames);
    await prefs.setInt(_asked, state.timesAsked);
    final last = state.lastAskedAt;
    if (last != null) await prefs.setInt(_last, last.millisecondsSinceEpoch);
  }
}

/// نافذة التقييم الحقيقية. نظام التشغيل بيحدّها لوحده، فممكن الطلب ما يعرضش
/// حاجة، وده عادي.
class InAppStoreReview implements StoreReview {
  InAppStoreReview([InAppReview? review])
    : _review = review ?? InAppReview.instance;

  final InAppReview _review;

  @override
  Future<bool> request() async {
    try {
      if (!await _review.isAvailable()) return false;
      await _review.requestReview();
      return true;
    } catch (_) {
      // مفيش متجر على الجهاز (محاكي / نسخة مش من المتجر).
      return false;
    }
  }
}
