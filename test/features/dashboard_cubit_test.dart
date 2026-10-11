import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:screw_calculator/core/models/player_model.dart';
import 'package:screw_calculator/features/dashboard/domain/entities/active_game.dart';
import 'package:screw_calculator/features/dashboard/domain/repositories/active_game_repository.dart';
import 'package:screw_calculator/features/dashboard/domain/repositories/dashboard_repository.dart';
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
}
