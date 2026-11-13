import 'package:flutter_test/flutter_test.dart';
import 'package:screw_calculator/features/review/domain/entities/review_state.dart';
import 'package:screw_calculator/features/review/domain/repositories/review_repository.dart';
import 'package:screw_calculator/features/review/domain/review_policy.dart';
import 'package:screw_calculator/features/review/domain/usecases/note_finished_game_usecase.dart';

class _Repo implements ReviewRepository {
  ReviewState state = const ReviewState();

  @override
  Future<ReviewState> load() async => state;

  @override
  Future<void> save(ReviewState s) async => state = s;
}

class _Store implements StoreReview {
  _Store({this.available = true});

  final bool available;
  int requests = 0;

  @override
  Future<bool> request() async {
    if (!available) return false;
    requests++;
    return true;
  }
}

void main() {
  const policy = ReviewPolicy();
  final t0 = DateTime(2026, 1, 1);

  test('policy: needs a finished game, at most 3 asks, 90 days apart', () {
    expect(policy.shouldAsk(const ReviewState(), t0), isFalse);
    expect(policy.shouldAsk(const ReviewState(finishedGames: 1), t0), isTrue);
    final asked = ReviewState(finishedGames: 5, timesAsked: 1, lastAskedAt: t0);
    expect(policy.shouldAsk(asked, t0.add(const Duration(days: 89))), isFalse);
    expect(policy.shouldAsk(asked, t0.add(const Duration(days: 90))), isTrue);
    expect(
      policy.shouldAsk(
        ReviewState(finishedGames: 9, timesAsked: 3, lastAskedAt: t0),
        t0.add(const Duration(days: 900)),
      ),
      isFalse,
    );
  });

  test(
    'first saved game asks once; the next ones wait for the cooldown',
    () async {
      final repo = _Repo();
      final store = _Store();
      var now = t0;
      final note = NoteFinishedGameUseCase(repo, store, now: () => now);

      expect(await note(), isTrue);
      expect(await note(), isFalse);
      expect(repo.state.finishedGames, 2);
      expect(repo.state.timesAsked, 1);

      now = t0.add(const Duration(days: 91));
      expect(await note(), isTrue);
      expect(store.requests, 2);
    },
  );

  test(
    'no store on the device: counts the game, does not spend an ask',
    () async {
      final repo = _Repo();
      final note = NoteFinishedGameUseCase(repo, _Store(available: false));
      expect(await note(), isFalse);
      expect(repo.state.finishedGames, 1);
      expect(repo.state.timesAsked, 0);
    },
  );
}
