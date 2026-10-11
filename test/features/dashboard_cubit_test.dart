import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:screw_calculator/core/models/player_model.dart';
import 'package:screw_calculator/features/dashboard/domain/entities/active_game.dart';
import 'package:screw_calculator/features/dashboard/domain/entities/last_game_summary.dart';
import 'package:screw_calculator/features/dashboard/domain/repositories/active_game_repository.dart';
import 'package:screw_calculator/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:screw_calculator/features/dashboard/domain/repositories/last_game_publisher.dart';
import 'package:screw_calculator/features/dashboard/domain/usecases/save_game_usecase.dart';
import 'package:screw_calculator/features/dashboard/domain/usecases/upload_screenshot_usecase.dart';
import 'package:screw_calculator/features/dashboard/presentation/cubit/dashboard_cubit.dart';

class _FakeDashboardRepo implements DashboardRepository {
  @override
  Future<void> saveGame(List<PlayerModel> players) async {}

  @override
  Future<void> uploadScreenshot(File file, {required String title}) async {}
}

class _FakeActiveGameRepo implements ActiveGameRepository {
  ActiveGame? saved;

  @override
  Future<void> clear() async => saved = null;

  @override
  Future<ActiveGame?> load() async => saved;

  @override
  Future<void> save(ActiveGame game) async => saved = game;
}

class _NoopPublisher implements LastGamePublisher {
  @override
  Future<void> publish(LastGameSummary summary) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakeActiveGameRepo active;
  late DashboardCubit cubit;
  late PlayerModel a;
  late PlayerModel b;

  setUp(() {
    active = _FakeActiveGameRepo();
    final repo = _FakeDashboardRepo();
    cubit = DashboardCubit(
      saveGameUseCase: SaveGameUseCase(repo),
      uploadScreenshotUseCase: UploadScreenshotUseCase(repo),
      activeGameRepository: active,
      lastGamePublisher: _NoopPublisher(),
    );
    a = PlayerModel(id: 1, name: 'A');
    b = PlayerModel(id: 2, name: 'B');
    cubit.start(players: [a, b], showTeamsView: false);
  });

  tearDown(() => cubit.close());

  test('applyScore persists the active game', () {
    cubit.applyScore(a, 7);
    expect(a.total, '7');
    expect(active.saved?.players.first.gw1, '7');
  });

  test('undo restores the previous value and total', () {
    cubit.applyScore(a, 7);
    cubit.applyScore(a, 3);
    expect(a.total, '10');

    cubit.undo();
    expect(a.total, '7');
    expect(a.gw2, '');

    cubit.undo();
    expect(a.total, '0');
    expect(cubit.canUndo, isFalse);
  });

  test('undo also reverts an edit of the last score', () {
    cubit.applyScore(a, 7);
    cubit.applyScore(a, 5, edit: true);
    expect(a.gw1, '5');

    cubit.undo();
    expect(a.gw1, '7');
  });

  test('resetGame clears results and the saved game', () {
    cubit.applyScore(a, 7);
    cubit.resetGame();
    expect(a.total, '0');
    expect(active.saved, isNull);
  });

  test('applyScoreAt edits any round and logs the change', () {
    cubit.applyScore(a, 7);
    cubit.applyScore(a, 3);
    cubit.applyScoreAt(a, 0, 5); // تعديل الجولة 1

    expect(a.gw1, '5');
    expect(a.total, '8'); // 5 + 3
    expect(cubit.state.edits, hasLength(1));
    expect(cubit.state.edits.first.round, 1);
    expect(cubit.state.edits.first.oldValue, '7');
    expect(cubit.state.edits.first.newValue, '5');
    expect(cubit.isEdited(a, 1), isTrue);
    expect(cubit.isEdited(a, 2), isFalse);
    expect(active.saved?.edits, hasLength(1));
  });

  test('filling an empty round via applyScoreAt is not logged as an edit', () {
    cubit.applyScoreAt(a, 0, 4);
    expect(a.gw1, '4');
    expect(cubit.state.edits, isEmpty);
  });

  test('undo reverts an arbitrary-round edit and its log entry', () {
    cubit.applyScore(a, 7);
    cubit.applyScore(a, 3);
    cubit.applyScoreAt(a, 0, 5);

    cubit.undo();
    expect(a.gw1, '7');
    expect(a.total, '10');
    expect(cubit.state.edits, isEmpty);
  });

  test('resetGame clears the edit log', () {
    cubit.applyScore(a, 7);
    cubit.applyScoreAt(a, 0, 1);
    cubit.resetGame();
    expect(cubit.state.edits, isEmpty);
  });
}
