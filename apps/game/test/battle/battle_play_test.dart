import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lk_rules/lk_rules.dart';
import 'package:long_ky_game/features/battle/battle_cubit.dart';
import 'package:long_ky_game/features/battle/board/board_scene.dart';
import 'package:long_ky_game/features/battle/labels.dart';
import 'package:long_ky_game/features/battle/overlays/hand.dart';

import 'overlay_support.dart';

typedef Tap = Future<void> Function(Finder f);

/// Playing a mission through the screen: orders, cards, the choice dialog,
/// the battle preview, animations and reduce motion, with touch and mouse.
void main() {
  final rules = ruleset(mission);
  final l = strings('vi');

  Tap touch(WidgetTester tester) => (f) async {
    await tester.ensureVisible(f);
    await tester.pump();
    await tester.tap(f);
    await settle(tester);
  };

  Tap mouse(WidgetTester tester) => (f) async {
    await tester.ensureVisible(f);
    await tester.pump();
    await mouseTap(tester, f);
    await settle(tester);
  };

  Finder card(String id) => find.byWidgetPredicate((w) => w is CardTile && w.card.id == id).first;

  /// Opens a card from the hand: a column on regular, the fan on compact.
  Future<void> openCard(WidgetTester tester, BattleLayoutMode mode, Tap tap, String id) async {
    if (mode.isCompact) {
      await tap(find.byKey(const Key('hand-handle')));
      // Cards overlap in the fan: tap the visible left part.
      final at = tester.getTopLeft(card(id)) + const Offset(24, 40);
      await tester.tapAt(at);
      await settle(tester);
    } else {
      await tap(card(id));
    }
    expect(find.byKey(const Key('card-dialog')), findsOneWidget);
  }

  for (final (name, size, mode) in layouts) {
    group('orders ($name)', () {
      testWidgets('an officer is given orders in the Orders phase, freely changed, and cleared', (tester) async {
        final cubit = await pumpBattle(tester, size);
        final tap = touch(tester);
        await tap(find.byKey(const Key('officer-tran-thai-tong')));
        // Council: no orders yet.
        expect(find.text(l.ordersOnlyInOrders), findsOneWidget);
        expect(find.byKey(const Key('order-move-thang-long')), findsNothing);

        await tap(find.byKey(const Key('phase-button')));
        expect(cubit.game.phase, Phase.orders);
        expect(
          find.byKey(const Key('order-move-thang-long')),
          findsOneWidget,
          reason: 'the inspector follows the phase',
        );

        await tap(find.byKey(const Key('order-move-thang-long')));
        expect(cubit.game.officers['tran-thai-tong']!.order, Order.move('thang-long'));
        // Changed freely until the phase ends.
        await tap(find.byKey(const Key('order-rally-none')));
        // Staying at the node the Yuan assault is a battle: confirm the preview.
        expect(find.byKey(const Key('battle-preview')), findsOneWidget);
        await tap(find.byKey(const Key('preview-confirm')));
        expect(cubit.game.officers['tran-thai-tong']!.order, Order.rally);
        expect(find.textContaining(l.orderRally), findsWidgets);
        await tap(find.byKey(const Key('order-clear')));
        expect(cubit.game.officers['tran-thai-tong']!.order, isNull);
        expect(tester.takeException(), isNull);
      });

      testWidgets('an order that causes a battle opens the preview: Cancel gives no order, confirming gives it', (
        tester,
      ) async {
        final cubit = await pumpBattle(tester, size);
        final tap = touch(tester);
        await tap(find.byKey(const Key('phase-button')));
        await tap(find.byKey(const Key('officer-tran-thai-tong')));

        await tap(find.byKey(const Key('order-hold-none')));
        expect(find.byKey(const Key('battle-preview')), findsOneWidget);
        expect(
          find.text(l.previewField(l.content(rules.map.nodes.firstWhere((n) => n.id == 'binh-le-nguyen').name))),
          findsOneWidget,
        );
        await tap(find.byKey(const Key('preview-cancel')));
        expect(find.byKey(const Key('battle-preview')), findsNothing);
        expect(cubit.game.officers['tran-thai-tong']!.order, isNull);

        await tap(find.byKey(const Key('order-hold-none')));
        await tap(find.byKey(const Key('preview-confirm')));
        expect(cubit.game.officers['tran-thai-tong']!.order, Order.hold);
      });

      testWidgets('an order that causes no battle is given at once', (tester) async {
        final cubit = await pumpBattle(tester, size);
        final tap = touch(tester);
        await tap(find.byKey(const Key('phase-button')));
        await tap(find.byKey(const Key('officer-tran-thai-tong')));
        await tap(find.byKey(const Key('order-move-thang-long')));
        expect(find.byKey(const Key('battle-preview')), findsNothing);
        expect(cubit.game.officers['tran-thai-tong']!.order, Order.move('thang-long'));
      });

      testWidgets('an activated skill is used in Council', (tester) async {
        final cubit = await pumpBattle(tester, size);
        final tap = touch(tester);
        await tap(find.byKey(const Key('officer-tran-thu-do')));
        expect(cubit.game.officers['tran-thu-do']!.skillUsesLeft, 1);
        await tap(find.byKey(const Key('skill-none')));
        expect(cubit.game.officers['tran-thu-do']!.skillUsesLeft, 0);
        expect(find.byKey(const Key('skill-none')), findsNothing, reason: 'no uses left');
      });
    });

    group('cards ($name)', () {
      testWidgets('a card is opened, played on a target and is final', (tester) async {
        final cubit = await pumpBattle(tester, size);
        final tap = touch(tester);
        final support = cubit.game.support;
        final hand = cubit.game.hand.length;
        await openCard(tester, mode, tap, 'vuon-khong-nha-trong');
        expect(find.text(l.cardFinal), findsOneWidget);

        await tap(find.byKey(const Key('play-binh-le-nguyen')));
        expect(find.byKey(const Key('card-dialog')), findsNothing);
        expect(cubit.game.nodes['binh-le-nguyen']!.evacuated, isTrue);
        expect(cubit.game.hand.length, hand - 1);
        expect(cubit.game.support, support - 2);
        expect(cubit.game.hand, isNot(contains('vuon-khong-nha-trong')));
        expect(tester.takeException(), isNull);
      });

      testWidgets('closing the dialog plays nothing', (tester) async {
        final cubit = await pumpBattle(tester, size);
        final tap = touch(tester);
        final before = cubit.state;
        await openCard(tester, mode, tap, 'vuon-khong-nha-trong');
        await tap(find.byKey(const Key('card-dialog-close')));
        expect(find.byKey(const Key('card-dialog')), findsNothing);
        expect(identical(cubit.state, before), isTrue);
      });

      testWidgets('in the Orders phase a card can be read but not played', (tester) async {
        await pumpBattle(tester, size);
        final tap = touch(tester);
        await tap(find.byKey(const Key('phase-button')));
        await openCard(tester, mode, tap, 'vuon-khong-nha-trong');
        expect(find.text(l.cardOnlyCouncil), findsOneWidget);
        expect(find.byKey(const Key('play-binh-le-nguyen')), findsNothing);
      });
    });

    group('choice dialog ($name)', () {
      testWidgets('a pending choice blocks the screen until one option is chosen', (tester) async {
        final cubit = await pumpBattle(tester, size, missionId: 'ch1_m1');
        expect(cubit.game.pendingChoice, isNotNull);
        expect(find.byKey(const Key('choice-overlay')), findsOneWidget);

        // Taps on the phase button and the strip do nothing behind the dialog.
        await tester.tap(find.byKey(const Key('phase-button')), warnIfMissed: false);
        await tester.tap(find.byKey(const Key('officer-tran-thai-tong')), warnIfMissed: false);
        await settle(tester);
        expect(cubit.game.phase, Phase.council);
        expect(find.byKey(const Key('inspector-officer')), findsNothing);
        expect(tester.widget<FilledButton>(find.byKey(const Key('phase-button'))).onPressed, isNull);

        await tester.tap(find.byKey(const Key('choice-0')));
        await settle(tester);
        expect(cubit.game.pendingChoice, isNull);
        expect(find.byKey(const Key('choice-overlay')), findsNothing);
        // The game goes on.
        await tester.tap(find.byKey(const Key('phase-button')));
        await settle(tester);
        expect(cubit.game.phase, Phase.orders);
      });
    });

    group('animations ($name)', () {
      /// Orders given, ready to end the turn.
      Future<BattleCubit> readyToResolve(WidgetTester tester, {bool reduceMotion = false}) async {
        final cubit = await pumpBattle(tester, size, reduceMotion: reduceMotion);
        cubit.endPhase();
        await settle(tester);
        cubit.setOrder('tran-thai-tong', Order.move('song-lo'));
        cubit.setOrder('le-phu-tran', Order.move('song-lo'));
        cubit.setOrder('tran-thu-do', Order.move('song-lo'));
        await settle(tester);
        return cubit;
      }

      testWidgets('ending the turn plays the moves in order, then the next turn begins', (tester) async {
        final cubit = await readyToResolve(tester);
        await tester.tap(find.byKey(const Key('phase-button')));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 20));

        // While it plays: the board is busy and the button waits.
        expect(boardGame(tester).busy.value, isTrue);
        await tester.pump(const Duration(milliseconds: 50));
        expect(find.text(l.phaseButtonWait), findsOneWidget);
        expect(tester.widget<FilledButton>(find.byKey(const Key('phase-button'))).onPressed, isNull);
        expect(find.byKey(const Key('result-screen')), findsNothing, reason: 'not before the animations end');
        // A tap on the button meanwhile changes nothing.
        final step = cubit.state.step;
        await tester.tap(find.byKey(const Key('phase-button')), warnIfMissed: false);
        expect(cubit.state.step, step);
        // The intent arrows of the next turn wait, and the army's token travels.
        expect(boardGame(tester).animator.moveOf('mong-co-1258'), isNotNull);

        await playOut(tester);
        // Turn 1 is over; the mission is not (it takes four turns).
        expect(find.byKey(const Key('result-screen')), findsNothing);
        expect(cubit.game.turn, 2);
        expect(cubit.game.phase, Phase.council);
        expect(find.text(l.phaseButtonCouncil), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('reduce motion skips every animation', (tester) async {
        final cubit = await readyToResolve(tester, reduceMotion: true);
        await tester.tap(find.byKey(const Key('phase-button')));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 20));
        expect(boardGame(tester).busy.value, isFalse);
        expect(boardGame(tester).animator.isBusy, isFalse);
        expect(cubit.game.turn, 2, reason: 'at once');
        expect(cubit.game.phase, Phase.council);
        expect(find.text(l.phaseButtonCouncil), findsOneWidget);
      });

      testWidgets('the board shows the new state once the animations are over', (tester) async {
        final cubit = await readyToResolve(tester);
        await tester.tap(find.byKey(const Key('phase-button')));
        await settle(tester);
        await playOut(tester);
        final scene = boardGame(tester).scene!;
        for (final t in scene.tokens.where((t) => t.kind == TokenKind.officer)) {
          expect(t.nodeId, cubit.game.officers[t.id]!.nodeId);
        }
      });
    });
  }

  group('a whole mission, start to finish', () {
    /// ch1_m2: evacuate Bình Lệ Nguyên by card, fall back to Sông Lô and hold it for four turns.
    Future<void> playMission(WidgetTester tester, Size size, BattleLayoutMode mode, Tap tap) async {
      var backed = 0;
      final cubit = await pumpBattle(tester, size, onExit: () => backed++);
      expect(cubit.game.phase, Phase.council);

      // Council: a card.
      await openCard(tester, mode, tap, 'vuon-khong-nha-trong');
      await tap(find.byKey(const Key('play-binh-le-nguyen')));
      expect(cubit.game.nodes['binh-le-nguyen']!.evacuated, isTrue);
      if (mode.isCompact) await tap(find.byKey(const Key('hand-handle')));

      // Council → Orders.
      await tap(find.byKey(const Key('phase-button')));
      expect(cubit.game.phase, Phase.orders);

      // Lê Phụ Trần first holds: the preview warns, they think again.
      await tap(find.byKey(const Key('officer-le-phu-tran')));
      await tap(find.byKey(const Key('order-hold-none')));
      expect(find.byKey(const Key('battle-preview')), findsOneWidget);
      await tap(find.byKey(const Key('preview-cancel')));
      expect(cubit.game.officers['le-phu-tran']!.order, isNull);

      // Everyone falls back to Sông Lô.
      for (final id in ['le-phu-tran', 'tran-thai-tong', 'tran-thu-do']) {
        await tap(find.byKey(Key('officer-$id')));
        await tap(find.byKey(const Key('order-move-song-lo')));
        expect(cubit.game.officers[id]!.order, Order.move('song-lo'), reason: id);
      }

      // End Orders: the turn resolves in front of the player.
      await tap(find.byKey(const Key('phase-button')));
      await playOut(tester);
      expect(cubit.game.isOver, isFalse);
      expect(cubit.game.turn, 2);

      // Three more turns of holding at Sông Lô: Council, then Orders.
      for (var turn = 2; turn <= 4; turn++) {
        await tap(find.byKey(const Key('phase-button')));
        await tap(find.byKey(const Key('phase-button')));
        await playOut(tester);
      }
      expect(cubit.game.outcome, Outcome.won);
      expect(find.byKey(const Key('result-screen')), findsOneWidget);
      expect(find.byKey(const Key('result-title')), findsOneWidget);
      expect(find.text(l.outcomeWon), findsOneWidget);
      expect(tester.widget<FilledButton>(find.byKey(const Key('phase-button'))).onPressed, isNull);

      await tap(find.byKey(const Key('result-back')));
      expect(backed, 1);
      expect(tester.takeException(), isNull);
    }

    testWidgets('ch1_m2 on a phone, with touch', (tester) async {
      await playMission(tester, compact, BattleLayoutMode.compact, touch(tester));
    });

    testWidgets('ch1_m2 on a desktop window, with the mouse', (tester) async {
      await playMission(tester, regular, BattleLayoutMode.regular, mouse(tester));
    });

    testWidgets('ch1_m2 on a tablet size with touch, and a phone with the mouse (both inputs on both layouts)', (
      tester,
    ) async {
      await playMission(tester, regular, BattleLayoutMode.regular, touch(tester));
    });

    testWidgets('ch1_m2 on a phone with the mouse', (tester) async {
      await playMission(tester, compact, BattleLayoutMode.compact, mouse(tester));
    });
  });
}
