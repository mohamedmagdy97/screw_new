import 'package:flutter/material.dart';
import 'package:screw_calculator/core/theme/app_palette.dart';

part 'app_colors.dart';

part 'app_text_styles.dart';

/// Design tokens — مسافات وأنصاف أقطار وارتفاعات موحّدة عبر التطبيق.
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
}

abstract final class AppRadii {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double pill = 999;
}

/// مُنشئ الثيم الموحّد للتطبيق (فاتح + داكن) المبني على هوية اللون البنفسجي.
abstract final class AppTheme {
  static const String _fontFamily = AppFonts.regular;

  static ThemeData get light => _build(Brightness.light);

  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;
    final AppPalette p = isDark ? AppPalette.dark : AppPalette.light;

    final ColorScheme scheme =
        ColorScheme.fromSeed(
          seedColor: p.brand,
          brightness: brightness,
        ).copyWith(
          primary: p.brand,
          onPrimary: Colors.white,
          secondary: p.accent,
          onSecondary: isDark ? const Color(0xFF06222B) : Colors.white,
          surface: p.surface,
          onSurface: p.textPrimary,
          error: p.lose,
          outline: p.border,
        );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      fontFamily: _fontFamily,
      scaffoldBackgroundColor: p.screen,
      splashColor: p.brand.withValues(alpha: 0.12),
      extensions: <ThemeExtension<dynamic>>[p],
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: p.screen,
        surfaceTintColor: Colors.transparent,
        foregroundColor: p.textPrimary,
        titleTextStyle: TextStyle(
          color: p.textPrimary,
          fontSize: 20,
          fontFamily: AppFonts.bold,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: p.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
          side: BorderSide(color: p.border),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: p.surfaceElevated,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.xl),
          side: BorderSide(color: p.border),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: p.brand,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.md,
          ),
          textStyle: const TextStyle(fontFamily: AppFonts.bold, fontSize: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? p.surfaceElevated : p.surface,
        hintStyle: TextStyle(color: p.textSecondary),
        labelStyle: TextStyle(color: p.textSecondary),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: BorderSide(color: p.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: BorderSide(color: p.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: BorderSide(color: p.brand, width: 1.6),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: p.brand,
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
      ),
      dividerTheme: DividerThemeData(color: p.border, thickness: 1),
      iconTheme: IconThemeData(color: p.textPrimary),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: p.brand),
    );
  }
}

/// تدرّجات لونية مساعدة محفوظة للتوافق مع الكود القديم.
class AppStyle {
  static LinearGradient bgLinearGradientGray() {
    return const LinearGradient(
      begin: Alignment.centerRight,
      end: Alignment.centerLeft,
      colors: [Color.fromRGBO(90, 91, 92, 1.0), Color.fromRGBO(90, 91, 92, 1.0)],
    );
  }

  static LinearGradient bgLinearGradientBrand() {
    return const LinearGradient(
      colors: [Color.fromRGBO(192, 0, 111, 1), Color.fromRGBO(255, 14, 157, 1)],
    );
  }

  static LinearGradient bgLinearGradientBrandDrawerBt() {
    return const LinearGradient(
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      colors: [Color.fromRGBO(192, 0, 111, 1), Color.fromRGBO(255, 14, 157, 1)],
    );
  }

  static LinearGradient bgLinearGradientDrawer() {
    return const LinearGradient(
      begin: Alignment.bottomCenter,
      end: Alignment.center,
      stops: [0.0, 0.6],
      colors: [Color.fromRGBO(0, 0, 0, 0.03), Color.fromRGBO(0, 0, 0, 0)],
    );
  }

  static LinearGradient bgLinearGradientLoader() {
    return const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color.fromRGBO(1, 6, 0, 0.15), Color.fromRGBO(0, 0, 0, 0)],
    );
  }

  static LinearGradient bgLinearGradientBrand2() {
    return const LinearGradient(
      begin: Alignment.centerRight,
      end: Alignment.centerLeft,
      colors: [Color.fromRGBO(192, 0, 111, 1), Color.fromRGBO(255, 14, 157, 1)],
    );
  }

  static LinearGradient get whiteGradient {
    return const LinearGradient(colors: [Colors.white, Colors.white]);
  }
}
