import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:screw_calculator/core/models/player_model.dart';
import 'package:screw_calculator/core/models/team_model_new.dart';
import 'package:screw_calculator/features/dashboard/domain/entities/active_game.dart';
import 'package:screw_calculator/features/dashboard/domain/entities/last_game_summary.dart';
import 'package:screw_calculator/features/dashboard/domain/entities/score_edit.dart';
import 'package:screw_calculator/features/dashboard/domain/repositories/active_game_repository.dart';
import 'package:screw_calculator/features/dashboard/domain/repositories/last_game_publisher.dart';
import 'package:screw_calculator/features/dashboard/domain/usecases/save_game_usecase.dart';
import 'package:screw_calculator/features/dashboard/domain/usecases/upload_screenshot_usecase.dart';

part 'dashboard_state.dart';

/// رسائل الحالة (تُترجم في طبقة العرض).
enum DashboardMessage { saved, saveFailed }

/// رقم الجولة المُعاد عند اكتمال كل الجولات.
const int kGameFinishedRound = 10;

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit({
    required SaveGameUseCase saveGameUseCase,
    required UploadScreenshotUseCase uploadScreenshotUseCase,
    required ActiveGameRepository activeGameRepository,
    required LastGamePublisher lastGamePublisher,
  }) : _saveGameUseCase = saveGameUseCase,
       _activeGameRepository = activeGameRepository,
       _lastGamePublisher = lastGamePublisher,
       _uploadScreenshotUseCase = uploadScreenshotUseCase,
       super(const DashboardState(players: [], teams: []));

  final SaveGameUseCase _saveGameUseCase;
  final UploadScreenshotUseCase _uploadScreenshotUseCase;
  final ActiveGameRepository _activeGameRepository;
  final LastGamePublisher _lastGamePublisher;

  /// لقطات ما قبل كل إدخال لدعم التراجع (Undo) عن آخر نتيجة.
  final List<_ScoreSnapshot> _undoStack = [];

  /// تُضبط عند الإعلان عن نتيجة اللعبة حتى لا يتكرر الإعلان.
  bool finishAnnounced = false;

  /// تهيئة اللعبة بقائمة اللاعبين وإن كان وضع الفرق مفعّلاً.
  void start({
    required List<PlayerModel> players,
    required bool showTeamsView,
    List<ScoreEdit> edits = const [],
    List<String> teamNames = const [
      'الفريق الأول',
      'الفريق الثاني',
      'الفريق الثالث',
      'الفريق الرابع',
    ],
  }) {
    emit(
      state.copyWith(
        players: players,
        teams: showTeamsView ? _buildTeams(players, teamNames) : const [],
        showTeamsView: showTeamsView,
        edits: edits,
      ),
    );
    _undoStack.clear();
    finishAnnounced = isFinished;
    _persist();
  }

  bool get canUndo => _undoStack.isNotEmpty;

  /// يتراجع عن آخر نتيجة أُدخلت (إضافة أو تعديل) لأي لاعب.
  void undo() {
    if (_undoStack.isEmpty) return;
    final snapshot = _undoStack.removeLast();
    snapshot.restore();
    finishAnnounced = isFinished;
    HapticFeedback.selectionClick();
    emit(
      state.copyWith(
        revision: state.revision + 1,
        edits: state.edits.sublist(0, snapshot.editsLength),
      ),
    );
    _persist();
  }

  void _persist() {
    final game = ActiveGame(
      players: state.players,
      friendly: state.showTeamsView,
      edits: state.edits,
    );
    if (game.hasProgress) {
      _activeGameRepository.save(game);
    } else {
      _activeGameRepository.clear();
    }
  }

  List<Team> _buildTeams(List<PlayerModel> players, List<String> names) {
    if (players.length < 4) return const [];
    return [
      Team(name: names[0], playerOne: players[0], playerTwo: players[1]),
      Team(name: names[1], playerOne: players[2], playerTwo: players[3]),
      if (players.length > 4)
        Team(name: names[2], playerOne: players[4], playerTwo: players[5]),
      if (players.length > 6)
        Team(name: names[3], playerOne: players[6], playerTwo: players[7]),
    ];
  }

  /// يضيف/يعدّل نتيجة لاعب (القيمة بعد الضرب بالمضاعف من واجهة الإدخال).
  void applyScore(PlayerModel player, int value, {bool edit = false}) {
    _undoStack.add(_ScoreSnapshot(player, editsLength: state.edits.length));
    if (edit) {
      player.editLastRoundScore(value);
    } else {
      player.addRoundScore(value);
    }
    HapticFeedback.lightImpact();
    emit(state.copyWith(revision: state.revision + 1));
    _persist();
    if (isFinished) _publishLastGame();
  }

  /// ينشر الفائز والخاسر إلى ويدجت الشاشة الرئيسية عند انتهاء اللعبة.
  void _publishLastGame() {
    final best = winnerTotal;
    final worst = loserTotal;
    if (best == null || worst == null) return;
    String names(int total) => state.players
        .where((p) => (int.tryParse(p.total ?? '') ?? -1) == total)
        .map((p) => p.name ?? '')
        .join(', ');
    _lastGamePublisher.publish(
      LastGameSummary(
        winners: names(best),
        winnerTotal: best,
        losers: names(worst),
        loserTotal: worst,
      ),
    );
  }

  /// يعدّل نتيجة أي جولة (1..5 → [roundIndex] 0..4) لأي لاعب ويسجّل التعديل.
  void applyScoreAt(PlayerModel player, int roundIndex, int value) {
    final old = player.roundValueAt(roundIndex);
    _undoStack.add(_ScoreSnapshot(player, editsLength: state.edits.length));
    player.setRoundScoreAt(roundIndex, value);
    final edits = old.isEmpty || old == value.toString()
        ? state.edits
        : [
            ...state.edits,
            ScoreEdit(
              playerName: player.name ?? '',
              playerId: player.id,
              round: roundIndex + 1,
              oldValue: old,
              newValue: value.toString(),
              at: DateTime.now(),
            ),
          ];
    HapticFeedback.lightImpact();
    emit(state.copyWith(revision: state.revision + 1, edits: edits));
    _persist();
    if (isFinished) _publishLastGame();
  }

  /// هل عُدّلت نتيجة هذا اللاعب في هذه الجولة (1..5) بعد إدخالها؟
  bool isEdited(PlayerModel player, int round) => state.edits.any(
    (e) =>
        e.round == round &&
        e.playerId == player.id &&
        e.playerName == (player.name ?? ''),
  );

  void hideMarquee() => emit(state.copyWith(marqueeVisible: false));

  /// إعادة بدء الجولة: تصفير نتائج كل اللاعبين.
  void resetGame() {
    for (final player in state.players) {
      player.resetRounds();
    }
    _undoStack.clear();
    finishAnnounced = false;
    emit(state.copyWith(revision: state.revision + 1, edits: const []));
    _persist();
  }

  Future<void> saveGame() async {
    emit(state.copyWith(status: DashboardStatus.saving));
    try {
      await _saveGameUseCase(state.players);
      await _activeGameRepository.clear();
      emit(
        state.copyWith(
          status: DashboardStatus.saved,
          message: DashboardMessage.saved,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: DashboardStatus.saveError,
          message: DashboardMessage.saveFailed,
        ),
      );
    } finally {
      emit(state.copyWith(status: DashboardStatus.idle));
    }
  }

  Future<void> uploadScreenshot(File file, {required String title}) {
    return _uploadScreenshotUseCase(file, title: title);
  }

  // ===== قيم محسوبة للعرض =====

  /// أول جولة (1..5) لم يُدخلها كل اللاعبين، أو [kGameFinishedRound] لو اكتملت.
  int get currentRound {
    for (int round = 1; round <= 5; round++) {
      final anyEmpty = state.players.any((p) => p.getRoundScore(round).isEmpty);
      if (anyEmpty) return round;
    }
    return kGameFinishedRound;
  }

  bool get isFinished => currentRound == kGameFinishedRound;

  /// أقل مجموع (الفائز في Screw) أو null لو لا يوجد لاعبون.
  int? get winnerTotal => _reduceTotals((a, b) => a < b ? a : b);

  /// أكبر مجموع (الخاسر) أو null.
  int? get loserTotal => _reduceTotals((a, b) => a > b ? a : b);

  int? _reduceTotals(int Function(int, int) selector) {
    if (state.players.isEmpty) return null;
    return state.players
        .map((p) => int.tryParse(p.total ?? '0') ?? 0)
        .reduce(selector);
  }

  Team? get winningTeam {
    if (state.teams.isEmpty) return null;
    return state.teams.reduce(
      (curr, next) => curr.totalScore < next.totalScore ? curr : next,
    );
  }

  /// يمكن المشاركة بعد إدخال 4 جولات على الأقل لكل اللاعبين.
  bool get canShare =>
      state.players.isNotEmpty &&
      state.players.every((p) => p.filledRoundsCount >= 4);
}

/// لقطة لقيم جولات لاعب قبل تعديلها، تسمح باستعادتها عند التراجع.
class _ScoreSnapshot {
  _ScoreSnapshot(this.player, {required this.editsLength})
    : values = List<String>.of(player.roundValues);

  final PlayerModel player;
  final int editsLength;
  final List<String> values;

  void restore() {
    player
      ..gw1 = values[0]
      ..gw2 = values[1]
      ..gw3 = values[2]
      ..gw4 = values[3]
      ..gw5 = values[4]
      ..recomputeTotal();
  }
}
