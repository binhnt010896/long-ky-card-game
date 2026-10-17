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

  final l = strings('vi');

  testWidgets('after the mission ends, Keep playing goes on until a side has no troops; the result stands', (tester) async {
    final rules = ruleset('ch1_m2');
    setViewSize(tester, compact);
    final cubit = BattleCubit(GameEngine(rules), seed: 1);
    await tester.pumpWidget(appAround(BlocProvider.value(value: cubit, child: BattleScreen(ruleset: rules))));
    await settle(tester);
    winM2(cubit);
    await settle(tester);
    await playOut(tester);
    expect(cubit.game.outcome, Outcome.won);
    expect(find.byKey(const Key('review-continue')), findsOneWidget);

    await tester.tap(find.byKey(const Key('review-continue')));
    await settle(tester);
    expect(cubit.game.freePlay, isTrue);
    expect(cubit.game.isOver, isFalse);
    expect(cubit.game.outcome, Outcome.won, reason: 'the mission result stands');
    expect(find.byKey(const Key('review-banner')), findsNothing);
    expect(find.byKey(const Key('free-play-tag')), findsOneWidget);
    expect(find.text(l.freePlayTag), findsOneWidget);

    // The Yuan run out of troops: free play ends, for good.
    cubit.endPhase();
    await settle(tester);
    expect(cubit.game.phase, Phase.orders);
    cubit.emit(
      BattleViewState(
        state: cubit.game.copyWith(armies: {for (final a in cubit.game.armies.entries) a.key: a.value.copyWith(troops: 0)}),
        events: cubit.state.events,
        step: cubit.state.step,
      ),
    );
    cubit.endPhase();
    await settle(tester);
    await playOut(tester);
    expect(cubit.game.isOver, isTrue);
    expect(cubit.game.freePlayOutcome, Outcome.won);
    expect(find.text(l.freePlayWon), findsOneWidget);
    expect(find.byKey(const Key('review-continue')), findsNothing, reason: 'free play is played once');

    await tester.tap(find.byKey(const Key('review-result')));
    await settle(tester);
    expect(find.byKey(const Key('result-screen')), findsOneWidget);
    expect(find.byKey(const Key('result-free-play')), findsOneWidget);
    expect(find.byKey(const Key('result-continue')), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
