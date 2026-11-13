import 'dart:math';

/// أكواد اللعب لايف: 6 حروف/أرقام سهلة القراية (من غير O/0 و I/1/L).
abstract final class LiveCode {
  static const String alphabet = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';
  static const int length = 6;

  /// اللي بيتكتب في الـ QR: `screwlive:ABC123`.
  static const String qrPrefix = 'screwlive:';

  static String generate([Random? random]) {
    final r = random ?? Random.secure();
    return String.fromCharCodes(
      List.generate(
        length,
        (_) => alphabet.codeUnitAt(r.nextInt(alphabet.length)),
      ),
    );
  }

  static String qrData(String code) => '$qrPrefix$code';

  /// ينضّف المدخل (كود مكتوب أو محتوى QR) ويرجّع الكود، أو null لو مش صالح.
  static String? parse(String? input) {
    if (input == null) return null;
    var s = input.trim();
    if (s.toLowerCase().startsWith(qrPrefix)) {
      s = s.substring(qrPrefix.length);
    }
    s = s.toUpperCase().replaceAll(RegExp(r'[\s-]'), '');
    if (s.length != length) return null;
    for (final c in s.codeUnits) {
      if (!alphabet.codeUnits.contains(c)) return null;
    }
    return s;
  }
}
