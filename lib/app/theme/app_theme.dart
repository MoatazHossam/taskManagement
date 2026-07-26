import 'package:flutter/material.dart';

import 'app_tokens.dart';

abstract final class AppTheme {
  static ThemeData light() => _theme(Brightness.light, AppPalette.brand);
  static ThemeData dark() => _theme(Brightness.dark, AppPalette.brandDark);

  static ThemeData _theme(Brightness brightness, Color seed) {
    final dark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: brightness,
      surface: dark ? AppPalette.darkCanvas : Colors.white,
    );
    final outline = scheme.outlineVariant.withValues(alpha: dark ? .45 : .75);
    final rounded = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadii.medium),
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      brightness: brightness,
      scaffoldBackgroundColor: dark ? AppPalette.darkCanvas : AppPalette.canvas,
      fontFamily: 'sans-serif',
      textTheme: Typography.material2021(platform: TargetPlatform.android)
          .black
          .apply(
            bodyColor: scheme.onSurface,
            displayColor: scheme.onSurface,
            fontFamily: 'sans-serif',
          )
          .copyWith(
            headlineMedium: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, height: 1.25),
            headlineSmall: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, height: 1.3),
            titleLarge: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, height: 1.35),
            titleMedium: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, height: 1.4),
            bodyLarge: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400, height: 1.55),
            bodyMedium: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, height: 1.5),
            labelLarge: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, height: 1.3),
          ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: dark ? AppPalette.darkCanvas : AppPalette.canvas,
        titleTextStyle: TextStyle(color: scheme.onSurface, fontSize: 20, fontWeight: FontWeight.w700),
      ),
      cardTheme: CardThemeData(
        elevation: AppElevations.none,
        margin: EdgeInsets.zero,
        color: scheme.surface,
        shape: rounded.copyWith(side: BorderSide(color: outline)),
      ),
      dividerTheme: DividerThemeData(color: outline, thickness: 1),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.medium, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadii.medium)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadii.medium), borderSide: BorderSide(color: outline)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(minimumSize: const Size(0, AppSizes.control), shape: rounded, padding: const EdgeInsets.symmetric(horizontal: AppSpacing.large)),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(minimumSize: const Size(0, AppSizes.control), shape: rounded, padding: const EdgeInsets.symmetric(horizontal: AppSpacing.large)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        height: 72,
        backgroundColor: scheme.surface,
        indicatorShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.medium)),
      ),
      navigationRailTheme: NavigationRailThemeData(
        elevation: 0,
        backgroundColor: scheme.surface,
        indicatorShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.medium)),
        selectedLabelTextStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
      dialogTheme: DialogThemeData(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.large))),
      bottomSheetTheme: BottomSheetThemeData(
        showDragHandle: true,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.large))),
      ),
      visualDensity: VisualDensity.standard,
    );
  }
}
