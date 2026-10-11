// يولّد لقطات متجر Google Play من شاشات التطبيق الحقيقية بدون جهاز/محاكي.
//
// التشغيل:  flutter test tool/render_store_test.dart
// المخرجات: design/store/play/*.png  (+ design/store/raw/*.png)
import 'dart:io';
import 'dart:ui' as ui;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
// ignore: depend_on_referenced_packages
import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:screw_calculator/core/models/player_model.dart';
import 'package:screw_calculator/core/theme/app_palette.dart';
import 'package:screw_calculator/core/theme/app_theme.dart';
import 'package:screw_calculator/core/utils/enums.dart';
import 'package:screw_calculator/core/widgets/app_dialog.dart';
import 'package:screw_calculator/features/chat/data/datasources/chat_moderation_store.dart';
import 'package:screw_calculator/features/chat/presentation/screens/chat_screen.dart';
import 'package:screw_calculator/features/dashboard/domain/entities/active_game.dart';
import 'package:screw_calculator/features/dashboard/domain/entities/last_game_summary.dart';
import 'package:screw_calculator/features/dashboard/domain/repositories/active_game_repository.dart';
import 'package:screw_calculator/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:screw_calculator/features/dashboard/domain/repositories/last_game_publisher.dart';
import 'package:screw_calculator/features/dashboard/domain/usecases/save_game_usecase.dart';
import 'package:screw_calculator/features/dashboard/domain/usecases/upload_screenshot_usecase.dart';
import 'package:screw_calculator/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:screw_calculator/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:screw_calculator/features/dashboard/presentation/widgets/share_result_card.dart';
import 'package:screw_calculator/features/game_mode/presentation/cubit/game_mode_cubit.dart';
import 'package:screw_calculator/features/game_mode/presentation/screens/game_mode_screen.dart';
import 'package:screw_calculator/features/history/domain/entities/game_history_entity.dart';
import 'package:screw_calculator/features/history/domain/repositories/history_repository.dart';
import 'package:screw_calculator/features/history/domain/usecases/get_games_usecase.dart';
import 'package:screw_calculator/features/home/data/datasources/home_local_data_source.dart';
import 'package:screw_calculator/features/home/domain/repositories/home_repository.dart';
import 'package:screw_calculator/features/home/presentation/controller/home_controller.dart';
import 'package:screw_calculator/features/home/presentation/screens/home_screen.dart';
import 'package:screw_calculator/features/home/presentation/widgets/chat_entry_flow.dart';
import 'package:screw_calculator/features/rules/presentation/screens/rules_screen.dart';
import 'package:screw_calculator/features/stats/presentation/cubit/stats_cubit.dart';
import 'package:screw_calculator/features/stats/presentation/screens/stats_screen.dart';
import 'package:screw_calculator/features/tournament/domain/entities/tournament.dart';
import 'package:screw_calculator/features/tournament/domain/repositories/tournament_repository.dart';
import 'package:screw_calculator/features/tournament/presentation/cubit/tournament_cubit.dart';
import 'package:screw_calculator/features/tournament/presentation/screens/tournament_screen.dart';
import 'package:screw_calculator/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'brand/logo_options.dart';
import 'brand/logo_painter.dart';

// ---------- Fakes ----------
class _DashRepo implements DashboardRepository {
  @override
  Future<void> saveGame(List<PlayerModel> players) async {}

  @override
  Future<void> uploadScreenshot(File file, {required String title}) async {}
}

class _ActiveRepo implements ActiveGameRepository {
  @override
  Future<void> clear() async {}

  @override
  Future<ActiveGame?> load() async => null;

  @override
  Future<void> save(ActiveGame game) async {}
}

class _HomeRepo implements HomeRepository {
  @override
  Future<bool> canEnterChat({
    required String phone,
    required String name,
  }) async => true;

  @override
  CachedUser getCachedUser() => const CachedUser();

  @override
  Future<void> registerUser({
    required String name,
    required String phone,
    required String country,
    required String age,
  }) async {}

  @override
  Future<UserValidationResult> validateUser({
    required String name,
    required String phone,
    required String country,
  }) async => UserValidationResult.notExists;
}

class _TournamentRepo implements TournamentRepository {
  @override
  Future<void> clear() async {}

  @override
  Future<Tournament?> load() async => null;

  @override
  Future<void> save(Tournament tournament) async {}
}

class _HistoryRepo implements HistoryRepository {
  _HistoryRepo(this.games);

  final List<GameHistoryEntity> games;

  @override
  Future<bool> clearAllGames() async => true;

  @override
  Future<List<GameHistoryEntity>> getGames() async => games;

  @override
  Future<bool> removeGame(int index) async => true;
}

// ---------- Demo data ----------
PlayerModel _p(int id, String name, List<int> rounds) {
  final p = PlayerModel(id: id, name: name);
  rounds.forEach(p.addRoundScore);
  return p;
}

List<PlayerModel> _midGame() => [
  _p(1, 'علي', [12, 0, 8]),
  _p(2, 'عمر', [5, 14, 9]),
  _p(3, 'سلمى', [0, 6, 3]),
  _p(4, 'يوسف', [18, 10, 22]),
];

List<PlayerModel> _finished() => [
  _p(1, 'علي', [12, 0, 8, 5, 10]),
  _p(2, 'عمر', [5, 14, 9, 20, 7]),
  _p(3, 'سلمى', [0, 6, 3, 4, 2]),
  _p(4, 'يوسف', [18, 10, 22, 12, 15]),
];

List<PlayerModel> _teams() => [
  _p(1, 'علي', [12, 0, 8]),
  _p(2, 'عمر', [5, 14, 9]),
  _p(3, 'سلمى', [0, 6, 3]),
  _p(4, 'يوسف', [18, 10, 22]),
];

GameHistoryEntity _game(List<List<int>> rounds, List<String> names) =>
    GameHistoryEntity(
      players: [
        for (var i = 0; i < names.length; i++) _p(i + 1, names[i], rounds[i]),
      ],
    );

List<GameHistoryEntity> _history() {
  const names = ['علي', 'عمر', 'سلمى', 'يوسف'];
  final totals = <List<List<int>>>[
    [
      [5, 5, 5, 5, 5],
      [9, 9, 9, 9, 9],
      [2, 2, 2, 2, 2],
      [12, 12, 12, 12, 12],
    ],
    [
      [8, 8, 8, 8, 8],
      [3, 3, 3, 3, 3],
      [4, 4, 4, 4, 4],
      [15, 15, 15, 15, 15],
    ],
    [
      [10, 4, 6, 8, 2],
      [20, 5, 9, 1, 15],
      [3, 3, 3, 3, 3],
      [30, 4, 8, 2, 6],
    ],
    [
      [6, 6, 6, 6, 6],
      [2, 2, 2, 2, 2],
      [9, 9, 9, 9, 9],
      [11, 11, 11, 11, 11],
    ],
    [
      [7, 7, 7, 7, 7],
      [14, 14, 14, 14, 14],
      [1, 1, 1, 1, 1],
      [8, 8, 8, 8, 8],
    ],
    [
      [4, 4, 4, 4, 4],
      [13, 13, 13, 13, 13],
      [6, 6, 6, 6, 6],
      [2, 2, 2, 2, 2],
    ],
  ];
  return [for (final t in totals) _game(t, names)];
}

// ---------- Rendering helpers ----------
const double _logicalW = 390;
const double _logicalH = 844;
const double _dpr = 3;

Future<void> _loadFont(String family, String path) async {
  final loader = FontLoader(family)
    ..addFont(Future.value(ByteData.sublistView(File(path).readAsBytesSync())));
  await loader.load();
}

/// لغة الرندر: `STORE_LOCALE=en` للتحقق من الواجهة الإنجليزية.
final String _locale = Platform.environment['STORE_LOCALE'] ?? 'ar';

/// `STORE_THEME=light` لرندر الوضع الفاتح.
final ThemeMode _themeMode = Platform.environment['STORE_THEME'] == 'light'
    ? ThemeMode.light
    : ThemeMode.dark;

Widget _app(Widget home) {
  return ScreenUtilInit(
    designSize: const Size(414, 896),
    minTextAdapt: true,
    builder: (context, _) => MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: Locale(_locale),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark.copyWith(
        textTheme: AppTheme.dark.textTheme.apply(
          fontFamilyFallback: const ['AppleEmoji'],
        ),
      ),
      themeMode: _themeMode,
      // نفس سلوك التطبيق: هيكل الواجهة LTR والمحتوى يتبع اللغة.
      builder: (context, child) => Directionality(
        textDirection: TextDirection.ltr,
        child: child ?? const SizedBox.shrink(),
      ),
      home: home,
    ),
  );
}

Future<ui.Image> _capture(
  WidgetTester t,
  Widget home, {
  Future<void> Function()? afterPump,
}) async {
  final key = GlobalKey();
  // اطبع أي استثناء فورًا (الاختبار قد لا ينتهي فلا يظهر التقرير النهائي).
  FlutterError.onError = (details) {
    stderr.writeln('FLUTTER ERROR: ${details.exceptionAsString()}');
    stderr.writeln(
      (details.stack?.toString() ?? '').split('\n').take(14).join('\n'),
    );
  };
  t.view
    ..physicalSize = const Size(_logicalW * _dpr, _logicalH * _dpr)
    ..devicePixelRatio = _dpr
    ..padding = const FakeViewPadding(top: 54 * _dpr, bottom: 30 * _dpr)
    ..viewPadding = const FakeViewPadding(top: 54 * _dpr, bottom: 30 * _dpr);
  await t.pumpWidget(RepaintBoundary(key: key, child: _app(home)));
  await t.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 300)),
  );
  await t.pump(const Duration(milliseconds: 800));
  if (afterPump != null) await afterPump();
  await t.pump(const Duration(milliseconds: 800));
  await t.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 200)),
  );
  await t.pump(const Duration(milliseconds: 100));
  final boundary =
      key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  return (await t.runAsync(() => boundary.toImage(pixelRatio: _dpr)))!;
}

Future<Uint8List> _pngOf(ui.Image image) async {
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  return data!.buffer.asUint8List();
}

void _writeFile(String path, Uint8List bytes) {
  File(path)
    ..createSync(recursive: true)
    ..writeAsBytesSync(bytes);
}

TextPainter _tp(
  String text,
  double size,
  Color color, {
  String font = 'JannaLT-Bold',
  double width = 900,
}) {
  return TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(
        fontFamily: font,
        fontSize: size,
        color: color,
        height: 1.25,
      ),
    ),
    textAlign: TextAlign.center,
    textDirection: TextDirection.rtl,
  )..layout(maxWidth: width);
}

/// يركّب لقطة الشاشة داخل تصميم متجر 1080×1920 بعنوان عربي وإطار هاتف.
Future<Uint8List> _compose(ui.Image shot, String title, String subtitle) async {
  const w = 1080.0;
  const h = 1920.0;
  final recorder = ui.PictureRecorder();
  final c = ui.Canvas(recorder);
  const bg = ui.Rect.fromLTWH(0, 0, w, h);
  c.drawRect(
    bg,
    ui.Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFA855F7), BrandColors.indigo, Color(0xFF312E81)],
        stops: [0, 0.55, 1],
      ).createShader(bg),
  );
  c.drawCircle(
    const Offset(w * 0.9, h * 0.12),
    330,
    ui.Paint()..color = const Color(0x1FFFFFFF),
  );
  c.drawCircle(
    const Offset(w * 0.05, h * 0.5),
    220,
    ui.Paint()..color = const Color(0x1422D3EE),
  );

  final t1 = _tp(title, 84, Colors.white);
  t1.paint(c, Offset((w - t1.width) / 2, 120));
  final t2 = _tp(
    subtitle,
    42,
    const Color(0xE6FFFFFF),
    font: 'JannaLT-Regular',
  );
  t2.paint(c, Offset((w - t2.width) / 2, 120 + t1.height + 18));

  // إطار الهاتف (يخرج من أسفل التصميم).
  const phoneW = 860.0;
  final phoneH = phoneW * (_logicalH / _logicalW);
  const left = (w - phoneW) / 2;
  const top = 440.0;
  final outer = ui.RRect.fromRectAndRadius(
    ui.Rect.fromLTWH(left - 16, top - 16, phoneW + 32, phoneH + 32),
    const ui.Radius.circular(120),
  );
  c.drawRRect(
    outer.shift(const Offset(0, 24)),
    ui.Paint()
      ..color = const Color(0x66000000)
      ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 36),
  );
  c.drawRRect(outer, ui.Paint()..color = const Color(0xFF0B0813));
  final screen = ui.RRect.fromRectAndRadius(
    ui.Rect.fromLTWH(left, top, phoneW, phoneH),
    const ui.Radius.circular(104),
  );
  c.save();
  c.clipRRect(screen);
  c.drawImageRect(
    shot,
    ui.Rect.fromLTWH(0, 0, shot.width.toDouble(), shot.height.toDouble()),
    ui.Rect.fromLTWH(left, top, phoneW, phoneH),
    ui.Paint()..filterQuality = ui.FilterQuality.high,
  );
  c.restore();
  // جزيرة الكاميرا.
  c.drawRRect(
    ui.RRect.fromRectAndRadius(
      const ui.Rect.fromLTWH(w / 2 - 90, top + 22, 180, 44),
      const ui.Radius.circular(22),
    ),
    ui.Paint()..color = const Color(0xFF0B0813),
  );

  final image = await recorder.endRecording().toImage(w.toInt(), h.toInt());
  return _pngOf(image);
}

class _NoopPublisher implements LastGamePublisher {
  @override
  Future<void> publish(LastGameSummary summary) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final sl = GetIt.instance;
  late Directory hiveDir;

  setUpAll(() async {
    // ignore: invalid_use_of_visible_for_testing_member
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await _loadFont('JannaLT-Bold', 'assets/fonts/JannaLT-Bold.ttf');
    await _loadFont('JannaLT-Regular', 'assets/fonts/JannaLT-Regular.ttf');
    await _loadFont(
      'MaterialIcons',
      '/Users/megtech/dev/v3.41/flutter/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
    );
    await _loadFont(
      'packages/cupertino_icons/CupertinoIcons',
      '${Platform.environment['HOME']}/.pub-cache/hosted/pub.dev/cupertino_icons-1.0.8/assets/CupertinoIcons.ttf',
    );
    await _loadFont(
      'AppleEmoji',
      '/System/Library/Fonts/Apple Color Emoji.ttc',
    );
    hiveDir = Directory.systemTemp.createTempSync('hive_store');
    Hive.init(hiveDir.path);
    await Hive.openBox<dynamic>('userBox');
  });

  tearDownAll(() => hiveDir.deleteSync(recursive: true));

  setUp(() async {
    await sl.reset();
    sl
      ..registerFactory<DashboardCubit>(
        () => DashboardCubit(
          saveGameUseCase: SaveGameUseCase(_DashRepo()),
          uploadScreenshotUseCase: UploadScreenshotUseCase(_DashRepo()),
          activeGameRepository: _ActiveRepo(),
          lastGamePublisher: _NoopPublisher(),
        ),
      )
      ..registerSingleton<HomeController>(
        HomeController(repository: _HomeRepo()),
      )
      ..registerFactory<TournamentCubit>(
        () => TournamentCubit(repository: _TournamentRepo()),
      )
      ..registerFactory<StatsCubit>(
        () => StatsCubit(
          getGamesUseCase: GetGamesUseCase(_HistoryRepo(_history())),
        ),
      );
  });

  const shots = <String, List<String>>{
    '1-gamemode': ['ابدأ لعبتك في ثوانٍ', 'فردي أو فرق، بتصميم عصري وسريع'],
    '2-scoresheet': ['احسب بالكروت باللمس', 'اختر كروتك والمجموع يتحسب لوحده'],
    '3-score': ['سجّل كل جولة بسهولة', 'تراجع أو عدّل أي نتيجة في أي وقت'],
    '4-winner': ['اعرف الفائز فورًا', 'الأقل نقاطًا يفوز.. والخاسر معروف'],
    '5-teams': ['العب فرق زوجي', 'حتى 4 فرق ومجموع كل فريق أمامك'],
    '6-stats': ['إحصائيات لاعبينك', 'نسب الفوز ومتوسط النقاط من سجلّك'],
    '7-rules': ['دليل الكروت والقواعد', 'بحث وتصفية سريعة بالعربي والإنجليزي'],
    '8-share': [
      'شارك النتيجة بصورة أنيقة',
      'بطاقة جاهزة برابط التحميل لأصدقائك',
    ],
  };

  Future<void> save(String id, ui.Image shot) async {
    // التركيب النهائي يتم في اختبار منفصل (compose) لأن toImage يحتاج zone حقيقي.
    final dir =
        Platform.environment['STORE_OUT'] ??
        (_locale == 'ar' ? 'raw' : 'check_$_locale');
    _writeFile('design/store/$dir/$id.png', await _pngOf(shot));
  }

  testWidgets('1 gamemode', (t) async {
    final img = await _capture(
      t,
      BlocProvider<GameModeCubit>(
        create: (_) => GameModeCubit(),
        child: const GameModeView(),
      ),
    );
    await save('1-gamemode', img);
  });

  testWidgets('2 scoresheet', (t) async {
    ModeClass.mode = GameModeEnum.classic;
    final img = await _capture(
      t,
      DashboardScreen(players: _midGame()),
      afterPump: () async {
        t
            .element(find.byType(Scaffold).first)
            .read<DashboardCubit>()
            .hideMarquee();
        await t.pump(const Duration(seconds: 4));
        await t.tap(find.byIcon(Icons.add_rounded).first);
        await t.pump(const Duration(milliseconds: 700));
        // اختيار كروت ليظهر المجموع (7 + 10 + سكرول أحمر).
        await t.tap(find.text('8').last);
        await t.pump(const Duration(milliseconds: 150));
        await t.tap(find.text('5').last);
        await t.pump(const Duration(milliseconds: 150));
        await t.tap(find.text('2').last);
        await t.pump(const Duration(milliseconds: 300));
      },
    );
    await save('2-scoresheet', img);
  });

  testWidgets('3 score', (t) async {
    ModeClass.mode = GameModeEnum.classic;
    final img = await _capture(
      t,
      DashboardScreen(players: _midGame()),
      afterPump: () async {
        t
            .element(find.byType(Scaffold).first)
            .read<DashboardCubit>()
            .hideMarquee();
        await t.pump(const Duration(seconds: 4));
      },
    );
    await save('3-score', img);
  });

  testWidgets('4 winner', (t) async {
    ModeClass.mode = GameModeEnum.classic;
    final img = await _capture(
      t,
      DashboardScreen(players: _finished()),
      afterPump: () async {
        await t.pump(const Duration(milliseconds: 300));
        final ok = find.text('تمام');
        if (ok.evaluate().isNotEmpty) {
          await t.tap(ok);
          await t.pump(const Duration(milliseconds: 400));
        }
        t
            .element(find.byType(Scaffold).first)
            .read<DashboardCubit>()
            .hideMarquee();
        await t.pump(const Duration(seconds: 4));
      },
    );
    await save('4-winner', img);
  });

  testWidgets('5 teams', (t) async {
    ModeClass.mode = GameModeEnum.friendly;
    final img = await _capture(
      t,
      DashboardScreen(players: _teams(), teamsMode: true),
      afterPump: () async {
        t
            .element(find.byType(Scaffold).first)
            .read<DashboardCubit>()
            .hideMarquee();
        await t.pump(const Duration(seconds: 4));
      },
    );
    await save('5-teams', img);
  });

  testWidgets('6 stats', (t) async {
    final img = await _capture(t, const StatsScreen());
    await save('6-stats', img);
  });

  testWidgets('7 rules', (t) async {
    final img = await _capture(t, const RulesScreen());
    await save('7-rules', img);
  });

  testWidgets('8 share', (t) async {
    final img = await _capture(
      t,
      Scaffold(
        body: Align(
          alignment: const Alignment(0, -0.2),
          child: Builder(
            builder: (context) => const ShareResultCard(
              palette: AppPalette.dark,
              title: 'نتيجة اللعبة',
              footer: 'سكرو حاسبة',
              downloadLabel: 'حمّل التطبيق من Google Play',
              downloadUrl:
                  'https://play.google.com/store/apps/details?id=com.megTech.screw_calculator',
              entries: [
                ShareResultEntry(name: 'سلمى', total: 15),
                ShareResultEntry(name: 'علي', total: 35),
                ShareResultEntry(name: 'عمر', total: 55),
                ShareResultEntry(name: 'يوسف', total: 77),
              ],
            ),
          ),
        ),
      ),
    );
    await save('8-share', img);
  });

  Future<void> design(String id, ui.Image shot) async {
    final dir = Platform.environment['STORE_OUT'] ?? 'check_design';
    _writeFile('design/store/$dir/$id.png', await _pngOf(shot));
  }

  testWidgets('design gamemode', (t) async {
    final img = await _capture(
      t,
      BlocProvider<GameModeCubit>(
        create: (_) => GameModeCubit(),
        child: const GameModeView(),
      ),
    );
    await design('gamemode', img);
  });

  testWidgets('design drawer', (t) async {
    ModeClass.mode = GameModeEnum.classic;
    final home = sl<HomeController>();
    final img = await _capture(
      t,
      const HomeScreen(index: 0),
      afterPump: () async {
        home.scaffoldKey.currentState!.openEndDrawer();
        await t.pump(const Duration(milliseconds: 600));
      },
    );
    await design('drawer', img);
  });

  testWidgets('design scoresheet', (t) async {
    ModeClass.mode = GameModeEnum.classic;
    final img = await _capture(
      t,
      DashboardScreen(players: _midGame()),
      afterPump: () async {
        t
            .element(find.byType(Scaffold).first)
            .read<DashboardCubit>()
            .hideMarquee();
        await t.pump(const Duration(seconds: 4));
        await t.tap(find.byIcon(Icons.add_rounded).first);
        await t.pump(const Duration(milliseconds: 700));
      },
    );
    await design('scoresheet', img);
  });

  testWidgets('design rules', (t) async {
    final img = await _capture(t, const RulesScreen());
    await design('rules', img);
  });

  testWidgets('design dialog', (t) async {
    final img = await _capture(
      t,
      Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () => showAppConfirmDialog(
                context,
                icon: Icons.restart_alt_rounded,
                tone: AppDialogTone.danger,
                title: 'تحذير',
                message: 'هل تريد إعادة بدأ الجولة؟',
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
      afterPump: () async {
        await t.tap(find.text('open'));
        await t.pump(const Duration(milliseconds: 600));
      },
    );
    await design('dialog', img);
  });

  testWidgets('design chatentry', (t) async {
    ModeClass.mode = GameModeEnum.classic;
    final home = sl<HomeController>();
    final img = await _capture(
      t,
      Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () => openPublicChat(context, home),
              child: const Text('open'),
            ),
          ),
        ),
      ),
      afterPump: () async {
        await t.tap(find.text('open'));
        await t.pump(const Duration(milliseconds: 700));
      },
    );
    await design('chatentry', img);
  });

  testWidgets('design chatscreen', (t) async {
    setupFirebaseCoreMocks();
    // عمليات async حقيقية (قنوات/ملفات) لا تعمل داخل fake-async.
    await t.runAsync(() async {
      await Firebase.initializeApp();
      await Hive.openBox<dynamic>('cachedMessages');
      final box = Hive.box<dynamic>('userBox');
      await box.put('name', 'علي');
      await box.put('phone', '01000000000');
      await box.put('country', 'القاهرة');
      final cache = Hive.box<dynamic>('cachedMessages');
      await cache.clear();
      final now = DateTime.now();
      Map<String, dynamic> msg(
        String id,
        String name,
        String phone,
        String text, {
        int minutesAgo = 5,
        String? replyTo,
        bool deleted = false,
        Map<String, dynamic>? reactions,
      }) => {
        'id': id,
        'name': name,
        'age': 20,
        'phone': phone,
        'message': text,
        'timestamp': now
            .subtract(Duration(minutes: minutesAgo))
            .toIso8601String(),
        'reactions': reactions ?? <String, dynamic>{},
        'seenBy': <String>['علي'],
        'isDeleted': deleted,
        'isPinned': false,
        'isMe': false,
        'status': 'sent',
        'replyTo': replyTo,
        'audioUrl': null,
        'type': 'text',
        'deviceName': 'Pixel',
        'country': 'القاهرة',
      };
      await cache.put(
        '1',
        msg('1', 'سلمى', '0102', 'اهلا بالجميع', minutesAgo: 30),
      );
      await cache.put(
        '2',
        msg(
          '2',
          'علي',
          '01000000000',
          'اهلا سلمى',
          minutesAgo: 25,
          replyTo: '1',
        ),
      );
      await cache.put(
        '3',
        msg(
          '3',
          'عمر',
          '0103',
          'تحبوا نلعب جولة؟',
          minutesAgo: 20,
          reactions: {'0102': 'سلمى|👍'},
        ),
      );
      await cache.put(
        '4',
        msg('4', 'عمر', '0103', 'x', minutesAgo: 15, deleted: true),
      );
      await cache.put(
        '5',
        msg(
          '5',
          'علي',
          '01000000000',
          'تمام يلا',
          minutesAgo: 10,
          replyTo: '3',
        ),
      );
    });
    sl.registerLazySingleton<ChatModerationStore>(
      () => ChatModerationStore(firestore: FirebaseFirestore.instance),
    );
    final img = await _capture(t, const ChatScreen());
    await design('chat', img);
  });

  testWidgets('design tournament', (t) async {
    final img = await _capture(t, const TournamentScreen());
    await design('tournament', img);
  });

  test('compose store images', () async {
    for (final id in shots.keys) {
      final bytes = File('design/store/raw/$id.png').readAsBytesSync();
      final codec = await ui.instantiateImageCodec(bytes);
      final shot = (await codec.getNextFrame()).image;
      final tpl = shots[id]!;
      _writeFile(
        'design/store/play/phone-$id.png',
        await _compose(shot, tpl[0], tpl[1]),
      );
    }
  });

  test('graphics (feature + icon)', () async {
    // أيقونة المتجر 512 (بلا شفافية).
    Future<Uint8List> draw(int w, int h, void Function(ui.Canvas) f) async {
      final r = ui.PictureRecorder();
      f(ui.Canvas(r));
      return _pngOf(await r.endRecording().toImage(w, h));
    }

    _writeFile(
      'design/store/play/icon-512.png',
      await draw(512, 512, (c) => paintOptionCard(c, 512)),
    );
    _writeFile(
      'design/store/play/feature-graphic-1024x500.png',
      await draw(1024, 500, (c) {
        const r = ui.Rect.fromLTWH(0, 0, 1024, 500);
        c.drawRect(
          r,
          ui.Paint()
            ..shader = const LinearGradient(
              colors: [
                Color(0xFF312E81),
                BrandColors.indigo,
                Color(0xFFA855F7),
              ],
            ).createShader(r),
        );
        c.save();
        c.translate(90, 100);
        c.clipRRect(
          ui.RRect.fromRectAndRadius(
            const ui.Rect.fromLTWH(0, 0, 300, 300),
            const ui.Radius.circular(68),
          ),
        );
        paintOptionCard(c, 300);
        c.restore();
        final t1 = _tp('سكرو حاسبة', 92, Colors.white, width: 520);
        t1.paint(c, Offset(1024 - 60 - 520 + (520 - t1.width) / 2, 130));
        final t2 = _tp(
          'احسب نقاط لعبتك بسهولة',
          38,
          const Color(0xE6FFFFFF),
          font: 'JannaLT-Regular',
          width: 520,
        );
        t2.paint(c, Offset(1024 - 60 - 520 + (520 - t2.width) / 2, 260));
      }),
    );
  });
}
