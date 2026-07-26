import 'package:flutter/material.dart';

/// The small, deliberate token set used by every foundation component.
abstract final class AppSpacing {
  static const double xSmall = 4;
  static const double small = 8;
  static const double medium = 16;
  static const double section = 20;
  static const double large = 24;
  static const double xLarge = 32;
  static const double xxLarge = 48;
}

abstract final class AppRadii {
  static const double small = 8;
  static const double medium = 12;
  static const double large = 18;
  static const double pill = 999;
}

abstract final class AppSizes {
  static const double control = 48;
  static const double compactControl = 40;
  static const double avatar = 44;
  static const double phoneNavigation = 64;
  static const double compactHeader = 52;
  static const double navigationRail = 240;
  static const double pageMax = 1120;
}

abstract final class AppIconSizes {
  static const double small = 18;
  static const double medium = 24;
  static const double large = 40;
}

abstract final class AppElevations {
  static const double none = 0;
  static const double low = 1;
  static const double medium = 3;
}

abstract final class AppBreakpoints {
  static const double compactMax = 399;
  static const double tablet = 700;
  static const double readableContent = 840;
}

abstract final class AppPalette {
  static const brand = Color(0xFF176B63);
  static const brandDark = Color(0xFF73D6CB);
  static const ink = Color(0xFF17201F);
  static const canvas = Color(0xFFF5F7F6);
  static const darkCanvas = Color(0xFF101514);
  static const darkSurface = Color(0xFF18201E);
  static const darkElevatedSurface = Color(0xFF202B28);
  static const darkDisabledSurface = Color(0xFF151B1A);
  static const darkOutline = Color(0xFF3B4A46);
}

@immutable
class AppSurfaceColors extends ThemeExtension<AppSurfaceColors> {
  const AppSurfaceColors({
    required this.page,
    required this.standard,
    required this.elevated,
    required this.border,
    required this.disabled,
  });

  final Color page;
  final Color standard;
  final Color elevated;
  final Color border;
  final Color disabled;

  @override
  AppSurfaceColors copyWith({
    Color? page,
    Color? standard,
    Color? elevated,
    Color? border,
    Color? disabled,
  }) => AppSurfaceColors(
    page: page ?? this.page,
    standard: standard ?? this.standard,
    elevated: elevated ?? this.elevated,
    border: border ?? this.border,
    disabled: disabled ?? this.disabled,
  );

  @override
  AppSurfaceColors lerp(covariant AppSurfaceColors? other, double t) =>
      other == null
      ? this
      : AppSurfaceColors(
          page: Color.lerp(page, other.page, t)!,
          standard: Color.lerp(standard, other.standard, t)!,
          elevated: Color.lerp(elevated, other.elevated, t)!,
          border: Color.lerp(border, other.border, t)!,
          disabled: Color.lerp(disabled, other.disabled, t)!,
        );
}

extension AppSurfaceTheme on BuildContext {
  AppSurfaceColors get surfaces =>
      Theme.of(this).extension<AppSurfaceColors>()!;
}

abstract final class AppSemanticColors {
  static const success = Color(0xFF16794A);
  static const warning = Color(0xFF9A6700);
  static const error = Color(0xFFBA1A1A);
  static const information = Color(0xFF2563A5);
  static const taskPending = Color(0xFF64748B);
  static const taskActive = Color(0xFF2563EB);
  static const taskComplete = Color(0xFF15803D);
  static const priorityCritical = Color(0xFFB42318);
  static const priorityHigh = Color(0xFFD97706);
  static const confidential = Color(0xFF6D28D9);
}
