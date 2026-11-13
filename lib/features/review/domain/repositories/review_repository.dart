import 'package:screw_calculator/features/review/domain/entities/review_state.dart';

abstract class ReviewRepository {
  Future<ReviewState> load();

  Future<void> save(ReviewState state);
}

/// نافذة التقييم الخاصة بالمنصّة (Google Play / App Store).
abstract class StoreReview {
  /// يعرض النافذة لو المنصّة سامحة دلوقتي. يرجّع هل طلبناها فعلًا.
  Future<bool> request();
}
