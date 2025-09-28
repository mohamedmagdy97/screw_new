import 'package:flutter/material.dart';

BoxDecoration customBoxDecoration({
  Color? color,
  double? radiusBottom,
  double? spreadRadius,
  double? blurRadius,
}) {
  return BoxDecoration(
    gradient: LinearGradient(
      colors: [
        Colors.purple.shade400.withOpacity(0.5),
        Colors.purple.shade800.withOpacity(0.25),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(16),
    boxShadow: const [
      BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, -2)),
    ],
  );
}
