// أدوات رسم هوية "سكرو حاسبة": علامة التطبيق (screw head) والـ lockup.
//
// تُستخدم من `tool/render_brand_test.dart` لتوليد أيقونات التطبيق ولوحة الهوية.
import 'dart:math' as math;

import 'package:flutter/painting.dart';

/// ألوان الهوية (مطابقة لـ AppPalette في التطبيق).
abstract final class BrandColors {
  static const Color violet = Color(0xFF8B5CF6);
  static const Color violetDeep = Color(0xFF7C3AED);
  static const Color indigo = Color(0xFF4F46E5);
  static const Color ink = Color(0xFF2E1065);
  static const Color cyan = Color(0xFF22D3EE);
  static const Color gold = Color(0xFFFBBF24);
  static const Color night = Color(0xFF0E0B16);
  static const Color cloud = Color(0xFFF3F0FB);
}

/// يرسم أيقونة التطبيق داخل مربع [size]. [rounded] يضيف زوايا دائرية شفافة.
void paintAppIcon(Canvas canvas, double size, {bool rounded = false}) {
  final rect = Rect.fromLTWH(0, 0, size, size);
  if (rounded) {
    canvas.clipRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(size * 0.225)),
    );
  }

  // الخلفية: تدرّج بنفسجي → إنديجو.
  canvas.drawRect(
    rect,
    Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [BrandColors.violet, BrandColors.indigo],
      ).createShader(rect),
  );
  // لمعة خفيفة أعلى اليسار.
  canvas.drawRect(
    rect,
    Paint()
      ..shader = const RadialGradient(
        center: Alignment(-0.6, -0.7),
        radius: 0.9,
        colors: [Color(0x40FFFFFF), Color(0x00FFFFFF)],
      ).createShader(rect),
  );

  // وهج سماوي خفيف أسفل اليمين لعمق بصري.
  canvas.drawRect(
    rect,
    Paint()
      ..shader = const RadialGradient(
        center: Alignment(0.9, 0.95),
        radius: 0.8,
        colors: [Color(0x3322D3EE), Color(0x0022D3EE)],
      ).createShader(rect),
  );

  paintScrewHead(canvas, Offset(size / 2, size / 2), size * 0.31);
}

/// رأس برغي فيليبس: دائرة بيضاء بعلامة "+" ولمسة سماوية.
void paintScrewHead(Canvas canvas, Offset c, double r) {
  // ظل ناعم.
  canvas.drawCircle(
    c.translate(0, r * 0.12),
    r,
    Paint()
      ..color = const Color(0x55000000)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.18),
  );
  // جسم الرأس.
  final headRect = Rect.fromCircle(center: c, radius: r);
  canvas.drawCircle(
    c,
    r,
    Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFFFFFFF), Color(0xFFE9E3FF)],
      ).createShader(headRect),
  );
  // حلقة داخلية.
  canvas.drawCircle(
    c,
    r * 0.84,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.07
      ..color = const Color(0x337C3AED),
  );
  // علامة "+" (برغي فيليبس = إضافة نقاط).
  final arm = r * 0.30;
  final len = r * 1.08;
  final crossPaint = Paint()
    ..shader = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [BrandColors.violetDeep, BrandColors.ink],
    ).createShader(headRect);
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromCenter(center: c, width: len, height: arm),
      Radius.circular(arm * 0.45),
    ),
    crossPaint,
  );
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromCenter(center: c, width: arm, height: len),
      Radius.circular(arm * 0.45),
    ),
    crossPaint,
  );
  // لمعة سماوية صغيرة على الحافة (لمسة الهوية).
  canvas.drawArc(
    Rect.fromCircle(center: c, radius: r * 0.92),
    -math.pi * 0.95,
    math.pi * 0.35,
    false,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = r * 0.075
      ..color = BrandColors.cyan,
  );
}

/// يرسم نصًا في [center] أفقيًا.
void paintText(
  Canvas canvas,
  String text,
  Offset center, {
  required double fontSize,
  required Color color,
  String fontFamily = 'JannaLT-Bold',
  double letterSpacing = 0,
  TextDirection direction = TextDirection.rtl,
}) {
  final tp = TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(
        fontFamily: fontFamily,
        fontSize: fontSize,
        color: color,
        letterSpacing: letterSpacing,
      ),
    ),
    textDirection: direction,
  )..layout();
  tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
}

/// Lockup رأسي شفاف: العلامة + "سكرو حاسبة" + "SCREW CALCULATOR".
void paintLockup(
  Canvas canvas,
  Size size, {
  required Color textColor,
  void Function(Canvas canvas, double size, {bool rounded})? icon,
}) {
  final markSize = size.width * 0.62;
  final markRect = Rect.fromCenter(
    center: Offset(size.width / 2, markSize / 2 + size.height * 0.04),
    width: markSize,
    height: markSize,
  );
  canvas.save();
  canvas.translate(markRect.left, markRect.top);
  (icon ?? paintAppIcon)(canvas, markSize, rounded: true);
  canvas.restore();

  paintText(
    canvas,
    'سكرو حاسبة',
    Offset(size.width / 2, markRect.bottom + size.height * 0.13),
    fontSize: size.width * 0.15,
    color: textColor,
  );
  paintText(
    canvas,
    'SCREW CALCULATOR',
    Offset(size.width / 2, markRect.bottom + size.height * 0.255),
    fontSize: size.width * 0.052,
    color: BrandColors.violet,
    fontFamily: 'JannaLT-Regular',
    letterSpacing: size.width * 0.012,
    direction: TextDirection.ltr,
  );
}
