import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:screw_calculator/features/live/domain/entities/live_game.dart';
import 'package:screw_calculator/features/live/domain/live_code.dart';
import 'package:screw_calculator/features/live/domain/repositories/live_game_repository.dart';

/// `live_games/{code}` على Firestore. كل لعبة فيها `expireAt` بعد 24 ساعة
/// عشان سياسة TTL في Firestore تمسحها لوحدها.
class LiveGameRepositoryImpl implements LiveGameRepository {
  LiveGameRepositoryImpl({required this.firestore, this.newCode});

  final FirebaseFirestore firestore;

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
      await doc.set(_data(build(code)));
      return code;
    }
    throw StateError('live: no free code');
  }

  @override
  Future<void> update(LiveGame game) => _games.doc(game.code).set(_data(game));

  @override
  Future<void> end(String code) => _games.doc(code).update({
    'ended': true,
    'updatedAt': FieldValue.serverTimestamp(),
  });

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
