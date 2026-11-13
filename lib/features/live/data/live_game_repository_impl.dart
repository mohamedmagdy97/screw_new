import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:screw_calculator/features/live/data/pending_live_codes.dart';
import 'package:screw_calculator/features/live/domain/entities/live_game.dart';
import 'package:screw_calculator/features/live/domain/live_code.dart';
import 'package:screw_calculator/features/live/domain/repositories/live_game_repository.dart';

/// `live_games/{code}` على Firestore.
///
/// اللعبة بتتمسح من السيرفر أول ما صاحبها يوقّف اللايف أو يخرج من شاشة
/// النتايج، ولو التطبيق اتقفل فجأة بتتمسح أول ما يفتح تاني ([PendingLiveCodes]).
/// `expireAt` (بعد 24 ساعة) احتياطي لو اتفعّلت سياسة TTL في Firestore.
class LiveGameRepositoryImpl implements LiveGameRepository {
  LiveGameRepositoryImpl({
    required this.firestore,
    PendingLiveCodes? pending,
    this.newCode,
  }) : _pending = pending ?? PrefsPendingLiveCodes();

  final FirebaseFirestore firestore;
  final PendingLiveCodes _pending;

  /// للاختبارات؛ الافتراضي [LiveCode.generate].
  final String Function()? newCode;

  static const String collection = 'live_games';
  static const Duration lifetime = Duration(hours: 24);

  CollectionReference<Map<String, dynamic>> get _games =>
      firestore.collection(collection);

  Map<String, Object?> _data(LiveGame game) => {
    ...game.toMap(),
    'updatedAt': FieldValue.serverTimestamp(),
    'expireAt': Timestamp.fromDate(DateTime.now().add(lifetime)),
  };

  @override
  Future<String> create(LiveGame Function(String code) build) async {
    for (var attempt = 0; attempt < 5; attempt++) {
      final code = (newCode ?? LiveCode.generate)();
      final doc = _games.doc(code);
      if ((await doc.get()).exists) continue;
      await _pending.add(code);
      await doc.set(_data(build(code)));
      return code;
    }
    throw StateError('live: no free code');
  }

  @override
  Future<void> update(LiveGame game) => _games.doc(game.code).set(_data(game));

  @override
  Future<void> end(String code) async {
    final doc = _games.doc(code);
    // نعلّم إنها خلصت الأول (اللي بيتابعوا يشوفوا الرسالة)، وبعدين نمسحها.
    await doc.update({
      'ended': true,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await doc.delete();
    await _pending.remove(code);
  }

  @override
  Future<void> cleanupLeftovers() async {
    for (final code in await _pending.load()) {
      try {
        final doc = _games.doc(code);
        if ((await doc.get()).exists) {
          await doc.update({'ended': true});
          await doc.delete();
        }
        await _pending.remove(code);
      } catch (_) {
        // نحاول تاني المرة الجاية (مثلًا مفيش نت دلوقتي).
      }
    }
  }

  @override
  Stream<LiveGame?> watch(String code) {
    return _games.doc(code).snapshots().map((snap) {
      final data = snap.data();
      if (!snap.exists || data == null) return null;
      final updated = data['updatedAt'];
      return LiveGame.fromMap(
        data,
        updatedAt: updated is Timestamp ? updated.toDate() : null,
      );
    });
  }
}
