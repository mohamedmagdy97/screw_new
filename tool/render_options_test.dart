// يولّد لوحة مقارنة لاقتراحات الأيقونة في design/brand/options.
//
// التشغيل:  flutter test tool/render_options_test.dart
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'brand/logo_options.dart';
import 'brand/logo_painter.dart';

Future<void> _loadFont(String family, String path) async {
  final loader = FontLoader(family)
    ..addFont(Future.value(ByteData.sublistView(File(path).readAsBytesSync())));
  await loader.load();
}

Future<Uint8List> _png(int w, int h, void Function(ui.Canvas) draw) async {
  final recorder = ui.PictureRecorder();
  draw(ui.Canvas(recorder));
  final image = await recorder.endRecording().toImage(w, h);
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  return data!.buffer.asUint8List();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('render icon options', () async {
    await _loadFont('JannaLT-Bold', 'assets/fonts/JannaLT-Bold.ttf');
    await _loadFont('JannaLT-Regular', 'assets/fonts/JannaLT-Regular.ttf');

    final painters = <String, void Function(ui.Canvas, double)>{
      'current': paintAppIcon,
      'A-wordmark': paintOptionWordmark,
      'B-hybrid': paintOptionHybrid,
      'C-card': paintOptionCard,
    };

    for (final e in painters.entries) {
      File('design/brand/options/${e.key}.png')
        ..createSync(recursive: true)
        ..writeAsBytesSync(
          await _png(1024, 1024, (c) {
            c.clipRRect(
              ui.RRect.fromRectAndRadius(
                const ui.Rect.fromLTWH(0, 0, 1024, 1024),
                const ui.Radius.circular(230),
              ),
            );
            e.value(c, 1024);
          }),
        );
    }

    // لوحة مقارنة: 4 أيقونات بحجم المتجر الفعلي (≈120) + حجم كبير.
    const cell = 300.0;
    final sheet = await _png(1280, 440, (c) {
      c.drawRect(
        const ui.Rect.fromLTWH(0, 0, 1280, 440),
        ui.Paint()..color = const ui.Color(0xFFF3F0FB),
      );
      var x = 20.0;
      for (final e in painters.entries) {
        c.save();
        c.translate(x, 20);
        c.clipRRect(
          ui.RRect.fromRectAndRadius(
            const ui.Rect.fromLTWH(0, 0, cell, cell),
            const ui.Radius.circular(cell * 0.225),
          ),
        );
        e.value(c, cell);
        c.restore();
        // نسخة صغيرة بحجم أيقونة الشاشة الرئيسية.
        c.save();
        c.translate(x + 90, 340);
        c.clipRRect(
          ui.RRect.fromRectAndRadius(
            const ui.Rect.fromLTWH(0, 0, 60, 60),
            const ui.Radius.circular(60 * 0.225),
          ),
        );
        e.value(c, 60);
        c.restore();
        x += cell + 20;
      }
    });
    File('design/brand/options/comparison.png').writeAsBytesSync(sheet);
  });
}
