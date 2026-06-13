import 'package:flutter/material.dart';

/// نظام ألوان دلالي (semantic) متكيّف مع الوضع الفاتح/الداكن.
///
/// الشاشات تستخدم هذه الرموز بدل الألوان الثابتة (مثل `AppColors.bg`) حتى
/// تتكيّف تلقائيًا. الوصول عبر `context.palette`.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.brand,
    required this.brandSoft,
    required this.accent,
    required this.screen,
    required this.surface,
    required this.surfaceElevated,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.win,
    required this.lose,
    required this.brandGradient,
  });

  /// اللون البنفسجي الأساسي (الهوية).
  final Color brand;

  /// بنفسجي فاتح للنصوص/الإبرازات الثانوية.
  final Color brandSoft;

  /// اللون المساعد العصري (سماوي/نيون).
  final Color accent;

  /// خلفية الشاشة.
  final Color screen;

  /// أسطح الكروت.
  final Color surface;

  /// أسطح مرتفعة (dialogs / عناصر بارزة).
  final Color surfaceElevated;

  /// لون الحدود الخفيفة.
  final Color border;

  /// لون النص الأساسي.
  final Color textPrimary;

  /// لون النص الثانوي.
  final Color textSecondary;

  /// لون الفائز / النجاح.
  final Color win;

  /// لون الخاسر / الخطأ.
  final Color lose;

  /// تدرّج الهوية (للأزرار والعناوين).
  final Gradient brandGradient;

  // ===== Dark (gaming) =====
  static const AppPalette dark = AppPalette(
    brand: Color(0xFF8B5CF6),
    brandSoft: Color(0xFFC4B5FD),
    accent: Color(0xFF22D3EE),
    screen: Color(0xFF0E0B16),
    surface: Color(0xFF1A1426),
    surfaceElevated: Color(0xFF241B33),
    border: Color(0xFF332A47),
    textPrimary: Color(0xFFF5F2FF),
    textSecondary: Color(0xFFA99FC4),
    win: Color(0xFF34D399),
    lose: Color(0xFFFB7185),
    brandGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
    ),
  );

  // ===== Light (gaming, high-contrast) =====
  static const AppPalette light = AppPalette(
    brand: Color(0xFF7C3AED),
    brandSoft: Color(0xFF7C3AED),
    accent: Color(0xFF0891B2),
    screen: Color(0xFFF3F0FB),
    surface: Color(0xFFFFFFFF),
    surfaceElevated: Color(0xFFFFFFFF),
    border: Color(0xFFE6E0F2),
    textPrimary: Color(0xFF1E1733),
    textSecondary: Color(0xFF6E6589),
    win: Color(0xFF059669),
    lose: Color(0xFFE11D48),
    brandGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
    ),
  );

  @override
  AppPalette copyWith({
    Color? brand,
    Color? brandSoft,
    Color? accent,
    Color? screen,
    Color? surface,
    Color? surfaceElevated,
    Color? border,
    Color? textPrimary,
    Color? textSecondary,
    Color? win,
    Color? lose,
    Gradient? brandGradient,
  }) {
    return AppPalette(
      brand: brand ?? this.brand,
      brandSoft: brandSoft ?? this.brandSoft,
      accent: accent ?? this.accent,
      screen: screen ?? this.screen,
      surface: surface ?? this.surface,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      border: border ?? this.border,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      win: win ?? this.win,
      lose: lose ?? this.lose,
      brandGradient: brandGradient ?? this.brandGradient,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return AppPalette(
      brand: Color.lerp(brand, other.brand, t)!,
      brandSoft: Color.lerp(brandSoft, other.brandSoft, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      screen: Color.lerp(screen, other.screen, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceElevated: Color.lerp(surfaceElevated, other.surfaceElevated, t)!,
      border: Color.lerp(border, other.border, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      win: Color.lerp(win, other.win, t)!,
      lose: Color.lerp(lose, other.lose, t)!,
      brandGradient: Gradient.lerp(brandGradient, other.brandGradient, t)!,
    );
  }
}

/// وصول مريح للـ palette من الـ context.
extension AppPaletteX on BuildContext {
  AppPalette get palette =>
      Theme.of(this).extension<AppPalette>() ?? AppPalette.dark;
}
