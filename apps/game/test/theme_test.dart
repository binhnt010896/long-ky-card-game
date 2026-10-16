import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:long_ky_game/app/theme.dart';

double _channel(double c) => c <= 0.03928 ? c / 12.92 : math.pow((c + 0.055) / 1.055, 2.4).toDouble();

double _luminance(Color c) => 0.2126 * _channel(c.r) + 0.7152 * _channel(c.g) + 0.0722 * _channel(c.b);

/// WCAG 2 contrast ratio.
double contrast(Color a, Color b) {
  final la = _luminance(a);
  final lb = _luminance(b);
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

void main() {
  test('text colours meet WCAG AA (4.5:1) on their backgrounds', () {
    const pairs = {
      'ivory on lacquer': (LongKyColors.ivory, LongKyColors.lacquer),
      'gold on lacquer': (LongKyColors.goldLeaf, LongKyColors.lacquer),
      'ivory on raised lacquer': (LongKyColors.ivory, LongKyColors.lacquerRaised),
      'lacquer on gold (buttons)': (LongKyColors.lacquer, LongKyColors.goldLeaf),
      'ivory on cinnabar': (LongKyColors.ivory, LongKyColors.cinnabar),
      'ivory on river blue': (LongKyColors.ivory, LongKyColors.riverBlue),
    };
    pairs.forEach((name, pair) {
      final ratio = contrast(pair.$1, pair.$2);
      // ignore: avoid_print
      print('$name: ${ratio.toStringAsFixed(1)}:1');
      expect(ratio, greaterThanOrEqualTo(4.5), reason: name);
    });
  });

  test('the theme uses the bundled Be Vietnam Pro font and the lacquer background', () {
    final theme = buildLongKyTheme();
    expect(theme.textTheme.bodyMedium!.fontFamily, longKyFontFamily);
    expect(theme.scaffoldBackgroundColor, LongKyColors.lacquer);
    expect(theme.colorScheme.primary, LongKyColors.goldLeaf);
  });
}
