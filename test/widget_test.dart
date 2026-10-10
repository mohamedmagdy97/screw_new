// Smoke tests for the screw_calculator app theme.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:screw_calculator/core/theme/app_palette.dart';
import 'package:screw_calculator/core/theme/app_theme.dart';

void main() {
  test('AppTheme exposes light and dark themes with matching brightness', () {
    expect(AppTheme.light.brightness, Brightness.light);
    expect(AppTheme.dark.brightness, Brightness.dark);
  });

  test('AppTheme uses the palette brand color as primary', () {
    expect(AppTheme.light.colorScheme.primary, AppPalette.light.brand);
    expect(AppTheme.dark.colorScheme.primary, AppPalette.dark.brand);
  });
}
