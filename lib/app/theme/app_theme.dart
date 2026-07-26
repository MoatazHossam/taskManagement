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
    final surfaces = AppSurfaceColors(
      page: dark ? AppPalette.darkCanvas : AppPalette.canvas,
      standard: dark ? AppPalette.darkSurface : Colors.white,
      elevated: dark ? AppPalette.darkElevatedSurface : const Color(0xFFF0F6F4),
      border: dark ? AppPalette.darkOutline : const Color(0xFFD7E0DD),
      disabled: dark ? AppPalette.darkDisabledSurface : const Color(0xFFE9EEEC),
    );
    final outline = surfaces.border;
    final rounded = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadii.medium),
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      brightness: brightness,
      scaffoldBackgroundColor: surfaces.page,
      extensions: [surfaces],
      fontFamily: 'sans-serif',
      textTheme: Typography.material2021(platform: TargetPlatform.android).black
          .apply(
            bodyColor: scheme.onSurface,
            displayColor: scheme.onSurface,
            fontFamily: 'sans-serif',
          )
          .copyWith(
            headlineMedium: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              height: 1.25,
            ),
            headlineSmall: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
            titleLarge: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
            titleMedium: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              height: 1.4,
            ),
            bodyLarge: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              height: 1.55,
            ),
            bodyMedium: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 1.5,
            ),
            labelLarge: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
          ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: surfaces.page,
        toolbarHeight: AppSizes.compactHeader,
        titleTextStyle: TextStyle(
          color: scheme.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: AppElevations.none,
        margin: EdgeInsets.zero,
        color: surfaces.standard,
        shape: rounded.copyWith(side: BorderSide(color: outline)),
      ),
      dividerTheme: DividerThemeData(color: outline, thickness: 1),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaces.standard,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.medium,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.medium),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.medium),
          borderSide: BorderSide(color: outline),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, AppSizes.control),
          shape: rounded,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.large),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, AppSizes.control),
          shape: rounded,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.large),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        height: AppSizes.phoneNavigation,
        backgroundColor: surfaces.standard,
        indicatorColor: scheme.primaryContainer.withValues(alpha: .72),
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.pill),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontSize: 11,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
          ),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        elevation: 0,
        backgroundColor: scheme.surface,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.medium),
        ),
        selectedLabelTextStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.large),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadii.large),
          ),
        ),
      ),
      visualDensity: VisualDensity.standard,
    );
  }
}
