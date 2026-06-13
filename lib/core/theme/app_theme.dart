import 'package:flutter/material.dart';

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

    final ColorScheme scheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.mainColor,
          brightness: brightness,
        ).copyWith(
          primary: AppColors.mainColor,
          secondary: AppColors.secondaryColor,
          surface: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        );

    final Color scaffoldBg = isDark ? AppColors.bg : AppColors.bgLight;
    final Color onSurface = isDark ? AppColors.white : AppColors.textColorTitle;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      fontFamily: _fontFamily,
      scaffoldBackgroundColor: scaffoldBg,
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.mainColor,
        foregroundColor: AppColors.white,
        titleTextStyle: TextStyle(
          color: AppColors.white,
          fontSize: 20,
          fontFamily: AppFonts.bold,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.xl),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.mainColor,
          foregroundColor: AppColors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? AppColors.surfaceDark : AppColors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: BorderSide(color: AppColors.mainColor.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: const BorderSide(color: AppColors.mainColor, width: 1.6),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.mainColor,
        contentTextStyle: const TextStyle(color: AppColors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: onSurface.withValues(alpha: 0.12),
        thickness: 1,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.mainColor,
      ),
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
