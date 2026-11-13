import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:screw_calculator/app/di/service_locator.dart';
import 'package:screw_calculator/core/constants/developer_info.dart';
import 'package:screw_calculator/core/theme/app_theme.dart';
import 'package:screw_calculator/features/about/presentation/screens/about_screen.dart';
import 'package:screw_calculator/core/helpers/url_launcher_data_source.dart';
import 'package:screw_calculator/features/more_apps/domain/entities/megtech_app.dart';
import 'package:screw_calculator/features/more_apps/domain/repositories/more_apps_repository.dart';
import 'package:screw_calculator/features/more_apps/domain/usecases/get_more_apps_usecase.dart';
import 'package:screw_calculator/l10n/app_localizations.dart';

class _Launcher implements UrlLauncherDataSource {
  bool result = true;
  final opened = <String>[];

  @override
  Future<bool> launchUrl(String url) async {
    opened.add(url);
    return result;
  }
}

class _Repo implements MoreAppsRepository {
  @override
  Future<List<MegTechApp>> apps() async => const [
    MegTechApp(
      id: 'com.megtech.mahkama',
      name: 'محكمة',
      tagline: 'لعبة تحقيق جماعية: مين المذنب؟',
      icon: 'assets/megtech/icons/mahkama.png',
      playUrl: 'https://play.google.com/store/apps/details?id=m',
    ),
  ];
}

void main() {
  late _Launcher launcher;
  String? clipboard;

  setUp(() {
    launcher = _Launcher();
    sl
      ..registerSingleton<UrlLauncherDataSource>(launcher)
      ..registerSingleton(
        GetMoreAppsUseCase(_Repo(), selfId: 'com.megTech.screw_calculator'),
      );
    PackageInfo.setMockInitialValues(
      appName: 'Screw',
      packageName: 'com.megTech.screw_calculator',
      version: '2.1.1',
      buildNumber: '15',
      buildSignature: '',
    );
    clipboard = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'Clipboard.setData') {
            clipboard =
                (call.arguments as Map<Object?, Object?>)['text'] as String?;
          }
          return null;
        });
  });

  tearDown(() async {
    await sl.reset();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  Future<void> pump(WidgetTester tester, ThemeData theme) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        locale: const Locale('ar'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const AboutScreen(),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tapKey(WidgetTester tester, String key) async {
    final finder = find.byKey(ValueKey(key));
    await tester.scrollUntilVisible(finder, 120);
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  for (final (name, theme) in [
    ('light', AppTheme.light),
    ('dark', AppTheme.dark),
  ]) {
    testWidgets('shows app, developer and MegTech at 320×568 ($name)', (
      tester,
    ) async {
      await pump(tester, theme);
      expect(tester.takeException(), isNull);
      expect(find.text('الإصدار 2.1.1 (15)'), findsOneWidget);
      await tester.scrollUntilVisible(find.text(DeveloperInfo.title), 120);
      expect(find.text(DeveloperInfo.name), findsOneWidget);
      expect(find.text(DeveloperInfo.title), findsOneWidget);
      expect(find.byKey(const ValueKey('megtech-mark')), findsWidgets);

      await tester.scrollUntilVisible(find.text('محكمة'), 120);
      expect(find.text('تطبيقات تانية من MegTech'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('WhatsApp opens with the app and version prefilled', (
    tester,
  ) async {
    await pump(tester, AppTheme.light);
    await tapKey(tester, 'about-whatsapp');
    final url = Uri.parse(launcher.opened.single);
    expect(url.host, 'wa.me');
    expect(url.path, '/${DeveloperInfo.whatsappNumber}');
    expect(url.queryParameters['text'], contains('سكرو حاسبة'));
    expect(url.queryParameters['text'], contains('2.1.1'));
  });

  testWidgets('if WhatsApp will not open, the number is copied', (
    tester,
  ) async {
    await pump(tester, AppTheme.light);
    launcher.result = false;
    await tapKey(tester, 'about-suggest');
    expect(clipboard, DeveloperInfo.whatsappDisplay);
    expect(find.text('مقدرناش نفتح واتساب. الرقم اتنسخ.'), findsOneWidget);
  });

  testWidgets('tapping the e-mail copies it', (tester) async {
    await pump(tester, AppTheme.dark);
    await tapKey(tester, 'about-email');
    expect(clipboard, DeveloperInfo.email);
    expect(find.text('اتنسخ الإيميل'), findsOneWidget);
  });
}
