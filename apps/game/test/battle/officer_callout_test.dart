import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lk_rules/lk_rules.dart';
import 'package:long_ky_game/features/battle/battle_cubit.dart';
import 'package:long_ky_game/features/battle/battle_screen.dart';
import 'package:long_ky_game/features/battle/overlays/officer_callout.dart';

import '../golden/golden_support.dart';
import 'overlay_support.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await loadGoldenFonts();
  });

  final rules = ruleset('ch1_m2');
  final state = GameEngine(rules).newGame(1).state;

  group('calloutFor', () {
    test('the king, when the turn is resolved', () {
      final c = calloutFor(rules, state, const [PhaseChanged(Phase.resolution)]);
      expect(c!.officerId, 'tran-thai-tong');
      expect(c.kind, CalloutKind.charge);
    });

    test('an officer who uses a skill', () {
      final c = calloutFor(rules, state, const [SkillUsed('tran-thu-do', 'dau-than-chua-roi')]);
      expect(c!.officerId, 'tran-thu-do');
      expect(c.kind, CalloutKind.skill);
    });

    test('nothing for other steps, or when the mission ends in the step', () {
      expect(calloutFor(rules, state, const [PhaseChanged(Phase.orders)]), isNull);
      expect(calloutFor(rules, state, const [PhaseChanged(Phase.resolution), MissionEnded(Outcome.won)]), isNull);
    });
  });

  testWidgets('resolving the turn shows the king, and he is gone a few seconds later', (tester) async {
    setViewSize(tester, compact);
    final cubit = BattleCubit(GameEngine(rules), seed: 1);
    await tester.pumpWidget(appAround(BlocProvider.value(value: cubit, child: BattleScreen(ruleset: rules))));
    await settle(tester);
    cubit.endPhase();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byKey(const Key('officer-callout')), findsNothing, reason: 'Council to Orders is not the shout');
    cubit.endPhase();
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.byKey(const Key('officer-callout')), findsOneWidget);
    expect(find.text('Trần Thái Tông'), findsWidgets);
    expect(find.text(strings('vi').calloutCharge), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pump(OfficerCallout.length);
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byKey(const Key('officer-callout')), findsNothing);
  });
}
