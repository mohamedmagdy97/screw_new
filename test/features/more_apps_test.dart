import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:screw_calculator/core/constants/app_links.dart';
import 'package:screw_calculator/core/theme/app_theme.dart';
import 'package:screw_calculator/features/more_apps/data/more_apps_json.dart';
import 'package:screw_calculator/features/more_apps/data/repositories/more_apps_repository_impl.dart';
import 'package:screw_calculator/features/more_apps/domain/entities/megtech_app.dart';
import 'package:screw_calculator/features/more_apps/domain/repositories/more_apps_repository.dart';
import 'package:screw_calculator/features/more_apps/domain/usecases/get_more_apps_usecase.dart';
import 'package:screw_calculator/features/more_apps/presentation/widgets/more_apps_section.dart';
import 'package:screw_calculator/l10n/app_localizations.dart';

/// يقرأ الأصول من ملفات المشروع مباشرة (المسار = مفتاح الـ asset).
class _FileBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async =>
      ByteData.sublistView(File(key).readAsBytesSync());
}

class _Repo implements MoreAppsRepository {
  _Repo(this._apps);

  final List<MegTechApp>? _apps;

  @override
  Future<List<MegTechApp>> apps() async =>
      _apps ?? (throw const FormatException('broken'));
}

String _one(Map<String, Object?> app) => jsonEncode({
  'version': 1,
  'apps': [app],
});

const _self = MegTechApp(
  id: 'com.megTech.screw_calculator',
  name: 'سكرو حاسبة',
  tagline: 't',
  icon: 'i',
  playUrl: 'https://play.google.com/x',
  appStoreUrl: 'https://apps.apple.com/x',
);
const _androidOnly = MegTechApp(
  id: 'com.megtech.a',
  name: 'A',
  tagline: 't',
  icon: 'i',
  playUrl: 'https://play.google.com/a',
);
const _both = MegTechApp(
  id: 'com.megtech.b',
  name: 'B',
  tagline: 't',
  icon: 'i',
  playUrl: 'https://play.google.com/b',
  appStoreUrl: 'https://apps.apple.com/b',
);

void main() {
  group('GetMoreAppsUseCase', () {
    test('hides this app (any letter case), keeps catalogue order', () async {
      final get = GetMoreAppsUseCase(
        _Repo(const [_androidOnly, _self, _both]),
        selfId: 'COM.MEGTECH.Screw_Calculator',
      );
      expect(await get(AppPlatform.android), [_androidOnly, _both]);
    });

    test('on iPhone, Android-only apps are left out (Apple 2.3.10)', () async {
      final get = GetMoreAppsUseCase(
        _Repo(const [_androidOnly, _both]),
        selfId: AppLinks.androidPackage,
      );
      final apps = await get(AppPlatform.ios);
      expect(apps, [_both]);
      expect(
        apps.map((a) => a.linkFor(AppPlatform.ios)),
        everyElement(startsWith('https://apps.apple.com/')),
      );
    });

    test('a failure is an empty list, so the section stays hidden', () async {
      final get = GetMoreAppsUseCase(_Repo(null), selfId: 'x');
      expect(await get(AppPlatform.android), isEmpty);
    });
  });

  group('MoreAppsJson', () {
    String icon(String name) => 'icons/$name';

    test('rejects non-store and non-https links', () {
      for (final bad in [
        'http://play.google.com/x',
        'https://evil.com/x',
        'https://play.google.com.evil.com/x',
      ]) {
        expect(
          MoreAppsJson.parse(
            _one({
              'id': 'a',
              'name': 'A',
              'tagline': 't',
              'icon': 'a.png',
              'play': bad,
            }),
            iconPath: icon,
          ),
          isEmpty,
          reason: bad,
        );
      }
    });

    test('keeps an app with one valid store and resolves its icon', () {
      final ok = MoreAppsJson.parse(
        _one({
          'id': 'a',
          'name': 'A',
          'tagline': 't',
          'icon': 'a.png',
          'play': 'https://evil.com/x',
          'appStore': 'https://apps.apple.com/app/id1',
        }),
        iconPath: icon,
      );
      expect(ok.single.icon, 'icons/a.png');
      expect(ok.single.playUrl, isNull);
      expect(ok.single.appStoreUrl, 'https://apps.apple.com/app/id1');
    });

    test('a broken file throws', () {
      expect(
        () => MoreAppsJson.parse('nope', iconPath: icon),
        throwsFormatException,
      );
      expect(
        () => MoreAppsJson.parse('{"apps": 3}', iconPath: icon),
        throwsFormatException,
      );
    });
  });

  group('MoreAppsRepositoryImpl', () {
    test(
      'offline: falls back to the bundled list, whose icons all ship',
      () async {
        var calls = 0;
        final repo = MoreAppsRepositoryImpl(
          bundle: _FileBundle(),
          fetch: (_) async {
            calls++;
            throw const SocketException('offline');
          },
        );
        final apps = await repo.apps();
        expect(
          apps.map((a) => a.id),
          containsAll(<String>[
            'com.megtech.mahkama',
            'com.megtech.hiddentruth',
            'com.megtech.clenova',
            AppLinks.androidPackage,
          ]),
        );
        for (final app in apps) {
          expect(File(app.icon).existsSync(), isTrue, reason: app.icon);
        }
        // النسخة المضمّنة لا تُخزَّن: المرة الجاية نجرب الأونلاين تاني.
        await repo.apps();
        expect(calls, 2);
      },
    );

    test('a bad online file also falls back to the bundled list', () async {
      final repo = MoreAppsRepositoryImpl(
        bundle: _FileBundle(),
        fetch: (_) async => '<html>',
      );
      expect(await repo.apps(), isNotEmpty);
    });

    test('online wins, with icons next to the JSON, and is cached', () async {
      var calls = 0;
      final repo = MoreAppsRepositoryImpl(
        bundle: _FileBundle(),
        fetch: (_) async {
          calls++;
          return _one({
            'id': 'n',
            'name': 'N',
            'tagline': 't',
            'icon': 'n.png',
            'play': 'https://play.google.com/n',
          });
        },
      );
      final apps = await repo.apps();
      expect(
        apps.single.icon,
        'https://el-mahkama.web.app/megtech/icons/n.png',
      );
      await repo.apps();
      expect(calls, 1);
    });

    test('fetchCatalogueText: https only, 200 only, size cap', () async {
      final url = MoreAppsRepositoryImpl.defaultUrl;
      final ok = MockClient(
        (_) async => http.Response.bytes(utf8.encode('{"س": 1}'), 200),
      );
      expect(await fetchCatalogueText(url, client: ok), '{"س": 1}');
      expect(
        () => fetchCatalogueText(
          Uri.parse('http://el-mahkama.web.app/megtech/apps.json'),
          client: ok,
        ),
        throwsFormatException,
      );
      await expectLater(
        fetchCatalogueText(
          url,
          client: MockClient((_) async => http.Response('no', 404)),
        ),
        throwsA(isA<http.ClientException>()),
      );
      await expectLater(
        fetchCatalogueText(url, client: ok, maxBytes: 3),
        throwsFormatException,
      );
    });
  });

  group('MoreAppsSection', () {
    const apps = [
      MegTechApp(
        id: 'com.megtech.mahkama',
        name: 'محكمة',
        tagline: 'لعبة تحقيق جماعية: مين المذنب؟',
        icon: 'assets/megtech/icons/mahkama.png',
        playUrl: 'https://play.google.com/store/apps/details?id=m',
        appStoreUrl: 'https://apps.apple.com/app/id6825098362',
      ),
      MegTechApp(
        id: 'com.megtech.hiddentruth',
        name: 'الحقيقة المجهولة',
        tagline: 'اكتب حكاية حقيقية في السر وخلّي صحابك يخمّنوا مين صاحبها',
        icon: 'assets/megtech/icons/hiddentruth.png',
        playUrl: 'https://play.google.com/store/apps/details?id=h',
      ),
      MegTechApp(
        id: 'com.megtech.clenova',
        name: 'Clenova',
        tagline: 'نضّف موبايلك من الصور والملفات المتكررة',
        icon: 'assets/megtech/icons/clenova.png',
        playUrl: 'https://play.google.com/store/apps/details?id=c',
      ),
    ];

    Future<List<String>> pump(
      WidgetTester tester, {
      required ThemeData theme,
      TargetPlatform platform = TargetPlatform.android,
      List<MegTechApp> list = apps,
    }) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final opened = <String>[];
      final get = GetMoreAppsUseCase(
        _Repo(list),
        selfId: AppLinks.androidPackage,
      );
      await tester.pumpWidget(
        MaterialApp(
          theme: theme.copyWith(platform: platform),
          locale: const Locale('ar'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Scaffold(
            // نفس عرض القائمة الجانبية على شاشة 320 (84%).
            body: Align(
              alignment: AlignmentDirectional.topStart,
              child: SizedBox(
                width: 320 * 0.84,
                child: SingleChildScrollView(
                  child: MoreAppsSection(
                    load: get.call,
                    open: (url) async => opened.add(url),
                    allAppsUrl: AppLinks.megtechApps,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      return opened;
    }

    for (final (name, theme) in [
      ('light', AppTheme.light),
      ('dark', AppTheme.dark),
    ]) {
      testWidgets('fits 320×568 in $name theme and opens Play', (tester) async {
        final opened = await pump(tester, theme: theme);
        expect(tester.takeException(), isNull);
        expect(find.text('تطبيقات تانية من MegTech'), findsOneWidget);
        expect(find.text('Clenova'), findsOneWidget);
        expect(find.text('نزّل'), findsNWidgets(3));

        await tester.tap(
          find.byKey(const ValueKey('more-app-com.megtech.clenova')),
        );
        await tester.tap(find.byKey(const ValueKey('more-apps-all')));
        expect(opened, [
          'https://play.google.com/store/apps/details?id=c',
          'https://el-mahkama.web.app/megtech/',
        ]);
      });
    }

    testWidgets('iPhone: App Store apps only, no Google Play link', (
      tester,
    ) async {
      final opened = await pump(
        tester,
        theme: AppTheme.dark,
        platform: TargetPlatform.iOS,
      );
      expect(find.text('محكمة'), findsOneWidget);
      expect(find.text('Clenova'), findsNothing);
      expect(find.text('الحقيقة المجهولة'), findsNothing);

      await tester.tap(
        find.byKey(const ValueKey('more-app-com.megtech.mahkama')),
      );
      await tester.tap(find.byKey(const ValueKey('more-apps-all')));
      expect(opened, [
        'https://apps.apple.com/app/id6825098362',
        'https://el-mahkama.web.app/megtech/?p=ios',
      ]);
      expect(opened.any((url) => url.contains('play.google')), isFalse);
    });

    testWidgets('nothing to show: the section is hidden', (tester) async {
      await pump(tester, theme: AppTheme.light, list: const []);
      expect(find.byType(Material), findsOneWidget); // Scaffold فقط
      expect(find.text('تطبيقات تانية من MegTech'), findsNothing);
    });
  });
}
