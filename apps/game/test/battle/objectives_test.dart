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

  for (final (name, size) in [('phone', compact), ('desktop', regular)]) {
    testWidgets('the objectives are one tap away on a $name: win, lose and stars', (tester) async {
      final rules = ruleset('ch1_m2');
      setViewSize(tester, size);
      final cubit = BattleCubit(GameEngine(rules), seed: 1);
      await tester.pumpWidget(
        appAround(BlocProvider.value(value: cubit, child: BattleScreen(ruleset: rules))),
      );
      await settle(tester);
      await tester.tap(find.byKey(const Key('objectives-button')));
      await settle(tester);
      expect(find.byKey(const Key('objectives-dialog')), findsOneWidget);
      expect(find.byKey(const Key('objectives-win')), findsOneWidget);
      expect(find.byKey(const Key('objectives-loss')), findsOneWidget);
      expect(find.byKey(const Key('objectives-stars')), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(find.byKey(const Key('objectives-close')));
      await settle(tester);
      expect(find.byKey(const Key('objectives-dialog')), findsNothing);
    });
  }
}
