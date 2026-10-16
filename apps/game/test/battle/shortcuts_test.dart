import 'package:flame/game.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lk_rules/lk_rules.dart';
import 'package:long_ky_game/features/battle/battle_keys.dart';
import 'package:long_ky_game/features/battle/board/board_game.dart';
import 'package:long_ky_game/features/battle/board/board_scene.dart';
import 'package:long_ky_game/features/battle/labels.dart';

import 'overlay_support.dart';

/// The keyboard, the right button and hover (build-spec section 6), on
/// both layouts.
void main() {
  final rules = ruleset(mission);
  final l = strings('vi');

  group('commandForKey', () {
    test('Space and Enter end the phase; Esc escapes; Tab cycles; 1-9 pick a card', () {
      expect(commandForKey(LogicalKeyboardKey.space), isA<EndPhaseCommand>());
      expect(commandForKey(LogicalKeyboardKey.enter), isA<EndPhaseCommand>());
      expect(commandForKey(LogicalKeyboardKey.numpadEnter), isA<EndPhaseCommand>());
      expect(commandForKey(LogicalKeyboardKey.escape), isA<EscapeCommand>());
      expect((commandForKey(LogicalKeyboardKey.tab) as CycleOfficerCommand).step, 1);
      expect((commandForKey(LogicalKeyboardKey.tab, shift: true) as CycleOfficerCommand).step, -1);
      for (var i = 1; i <= 9; i++) {
        final key = LogicalKeyboardKey.findKeyByKeyId(LogicalKeyboardKey.digit1.keyId + i - 1)!;
        expect((commandForKey(key) as PickCardCommand).index, i - 1, reason: 'digit $i');
      }
      expect((commandForKey(LogicalKeyboardKey.numpad3) as PickCardCommand).index, 2);
    });

    test('other keys are not battle keys', () {
      for (final k in [LogicalKeyboardKey.keyA, LogicalKeyboardKey.digit0, LogicalKeyboardKey.arrowLeft]) {
        expect(commandForKey(k), isNull, reason: k.keyLabel);
      }
    });
  });

  group('cycleOfficer', () {
    const ids = ['a', 'b', 'c'];

    test('goes forwards and back, wrapping round', () {
      expect(cycleOfficer(ids, 'a', 1), 'b');
      expect(cycleOfficer(ids, 'c', 1), 'a');
      expect(cycleOfficer(ids, 'a', -1), 'c');
      expect(cycleOfficer(ids, 'b', -1), 'a');
    });

    test('with nobody current: first going forwards, last going back', () {
      expect(cycleOfficer(ids, null, 1), 'a');
      expect(cycleOfficer(ids, null, -1), 'c');
    });

    test('an officer who is no longer in the list counts as nobody (captured, defected)', () {
      expect(cycleOfficer(const ['a', 'c'], 'b', 1), 'a');
      expect(cycleOfficer(const ['a', 'c'], 'b', -1), 'c');
    });

    test('nobody to go to', () {
      expect(cycleOfficer(const [], null, 1), isNull);
      expect(cycleOfficer(const ['a'], 'a', 1), 'a');
    });
  });

  for (final (name, size, mode) in layouts) {
    group('keyboard ($name)', () {
      testWidgets('Space ends Council; Enter ends Orders', (tester) async {
        final cubit = await pumpBattle(tester, size);
        expect(cubit.game.phase, Phase.council);
        await tester.sendKeyEvent(LogicalKeyboardKey.space);
        await settle(tester);
        expect(cubit.game.phase, Phase.orders);
        cubit.setOrder('tran-thai-tong', Order.move('thang-long'));
        cubit.setOrder('le-phu-tran', Order.move('thang-long'));
        cubit.setOrder('tran-thu-do', Order.move('thang-long'));
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await settle(tester);
        await playOut(tester);
        expect(cubit.game.outcome, Outcome.won);
      });

      testWidgets('works even after a button was tapped (a focused button does not take the key)', (tester) async {
        final cubit = await pumpBattle(tester, size);
        await tester.tap(find.byKey(const Key('officer-tran-thai-tong')));
        await settle(tester);
        await tester.sendKeyEvent(LogicalKeyboardKey.space);
        await settle(tester);
        expect(cubit.game.phase, Phase.orders);
      });

      testWidgets('is ignored while the animations play, and after the mission', (tester) async {
        final cubit = await pumpBattle(tester, size);
        cubit.endPhase();
        for (final id in ['tran-thai-tong', 'le-phu-tran', 'tran-thu-do']) {
          cubit.setOrder(id, Order.move('thang-long'));
        }
        await tester.sendKeyEvent(LogicalKeyboardKey.space);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));
        final step = cubit.state.step;
        await tester.sendKeyEvent(LogicalKeyboardKey.space);
        await tester.pump();
        expect(cubit.state.step, step, reason: 'busy');
        await playOut(tester);
        expect(cubit.game.isOver, isTrue);
        await tester.sendKeyEvent(LogicalKeyboardKey.space);
        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await settle(tester);
        expect(cubit.state.step, step, reason: 'nothing after the end');
        expect(find.byKey(const Key('battle-menu')), findsNothing);
      });

      testWidgets('keys do nothing under a choice dialog', (tester) async {
        final cubit = await pumpBattle(tester, size, missionId: 'ch1_m1');
        expect(cubit.game.pendingChoice, isNotNull);
        for (final k in [
          LogicalKeyboardKey.space,
          LogicalKeyboardKey.enter,
          LogicalKeyboardKey.escape,
          LogicalKeyboardKey.digit1,
          LogicalKeyboardKey.tab,
        ]) {
          await tester.sendKeyEvent(k);
        }
        await settle(tester);
        expect(cubit.game.pendingChoice, isNotNull);
        expect(cubit.game.phase, Phase.council);
        expect(find.byKey(const Key('card-dialog')), findsNothing);
        expect(find.byKey(const Key('battle-menu')), findsNothing);
      });

      testWidgets('1-9 open that card of the hand; a number past the hand does nothing', (tester) async {
        final cubit = await pumpBattle(tester, size);
        final hand = cubit.game.hand;
        expect(hand.length, 4);
        await tester.sendKeyEvent(LogicalKeyboardKey.digit2);
        await settle(tester);
        expect(find.byKey(const Key('card-dialog')), findsOneWidget);
        expect(find.text(l.content(rules.cards[hand[1]]!.name)), findsWidgets);
        // The dialog is on top: keys now belong to it (Esc closes it), not to the battle.
        final step = cubit.state.step;
        await tester.sendKeyEvent(LogicalKeyboardKey.space);
        await settle(tester);
        expect(cubit.state.step, step, reason: 'Space does not end the phase behind a dialog');
        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await settle(tester);
        expect(find.byKey(const Key('card-dialog')), findsNothing);

        await tester.sendKeyEvent(LogicalKeyboardKey.digit9);
        await settle(tester);
        expect(find.byKey(const Key('card-dialog')), findsNothing);
        await tester.sendKeyEvent(LogicalKeyboardKey.numpad1);
        await settle(tester);
        expect(find.byKey(const Key('card-dialog')), findsOneWidget);
      });

      testWidgets('Tab cycles the officers, wrapping round; Shift+Tab goes back', (tester) async {
        await pumpBattle(tester, size);
        final order = ['le-phu-tran', 'tran-thai-tong', 'tran-thu-do']; // sorted by id, as the strip is
        Selection? sel() => boardGame(tester).selection.value;

        for (var i = 0; i < 4; i++) {
          await tester.sendKeyEvent(LogicalKeyboardKey.tab);
          await settle(tester);
          expect(sel(), Selection(SelectionKind.officer, order[i % 3]), reason: 'Tab $i');
        }
        await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
        await settle(tester);
        expect(sel(), Selection(SelectionKind.officer, order[2]), reason: 'Shift+Tab from the second goes back one');
        expect(find.byKey(const Key('inspector-officer')), findsOneWidget);
      });

      testWidgets('Shift+Tab with nothing selected starts from the last officer', (tester) async {
        await pumpBattle(tester, size);
        await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
        await settle(tester);
        expect(boardGame(tester).selection.value, const Selection(SelectionKind.officer, 'tran-thu-do'));
      });

      testWidgets('Ctrl, Alt and Meta combinations are left to the system', (tester) async {
        final cubit = await pumpBattle(tester, size);
        await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
        await tester.sendKeyEvent(LogicalKeyboardKey.space);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
        await settle(tester);
        expect(cubit.game.phase, Phase.council);
      });
    });

    group('Esc ($name)', () {
      testWidgets('closes the inspector; with nothing open it opens the menu; Esc closes the menu', (tester) async {
        await pumpBattle(tester, size);
        await tester.tap(find.byKey(const Key('officer-tran-thai-tong')));
        await settle(tester);
        expect(find.byKey(const Key('inspector-officer')), findsOneWidget);

        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await settle(tester);
        expect(find.byKey(const Key('inspector-officer')), findsNothing);
        expect(find.byKey(const Key('battle-menu')), findsNothing);

        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await settle(tester);
        expect(find.byKey(const Key('battle-menu')), findsOneWidget);
        expect(find.text(l.battleMenuTitle), findsOneWidget);

        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await settle(tester);
        expect(find.byKey(const Key('battle-menu')), findsNothing);
      });

      testWidgets('the menu resumes, or leaves the battle', (tester) async {
        var left = 0;
        await pumpBattle(tester, size, onExit: () => left++);
        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await settle(tester);
        await tester.tap(find.byKey(const Key('menu-resume')));
        await settle(tester);
        expect(find.byKey(const Key('battle-menu')), findsNothing);
        expect(left, 0);

        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await settle(tester);
        await tester.tap(find.byKey(const Key('menu-leave')));
        await settle(tester);
        expect(left, 1);
      });

      testWidgets('English menu', (tester) async {
        await pumpBattle(tester, size, lang: 'en');
        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await settle(tester);
        expect(find.text('Paused'), findsOneWidget);
        expect(find.text('Leave the battle (saved)'), findsOneWidget);
      });
    });

    group('right button ($name)', () {
      Future<void> rightClick(WidgetTester tester, Offset at) async {
        final g = await tester.createGesture(kind: PointerDeviceKind.mouse, buttons: kSecondaryMouseButton);
        await g.down(at);
        await g.up();
        await g.removePointer();
        await settle(tester);
      }

      testWidgets('cancels the current selection', (tester) async {
        await pumpBattle(tester, size);
        await tester.tap(find.byKey(const Key('officer-tran-thai-tong')));
        await settle(tester);
        expect(boardGame(tester).selection.value, isNotNull);
        await rightClick(tester, tester.getCenter(find.byKey(const Key('top-bar'))));
        expect(boardGame(tester).selection.value, isNull);
        expect(find.byKey(const Key('inspector-officer')), findsNothing);
      });

      testWidgets('a left click does not cancel it', (tester) async {
        await pumpBattle(tester, size);
        await tester.tap(find.byKey(const Key('officer-tran-thai-tong')));
        await settle(tester);
        await tester.tapAt(tester.getCenter(find.byKey(const Key('top-bar'))));
        await settle(tester);
        expect(boardGame(tester).selection.value, isNotNull);
      });

      testWidgets('with nothing selected it does nothing', (tester) async {
        await pumpBattle(tester, size);
        await rightClick(tester, tester.getCenter(find.byKey(const Key('top-bar'))));
        expect(boardGame(tester).selection.value, isNull);
        expect(tester.takeException(), isNull);
      });
    });

    group('hover ($name)', () {
      testWidgets('resting the mouse on a token or node names it; leaving clears it', (tester) async {
        await pumpBattle(tester, size);
        final scene = boardGame(tester).scene!;
        final origin = tester.getTopLeft(find.byType(GameWidget<BoardGame>).first);
        final king = scene.tokens.firstWhere((t) => t.id == 'tran-thai-tong');
        final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
        await mouse.addPointer(location: Offset.zero);
        await mouse.moveTo(origin + king.center);
        await tester.pump();
        expect(find.byKey(const Key('board-hover')), findsOneWidget);
        expect(
          find.descendant(
            of: find.byKey(const Key('board-hover')),
            matching: find.text('${l.content(rules.officers['tran-thai-tong']!.name)} · ${l.troopsFull(12)}'),
          ),
          findsOneWidget,
        );

        final node = scene.nodes.firstWhere((n) => n.id == 'thang-long');
        await mouse.moveTo(origin + node.center);
        await tester.pump();
        expect(
          find.textContaining(l.terrainName(rules.map.nodes.firstWhere((n) => n.id == 'thang-long').terrain)),
          findsWidgets,
        );

        await mouse.moveTo(origin + const Offset(2, 2));
        await tester.pump();
        expect(find.byKey(const Key('board-hover')), findsNothing, reason: 'nothing under the pointer');
        await mouse.removePointer();
      });

      testWidgets('the label stays inside the board near its edges', (tester) async {
        await pumpBattle(tester, size);
        final scene = boardGame(tester).scene!;
        final origin = tester.getTopLeft(find.byType(GameWidget<BoardGame>).first);
        final boardRect = tester.getRect(find.byType(GameWidget<BoardGame>).first);
        final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
        await mouse.addPointer(location: Offset.zero);
        // The right-most node: its label would run past the right edge if placed to the right.
        final right = scene.nodes.reduce((a, b) => a.center.dx > b.center.dx ? a : b);
        await mouse.moveTo(origin + right.center);
        await tester.pump();
        final label = tester.getRect(find.byKey(const Key('board-hover')));
        expect(label.right, lessThanOrEqualTo(boardRect.right + 0.5));
        expect(label.left, greaterThanOrEqualTo(boardRect.left - 0.5));
        await mouse.removePointer();
      });

      testWidgets('officer tiles, the phase button and cards carry tooltips with their keys', (tester) async {
        await pumpBattle(tester, size);
        final tips = tester.widgetList<Tooltip>(find.byType(Tooltip)).map((t) => t.message ?? '').toList();
        expect(tips.any((t) => t.contains('(Tab)')), isTrue);
        expect(tips.any((t) => t.contains('(Space / Enter)')), isTrue);
        if (mode == BattleLayoutMode.regular) {
          expect(tips.any((t) => t.contains('(1)')), isTrue);
          expect(tips.any((t) => t.contains('(4)')), isTrue);
        }
      });
    });
  }
}
