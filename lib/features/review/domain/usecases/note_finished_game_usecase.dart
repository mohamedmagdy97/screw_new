import 'package:screw_calculator/features/review/domain/repositories/review_repository.dart';
import 'package:screw_calculator/features/review/domain/review_policy.dart';

/// بيتنادى بعد حفظ جولة كاملة: بيعدّها، ولو [ReviewPolicy] سامحة بيطلب
/// نافذة التقييم. يرجّع هل طلبها. أي خطأ بيتبلع: التقييم عمره ما يبوّظ الحفظ.
class NoteFinishedGameUseCase {
  NoteFinishedGameUseCase(
    this._repository,
    this._store, {
    ReviewPolicy policy = const ReviewPolicy(),
    DateTime Function()? now,
  }) : _policy = policy,
       _now = now ?? DateTime.now;

  final ReviewRepository _repository;
  final StoreReview _store;
  final ReviewPolicy _policy;
  final DateTime Function() _now;

  Future<bool> call() async {
    try {
      final now = _now();
      var state = await _repository.load();
      state = state.copyWith(finishedGames: state.finishedGames + 1);
      final asked = _policy.shouldAsk(state, now) && await _store.request();
      if (asked) {
        state = state.copyWith(
          timesAsked: state.timesAsked + 1,
          lastAskedAt: now,
        );
      }
      await _repository.save(state);
      return asked;
    } catch (_) {
      return false;
    }
  }
}
