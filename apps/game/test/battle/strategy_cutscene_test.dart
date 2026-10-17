import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:long_ky_game/features/battle/overlays/strategy_cutscene.dart';

import '../golden/golden_support.dart';
import 'overlay_support.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await loadGoldenFonts();
  });

  testWidgets('a strategy cutscene shows the card name, then ends by itself and takes no taps', (tester) async {
    final rules = ruleset('ch1_m2');
    final card = rules.cards.values.first;
    var done = 0;
    setViewSize(tester, compact);
    await tester.pumpWidget(appAround(StrategyCutscene(card: card, onDone: () => done++)));
    await tester.pump(const Duration(milliseconds: 800));
    expect(find.byKey(const Key('strategy-cutscene')), findsOneWidget);
    expect(find.byKey(const Key('cutscene-name')), findsOneWidget);
    expect(tester.takeException(), isNull);
    // IgnorePointer: the board under it stays usable.
    expect(find.descendant(of: find.byType(StrategyCutscene), matching: find.byType(IgnorePointer)), findsWidgets);
    expect(done, 0);
    await tester.pump(StrategyCutscene.length);
    expect(done, 1);
  });
}
