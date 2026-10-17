import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:long_ky_game/features/battle/battle_screen.dart';
import 'package:long_ky_game/data/progress.dart';

import 'battle/overlay_support.dart';
import 'support.dart';

double scaleOf(WidgetTester tester, Finder f) => MediaQuery.textScalerOf(tester.element(f)).scale(10) / 10;

void main() {
  group('the battle HUD on a phone', () {
    testWidgets('keeps text at most ${compactMaxTextScale * 100}% so labels are not cut off, even at 150%', (tester) async {
      await pumpBattle(tester, compact, textScale: 1.5);
      expect(tester.takeException(), isNull);
      expect(scaleOf(tester, find.byKey(const Key('top-bar'))), closeTo(compactMaxTextScale, 1e-9));
      expect(scaleOf(tester, find.byKey(const Key('officer-strip'))), closeTo(compactMaxTextScale, 1e-9));
      expect(scaleOf(tester, find.byKey(const Key('phase-button'))), closeTo(compactMaxTextScale, 1e-9));
    });

    testWidgets('does not touch smaller sizes', (tester) async {
      await pumpBattle(tester, compact, textScale: 0.8);
      expect(scaleOf(tester, find.byKey(const Key('top-bar'))), closeTo(0.8, 1e-9));
      await pumpBattle(tester, compact);
      expect(scaleOf(tester, find.byKey(const Key('top-bar'))), 1);
    });

    testWidgets('the regular layout has room and keeps the full text size', (tester) async {
      await pumpBattle(tester, regular, textScale: 1.5);
      expect(tester.takeException(), isNull);
      expect(scaleOf(tester, find.byKey(const Key('top-bar'))), closeTo(1.5, 1e-9));
    });

    testWidgets('every officer name still fits in the strip at 150% on a phone', (tester) async {
      await pumpBattle(tester, compact, textScale: 1.5);
      for (final name in ['Lê Phụ Trần', 'Trần Thái Tông', 'Trần Thủ Độ']) {
        final f = find.descendant(of: find.byKey(const Key('officer-strip')), matching: find.text(name));
        expect(f, findsOneWidget, reason: name);
        final box = tester.renderObject<RenderBox>(f);
        expect(box.size.width, greaterThan(0));
      }
    });
  });

  group('the text size setting', () {
    test('goes from 80% to 150% and 100% is the default', () {
      expect(GameSettings.minTextScale, 0.8);
      expect(GameSettings.maxTextScale, 1.5);
      expect(const GameSettings().textScale, 1);
      expect(const GameSettings().copyWith(textScale: 0.3).textScale, 0.8);
    });

    testWidgets('can be set to 80% in Settings and is kept after a restart', (tester) async {
      final store = await startApp(tester);
      await tester.tap(find.text('Cài đặt'));
      await tester.pumpAndSettle();
      final slider = find.byKey(const Key('textScale'));
      await tester.scrollUntilVisible(slider, 150, scrollable: find.byType(Scrollable).last);
      await tester.drag(slider, const Offset(-2000, 0));
      await tester.pumpAndSettle();
      expect(tester.widget<Slider>(slider).value, 0.8);
      expect((jsonDecode(store.text!) as Map)['settings']['textScale'], 0.8); // ignore: avoid_dynamic_calls
      expect(scaleOf(tester, slider), closeTo(0.8, 1e-9));
      await startApp(tester, store: store);
      await tester.tap(find.text('Cài đặt'));
      await tester.pumpAndSettle();
      expect(tester.widget<Slider>(find.byKey(const Key('textScale'))).value, 0.8);
    });
  });
}
