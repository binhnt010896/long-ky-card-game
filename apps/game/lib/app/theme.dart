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

/// Lacquer and gold-leaf button faces (painted textures under a bevel), shared
/// by every filled and outlined button. A texture that is not shipped leaves
/// the colour gradient on its own.
Widget longKyButtonFace(Set<WidgetState> states, Widget child, {required bool primary}) {
  final disabled = states.contains(WidgetState.disabled);
  final pressed = states.contains(WidgetState.pressed);
  final hovered = states.contains(WidgetState.hovered) || states.contains(WidgetState.focused);
  final radius = BorderRadius.circular(10);
  final List<Color> colors;
  if (disabled) {
    colors = const [Color(0xFF2A2623), Color(0xFF1B1816)];
  } else if (primary) {
    colors = pressed
        ? const [Color(0xFFB88F3A), Color(0xFF8A6A27)]
        : hovered
        ? const [Color(0xFFFBE7A6), Color(0xFFC79B42)]
        : const [Color(0xFFF1D58A), Color(0xFFB98E39)];
  } else {
    colors = pressed
        ? const [Color(0xFF2A100D), Color(0xFF160807)]
        : hovered
        ? const [Color(0xFF5A2620), Color(0xFF331511)]
        : const [Color(0xFF4A1E19), Color(0xFF260F0C)];
  }
  final texture = primary ? 'assets/images/ui/btn-gold.jpg' : 'assets/images/ui/btn-lacquer.jpg';
  return DecoratedBox(
    decoration: BoxDecoration(
      borderRadius: radius,
      gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: colors),
      image: disabled
          ? null
          : DecorationImage(
              image: AssetImage(texture),
              fit: BoxFit.cover,
              opacity: primary ? 0.32 : 0.5,
              onError: (_, _) {},
            ),
      border: Border.all(
        color: disabled ? const Color(0x33C9A24A) : (primary ? const Color(0xFFFFEFB8) : const Color(0xFFC9A24A)),
        width: primary ? 1.2 : 1.4,
      ),
      boxShadow: disabled
          ? null
          : const [BoxShadow(color: Color(0x99000000), blurRadius: 4, offset: Offset(0, 2))],
    ),
    child: Stack(
      alignment: Alignment.center,
      children: [
        // A fine inner line, like the inlay on a lacquer tray.
        if (!disabled)
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(3),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(
                    color: (primary ? const Color(0xFF5A3F0E) : const Color(0xFFC9A24A)).withValues(alpha: 0.45),
                    width: 0.8,
                  ),
                ),
              ),
            ),
          ),
        child,
      ],
    ),
  );
}

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
        minimumSize: const Size(220, 48),
        backgroundColor: const Color(0xFFD9B35A),
        foregroundColor: LongKyColors.lacquer,
        disabledBackgroundColor: LongKyColors.ivory.withValues(alpha: 0.12),
        disabledForegroundColor: LongKyColors.ivory.withValues(alpha: 0.45),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: Color(0xFFF1D58A), width: 1),
        ),
        elevation: 0,
        shadowColor: Colors.transparent,
        backgroundBuilder: (_, states, child) => longKyButtonFace(states, child!, primary: true),
        textStyle: const TextStyle(fontFamily: longKyFontFamily, fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(220, 48),
        foregroundColor: LongKyColors.ivory,
        backgroundColor: const Color(0xCC2B1411),
        side: BorderSide(color: LongKyColors.goldLeaf.withValues(alpha: 0.8), width: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 0,
        backgroundBuilder: (_, states, child) => longKyButtonFace(states, child!, primary: false),
        textStyle: const TextStyle(fontFamily: longKyFontFamily, fontSize: 16, fontWeight: FontWeight.w500),
      ),
    ),
    cardTheme: const CardThemeData(color: LongKyColors.lacquerRaised),
    dividerTheme: const DividerThemeData(color: LongKyColors.lacquerRaised),
  );
}
