import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lk_rules/lk_rules.dart';
import 'package:long_ky_game/features/battle/board/board_game.dart';
import 'package:long_ky_game/features/battle/board/board_scene.dart';
import 'package:long_ky_game/features/battle/labels.dart';
import 'package:long_ky_game/features/battle/overlays/hand.dart';

import 'overlay_support.dart';

/// The whole battle screen: overlays around the Flame board, at both layouts.
void expectInside(Rect r, Size size) {
  expect(r.left, greaterThanOrEqualTo(-0.01), reason: '$r');
  expect(r.top, greaterThanOrEqualTo(-0.01), reason: '$r');
  expect(r.right, lessThanOrEqualTo(size.width + 0.01), reason: '$r');
  expect(r.bottom, lessThanOrEqualTo(size.height + 0.01), reason: '$r');
}

void main() {
  final rules = ruleset(mission);
  final boardFinder = find.byType(GameWidget<BoardGame>);

  Future<void> tapBoardAt(WidgetTester tester, Offset boardLocal) async {
    await tester.tapAt(tester.getTopLeft(boardFinder) + boardLocal);
    await settle(tester);
  }

  for (final (name, size, mode) in layouts) {
    group('battle screen ($name, ${size.width.toInt()}×${size.height.toInt()})', () {
      testWidgets('draws every overlay and the board without errors', (tester) async {
        await pumpBattle(tester, size);
        expect(tester.takeException(), isNull);
        expect(find.byKey(const Key('top-bar')), findsOneWidget);
        expect(find.byKey(const Key('officer-strip')), findsOneWidget);
        expect(find.byKey(const Key('phase-button')), findsOneWidget);
        expect(boardFinder, findsOneWidget);
        expect(boardGame(tester).scene!.nodes, hasLength(9));
        // Nothing is selected, so no inspector.
        expect(find.byKey(const Key('inspector-node')), findsNothing);
        expect(find.byKey(const Key('inspector-officer')), findsNothing);
        if (mode.isCompact) {
          expect(find.byKey(const Key('hand-handle')), findsOneWidget);
          expect(find.byKey(const Key('hand-column')), findsNothing);
          expect(find.byKey(const Key('log-button')), findsOneWidget);
          expect(find.byKey(const Key('log-panel')), findsNothing);
        } else {
          expect(find.byKey(const Key('hand-column')), findsOneWidget);
          expect(find.byKey(const Key('hand-handle')), findsNothing);
          expect(find.byKey(const Key('log-panel')), findsOneWidget);
          expect(find.byKey(const Key('log-button')), findsNothing);
        }
      });

      testWidgets('the board sits in the space the overlays leave, and nothing sticks out of the screen', (
        tester,
      ) async {
        await pumpBattle(tester, size);
        final board = tester.getRect(boardFinder);
        final top = tester.getRect(find.byKey(const Key('top-bar')));
        final strip = tester.getRect(find.byKey(const Key('officer-strip')));
        final phase = tester.getRect(find.byKey(const Key('phase-button')));
        expectInside(board, size);
        expect(board.top, greaterThanOrEqualTo(top.bottom));
        expect(board.bottom, lessThanOrEqualTo(strip.top + 0.5));
        expect(board.overlaps(phase), isFalse);
        if (mode.isCompact) {
          expect(strip.right, lessThanOrEqualTo(phase.left + 0.5), reason: 'the strip stops where the buttons start');
          expect(board.width, size.width);
        } else {
          final hand = tester.getRect(find.byKey(const Key('hand-column')));
          final log = tester.getRect(find.byKey(const Key('log-panel')));
          expect(board.right, lessThanOrEqualTo(hand.left + 0.5));
          expect(board.left, greaterThanOrEqualTo(log.right - 0.5));
          expect(phase.bottom, lessThanOrEqualTo(size.height));
        }
        // The Flame scene was laid out for exactly that space.
        expect(boardGame(tester).scene!.layout.size, board.size);
        expect(tester.takeException(), isNull);
      });

      testWidgets('buttons are at least 48 px', (tester) async {
        await pumpBattle(tester, size, onExit: () {});
        final targets = [
          find.byKey(const Key('phase-button')),
          find.byKey(const Key('battle-exit')),
          if (mode.isCompact) find.byKey(const Key('hand-handle')),
          if (mode.isCompact) find.byKey(const Key('log-button')),
          if (!mode.isCompact) find.byKey(const Key('log-toggle')),
        ];
        for (final f in targets) {
          final s = tester.getSize(f);
          expect(s.width, greaterThanOrEqualTo(48), reason: '$f');
          expect(s.height, greaterThanOrEqualTo(48), reason: '$f');
        }
      });

      testWidgets('the back button calls onExit', (tester) async {
        var exits = 0;
        await pumpBattle(tester, size, onExit: () => exits++);
        await tester.tap(find.byKey(const Key('battle-exit')));
        expect(exits, 1);
      });

      testWidgets('tapping an officer in the strip selects them on the board and opens the inspector', (tester) async {
        await pumpBattle(tester, size);
        await tester.tap(find.byKey(const Key('officer-tran-thai-tong')));
        await settle(tester);
        expect(boardGame(tester).selection.value, const Selection(SelectionKind.officer, 'tran-thai-tong'));
        expect(boardGame(tester).scene!.selection, const Selection(SelectionKind.officer, 'tran-thai-tong'));
        expect(find.byKey(const Key('inspector-officer')), findsOneWidget);
        expect(find.text(strings('vi').content(rules.officers['tran-thai-tong']!.name)), findsWidgets);
        expect(tester.takeException(), isNull);
      });

      testWidgets('tapping a token or a node on the board opens the matching inspector; the close button clears it', (
        tester,
      ) async {
        await pumpBattle(tester, size);
        final scene = boardGame(tester).scene!;

        final army = scene.tokens.firstWhere((t) => t.kind == TokenKind.army);
        await tapBoardAt(tester, army.center);
        expect(find.byKey(const Key('inspector-army')), findsOneWidget);

        // Close it (on compact the sheet may cover the next target).
        await tester.tap(find.byKey(const Key('inspector-close')));
        await settle(tester);
        expect(boardGame(tester).selection.value, isNull);
        expect(find.byKey(const Key('inspector-army')), findsNothing);

        final empty = scene.nodes.firstWhere((n) => n.id == 'thang-long');
        await tapBoardAt(tester, empty.center);
        expect(find.byKey(const Key('inspector-node')), findsOneWidget);

        await tester.tap(find.byKey(const Key('inspector-close')));
        await settle(tester);
        expect(boardGame(tester).selection.value, isNull);
        expect(find.byKey(const Key('inspector-node')), findsNothing);
        expect(tester.takeException(), isNull);
      });

      testWidgets('the inspector sits where its layout says', (tester) async {
        await pumpBattle(tester, size);
        final scene = boardGame(tester).scene!;
        // Thăng Long: no token on it, so a tap on its centre is a node tap.
        final node = scene.nodes.firstWhere((n) => n.id == 'thang-long');
        await tapBoardAt(tester, node.center);
        final panel = tester.getRect(find.byKey(const Key('inspector-node')));
        expectInside(panel, size);
        final bottomRow = tester.getRect(find.byKey(const Key('officer-strip')));
        final phase = tester.getRect(find.byKey(const Key('phase-button')));
        if (mode.isCompact) {
          // Bottom sheet: touches the bottom row from above, never covers the phase button.
          expect(panel.bottom, closeTo(bottomRow.top, 0.5));
          expect(panel.overlaps(phase), isFalse);
          expect(panel.top, greaterThanOrEqualTo(tester.getRect(find.byKey(const Key('top-bar'))).bottom));
        } else {
          // Floating next to the selection: inside the board area, beside the node, not on it.
          final board = tester.getRect(boardFinder);
          final centre = board.topLeft + node.center;
          expect(panel.left, greaterThanOrEqualTo(board.left));
          expect(panel.right, lessThanOrEqualTo(board.right));
          expect(panel.top, greaterThanOrEqualTo(board.top));
          expect(panel.bottom, lessThanOrEqualTo(board.bottom));
          expect(
            panel.inflate(-0.1).contains(centre),
            isFalse,
            reason: 'the panel must not cover the node it is about',
          );
          expect(panel.width, lessThanOrEqualTo(300));
          expect((panel.center - centre).distance, lessThan(600));
          expect(panel.overlaps(tester.getRect(find.byKey(const Key('hand-column')))), isFalse);
        }
      });

      testWidgets('the phase button ends Council, shows Orders, and the log records it', (tester) async {
        final cubit = await pumpBattle(tester, size);
        final l = strings('vi');
        expect(cubit.state.state.phase, Phase.council);
        expect(find.text(l.phaseButtonCouncil), findsOneWidget);

        await tester.tap(find.byKey(const Key('phase-button')));
        await settle(tester);
        expect(cubit.state.state.phase, Phase.orders);
        expect(find.text(l.phaseButtonOrders), findsOneWidget);
        // The top bar follows the state.
        expect(
          find.descendant(of: find.byKey(const Key('top-bar')), matching: find.text(l.phaseOrders)),
          findsOneWidget,
        );

        // Open the log (compact) or read the side panel (regular).
        if (mode.isCompact) {
          expect(find.byKey(const Key('log-popover')), findsNothing);
          await tester.tap(find.byKey(const Key('log-button')));
          await settle(tester);
        }
        expect(find.text(l.logPhaseChanged(l.phaseOrders)), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('ending Orders resolves the turn; at the end of the mission the button says so', (tester) async {
        final cubit = await pumpBattle(tester, size);
        // With no orders the king falls back and the season runs out: four turns of Council and Orders.
        for (var turn = 1; turn <= 4; turn++) {
          await tester.tap(find.byKey(const Key('phase-button')));
          await settle(tester);
          await tester.tap(find.byKey(const Key('phase-button')));
          await settle(tester);
          await playOut(tester);
          expect(cubit.state.state.isOver, turn == 4, reason: 'turn $turn');
        }
        expect(cubit.state.state.outcome, Outcome.lost);
        expect(find.text(strings('vi').phaseButtonEnded), findsOneWidget);
        expect(tester.widget<FilledButton>(find.byKey(const Key('phase-button'))).onPressed, isNull);
        expect(tester.takeException(), isNull);
      });

      testWidgets('the English UI shows English text everywhere', (tester) async {
        await pumpBattle(tester, size, lang: 'en');
        final l = strings('en');
        expect(find.text(l.phaseButtonCouncil), findsOneWidget);
        expect(find.text(l.unityCourt), findsOneWidget);
        expect(boardGame(tester).scene!.nodes.map((n) => n.name), contains('Bình Lệ Nguyên'));
        expect(tester.takeException(), isNull);
      });

      testWidgets('150% text size still lays out without overflow', (tester) async {
        await pumpBattle(tester, size, textScale: 1.5);
        await tester.tap(find.byKey(const Key('officer-tran-thu-do')));
        await settle(tester);
        expect(tester.takeException(), isNull);
      });
    });
  }

  group('compact only', () {
    testWidgets('the hand fan opens from the handle and closes again; cards select', (tester) async {
      await pumpBattle(tester, compact);
      final cubit = tester.element(find.byKey(const Key('hand-handle')));
      expect(cubit, isNotNull);
      expect(find.byKey(const Key('hand-fan')), findsNothing);
      await tester.tap(find.byKey(const Key('hand-handle')));
      await settle(tester);
      expect(find.byKey(const Key('hand-fan')), findsOneWidget);
      final fan = tester.getRect(find.byKey(const Key('hand-fan')));
      expect(fan.left, greaterThanOrEqualTo(0));
      expect(fan.right, lessThanOrEqualTo(compact.width));
      expect(fan.bottom, lessThanOrEqualTo(tester.getRect(find.byKey(const Key('officer-strip'))).top + 5));
      // Tapping a card opens it; closing the dialog and tapping the handle closes the fan.
      final first = find.byWidgetPredicate((w) => w is CardTile);
      expect(first, findsNWidgets(rules.mission.handSize));
      await tester.tapAt(tester.getTopLeft(first.first) + const Offset(20, 40));
      await settle(tester);
      expect(find.byKey(const Key('card-dialog')), findsOneWidget);
      await tester.tap(find.byKey(const Key('card-dialog-close')));
      await settle(tester);
      expect(tester.takeException(), isNull);
      await tester.tap(find.byKey(const Key('hand-handle')));
      await settle(tester);
      expect(find.byKey(const Key('hand-fan')), findsNothing);
    });

    testWidgets('the log opens behind a button and closes again', (tester) async {
      await pumpBattle(tester, compact);
      expect(find.byKey(const Key('log-popover')), findsNothing);
      await tester.tap(find.byKey(const Key('log-button')));
      await settle(tester);
      expect(find.byKey(const Key('log-popover')), findsOneWidget);
      expectInside(tester.getRect(find.byKey(const Key('log-popover'))), compact);
      await tester.tap(find.byKey(const Key('log-close')));
      await settle(tester);
      expect(find.byKey(const Key('log-popover')), findsNothing);
    });
  });

  group('regular only', () {
    testWidgets('the hand is always visible; the log panel collapses and gives the room to the board', (tester) async {
      await pumpBattle(tester, regular);
      final l = strings('vi');
      final cubit = tester.element(find.byKey(const Key('hand-column')));
      expect(cubit, isNotNull);
      expect(find.text(l.handTitle(rules.mission.handSize)), findsOneWidget);
      final wide = tester.getRect(boardFinder);
      expect(find.text(l.logTitle), findsOneWidget);

      await tester.tap(find.byKey(const Key('log-toggle')));
      await settle(tester);
      expect(find.text(l.logTitle), findsNothing);
      final wider = tester.getRect(boardFinder);
      expect(wider.width, greaterThan(wide.width));
      expect(wider.right, wide.right, reason: 'only the left edge moves');
      expect(boardGame(tester).scene!.layout.size, wider.size, reason: 'the board follows its new size');

      await tester.tap(find.byKey(const Key('log-toggle')));
      await settle(tester);
      expect(tester.getRect(boardFinder).width, wide.width);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a selection stays selected while the log panel moves the board', (tester) async {
      await pumpBattle(tester, regular);
      await tester.tap(find.byKey(const Key('officer-le-phu-tran')));
      await settle(tester);
      await tester.tap(find.byKey(const Key('log-toggle')));
      await settle(tester);
      expect(boardGame(tester).selection.value, const Selection(SelectionKind.officer, 'le-phu-tran'));
      expect(find.byKey(const Key('inspector-officer')), findsOneWidget);
    });
  });

  group('resizing', () {
    testWidgets('growing the window from phone to desktop size swaps the layout and keeps the selection', (
      tester,
    ) async {
      await pumpBattle(tester, compact);
      await tester.tap(find.byKey(const Key('officer-tran-thai-tong')));
      await settle(tester);
      expect(find.byKey(const Key('hand-handle')), findsOneWidget);

      tester.view.physicalSize = regular;
      await settle(tester);
      expect(find.byKey(const Key('hand-column')), findsOneWidget);
      expect(find.byKey(const Key('hand-handle')), findsNothing);
      expect(boardGame(tester).selection.value, const Selection(SelectionKind.officer, 'tran-thai-tong'));
      expect(find.byKey(const Key('inspector-officer')), findsOneWidget);
      expect(boardGame(tester).scene!.layout.size, tester.getRect(boardFinder).size);
      expect(tester.takeException(), isNull);
    });

    testWidgets('the breakpoint is 900', (tester) async {
      await pumpBattle(tester, const Size(899, 600));
      expect(find.byKey(const Key('hand-handle')), findsOneWidget);
      tester.view.physicalSize = const Size(900, 600);
      await settle(tester);
      expect(find.byKey(const Key('hand-column')), findsOneWidget);
    });
  });
}
