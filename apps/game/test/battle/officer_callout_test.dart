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

  GameState ordered(Order? order) => state.copyWith(
    officers: {...state.officers, 'le-phu-tran': state.officers['le-phu-tran']!.copyWith(order: order)},
  );

  group('calloutFor', () {
    test('the king, when the turn is resolved with someone advancing or attacking', () {
      for (final order in [Order.move('song-lo'), Order.raid('mong-co-1258'), Order.ambush('a-b')]) {
        final c = calloutFor(rules, state, const [PhaseChanged(Phase.resolution)], previous: ordered(order));
        expect(c!.officerId, 'tran-thai-tong', reason: '$order');
        expect(c.kind, CalloutKind.charge);
      }
    });

    test('no king when nobody advances or attacks', () {
      for (final order in [null, Order.hold, Order.evacuate, Order.rally]) {
        final c = calloutFor(rules, state, const [PhaseChanged(Phase.resolution)], previous: ordered(order));
        expect(c, isNull, reason: '$order');
      }
      expect(calloutFor(rules, state, const [PhaseChanged(Phase.resolution)]), isNull, reason: 'no orders to judge');
    });

    test('an officer who uses a skill', () {
      final c = calloutFor(rules, state, const [SkillUsed('tran-thu-do', 'dau-than-chua-roi')]);
      expect(c!.officerId, 'tran-thu-do');
      expect(c.kind, CalloutKind.skill);
    });

    test('nothing for other steps, or when the mission ends in the step', () {
      expect(calloutFor(rules, state, const [PhaseChanged(Phase.orders)]), isNull);
      expect(
        calloutFor(rules, state, const [PhaseChanged(Phase.resolution), MissionEnded(Outcome.won)], previous: ordered(Order.move('x'))),
        isNull,
      );
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
    cubit.setOrder('le-phu-tran', Order.move('song-lo'));
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

  for (final (id, seconds, phrase) in [
    ('tran-thu-do', 5, 'Đầu thần chưa rơi xuống đất'),
    ('tran-quoc-tuan', 8, 'Dẫu cho trăm thân ta phơi ngoài nội cỏ'),
  ]) {
    testWidgets('$id: the skill callout lasts as long as the voice line ($seconds s) and shows its subtitle', (tester) async {
      final m5 = ruleset('ch1_m5');
      final officer = m5.officers[id]!;
      expect(OfficerCallout.lengthFor(officer, CalloutKind.skill), Duration(seconds: seconds));
      expect(OfficerCallout.lengthFor(officer, CalloutKind.charge), OfficerCallout.length);
      setViewSize(tester, compact);
      var done = 0;
      await tester.pumpWidget(
        appAround(
          OfficerCallout(officer: officer, kind: CalloutKind.skill, ruleset: m5, onDone: () => done++),
        ),
      );
      await tester.pump(const Duration(milliseconds: 2000));
      expect(find.byKey(const Key('callout-subtitle')), findsOneWidget);
      expect(find.textContaining(phrase), findsOneWidget);
      expect(tester.takeException(), isNull);
      final box = tester.getRect(find.byKey(const Key('callout-subtitle')));
      expect(box.bottom, lessThanOrEqualTo(compact.height));
      await tester.pump(Duration(seconds: seconds - 2));
      await tester.pump(const Duration(milliseconds: 100));
      expect(done, 1);
    });
  }

  testWidgets('a long voice line can be skipped with its button', (tester) async {
    final m5 = ruleset('ch1_m5');
    var done = 0;
    setViewSize(tester, compact);
    await tester.pumpWidget(
      appAround(
        OfficerCallout(
          officer: m5.officers['tran-quoc-tuan']!,
          kind: CalloutKind.skill,
          ruleset: m5,
          onDone: () => done++,
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(find.byKey(const Key('callout-skip')));
    expect(done, 1);
  });

  testWidgets('a turn in which nobody advances or attacks has no king and no shout', (tester) async {
    setViewSize(tester, compact);
    final cubit = BattleCubit(GameEngine(rules), seed: 1);
    await tester.pumpWidget(appAround(BlocProvider.value(value: cubit, child: BattleScreen(ruleset: rules))));
    await settle(tester);
    cubit.endPhase();
    for (final id in ['tran-thai-tong', 'le-phu-tran', 'tran-thu-do']) {
      cubit.setOrder(id, Order.hold);
    }
    cubit.endPhase();
    await tester.pump(const Duration(milliseconds: 600));
    expect(cubit.game.turn, 2);
    expect(find.byKey(const Key('officer-callout')), findsNothing);
  });
}
