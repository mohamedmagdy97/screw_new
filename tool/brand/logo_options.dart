// اقتراحات بديلة للأيقونة (تقارب فئة لعبة سكرو العربية دون نسخ هوية أي تطبيق).
import 'dart:math' as math;

import 'package:flutter/painting.dart';

import 'logo_painter.dart';

void _background(Canvas canvas, double size) {
  final rect = Rect.fromLTWH(0, 0, size, size);
  canvas.drawRect(
    rect,
    Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFA855F7), BrandColors.indigo],
      ).createShader(rect),
  );
  canvas.drawRect(
    rect,
    Paint()
      ..shader = const RadialGradient(
        center: Alignment(-0.5, -0.7),
        radius: 0.9,
        colors: [Color(0x44FFFFFF), Color(0x00FFFFFF)],
      ).createShader(rect),
  );
}

/// كلمة «سكرو» بشكل ملصق: حشوة فاتحة + حد داكن + ظل سماوي مُزاح.
void _stickerWord(
  Canvas canvas,
  String text,
  Offset center,
  double fontSize, {
  double rotation = 0,
}) {
  TextPainter make(Paint? fg, Color? color) {
    return TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontFamily: 'JannaLT-Bold',
          fontSize: fontSize,
          height: 1,
          color: fg == null ? color : null,
          foreground: fg,
        ),
      ),
      textDirection: TextDirection.rtl,
    )..layout();
  }

  final shadow = make(null, BrandColors.cyan);
  final outline = make(
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = fontSize * 0.16
      ..strokeJoin = StrokeJoin.round
      ..color = BrandColors.ink,
    null,
  );
  final fill = make(null, const Color(0xFFFFFFFF));
  canvas.save();
  canvas.translate(center.dx, center.dy);
  canvas.rotate(rotation);
  final o = Offset(-fill.width / 2, -fill.height / 2);
  // ظل سماوي بسيط.
  final shadowOutline = make(
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = fontSize * 0.16
      ..strokeJoin = StrokeJoin.round
      ..color = BrandColors.cyan,
    null,
  );
  shadowOutline.paint(canvas, o + Offset(fontSize * 0.05, fontSize * 0.07));
  outline.paint(canvas, o);
  fill.paint(canvas, o);
  shadow; // (غير مستخدم — يبقي التوقيع ثابتًا)
  canvas.restore();
}

/// A) الكلمة هي البطل — الأقرب لأسلوب ألعاب سكرو العربية.
void paintOptionWordmark(Canvas canvas, double size) {
  _background(canvas, size);
  _stickerWord(
    canvas,
    'سكرو',
    Offset(size * 0.5, size * 0.45),
    size * 0.34,
    rotation: -0.07,
  );
  // شارة البرغي الصغيرة أسفل اليمين.
  paintScrewHead(canvas, Offset(size * 0.77, size * 0.8), size * 0.1);
}

/// B) هجين: رأس البرغي أعلى + كلمة صغيرة أسفل.
void paintOptionHybrid(Canvas canvas, double size) {
  _background(canvas, size);
  paintScrewHead(canvas, Offset(size * 0.5, size * 0.37), size * 0.2);
  _stickerWord(canvas, 'سكرو', Offset(size * 0.5, size * 0.74), size * 0.26);
}

/// C) ورقة لعب مائلة بعلامة «+» وكلمة «سكرو».
/// الأيقونة المعتمدة: ورقة لعب مائلة بعلامة «+» وكلمة «سكرو».
void paintOptionCard(Canvas canvas, double size, {bool rounded = false}) {
  if (rounded) {
    canvas.clipRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size, size),
        Radius.circular(size * 0.225),
      ),
    );
  }
  _background(canvas, size);
  final c = Offset(size * 0.5, size * 0.42);
  canvas.save();
  canvas.translate(c.dx, c.dy);
  canvas.rotate(-math.pi / 16);
  final card = RRect.fromRectAndRadius(
    Rect.fromCenter(
      center: Offset.zero,
      width: size * 0.42,
      height: size * 0.56,
    ),
    Radius.circular(size * 0.05),
  );
  canvas.drawRRect(
    card.shift(Offset(0, size * 0.02)),
    Paint()
      ..color = const Color(0x66000000)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, size * 0.025),
  );
  canvas.drawRRect(card, Paint()..color = const Color(0xFFFFFFFF));
  paintScrewHead(canvas, Offset.zero, size * 0.13);
  canvas.restore();
  _stickerWord(canvas, 'سكرو', Offset(size * 0.5, size * 0.84), size * 0.2);
}
