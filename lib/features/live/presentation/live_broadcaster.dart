import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:screw_calculator/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:screw_calculator/features/live/domain/entities/live_game.dart';
import 'package:screw_calculator/features/live/domain/repositories/live_game_repository.dart';

/// لقطة لايف من حالة لوحة النتائج.
LiveGame liveGameFromDashboard(
  String code,
  DashboardState state, {
  required int round,
  required bool finished,
}) {
  return LiveGame(
    code: code,
    players: [
      for (final p in state.players)
        LivePlayer(
          name: p.name ?? '',
          total: int.tryParse(p.total ?? '') ?? 0,
          rounds: p.roundValues,
        ),
    ],
    teams: state.showTeamsView
        ? [
            for (final t in state.teams)
              LivePlayer(name: t.name, total: t.totalScore),
          ]
        : const [],
    round: finished ? 6 : round,
    finished: finished,
  );
}

/// بيبعت اللعبة لايف من موبايل اللي بيسجّل. التحديثات المتتالية بتتجمّع
/// (كل [debounce]) عشان ما نكتبش على Firestore مع كل ضغطة.
class LiveBroadcaster extends ChangeNotifier {
  LiveBroadcaster(
    this._repository, {
    this.debounce = const Duration(milliseconds: 400),
  });

  final LiveGameRepository _repository;
  final Duration debounce;

  String? _code;
  Timer? _timer;
  LiveGame Function(String code)? _pending;
  bool _disposed = false;

  String? get code => _code;
  bool get isLive => _code != null;

  /// يبدأ البث ويرجّع الكود.
  Future<String> start(LiveGame Function(String code) snapshot) async {
    final existing = _code;
    if (existing != null) return existing;
    final code = await _repository.create(snapshot);
    _code = code;
    notifyListeners();
    return code;
  }

  /// يجهّز تحديث (بيتبعت بعد [debounce]).
  void push(LiveGame Function(String code) snapshot) {
    if (_code == null) return;
    _pending = snapshot;
    _timer?.cancel();
    _timer = Timer(debounce, flush);
  }

  /// يبعت آخر تحديث متجهّز دلوقتي.
  Future<void> flush() async {
    _timer?.cancel();
    final code = _code;
    final pending = _pending;
    _pending = null;
    if (code == null || pending == null) return;
    try {
      await _repository.update(pending(code));
    } catch (e) {
      debugPrint('live update failed: $e');
    }
  }

  Future<void> stop() async {
    final code = _code;
    if (code == null) return;
    await flush();
    _code = null;
    if (!_disposed) notifyListeners();
    try {
      await _repository.end(code);
    } catch (e) {
      debugPrint('live end failed: $e');
    }
  }

  @override
  void dispose() {
    _disposed = true;
    unawaited(stop());
    super.dispose();
  }
}
