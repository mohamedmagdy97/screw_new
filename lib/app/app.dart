import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:screw_calculator/app/di/service_locator.dart';
import 'package:screw_calculator/core/l10n/locale_cubit.dart';
import 'package:screw_calculator/core/theme/app_theme.dart';
import 'package:screw_calculator/core/theme/theme_cubit.dart';
import 'package:screw_calculator/features/splash/presentation/screens/splash_screen.dart';
import 'package:screw_calculator/l10n/app_localizations.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(create: (_) => sl<ThemeCubit>()),
        BlocProvider<LocaleCubit>(create: (_) => sl<LocaleCubit>()),
      ],
      child: BlocBuilder<LocaleCubit, Locale>(
        builder: (context, locale) {
          return BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, themeMode) {
              return ScreenUtilInit(
                designSize: const Size(414, 896),
                minTextAdapt: true,
                builder: (context, child) => MaterialApp(
                  onGenerateTitle: (context) =>
                      AppLocalizations.of(context).appName,
                  debugShowCheckedModeBanner: false,
                  theme: AppTheme.light,
                  darkTheme: AppTheme.dark,
                  themeMode: themeMode,
                  locale: locale,
                  supportedLocales: AppLocalizations.supportedLocales,
                  localizationsDelegates:
                      AppLocalizations.localizationsDelegates,
                  builder: (context, child) {
                    // نحدّ تكبير الخط (0.9–1.3) كي لا ينكسر التصميم مع الخطوط الكبيرة.
                    final mq = MediaQuery.of(context);
                    return Directionality(
                      // هيكل الواجهة LTR كما صُمّم؛ المحتوى يتبع اللغة (ContentDirection).
                      textDirection: TextDirection.ltr,
                      child: MediaQuery(
                        data: mq.copyWith(
                          textScaler: mq.textScaler.clamp(
                            minScaleFactor: 0.9,
                            maxScaleFactor: 1.3,
                          ),
                        ),
                        child: child ?? const SizedBox.shrink(),
                      ),
                    );
                  },
                  home: const SplashScreen(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
