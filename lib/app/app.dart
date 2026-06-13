import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:screw_calculator/app/di/service_locator.dart';
import 'package:screw_calculator/core/theme/app_theme.dart';
import 'package:screw_calculator/core/theme/theme_cubit.dart';
import 'package:screw_calculator/features/splash/presentation/screens/splash_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ThemeCubit>(
      create: (_) => sl<ThemeCubit>(),
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return ScreenUtilInit(
            designSize: const Size(414, 896),
            minTextAdapt: true,
            builder: (context, child) => Directionality(
              textDirection: TextDirection.rtl,
              child: MaterialApp(
                title: 'سكرو حاسبة',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.light,
                darkTheme: AppTheme.dark,
                themeMode: themeMode,
                home: const SplashScreen(),
              ),
            ),
          );
        },
      ),
    );
  }
}
