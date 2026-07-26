import 'package:flutter/material.dart';

import 'app_tokens.dart';

abstract final class AppTheme {
  static ThemeData light() => _theme(Brightness.light, const Color(0xFF175C58));
  static ThemeData dark() => _theme(Brightness.dark, const Color(0xFF79D3CC));
  static ThemeData _theme(Brightness brightness, Color seed) {
    final scheme = ColorScheme.fromSeed(seedColor: seed, brightness: brightness);
    return ThemeData(useMaterial3: true, colorScheme: scheme, brightness: brightness, scaffoldBackgroundColor: scheme.surface, cardTheme: const CardThemeData(elevation: AppElevations.low, margin: EdgeInsets.zero), inputDecorationTheme: const InputDecorationTheme(border: OutlineInputBorder()), visualDensity: VisualDensity.standard);
  }
}
