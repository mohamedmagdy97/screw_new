import 'package:flutter/material.dart';

Route<T> buildFancyRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    transitionDuration: const Duration(milliseconds: 400),
    pageBuilder: (_, animation, secondaryAnimation) => page,
    transitionsBuilder: (_, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );

      final offsetAnimation =
      Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
          .animate(curved);

      final scaleAnimation = Tween<double>(begin: 0.95, end: 1).animate(curved);
      final fadeAnimation = Tween<double>(begin: 0, end: 1).animate(curved);

      return SlideTransition(
        position: offsetAnimation,
        child: ScaleTransition(
          scale: scaleAnimation,
          child: FadeTransition(opacity: fadeAnimation, child: child),
        ),
      );
    },
  );
}
