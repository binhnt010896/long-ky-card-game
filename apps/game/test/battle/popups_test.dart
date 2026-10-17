import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lk_rules/lk_rules.dart';
import 'package:long_ky_game/features/battle/battle_cubit.dart';
import 'package:long_ky_game/features/battle/battle_screen.dart';

import '../golden/golden_support.dart';
import 'overlay_support.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await loadGoldenFonts();
  });

  testWidgets('on a phone only one popup shows at a time: inspector, hand or log', (tester) async {
    final rules = ruleset('ch1_m2');
    setViewSize(tester, compact);
    final cubit = BattleCubit(GameEngine(rules), seed: 1);
    await tester.pumpWidget(appAround(BlocProvider.value(value: cubit, child: BattleScreen(ruleset: rules))));
    await settle(tester);

    final inspector = find.byKey(const Key('inspector-officer'));
    final handCards = find.byKey(const Key('hand-handle'));
    Future<void> pick() async {
      await tester.tap(find.byKey(const Key('officer-tran-thai-tong')));
      await settle(tester);
    }

    await pick();
    expect(inspector, findsOneWidget);
    // Opening the hand closes the inspector.
    await tester.tap(handCards);
    await settle(tester);
    expect(inspector, findsNothing);
    expect(find.byKey(const Key('hand-fan')), findsOneWidget);
    // Picking an officer closes the hand.
    await pick();
    expect(inspector, findsOneWidget);
    expect(find.byKey(const Key('hand-fan')), findsNothing);
    // The log closes the inspector, and the hand closes the log.
    await tester.tap(find.byKey(const Key('log-button')));
    await settle(tester);
    expect(inspector, findsNothing);
    expect(find.byKey(const Key('log-popover')), findsOneWidget);
    await tester.tap(handCards);
    await settle(tester);
    expect(find.byKey(const Key('log-popover')), findsNothing);
    expect(find.byKey(const Key('hand-fan')), findsOneWidget);
  });
}
