import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:screw_calculator/app/di/service_locator.dart';
import 'package:screw_calculator/core/models/player_model.dart';
import 'package:screw_calculator/core/theme/app_theme.dart';
import 'package:screw_calculator/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:screw_calculator/features/live/domain/entities/live_game.dart';
import 'package:screw_calculator/features/live/domain/live_code.dart';
import 'package:screw_calculator/features/live/domain/repositories/live_game_repository.dart';
import 'package:screw_calculator/features/live/presentation/live_broadcaster.dart';
import 'package:screw_calculator/features/live/presentation/screens/live_join_screen.dart';
import 'package:screw_calculator/l10n/app_localizations.dart';

class _Repo implements LiveGameRepository {
  final created = <LiveGame>[];
  final updates = <LiveGame>[];
  final ended = <String>[];
  final controller = StreamController<LiveGame?>.broadcast();

  @override
  Future<String> create(LiveGame Function(String code) build) async {
    created.add(build('ABC234'));
    return 'ABC234';
  }

  @override
  Future<void> update(LiveGame game) async => updates.add(game);

  @override
  Future<void> end(String code) async => ended.add(code);

  @override
  Stream<LiveGame?> watch(String code) => controller.stream;
}

PlayerModel _player(String name, List<int> rounds) {
  final p = PlayerModel(name: name);
  rounds.forEach(p.addRoundScore);
  return p;
}

void main() {
  group('LiveCode', () {
    test('generates readable 6-char codes', () {
      final random = Random(1);
      for (var i = 0; i < 200; i++) {
        final code = LiveCode.generate(random);
        expect(code.length, 6);
        expect(LiveCode.parse(code), code);
        expect(code, isNot(matches(RegExp('[01ILO]'))));
      }
    });

    test('parses typed codes and QR contents, rejects the rest', () {
      expect(LiveCode.parse(' abc234 '), 'ABC234');
      expect(LiveCode.parse('screwlive:ABC234'), 'ABC234');
      expect(LiveCode.parse(LiveCode.qrData('XYZ789')), 'XYZ789');
      expect(LiveCode.parse('ABC23'), isNull);
      expect(LiveCode.parse('ABC2O4'), isNull); // O مش في الأبجدية
      expect(LiveCode.parse('https://evil.com'), isNull);
      expect(LiveCode.parse(null), isNull);
    });
  });

  test('LiveGame survives a map round trip and ranks lowest first', () {
    const game = LiveGame(
      code: 'ABC234',
      players: [
        LivePlayer(name: 'Omar', total: 30, rounds: ['10', '20', '', '', '']),
        LivePlayer(name: 'Ali', total: 5, rounds: ['5', '0', '', '', '']),
      ],
      round: 3,
    );
    final back = LiveGame.fromMap(Map<String, dynamic>.from(game.toMap()));
    expect(back, game);
    expect(back.ranking.map((p) => p.name), ['Ali', 'Omar']);
  });

  test('snapshot from the dashboard keeps rounds, teams and status', () {
    final players = [
      _player('A', [1, 2]),
      _player('B', [3, 4]),
    ];
    final state = DashboardState(players: players, teams: const []);
    final game = liveGameFromDashboard(
      'ABC234',
      state,
      round: 3,
      finished: false,
    );
    expect(game.players.first.rounds, ['1', '2', '', '', '']);
    expect(game.players.last.total, 7);
    expect(game.round, 3);
    expect(game.teams, isEmpty);
  });

  group('LiveBroadcaster', () {
    test('start, debounced updates, stop', () async {
      final repo = _Repo();
      final live = LiveBroadcaster(repo, debounce: Duration.zero);
      LiveGame snap(int total) => LiveGame(
        code: 'x',
        players: [LivePlayer(name: 'A', total: total)],
      );

      live.push((_) => snap(1)); // قبل البدء: مفيش حاجة تتبعت
      expect(await live.start((c) => snap(0)), 'ABC234');
      expect(live.isLive, isTrue);
      expect(repo.created.single.players.single.total, 0);

      live
        ..push((_) => snap(1))
        ..push((_) => snap(2));
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(repo.updates.map((g) => g.players.single.total), [2]);

      await live.stop();
      expect(live.isLive, isFalse);
      expect(repo.ended, ['ABC234']);
      live.dispose();
    });
  });

  group('LiveJoinScreen', () {
    late _Repo repo;

    setUp(() {
      repo = _Repo();
      sl.registerSingleton<LiveGameRepository>(repo);
    });
    tearDown(() async {
      await repo.controller.close();
      await sl.reset();
    });

    Future<void> pump(WidgetTester tester, {String? scanned}) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          locale: const Locale('ar'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: LiveJoinScreen(scan: (_) async => scanned),
        ),
      );
    }

    testWidgets('a bad code shows an error and stays', (tester) async {
      await pump(tester);
      await tester.enterText(
        find.byKey(const ValueKey('live-code-field')),
        'AB',
      );
      await tester.tap(find.byKey(const ValueKey('live-join')));
      await tester.pump();
      expect(find.text('الكود 6 حروف وأرقام، زي ABC234'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a scanned QR opens the live board and follows updates', (
      tester,
    ) async {
      await pump(tester, scanned: 'ABC234');
      await tester.tap(find.byKey(const ValueKey('live-scan')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.text('لايف · ABC234'), findsOneWidget);

      repo.controller.add(
        const LiveGame(
          code: 'ABC234',
          players: [
            LivePlayer(name: 'عمر', total: 30, rounds: ['30', '', '', '', '']),
            LivePlayer(name: 'علي', total: 4, rounds: ['4', '', '', '', '']),
          ],
          round: 2,
        ),
      );
      await tester.pump();
      expect(find.text('الجولة 2 من 5'), findsOneWidget);
      expect(find.text('👑'), findsOneWidget);
      expect(find.text('علي'), findsOneWidget);
      expect(tester.takeException(), isNull);

      repo.controller.add(null);
      await tester.pump();
      expect(find.textContaining('مفيش لعبة لايف'), findsOneWidget);
    });
  });
}
