import 'package:flutter/material.dart';

/// Theme tokens (build-spec section 6, starting values).
///
/// WCAG contrast (checked in test/theme_test.dart): ivory on lacquer 16.1:1,
/// gold on lacquer 8.2:1, lacquer on gold 8.2:1. Cinnabar and river blue
/// are fills, not text colours on lacquer; ivory text on them is 5.4:1 and
/// 5.9:1.
abstract final class LongKyColors {
  static const Color lacquer = Color(0xFF0E0B0A);
  static const Color goldLeaf = Color(0xFFC9A24A);
  static const Color cinnabar = Color(0xFFB3261E);
  static const Color ivory = Color(0xFFF2E8D5);
  static const Color riverBlue = Color(0xFF2E5E6E);

  /// Slightly lifted lacquer for panels.
  static const Color lacquerRaised = Color(0xFF1E1916);
}

/// Bundled typeface; never downloaded at runtime.
const String longKyFontFamily = 'BeVietnamPro';

ThemeData buildLongKyTheme() {
  const scheme = ColorScheme.dark(
    primary: LongKyColors.goldLeaf,
    onPrimary: LongKyColors.lacquer,
    secondary: LongKyColors.riverBlue,
    onSecondary: LongKyColors.ivory,
    error: LongKyColors.cinnabar,
    onError: LongKyColors.ivory,
    surface: LongKyColors.lacquer,
    onSurface: LongKyColors.ivory,
    surfaceContainerHighest: LongKyColors.lacquerRaised,
  );
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: LongKyColors.lacquer,
    fontFamily: longKyFontFamily,
  );
  return base.copyWith(
    appBarTheme: const AppBarTheme(
      backgroundColor: LongKyColors.lacquer,
      foregroundColor: LongKyColors.goldLeaf,
      centerTitle: false,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(240, 52),
        backgroundColor: LongKyColors.goldLeaf,
        foregroundColor: LongKyColors.lacquer,
        textStyle: const TextStyle(fontFamily: longKyFontFamily, fontSize: 18, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(240, 52),
        foregroundColor: LongKyColors.ivory,
        side: const BorderSide(color: LongKyColors.goldLeaf),
        textStyle: const TextStyle(fontFamily: longKyFontFamily, fontSize: 18, fontWeight: FontWeight.w500),
      ),
    ),
    dividerTheme: const DividerThemeData(color: LongKyColors.lacquerRaised),
  );
}
