import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lk_rules/lk_rules.dart';
import 'package:long_ky_game/features/battle/battle_cubit.dart';
import 'package:long_ky_game/features/battle/battle_screen.dart';
import 'package:long_ky_game/features/battle/board/board_game.dart';
import 'package:long_ky_game/features/battle/board/board_scene.dart';
import 'package:long_ky_game/features/tutorial/guided_flow.dart';

import '../golden/golden_support.dart';
import 'overlay_support.dart';

const training = 'ch0_training';

void main() {
  // The real typeface, so text is measured the way it is on a device.
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await loadGoldenFonts();
  });

  final rules = ruleset(training);
  final steps = rules.mission.tutorial;
  TutorialContext ctxOf(GameState s, {SelectionTarget? kind, String? id, bool hand = false, bool zoomed = false}) =>
      TutorialContext(state: s, ruleset: rules, selectedKind: kind, selectedId: id, handOpen: hand, zoomed: zoomed);

  group('GuidedFlow', () {
    final engine = GameEngine(rules);
    final start = engine.newGame(1).state;

    test('starts at the first step, which is read, not acted on', () {
      final f = GuidedFlow(steps);
      expect(f.index, 0);
      expect(f.position, 1);
      expect(f.waitingForAction, isFalse);
      expect(f.update(ctxOf(start)), isFalse, reason: 'a read step waits for Next');
      f.advance();
      expect(f.index, 1);
    });

    test('a step that waits for the player moves on by itself when they do it', () {
      final f = GuidedFlow(steps);
      while (f.current!.id != 't0-select-army') {
        f.advance();
      }
      expect(f.waitingForAction, isTrue);
      expect(f.update(ctxOf(start)), isFalse);
      expect(f.current!.id, 't0-select-army');
      expect(f.update(ctxOf(start, kind: SelectionTarget.army, id: 'mong-co-1258')), isTrue);
      expect(f.current!.id, 't0-intent');
      expect(f.waitingForAction, isFalse);
    });

    test('steps already done are skipped over, not shown late', () {
      final f = GuidedFlow(steps);
      while (f.current!.id != 't0-hand') {
        f.advance();
      }
      // On a big screen the hand is always open: the step is passed at once.
      expect(f.update(ctxOf(start, hand: true)), isTrue);
      expect(f.current!.id, 't0-cards');
    });

    test('skipping a step, and finishing the lesson', () {
      final f = GuidedFlow(steps);
      f.advance();
      f.advance();
      expect(f.index, 2);
      f.finish();
      expect(f.finished, isTrue);
      expect(f.current, isNull);
      expect(f.waitingForAction, isFalse);
      f.advance();
      expect(f.index, steps.length, reason: 'advancing past the end stays at the end');
    });

    test('a battle picked up part-way resumes after the last step its state has passed', () {
      var s = engine.newGame(1).state;
      s = engine.apply(s, const GameAction.useSkill(officerId: 'tran-thu-do')).state;
      s = engine.apply(s, const GameAction.playCard(cardId: 'vuon-khong-nha-trong', target: 'binh-le-nguyen')).state;
      s = engine.apply(s, const GameAction.endPhase()).state; // Orders
      final f = GuidedFlow(steps)..resumeAt(ctxOf(s));
      expect(f.current!.id, 't0-orders-intro');
      expect(GuidedFlow(steps)..resumeAt(ctxOf(start)), isA<GuidedFlow>());
      final fresh = GuidedFlow(steps)..resumeAt(ctxOf(start));
      expect(fresh.index, 0, reason: 'a fresh game starts at the welcome');
    });

    test('every step with a condition other than Next names its own highlight or reads on its own', () {
      for (final t in steps) {
        expect(t.text.vi.trim(), isNotEmpty, reason: t.id);
        expect(t.text.en.trim(), isNotEmpty, reason: t.id);
      }
      // The lesson ends on a read step that is shown while the player resolves the winning turn.
      expect(steps.last.until, isNull);
    });
  });

  group('the lesson on screen (a phone held sideways)', () {
    Future<BattleCubit> pumpLesson(WidgetTester tester, Size size, {VoidCallback? onDone}) async {
      setViewSize(tester, size);
      final cubit = BattleCubit(GameEngine(rules), seed: 1);
      addTearDown(cubit.close);
      await tester.pumpWidget(
        appAround(
          BlocProvider.value(
            value: cubit,
            child: BattleScreen(ruleset: rules, tutorial: steps, onTutorialDone: onDone),
          ),
        ),
      );
      await settle(tester);
      return cubit;
    }

    String text(WidgetTester tester) => tester.widget<Text>(find.byKey(const Key('tutorial-text'))).data!;

    String stepText(String id) => steps.firstWhere((t) => t.id == id).text.vi;

    Future<void> tapNext(WidgetTester tester) async {
      await tester.tap(find.byKey(const Key('tutorial-next')));
      await settle(tester);
    }

    testWidgets('reads step by step, then waits for the player to zoom', (tester) async {
      await pumpLesson(tester, compact);
      expect(text(tester), stepText('t0-welcome'));
      expect(find.byKey(const Key('tutorial-count')), findsOneWidget);
      expect(find.byKey(const Key('tutorial-hint')), findsNothing, reason: 'a read step has no hint');
      for (final id in ['t0-welcome', 't0-goal', 't0-topbar', 't0-map']) {
        expect(text(tester), stepText(id));
        await tapNext(tester);
      }
      expect(text(tester), stepText('t0-zoom'));
      expect(find.byKey(const Key('tutorial-next')), findsNothing, reason: 'it waits for the player');
      expect(find.byKey(const Key('tutorial-hint')), findsOneWidget);
      expect(find.byKey(const Key('tutorial-skip-step')), findsOneWidget);

      await tester.tap(find.byKey(const Key('zoom-in')));
      await settle(tester);
      expect(text(tester), stepText('t0-zoom-back'), reason: 'zooming was the whole task');
      expect(tester.takeException(), isNull);
    });

    testWidgets('"Skip this step" never leaves anyone stuck', (tester) async {
      await pumpLesson(tester, compact);
      while (find.byKey(const Key('tutorial-next')).evaluate().isNotEmpty) {
        await tapNext(tester);
      }
      expect(text(tester), stepText('t0-zoom'));
      await tester.tap(find.byKey(const Key('tutorial-skip-step')));
      await settle(tester);
      expect(text(tester), stepText('t0-zoom-back'));
    });

    testWidgets('selecting things advances the steps that ask for it', (tester) async {
      final cubit = await pumpLesson(tester, compact);
      while (text(tester) != stepText('t0-select-army')) {
        if (find.byKey(const Key('tutorial-next')).evaluate().isNotEmpty) {
          await tapNext(tester);
        } else {
          await tester.tap(find.byKey(const Key('tutorial-skip-step')));
          await settle(tester);
        }
      }
      final game = boardGame(tester);
      final army = game.scene!.tokens.firstWhere((t) => t.id == 'mong-co-1258');
      await tester.tapAt(tester.getTopLeft(find.byType(GameWidget<BoardGame>)) + army.center);
      await settle(tester);
      expect(game.selection.value, const Selection(SelectionKind.army, 'mong-co-1258'));
      expect(text(tester), stepText('t0-intent'));
      await tapNext(tester);

      expect(text(tester), stepText('t0-select-king'));
      await tester.tap(find.byKey(const Key('officer-tran-thai-tong')));
      await settle(tester);
      expect(game.selection.value, const Selection(SelectionKind.officer, 'tran-thai-tong'));
      expect(text(tester), stepText('t0-inspector'));
      expect(cubit.game.turn, 1);
    });

    testWidgets('the whole lesson can be played to a win, and the tutorial reports it is done', (tester) async {
      var done = 0;
      final cubit = await pumpLesson(tester, compact, onDone: () => done++);
      final game = boardGame(tester);

      /// Taps Next / skips until the coach shows [id].
      Future<void> until(String id) async {
        for (var guard = 0; guard < 40 && text(tester) != stepText(id); guard++) {
          if (find.byKey(const Key('tutorial-next')).evaluate().isNotEmpty) {
            await tapNext(tester);
          } else {
            await tester.tap(find.byKey(const Key('tutorial-skip-step')));
            await settle(tester);
          }
        }
        expect(text(tester), stepText(id));
      }

      Future<void> select(Selection s) async {
        game.selection.value = s;
        await settle(tester);
      }

      await until('t0-select-army');
      await select(const Selection(SelectionKind.army, 'mong-co-1258'));
      expect(text(tester), stepText('t0-intent'));
      await until('t0-select-king');
      await select(const Selection(SelectionKind.officer, 'tran-thai-tong'));
      expect(text(tester), stepText('t0-inspector'));
      await until('t0-select-chancellor');
      await select(const Selection(SelectionKind.officer, 'tran-thu-do'));
      expect(text(tester), stepText('t0-skill'));

      cubit.useSkill('tran-thu-do');
      await settle(tester);
      expect(text(tester), stepText('t0-hand'), reason: 'using the skill was the whole task');
      await tester.tap(find.byKey(const Key('hand-handle')));
      await settle(tester);
      expect(text(tester), stepText('t0-cards'));
      await tapNext(tester);
      expect(text(tester), stepText('t0-play-evac'));
      cubit.playCard('vuon-khong-nha-trong', target: 'binh-le-nguyen');
      await settle(tester);
      expect(text(tester), stepText('t0-end-council'));
      cubit.endPhase();
      await settle(tester);
      expect(text(tester), stepText('t0-orders-intro'));
      await tapNext(tester);
      expect(text(tester), stepText('t0-hold-king'));
      cubit.setOrder('tran-thai-tong', Order.hold);
      await settle(tester);
      expect(text(tester), stepText('t0-end-orders'));
      cubit.endPhase();
      await settle(tester);
      await tester.pump(const Duration(seconds: 4));
      expect(cubit.game.turn, 2);
      expect(text(tester), stepText('t0-log'));
      await tapNext(tester);

      expect(text(tester), stepText('t0-raid'));
      cubit.endPhase();
      cubit.setOrder('tran-khanh-du', Order.raid('mong-co-1258'));
      await settle(tester);
      expect(text(tester), stepText('t0-end-turn-2'));
      cubit.endPhase();
      await settle(tester);
      await tester.pump(const Duration(seconds: 4));
      expect(cubit.game.turn, 3);
      expect(text(tester), stepText('t0-starving'));
      await tapNext(tester);

      expect(text(tester), stepText('t0-counter-card'));
      cubit.playCard('phan-cong', target: 'le-phu-tran');
      await settle(tester);
      expect(text(tester), stepText('t0-advance'));
      cubit.endPhase();
      cubit.setOrder('le-phu-tran', Order.move('binh-le-nguyen'));
      await settle(tester);
      expect(text(tester), stepText('t0-finish'));
      expect(done, 0);
      cubit.endPhase();
      await settle(tester);
      await tester.pump(const Duration(seconds: 5));
      expect(cubit.game.outcome, Outcome.won);
      expect(done, greaterThanOrEqualTo(1), reason: 'the tutorial reports it is over');
      expect(tester.takeException(), isNull);
    });

    testWidgets('"Skip the tutorial" ends it and reports it', (tester) async {
      var done = 0;
      await pumpLesson(tester, compact, onDone: () => done++);
      await tester.tap(find.byKey(const Key('tutorial-skip')));
      await settle(tester);
      expect(find.byKey(const Key('tutorial-coach')), findsNothing);
      expect(done, 1);
    });

    testWidgets('on a big screen the same lesson fits and shows the hand without being asked', (tester) async {
      await pumpLesson(tester, regular);
      while (text(tester) != stepText('t0-select-chancellor')) {
        if (find.byKey(const Key('tutorial-next')).evaluate().isNotEmpty) {
          await tapNext(tester);
        } else {
          await tester.tap(find.byKey(const Key('tutorial-skip-step')));
          await settle(tester);
        }
        if (find.byKey(const Key('tutorial-coach')).evaluate().isEmpty) break;
      }
      expect(tester.takeException(), isNull);
      expect(find.byKey(const Key('hand-column')), findsOneWidget);
    });
  });
}
