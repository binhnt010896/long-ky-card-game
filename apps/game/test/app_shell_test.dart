import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:long_ky_game/app/long_ky_app.dart';
import 'package:long_ky_game/data/progress_store.dart';

import 'support.dart';

/// Pops the top route (the AppBar back button or the system back).
Future<void> goBack(WidgetTester tester) async {
  tester.state<NavigatorState>(find.byType(Navigator).last).pop();
  await tester.pumpAndSettle();
}

/// Scrolls the settings list to [key] and returns its finder.
Future<Finder> reveal(WidgetTester tester, String key) async {
  final f = find.byKey(Key(key));
  await tester.scrollUntilVisible(f, 150, scrollable: find.byType(Scrollable).last);
  await tester.pumpAndSettle();
  return f;
}

Future<void> openSettings(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('title screen: Vietnamese by default, four entries, Continue disabled', (tester) async {
    await startApp(tester);
    expect(find.text(LongKyApp.productName), findsOneWidget);
    for (final label in ['Tiếp tục', 'Chiến dịch', 'Sử liệu', 'Cài đặt']) {
      expect(find.text(label), findsOneWidget, reason: label);
    }
    final continueButton = tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Tiếp tục'));
    expect(continueButton.onPressed, isNull);
  });

  testWidgets('routing: Campaign and Codex open and go back', (tester) async {
    await startApp(tester);
    await tester.tap(find.text('Chiến dịch'));
    await tester.pumpAndSettle();
    expect(find.text('Sắp ra mắt.'), findsOneWidget);
    await goBack(tester);
    await tester.tap(find.text('Sử liệu'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Sử liệu'), findsOneWidget);
  });

  testWidgets('language switch works live, everywhere', (tester) async {
    await startApp(tester);
    await openSettings(tester, 'Cài đặt');
    expect(find.text('Ngôn ngữ'), findsOneWidget);
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
    expect(find.text('Language'), findsOneWidget);
    expect(find.widgetWithText(AppBar, 'Settings'), findsOneWidget);
    await goBack(tester);
    expect(find.text('Campaign'), findsOneWidget, reason: 'the screen below changed language too');
    await openSettings(tester, 'Settings');
    await tester.tap(find.text('Tiếng Việt'));
    await tester.pumpAndSettle();
    expect(find.text('Ngôn ngữ'), findsOneWidget);
  });

  testWidgets('settings persist across restarts', (tester) async {
    final store = await startApp(tester);
    await openSettings(tester, 'Cài đặt');
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
    await tester.drag(await reveal(tester, 'musicVolume'), const Offset(-2000, 0));
    await tester.tap(await reveal(tester, 'reduceMotion'));
    await tester.pumpAndSettle();
    final saved = jsonDecode(store.text!) as Map<String, Object?>;
    expect(saved['version'], 1);
    expect((saved['settings']! as Map)['languageCode'], 'en');

    // Restart on the same storage.
    await startApp(tester, store: store);
    expect(find.text('Campaign'), findsOneWidget);
    await openSettings(tester, 'Settings');
    expect(tester.widget<Slider>(await reveal(tester, 'musicVolume')).value, 0);
    expect(tester.widget<SwitchListTile>(await reveal(tester, 'reduceMotion')).value, isTrue);
  });

  testWidgets('text size and reduce motion reach every screen through MediaQuery', (tester) async {
    await startApp(tester);
    await openSettings(tester, 'Cài đặt');
    await tester.drag(await reveal(tester, 'textScale'), const Offset(2000, 0));
    await tester.tap(await reveal(tester, 'reduceMotion'));
    await tester.pumpAndSettle();
    final mq = MediaQuery.of(tester.element(find.byKey(const Key('reduceMotion'))));
    expect(mq.textScaler.scale(10), closeTo(15, 1e-9));
    expect(mq.disableAnimations, isTrue);
  });

  testWidgets('reset progress asks first, clears stars, keeps settings', (tester) async {
    final store = MemoryProgressStore(jsonEncode({
      'version': 1,
      'stars': {'ch1_m1': [true, true, false]},
      'unlocks': ['tran-thu-do'],
      'settings': {'languageCode': 'en'},
    }));
    await startApp(tester, store: store);
    await openSettings(tester, 'Settings');
    await tester.tap(await reveal(tester, 'resetProgress'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect((jsonDecode(store.text!) as Map)['stars'], isNotEmpty);

    await tester.tap(find.byKey(const Key('resetProgress')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reset'));
    await tester.pumpAndSettle();
    final saved = jsonDecode(store.text!) as Map<String, Object?>;
    expect(saved['stars'], isEmpty);
    expect(saved['unlocks'], isEmpty);
    expect((saved['settings']! as Map)['languageCode'], 'en');
    expect(find.text('Progress reset.'), findsOneWidget);
  });

  testWidgets('credits list the font licence and every source from sources.json', (tester) async {
    await startApp(tester);
    await openSettings(tester, 'Cài đặt');
    await tester.tap(await reveal(tester, 'credits'));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 500)));
    await tester.pumpAndSettle();
    expect(find.textContaining('Be Vietnam Pro'), findsOneWidget);
    expect(find.text('SBT Lịch sử 7, trang 48'), findsOneWidget);
  });

  testWidgets('compact (phone) and regular (desktop) sizes lay out without overflow', (tester) async {
    for (final size in [const Size(800, 360), const Size(1600, 900)]) {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      await startApp(tester);
      await openSettings(tester, 'Cài đặt');
      expect(tester.takeException(), isNull, reason: '$size');
      await goBack(tester);
    }
    tester.view.reset();
  });
}
