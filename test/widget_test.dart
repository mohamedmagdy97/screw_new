// Smoke tests for the screw_calculator app.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:screw_calculator/core/theme/app_theme.dart';

void main() {
  test('AppTheme exposes light and dark themes with matching brightness', () {
    expect(AppTheme.light.brightness, Brightness.light);
    expect(AppTheme.dark.brightness, Brightness.dark);
  });

  test('AppTheme uses the brand primary color', () {
    expect(AppTheme.light.colorScheme.primary, AppColors.mainColor);
    expect(AppTheme.dark.colorScheme.primary, AppColors.mainColor);
  });
}
