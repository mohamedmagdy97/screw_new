// يولّد أصول الهوية (أيقونات iOS/Android + lockup + لوحة الهوية).
//
// التشغيل:  flutter test tool/render_brand_test.dart
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'brand/logo_options.dart';
import 'brand/logo_painter.dart';

Future<void> _loadFont(String family, String path) async {
  final bytes = File(path).readAsBytesSync();
  final loader = FontLoader(family)
    ..addFont(Future.value(ByteData.sublistView(Uint8List.fromList(bytes))));
  await loader.load();
}

Future<Uint8List> _render(
  int w,
  int h,
  void Function(ui.Canvas canvas, ui.Size size) draw,
) async {
  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(recorder);
  draw(canvas, ui.Size(w.toDouble(), h.toDouble()));
  final image = await recorder.endRecording().toImage(w, h);
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  return data!.buffer.asUint8List();
}

void _write(String path, Uint8List bytes) {
  File(path)
    ..createSync(recursive: true)
    ..writeAsBytesSync(bytes);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('render brand assets', () async {
    await _loadFont('JannaLT-Bold', 'assets/fonts/JannaLT-Bold.ttf');
    await _loadFont('JannaLT-Regular', 'assets/fonts/JannaLT-Regular.ttf');

    await tester(() async {
      // 1) أيقونة مصدر 1024 (مربعة كاملة، بلا شفافية — مطلوب لـ iOS).
      final icon1024 = await _render(
        1024,
        1024,
        (c, s) => paintOptionCard(c, s.width),
      );
      _write('design/brand/app-icon-1024.png', icon1024);

      // 2) أيقونات iOS بكل المقاسات من Contents.json.
      final iosDir = 'ios/Runner/Assets.xcassets/AppIcon.appiconset';
      final reg = RegExp(r'Icon-App-([\d.]+)x[\d.]+@(\d)x\.png');
      for (final f in Directory(iosDir).listSync().whereType<File>()) {
        final m = reg.firstMatch(f.uri.pathSegments.last);
        if (m == null) continue;
        final px = (double.parse(m.group(1)!) * int.parse(m.group(2)!)).round();
        _write(
          f.path,
          await _render(px, px, (c, s) => paintOptionCard(c, s.width)),
        );
      }

      // 3) أيقونات Android (زوايا دائرية شفافة).
      const densities = {
        'mdpi': 48,
        'hdpi': 72,
        'xhdpi': 96,
        'xxhdpi': 144,
        'xxxhdpi': 192,
      };
      densities.forEach((d, px) async {});
      for (final e in densities.entries) {
        final bytes = await _render(
          e.value,
          e.value,
          (c, s) => paintOptionCard(c, s.width, rounded: true),
        );
        for (final name in ['ic_launcher', 'launcher_icon']) {
          _write('android/app/src/main/res/mipmap-${e.key}/$name.png', bytes);
        }
      }

      // 3b) علامة فقط (بدون نص) لاستخدامها داخل بطاقات المشاركة.
      _write(
        'assets/icons/mark.png',
        await _render(
          512,
          512,
          (c, s) => paintOptionCard(c, s.width, rounded: true),
        ),
      );

      // 4) Lockup شفاف يُستخدم داخل التطبيق (splash/drawer).
      _write(
        'assets/icons/icon.png',
        await _render(
          648,
          761,
          (c, s) => paintLockup(
            c,
            s,
            textColor: BrandColors.violetDeep,
            icon: paintOptionCard,
          ),
        ),
      );
      // نسخة بيضاء النص للخلفيات الداكنة.
      _write(
        'design/brand/lockup-dark.png',
        await _render(
          648,
          761,
          (c, s) => paintLockup(
            c,
            s,
            textColor: const ui.Color(0xFFF5F2FF),
            icon: paintOptionCard,
          ),
        ),
      );
      _write(
        'design/brand/lockup-light.png',
        await _render(
          648,
          761,
          (c, s) => paintLockup(
            c,
            s,
            textColor: BrandColors.violetDeep,
            icon: paintOptionCard,
          ),
        ),
      );
    });
  });
}

Future<void> tester(Future<void> Function() body) async {
  // دالة مساعدة صغيرة لتجميع العمل؛ تعمل داخل نفس الـ zone.
  await body();
}
