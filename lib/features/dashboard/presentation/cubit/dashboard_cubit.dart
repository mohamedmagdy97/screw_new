import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:screw_calculator/core/models/player_model.dart';
import 'package:screw_calculator/core/models/team_model_new.dart';
import 'package:screw_calculator/features/dashboard/domain/usecases/save_game_usecase.dart';
import 'package:screw_calculator/features/dashboard/domain/usecases/upload_screenshot_usecase.dart';

part 'dashboard_state.dart';

/// رقم الجولة المُعاد عند اكتمال كل الجولات.
const int kGameFinishedRound = 10;

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit({
    required SaveGameUseCase saveGameUseCase,
    required UploadScreenshotUseCase uploadScreenshotUseCase,
  }) : _saveGameUseCase = saveGameUseCase,
       _uploadScreenshotUseCase = uploadScreenshotUseCase,
       super(const DashboardState(players: [], teams: []));

  final SaveGameUseCase _saveGameUseCase;
  final UploadScreenshotUseCase _uploadScreenshotUseCase;

  /// تهيئة اللعبة بقائمة اللاعبين وإن كان وضع الفرق مفعّلاً.
  void start({
    required List<PlayerModel> players,
    required bool showTeamsView,
  }) {
    emit(
      state.copyWith(
        players: players,
        teams: showTeamsView ? _buildTeams(players) : const [],
        showTeamsView: showTeamsView,
      ),
    );
  }

  List<Team> _buildTeams(List<PlayerModel> players) {
    if (players.length < 4) return const [];
    return [
      Team(name: 'الفريق الأول', playerOne: players[0], playerTwo: players[1]),
      Team(name: 'الفريق الثاني', playerOne: players[2], playerTwo: players[3]),
      if (players.length > 4)
        Team(name: 'الفريق الثالث', playerOne: players[4], playerTwo: players[5]),
      if (players.length > 6)
        Team(name: 'الفريق الرابع', playerOne: players[6], playerTwo: players[7]),
    ];
  }

  /// يضيف/يعدّل نتيجة لاعب (القيمة بعد الضرب بالمضاعف من واجهة الإدخال).
  void applyScore(PlayerModel player, int value, {bool edit = false}) {
    if (edit) {
      player.editLastRoundScore(value);
    } else {
      player.addRoundScore(value);
    }
    emit(state.copyWith(revision: state.revision + 1));
  }

  void hideMarquee() => emit(state.copyWith(marqueeVisible: false));

  /// إعادة بدء الجولة: تصفير نتائج كل اللاعبين.
  void resetGame() {
    for (final player in state.players) {
      player.resetRounds();
    }
    emit(state.copyWith(revision: state.revision + 1));
  }

  Future<void> saveGame() async {
    emit(state.copyWith(status: DashboardStatus.saving));
    try {
      await _saveGameUseCase(state.players);
      emit(state.copyWith(status: DashboardStatus.saved, message: 'تم حفظ الجولة'));
    } catch (_) {
      emit(
        state.copyWith(
          status: DashboardStatus.saveError,
          message: 'تعذّر حفظ الجولة',
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
      final anyEmpty = state.players.any(
        (p) => p.getRoundScore(round).isEmpty,
      );
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
