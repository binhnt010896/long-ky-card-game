import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lk_rules/lk_rules.dart';
import 'package:long_ky_game/data/progress.dart';
import 'package:long_ky_game/data/progress_repository.dart';
import 'package:long_ky_game/data/progress_store.dart';
import 'package:long_ky_game/features/battle/battle_cubit.dart';
import 'package:long_ky_game/features/battle/battle_page.dart';
import 'package:long_ky_game/features/battle/battle_screen.dart';
import 'package:long_ky_game/features/battle/labels.dart';
import 'package:long_ky_game/features/settings/progress_cubit.dart';
import 'package:long_ky_game/features/tutorial/tutorial_coach.dart';
import 'package:long_ky_game/features/tutorial/tutorial_flow.dart';

import 'overlay_support.dart';

/// Coach marks for the first missions (build-spec section 9, T-22): a new
/// player is guided through every phase of turn 1.
void main() {
  group('momentOf', () {
    test('reads the phase from the end of the step id', () {
      expect(momentOf('m1-intel'), TutorialMoment.council);
      expect(momentOf('m1-council'), TutorialMoment.council);
      expect(momentOf('m1-orders'), TutorialMoment.orders);
      expect(momentOf('m1-resolution'), TutorialMoment.orders);
      expect(momentOf('m1-upkeep'), TutorialMoment.upkeep);
      expect(momentOf('m3-tip'), TutorialMoment.council);
      expect(momentOf('anything-else'), TutorialMoment.council);
      expect(momentOf('nodash'), TutorialMoment.council);
    });

    test('every step of every mission has a moment, and missions 1 and 2 cover each phase', () {
      for (final id in content.missions.keys) {
        final steps = content.missions[id]!.tutorial;
        expect(steps, isNotEmpty, reason: id);
      }
      for (final id in ['ch1_m1', 'ch1_m2']) {
        final moments = content.missions[id]!.tutorial.map((t) => momentOf(t.id)).toSet();
        expect(moments, TutorialMoment.values.toSet(), reason: '$id has a step for each moment of turn 1');
        expect(content.missions[id]!.tutorial, hasLength(5), reason: '$id: one per phase');
      }
      for (final id in ['ch1_m3', 'ch1_m4', 'ch1_m5']) {
        expect(content.missions[id]!.tutorial, hasLength(1), reason: '$id has one tip');
      }
    });
  });

  group('TutorialFlow', () {
    final rules = ruleset('ch1_m2');
    final engine = GameEngine(rules);
    final flow = TutorialFlow([for (final t in rules.mission.tutorial) t.id]);
    final start = engine.newGame(1).state;
    final orders = engine.apply(start, const GameAction.endPhase()).state;

    test('walks turn 1 in order: Intel, Council, Orders, Resolution, then Upkeep next turn', () {
      final seen = <String>{};
      final shown = <String>[];
      void drain(GameState s) {
        for (var i = 0; i < 10; i++) {
          final id = flow.current(s, seen);
          if (id == null) return;
          shown.add(id);
          seen.add(id);
        }
      }

      drain(start);
      expect(shown, ['m2-intel', 'm2-council']);
      drain(orders);
      expect(shown, ['m2-intel', 'm2-council', 'm2-orders', 'm2-resolution']);
      // The turn resolves; the mission goes on to turn 2 (a state with a later turn).
      final turn2 = start.copyWith(turn: 2);
      drain(turn2);
      expect(shown.last, 'm2-upkeep');
      expect(flow.finished(turn2, seen), isTrue);
    });

    test('a step is shown once, and only the current one at a time', () {
      expect(flow.current(start, {}), 'm2-intel');
      expect(flow.current(start, {'m2-intel'}), 'm2-council');
      expect(flow.current(start, {'m2-intel', 'm2-council'}), isNull, reason: 'the Orders tips wait for Orders');
      expect(flow.current(orders, {'m2-intel', 'm2-council'}), 'm2-orders');
    });

    test('a step whose moment has passed is dropped, not shown late', () {
      // The player went straight to Orders without reading the Council tips.
      expect(flow.current(orders, {}), 'm2-orders');
      expect(flow.finished(orders, {}), isFalse, reason: 'the Orders and Upkeep tips are still to come');
      // Turn 3: everything but Upkeep has passed.
      final turn3 = start.copyWith(turn: 3);
      expect(flow.current(turn3, {}), 'm2-upkeep');
      expect(flow.finished(turn3, {'m2-upkeep'}), isTrue);
    });

    test('nothing during or after the end of the mission', () {
      final over = start.copyWith(phase: Phase.ended, outcome: Outcome.won);
      expect(flow.current(over, {}), isNull);
      expect(flow.finished(over, {}), isTrue);
    });

    test('a battle picked up in turn 3 has nothing left to teach but Upkeep', () {
      final late = start.copyWith(turn: 3, phase: Phase.orders);
      expect(flow.finished(late, {}), isFalse);
      expect(flow.finished(late, {'m2-upkeep'}), isTrue);
    });

    test('positions are 1-based places in the mission list', () {
      expect(flow.position('m2-intel'), 1);
      expect(flow.position('m2-upkeep'), 5);
    });

    test('a single tip is shown at the start and is then done', () {
      final tip = TutorialFlow(const ['m3-tip']);
      expect(tip.current(start, {}), 'm3-tip');
      expect(tip.current(start, {'m3-tip'}), isNull);
      expect(tip.finished(start, {'m3-tip'}), isTrue);
      expect(tip.finished(orders, {}), isTrue, reason: 'passed unread: nothing more to show');
    });
  });

  group('placeBubble', () {
    const screen = Size(800, 400);
    const bubble = Size(300, 100);

    test('below the target when it fits', () {
      final target = const Rect.fromLTWH(100, 20, 200, 40);
      final at = placeBubble(screen: screen, target: target, bubble: bubble);
      expect(at.dy, target.bottom + 12);
      expect(at.dx, closeTo(target.center.dx - 150, 1e-9));
    });

    test('above it when there is no room below', () {
      final target = const Rect.fromLTWH(100, 330, 200, 50);
      final at = placeBubble(screen: screen, target: target, bubble: bubble);
      expect(at.dy + bubble.height, target.top - 12);
    });

    test('beside it when there is no room above or below', () {
      // A tall element on the left edge of a short screen.
      final target = const Rect.fromLTWH(10, 8, 120, 384);
      final at = placeBubble(screen: screen, target: target, bubble: bubble);
      expect(at.dx, target.right + 12);
    });

    test('never covers the target when a clean place exists, and stays on the screen', () {
      for (final target in [
        const Rect.fromLTWH(0, 0, 100, 40),
        const Rect.fromLTWH(700, 360, 100, 40),
        const Rect.fromLTWH(350, 150, 100, 100),
        const Rect.fromLTWH(0, 350, 800, 50),
        const Rect.fromLTWH(600, 0, 200, 50),
      ]) {
        final at = placeBubble(screen: screen, target: target, bubble: bubble);
        final rect = at & bubble;
        expect(
          const Rect.fromLTWH(0, 0, 800, 400).contains(rect.topLeft) && rect.right <= 800 && rect.bottom <= 400,
          isTrue,
          reason: '$target → $rect',
        );
        expect(rect.overlaps(target), isFalse, reason: '$target → $rect');
      }
    });

    test('respects the safe area', () {
      final at = placeBubble(
        screen: screen,
        target: const Rect.fromLTWH(60, 100, 100, 40),
        bubble: bubble,
        safe: const EdgeInsets.fromLTRB(48, 0, 34, 21),
      );
      expect(at.dx, greaterThanOrEqualTo(48 + 8));
      expect(at.dy + bubble.height, lessThanOrEqualTo(400 - 21 - 8));
      expect(at.dx + bubble.width, lessThanOrEqualTo(800 - 34 - 8));
    });

    test('with no target the bubble is centred', () {
      final at = placeBubble(screen: screen, target: null, bubble: bubble);
      expect(at, const Offset(250, 150));
    });

    test('a target that fills the screen is covered as little as possible, not nowhere', () {
      final at = placeBubble(screen: screen, target: const Rect.fromLTWH(0, 0, 800, 400), bubble: bubble);
      final rect = at & bubble;
      expect(rect.left, greaterThanOrEqualTo(0));
      expect(rect.right, lessThanOrEqualTo(800));
      expect(rect.top, greaterThanOrEqualTo(0));
      expect(rect.bottom, lessThanOrEqualTo(400));
    });
  });

  group('coach marks on the battle screen', () {
    late ProgressCubit progress;
    late MemoryProgressStore store;
    final l = strings('vi');

    Future<BattleCubit> pumpTutorialBattle(
      WidgetTester tester,
      Size size, {
      String missionId = 'ch1_m2',
      String lang = 'vi',
      double textScale = 1,
      ProgressCubit? withProgress,
    }) async {
      setViewSize(tester, size);
      await tester.pumpWidget(
        appAround(
          BattlePage(missionId: missionId, seed: 1, bundle: DiskAssetBundle(), progress: withProgress ?? progress),
          lang: lang,
          textScale: textScale,
        ),
      );
      await tester.pump();
      await settle(tester);
      return tester.element(find.byType(BattleScreen)).read<BattleCubit>();
    }

    TutorialCoach coach(WidgetTester tester) => tester.widget<TutorialCoach>(find.byType(TutorialCoach));

    setUp(() {
      store = MemoryProgressStore();
      progress = ProgressCubit(ProgressRepository(store), const Progress());
    });

    for (final (name, size, _) in layouts) {
      group('($name)', () {
        testWidgets('turn 1 of ch1_m2 is taught phase by phase, each tip pointing at its element', (tester) async {
          final cubit = await pumpTutorialBattle(tester, size);
          final steps = ruleset('ch1_m2').mission.tutorial;
          Rect rectOf(String key) => tester.getRect(find.byKey(Key(key)));

          Future<void> expectTip(int i, Rect? target) async {
            expect(find.byType(TutorialCoach), findsOneWidget, reason: 'tip $i');
            expect(find.text(l.content(steps[i].text)), findsOneWidget, reason: 'tip $i text');
            expect(find.text(l.tutorialCount(i + 1, steps.length)), findsOneWidget);
            final bubble = tester.getRect(find.byKey(const Key('tutorial-bubble')));
            expect(
              (Offset.zero & size).contains(bubble.topLeft) &&
                  bubble.right <= size.width &&
                  bubble.bottom <= size.height,
              isTrue,
              reason: 'bubble $bubble on screen',
            );
            if (target != null) {
              final spot = coach(tester).target!;
              expect(
                spot.overlaps(target) || spot.inflate(2).contains(target.center),
                isTrue,
                reason: 'spotlight $spot on $target',
              );
              expect(bubble.overlaps(spot.inflate(2)), isFalse, reason: 'the bubble must not cover what it points at');
            }
          }

          // Intel: the arrows. (The board is the only thing on screen they can be pointed to by.)
          expect(cubit.game.phase, Phase.council);
          await expectTip(0, null);
          final arrows = coach(tester).target!;
          final board = tester.getRect(find.byType(BattleScreen)); // loose bound
          expect(board.contains(arrows.center), isTrue);
          await tester.tap(find.byKey(const Key('tutorial-next')));
          await settle(tester);

          // Council: the hand.
          await expectTip(1, rectOf(size.width < 900 ? 'hand-handle' : 'hand-column'));
          await tester.tap(find.byKey(const Key('tutorial-next')));
          await settle(tester);
          expect(find.byType(TutorialCoach), findsNothing, reason: 'nothing more until Orders');

          // Orders: the officer strip, then what ending the phase does.
          cubit.endPhase();
          await settle(tester);
          await expectTip(2, rectOf('officer-strip'));
          await tester.tap(find.byKey(const Key('tutorial-next')));
          await settle(tester);
          await expectTip(3, rectOf('phase-button'));
          await tester.tap(find.byKey(const Key('tutorial-next')));
          await settle(tester);
          expect(find.byType(TutorialCoach), findsNothing);
          expect(progress.state.tutorialDone, isEmpty, reason: 'Upkeep is still to come');
        });

        testWidgets('Upkeep is taught at the start of turn 2 and finishes the tutorial for good', (tester) async {
          // ch1_m1 goes on to turn 2 (the mission has three turns).
          final cubit = await pumpTutorialBattle(tester, size, missionId: 'ch1_m1');
          final m1 = ruleset('ch1_m1').mission.tutorial;
          expect(cubit.game.pendingChoice, isNotNull, reason: 'the envoy event comes first: no tip over a choice');
          expect(find.byType(TutorialCoach), findsNothing);
          cubit.resolveChoice(0);
          await settle(tester);
          for (var i = 0; i < 2; i++) {
            expect(find.text(l.content(m1[i].text)), findsOneWidget);
            await tester.tap(find.byKey(const Key('tutorial-next')));
            await settle(tester);
          }
          cubit.endPhase();
          await settle(tester);
          for (var i = 2; i < 4; i++) {
            expect(find.text(l.content(m1[i].text)), findsOneWidget);
            await tester.tap(find.byKey(const Key('tutorial-next')));
            await settle(tester);
          }
          cubit.endPhase(); // resolve turn 1
          await settle(tester);
          await playOut(tester);
          expect(cubit.game.turn, 2);
          while (cubit.game.pendingChoice != null) {
            cubit.resolveChoice(0);
            await settle(tester);
          }
          // Upkeep, in the top bar.
          expect(find.text(l.content(m1[4].text)), findsOneWidget);
          expect(find.text(l.tutorialGotIt), findsOneWidget, reason: 'the last tip says Got it');
          final spot = coach(tester).target!;
          expect(spot.overlaps(tester.getRect(find.byKey(const Key('top-bar')))), isTrue);
          await tester.tap(find.byKey(const Key('tutorial-next')));
          await settle(tester);
          expect(find.byType(TutorialCoach), findsNothing);
          expect(progress.state.tutorialDone, ['ch1_m1']);
          expect(store.text, contains('ch1_m1'), reason: 'saved to progress.json');
        });

        testWidgets('Skip ends all the tips at once, for good', (tester) async {
          await pumpTutorialBattle(tester, size);
          expect(find.byType(TutorialCoach), findsOneWidget);
          await tester.tap(find.byKey(const Key('tutorial-skip')));
          await settle(tester);
          expect(find.byType(TutorialCoach), findsNothing);
          expect(progress.state.tutorialDone, ['ch1_m2']);
          // A new battle of the same mission is not coached again.
          await tester.pumpWidget(const SizedBox());
          await pumpTutorialBattle(tester, size);
          expect(find.byType(TutorialCoach), findsNothing);
        });

        testWidgets('does not block the game: the spotlit button can be pressed with the tip showing', (tester) async {
          final cubit = await pumpTutorialBattle(tester, size);
          expect(find.text(l.content(ruleset('ch1_m2').mission.tutorial[0].text)), findsOneWidget);
          await tester.tap(find.byKey(const Key('phase-button')));
          await settle(tester);
          expect(cubit.game.phase, Phase.orders, reason: 'the tap reached the game under the dimmed screen');
          // The Council tips are gone unread; the Orders tip is next.
          expect(find.text(l.content(ruleset('ch1_m2').mission.tutorial[2].text)), findsOneWidget);
        });

        testWidgets('a mission with one tip shows it once at the start, then is done', (tester) async {
          await pumpTutorialBattle(tester, size, missionId: 'ch1_m3');
          final tip = ruleset('ch1_m3').mission.tutorial.single;
          expect(find.text(l.content(tip.text)), findsOneWidget);
          expect(find.text(l.tutorialCount(1, 1)), findsOneWidget);
          expect(find.text(l.tutorialGotIt), findsOneWidget);
          await tester.tap(find.byKey(const Key('tutorial-next')));
          await settle(tester);
          expect(find.byType(TutorialCoach), findsNothing);
          expect(progress.state.tutorialDone, ['ch1_m3']);
        });

        testWidgets('in English, with the English texts and buttons', (tester) async {
          await pumpTutorialBattle(tester, size, lang: 'en');
          final en = strings('en');
          expect(find.text(en.content(ruleset('ch1_m2').mission.tutorial[0].text)), findsOneWidget);
          expect(find.text('Next'), findsOneWidget);
          expect(find.text('Skip the tutorial'), findsOneWidget);
        });

        testWidgets('150% text: the bubble still fits on the screen and its buttons are 48 px', (tester) async {
          await pumpTutorialBattle(tester, size, textScale: 1.5);
          expect(tester.takeException(), isNull);
          final bubble = tester.getRect(find.byKey(const Key('tutorial-bubble')));
          expect(bubble.right, lessThanOrEqualTo(size.width));
          expect(bubble.bottom, lessThanOrEqualTo(size.height));
          for (final k in ['tutorial-next', 'tutorial-skip']) {
            expect(tester.getSize(find.byKey(Key(k))).height, greaterThanOrEqualTo(48), reason: k);
          }
        });

        testWidgets('is read out as one live region, with the tip text', (tester) async {
          final semantics = tester.ensureSemantics();
          await pumpTutorialBattle(tester, size);
          final tip = ruleset('ch1_m2').mission.tutorial[0];
          // The live region carries the tip; its buttons' labels may join it.
          expect(
            find.bySemanticsLabel(RegExp(RegExp.escape(l.tutorialSemantics(l.content(tip.text))))),
            findsOneWidget,
          );
          semantics.dispose();
        });
      });
    }

    testWidgets('without a progress record (nothing to remember the tutorial in) there are no tips', (tester) async {
      setViewSize(tester, regular);
      await tester.pumpWidget(appAround(BattlePage(missionId: 'ch1_m2', seed: 1, bundle: DiskAssetBundle())));
      await tester.pump();
      await settle(tester);
      expect(find.byType(TutorialCoach), findsNothing);
    });

    testWidgets('a player who has done the tutorial sees no tips', (tester) async {
      final done = ProgressCubit(ProgressRepository(MemoryProgressStore()), const Progress(tutorialDone: ['ch1_m2']));
      await pumpTutorialBattle(tester, regular, withProgress: done);
      expect(find.byType(TutorialCoach), findsNothing);
    });

    testWidgets('a battle resumed in turn 3 is coached only with what still applies: Upkeep', (tester) async {
      setViewSize(tester, regular);
      // Play ch1_m1 (three turns) on to turn 3.
      final m1 = GameEngine(ruleset('ch1_m1'));
      var s = m1.newGame(1).state;
      s = m1.apply(s, const GameAction.resolveChoice(index: 0)).state;
      for (var i = 0; i < 2; i++) {
        s = m1.apply(s, const GameAction.endPhase()).state;
        s = m1.apply(s, const GameAction.endPhase()).state;
        while (s.pendingChoice != null) {
          s = m1.apply(s, const GameAction.resolveChoice(index: 0)).state;
        }
      }
      expect(s.turn, greaterThanOrEqualTo(3));
      final cubit = BattleCubit.resume(m1, seed: 1, actions: s.log);
      addTearDown(cubit.close);
      await tester.pumpWidget(
        appAround(
          BlocProvider.value(
            value: cubit,
            child: BattleScreen(
              ruleset: ruleset('ch1_m1'),
              tutorial: ruleset('ch1_m1').mission.tutorial,
              onTutorialDone: () => progress.markTutorialDone('ch1_m1'),
            ),
          ),
        ),
      );
      await tester.pump();
      await settle(tester);
      // Only Upkeep (turn >= 2) can still apply; the rest has passed.
      expect(find.byType(TutorialCoach), findsOneWidget);
      expect(find.text(l.content(ruleset('ch1_m1').mission.tutorial[4].text)), findsOneWidget);
    });
  });
}
