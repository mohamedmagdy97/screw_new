import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:screw_calculator/core/models/player_model.dart';
import 'package:screw_calculator/core/theme/app_theme.dart';
import 'package:screw_calculator/features/dashboard/domain/entities/active_game.dart';
import 'package:screw_calculator/features/dashboard/domain/entities/last_game_summary.dart';
import 'package:screw_calculator/features/dashboard/domain/repositories/active_game_repository.dart';
import 'package:screw_calculator/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:screw_calculator/features/dashboard/domain/repositories/last_game_publisher.dart';
import 'package:screw_calculator/features/dashboard/domain/usecases/save_game_usecase.dart';
import 'package:screw_calculator/features/dashboard/domain/usecases/upload_screenshot_usecase.dart';
import 'package:screw_calculator/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:screw_calculator/features/dashboard/presentation/widgets/score_input_sheet.dart';
import 'package:screw_calculator/l10n/app_localizations.dart';

class _Repo implements DashboardRepository {
  @override
  Future<void> saveGame(List<PlayerModel> players) async {}

  @override
  Future<void> uploadScreenshot(File file, {required String title}) async {}
}

class _Active implements ActiveGameRepository {
  @override
  Future<void> clear() async {}

  @override
  Future<ActiveGame?> load() async => null;

  @override
  Future<void> save(ActiveGame game) async {}
}

class _Publisher implements LastGamePublisher {
  @override
  Future<void> publish(LastGameSummary summary) async {}
}

void main() {
  late DashboardCubit cubit;
  late PlayerModel player;

  setUp(() {
    final repo = _Repo();
    cubit = DashboardCubit(
      saveGameUseCase: SaveGameUseCase(repo),
      uploadScreenshotUseCase: UploadScreenshotUseCase(repo),
      activeGameRepository: _Active(),
      lastGamePublisher: _Publisher(),
    );
    player = PlayerModel(id: 1, name: 'Ali');
    cubit.start(
      players: [
        player,
        PlayerModel(id: 2, name: 'Omar'),
      ],
      showTeamsView: false,
    );
  });

  tearDown(() => cubit.close());

  Future<void> openSheet(WidgetTester t, {int? editRound}) async {
    t.view.physicalSize = const Size(1200, 2600);
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
    await t.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        theme: AppTheme.dark,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => showScoreInputSheet(
                  context: context,
                  cubit: cubit,
                  player: player,
                  editRoundIndex: editRound,
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await t.tap(find.text('open'));
    await t.pumpAndSettle();
  }

  testWidgets('picking cards sums the total and Add applies it', (t) async {
    await openSheet(t);

    await t.tap(find.text('8').last);
    await t.pump();
    await t.tap(find.text('5').last);
    await t.pump();
    await t.tap(find.text('2').last);
    await t.pump();
    expect(find.text('15'), findsOneWidget); // المجموع في خانة الكتابة

    await t.tap(find.text('Add'));
    await t.pumpAndSettle();

    expect(player.gw1, '15');
    expect(player.total, '15');
  });

  testWidgets('typing a score and multiplying by 2 works', (t) async {
    await openSheet(t);

    await t.enterText(find.byType(TextField), '7');
    await t.pump();
    await t.tap(find.text('×2 Double'));
    await t.pumpAndSettle();

    expect(player.gw1, '14');
  });

  testWidgets('remove-last-card undoes the last picked card', (t) async {
    await openSheet(t);

    await t.tap(find.text('8').last);
    await t.pump();
    await t.tap(find.text('1').last);
    await t.pump();
    await t.tap(find.byTooltip('Remove last card'));
    await t.pump();

    await t.tap(find.text('Add'));
    await t.pumpAndSettle();
    expect(player.gw1, '8');
  });

  testWidgets('edit mode prefills the round value and logs the edit', (
    t,
  ) async {
    cubit.applyScore(player, 9); // الجولة 1 = 9
    await openSheet(t, editRound: 0);

    expect(find.text('9'), findsWidgets);
    await t.tap(find.text('3').last); // 9 + 3 = 12
    await t.pump();
    await t.tap(find.text('Save changes'));
    await t.pumpAndSettle();

    expect(player.gw1, '12');
    expect(cubit.state.edits, hasLength(1));
    expect(cubit.state.edits.first.oldValue, '9');
    expect(cubit.state.edits.first.newValue, '12');
  });
}
