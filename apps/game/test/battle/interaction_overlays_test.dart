import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lk_rules/lk_rules.dart';
import 'package:long_ky_game/features/battle/battle_preview.dart';
import 'package:long_ky_game/features/battle/labels.dart';
import 'package:long_ky_game/features/battle/overlays/card_dialog.dart';
import 'package:long_ky_game/features/battle/overlays/choice_overlay.dart';
import 'package:long_ky_game/features/battle/overlays/officer_actions.dart';
import 'package:long_ky_game/features/battle/overlays/outcome_banner.dart';
import 'package:long_ky_game/features/battle/overlays/preview_dialog.dart';

import 'overlay_support.dart';

/// Orders, skills, the card dialog, the battle preview, the choice dialog and
/// the outcome banner, each at both layouts.
void main() {
  final rules = ruleset(mission);
  final engine = GameEngine(rules);
  final council = engine.newGame(1).state;
  final orders = engine.apply(council, const GameAction.endPhase()).state;
  final l = strings('vi');
  final namer = Namer(l, rules);

  for (final (name, size, _) in layouts) {
    group('officer actions ($name)', () {
      Widget actions(
        GameState s,
        String id, {
        bool enabled = true,
        ValueChanged<Order>? onOrder,
        VoidCallback? onClear,
        ValueChanged<String?>? onSkill,
      }) => SizedBox(
        width: 360,
        height: size.height,
        // In the app it sits in the inspector's scroll view.
        child: SingleChildScrollView(
          child: OfficerActions(
            officerId: id,
            state: s,
            ruleset: rules,
            legal: engine.legalActions(s),
            enabled: enabled,
            onSetOrder: onOrder ?? (_) {},
            onClearOrder: onClear ?? () {},
            onUseSkill: onSkill ?? (_) {},
          ),
        ),
      );

      testWidgets('Council: an activated skill can be used; an officer without one is told orders come later', (
        tester,
      ) async {
        final used = <String?>[];
        await pumpOverlay(tester, size, actions(council, 'tran-thu-do', onSkill: used.add));
        expect(find.byKey(const Key('skill-none')), findsOneWidget);
        expect(find.text(l.skillUse), findsOneWidget);
        await tester.tap(find.byKey(const Key('skill-none')));
        expect(used, [null]);

        await pumpOverlay(tester, size, actions(council, 'tran-thai-tong'));
        expect(find.text(l.ordersOnlyInOrders), findsOneWidget);
        expect(find.byKey(const Key('skill-none')), findsNothing);
      });

      testWidgets('Orders: lists exactly the legal orders and sets the one tapped', (tester) async {
        final given = <Order>[];
        await pumpOverlay(tester, size, actions(orders, 'tran-thai-tong', onOrder: given.add));
        final legal = [
          for (final a in engine.legalActions(orders))
            if (a is SetOrder && a.officerId == 'tran-thai-tong') a.order,
        ];
        expect(legal, isNotEmpty);
        for (final o in legal) {
          expect(find.byKey(Key('order-${o.kind.name}-${o.target ?? 'none'}')), findsOneWidget, reason: '$o');
        }
        expect(find.byKey(const Key('order-clear')), findsNothing, reason: 'no order to clear yet');
        expect(find.text(l.ordersTitle), findsOneWidget);
        await tester.tap(find.byKey(const Key('order-move-thang-long')));
        expect(given, [Order.move('thang-long')]);
        await tester.tap(find.byKey(const Key('order-hold-none')));
        expect(given.last, Order.hold);
      });

      testWidgets('Orders: names targets, shows the Support cost of evacuating, and marks the current order', (
        tester,
      ) async {
        final withOrder = engine
            .apply(orders, const GameAction.setOrder(officerId: 'tran-thai-tong', order: Order.hold))
            .state;
        var cleared = 0;
        await pumpOverlay(tester, size, actions(withOrder, 'tran-thai-tong', onClear: () => cleared++));
        expect(find.text(l.orderWithTarget(l.orderMove, namer.node('thang-long'))), findsOneWidget);
        expect(find.text(l.orderCostSupport(l.orderEvacuate, l.resourceSupport, 1)), findsOneWidget);
        expect(find.text(l.orderWithTarget(l.orderRaid, namer.army(withOrder, 'mong-co-1258'))), findsOneWidget);
        // The current order is the filled button, the others are outlined.
        expect(
          find.descendant(of: find.byKey(const Key('order-hold-none')), matching: find.byType(FilledButton)),
          findsOneWidget,
        );
        expect(
          find.descendant(of: find.byKey(const Key('order-move-thang-long')), matching: find.byType(FilledButton)),
          findsNothing,
        );
        await tester.ensureVisible(find.byKey(const Key('order-clear')));
        await tester.tap(find.byKey(const Key('order-clear')));
        expect(cleared, 1);
      });

      testWidgets('Orders: evacuating costs more Support while People is low', (tester) async {
        final low = withUnity(orders, people: 3);
        await pumpOverlay(tester, size, actions(low, 'tran-thai-tong'));
        expect(find.text(l.orderCostSupport(l.orderEvacuate, l.resourceSupport, 2)), findsOneWidget);
      });

      testWidgets('every button is at least 48 px tall', (tester) async {
        await pumpOverlay(tester, size, actions(orders, 'le-phu-tran'));
        for (final b in tester.widgetList<ButtonStyleButton>(find.byWidgetPredicate((w) => w is ButtonStyleButton))) {
          expect(tester.getSize(find.byWidget(b)).height, greaterThanOrEqualTo(48));
        }
      });

      testWidgets('nothing is offered while animations play, a choice is pending, or the mission is over', (
        tester,
      ) async {
        await pumpOverlay(tester, size, actions(orders, 'tran-thai-tong', enabled: false));
        final b = tester.widget<OutlinedButton>(
          find.descendant(of: find.byKey(const Key('order-move-thang-long')), matching: find.byType(OutlinedButton)),
        );
        expect(b.onPressed, isNull);

        final over = orders.copyWith(phase: Phase.ended, outcome: Outcome.won);
        await pumpOverlay(tester, size, actions(over, 'tran-thai-tong'));
        expect(find.byType(OutlinedButton), findsNothing);

        final pending = orders.copyWith(
          pendingChoice: const PendingChoice(source: ChoiceSource.card, sourceId: 'x', path: [0], optionCount: 2),
        );
        await pumpOverlay(tester, size, actions(pending, 'tran-thai-tong'));
        expect(find.byType(OutlinedButton), findsNothing);
      });

      testWidgets('a withdrawn officer takes no orders', (tester) async {
        final s = orders.copyWith(
          officers: {
            ...orders.officers,
            'tran-thai-tong': orders.officers['tran-thai-tong']!.copyWith(withdrawn: true),
          },
        );
        await pumpOverlay(tester, size, actions(s, 'tran-thai-tong'));
        expect(find.text(l.orderNoOrders), findsOneWidget);
      });
    });

    group('card dialog ($name)', () {
      Widget dialog(GameState s, String cardId, {bool enabled = true, ValueChanged<String?>? onPlay}) => CardDialog(
        card: rules.cards[cardId]!,
        state: s,
        ruleset: rules,
        legal: engine.legalActions(s),
        enabled: enabled,
        onPlay: onPlay ?? (_) {},
      );

      testWidgets('shows the card in full and one button per legal target; a tap plays on that target', (tester) async {
        final played = <String?>[];
        await pumpOverlay(tester, size, dialog(council, 'vuon-khong-nha-trong', onPlay: played.add));
        final card = rules.cards['vuon-khong-nha-trong']!;
        expect(find.text(l.content(card.name)), findsOneWidget);
        expect(find.text(l.content(card.text)), findsOneWidget);
        expect(find.text(l.cardPickTarget), findsOneWidget);
        expect(find.text(l.cardFinal), findsOneWidget);
        final targets = [
          for (final a in engine.legalActions(council))
            if (a is PlayCard && a.cardId == card.id) a.target,
        ];
        expect(targets, hasLength(8));
        for (final t in targets) {
          expect(find.byKey(Key('play-$t')), findsOneWidget);
        }
        expect(find.text(l.cardPlayOn(namer.node('binh-le-nguyen'))), findsOneWidget);
        await tester.ensureVisible(find.byKey(const Key('play-binh-le-nguyen')));
        await tester.tap(find.byKey(const Key('play-binh-le-nguyen')));
        expect(played, ['binh-le-nguyen']);
      });

      testWidgets('a card with no target has one Play button', (tester) async {
        final played = <String?>[];
        final s = council.copyWith(hand: ['nang-nong']);
        await pumpOverlay(tester, size, dialog(s, 'nang-nong', onPlay: played.add));
        expect(find.text(l.cardPlay), findsOneWidget);
        expect(find.text(l.cardPickTarget), findsNothing);
        await tester.tap(find.byKey(const Key('play-none')));
        expect(played, [null]);
      });

      testWidgets('outside Council, with too little Support, or with nowhere to play, it says why and offers nothing', (
        tester,
      ) async {
        await pumpOverlay(tester, size, dialog(orders, 'vuon-khong-nha-trong'));
        expect(find.text(l.cardOnlyCouncil), findsOneWidget);
        expect(find.byType(FilledButton), findsNothing);

        final broke = council.copyWith(support: 0);
        await pumpOverlay(tester, size, dialog(broke, 'vuon-khong-nha-trong'));
        expect(find.text(l.cardCannotAfford), findsOneWidget);
        expect(find.byType(FilledButton), findsNothing);
      });

      testWidgets('buttons are disabled while animations play', (tester) async {
        await pumpOverlay(tester, size, dialog(council, 'vuon-khong-nha-trong', enabled: false));
        expect(tester.widget<FilledButton>(find.byKey(const Key('play-binh-le-nguyen'))).onPressed, isNull);
      });

      testWidgets('the English dialog', (tester) async {
        await pumpOverlay(tester, size, dialog(council, 'vuon-khong-nha-trong'), lang: 'en');
        expect(find.text('Choose a target:'), findsOneWidget);
        expect(find.text('A played card cannot be taken back.'), findsOneWidget);
      });

      testWidgets('showCardDialog opens it, plays and closes', (tester) async {
        final played = <String?>[];
        setViewSize(tester, size);
        await tester.pumpWidget(
          appAround(
            Builder(
              builder: (context) => Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () => showCardDialog(
                      context,
                      card: rules.cards['vuon-khong-nha-trong']!,
                      state: council,
                      ruleset: rules,
                      legal: engine.legalActions(council),
                      enabled: true,
                      onPlay: played.add,
                    ),
                    child: const Text('open'),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('open'));
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('card-dialog')), findsOneWidget);
        await tester.ensureVisible(find.byKey(const Key('play-thang-long')));
        await tester.tap(find.byKey(const Key('play-thang-long')));
        await tester.pumpAndSettle();
        expect(played, ['thang-long']);
        expect(find.byKey(const Key('card-dialog')), findsNothing);
      });
    });

    group('battle preview ($name)', () {
      Future<void> open(
        WidgetTester tester,
        List<BattlePreview> previews,
        GameState s, {
        void Function(bool)? onResult,
      }) async {
        setViewSize(tester, size);
        await tester.pumpWidget(
          appAround(
            Builder(
              builder: (context) => Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      final r = await showBattlePreviewDialog(context, previews: previews, state: s, ruleset: rules);
                      onResult?.call(r);
                    },
                    child: const Text('open'),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('open'));
        await tester.pumpAndSettle();
      }

      testWidgets('shows both Powers, the expected winner and the expected losses', (tester) async {
        final p = battlePreviewsFor(engine, orders, 'tran-thai-tong', Order.hold);
        await open(tester, p, orders);
        final f = p.single.forecast;
        expect(find.text(l.previewTitle), findsOneWidget);
        expect(find.text(l.previewField(namer.node('binh-le-nguyen'))), findsOneWidget);
        expect(
          find.text(l.previewPowers(f.daiVietPower.toStringAsFixed(1), f.yuanPower.toStringAsFixed(1))),
          findsOneWidget,
        );
        expect(find.text(l.previewWinner(l.sideName(f.winner))), findsOneWidget);
        expect(find.text(l.previewLosses('${f.daiVietLosses}', '${f.yuanLosses}')), findsOneWidget);
        expect(find.textContaining(namer.officer('tran-thai-tong')), findsWidgets);
        expect(find.textContaining(namer.army(orders, 'mong-co-1258')), findsOneWidget);
      });

      testWidgets('an ambush shows a range of Power and says when the roll decides', (tester) async {
        const f = BattleForecast(
          daiVietPower: 10,
          daiVietPowerMax: 14,
          yuanPower: 12,
          winner: Side.yuan,
          winnerAtMaxRoll: Side.daiViet,
          daiVietLosses: 5,
          yuanLosses: 2,
          daiVietLossesAtMaxRoll: 2,
          yuanLossesAtMaxRoll: 4,
        );
        const p = BattlePreview(
          kind: BattleKind.ambush,
          nodeId: 'bach-hac',
          edge: 'bach-hac~song-thao',
          officerIds: ['le-phu-tran'],
          armyIds: ['mong-co-1258'],
          forecast: f,
        );
        await open(tester, [p], orders);
        expect(find.text(l.previewAmbush(namer.edge('bach-hac~song-thao'))), findsOneWidget);
        expect(find.text(l.previewPowers('10.0–14.0', '12.0')), findsOneWidget);
        expect(find.text(l.previewUncertain(l.sideYuan, l.sideDaiViet)), findsOneWidget);
        expect(find.text(l.previewLosses('2–5', '2–4')), findsOneWidget);
      });

      testWidgets('confirm gives the order, cancel and dismissing do not', (tester) async {
        final p = battlePreviewsFor(engine, orders, 'tran-thai-tong', Order.hold);
        final results = <bool>[];
        await open(tester, p, orders, onResult: results.add);
        await tester.ensureVisible(find.byKey(const Key('preview-confirm')));
        await tester.tap(find.byKey(const Key('preview-confirm')));
        await tester.pumpAndSettle();
        expect(results, [true]);

        await tester.tap(find.text('open'));
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.byKey(const Key('preview-cancel')));
        await tester.tap(find.byKey(const Key('preview-cancel')));
        await tester.pumpAndSettle();
        expect(results, [true, false]);

        await tester.tap(find.text('open'));
        await tester.pumpAndSettle();
        await tester.tapAt(const Offset(2, 2)); // the scrim
        await tester.pumpAndSettle();
        expect(results, [true, false, false]);
      });

      testWidgets('the English preview', (tester) async {
        final p = battlePreviewsFor(engine, orders, 'tran-thai-tong', Order.hold);
        setViewSize(tester, size);
        await tester.pumpWidget(
          appAround(
            BattlePreviewDialog(previews: p, state: orders, ruleset: rules),
            lang: 'en',
          ),
        );
        expect(find.text('Battle preview'), findsOneWidget);
        expect(find.textContaining('Expected:'), findsOneWidget);
      });
    });

    group('choice overlay ($name)', () {
      final m1 = ruleset('ch1_m1');
      final m1Start = GameEngine(m1).newGame(1).state;

      testWidgets('shows the card and one button per option; a tap chooses it', (tester) async {
        final chosen = <int>[];
        expect(m1Start.pendingChoice, isNotNull);
        await pumpOverlay(
          tester,
          size,
          SizedBox(
            width: size.width,
            height: size.height,
            child: ChoiceOverlay(choice: m1Start.pendingChoice!, ruleset: m1, onChoose: chosen.add),
          ),
        );
        final pc = m1Start.pendingChoice!;
        final card = m1.cards[pc.sourceId]!;
        final effect = choiceEffectOf(m1, pc);
        expect(find.text(l.choiceTitle), findsOneWidget);
        expect(find.text(l.content(card.name)), findsOneWidget);
        for (var i = 0; i < effect.options.length; i++) {
          expect(find.text(l.content(effect.options[i].label)), findsOneWidget);
          expect(tester.getSize(find.byKey(Key('choice-$i'))).height, greaterThanOrEqualTo(48));
        }
        await tester.tap(find.byKey(const Key('choice-1')));
        expect(chosen, [1]);
      });

      testWidgets('blocks taps on what is behind it, and cannot be dismissed', (tester) async {
        var behind = 0;
        setViewSize(tester, size);
        await tester.pumpWidget(
          appAround(
            Scaffold(
              body: Stack(
                children: [
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: TextButton(onPressed: () => behind++, child: const Text('behind')),
                    ),
                  ),
                  Positioned.fill(
                    child: ChoiceOverlay(choice: m1Start.pendingChoice!, ruleset: m1, onChoose: (_) {}),
                  ),
                ],
              ),
            ),
          ),
        );
        await tester.tap(find.text('behind'), warnIfMissed: false);
        await tester.tapAt(const Offset(3, 3));
        expect(behind, 0);
        expect(find.byKey(const Key('choice-overlay')), findsOneWidget);
      });

      testWidgets('English', (tester) async {
        await pumpOverlay(
          tester,
          size,
          SizedBox(
            width: size.width,
            height: size.height,
            child: ChoiceOverlay(choice: m1Start.pendingChoice!, ruleset: m1, onChoose: (_) {}),
          ),
          lang: 'en',
        );
        expect(find.text('A decision is needed'), findsOneWidget);
      });
    });

    group('outcome banner ($name)', () {
      testWidgets('a win shows the stars and Back', (tester) async {
        var back = 0;
        final won = council.copyWith(phase: Phase.ended, outcome: Outcome.won, stars: [true, false]);
        await pumpOverlay(tester, size, OutcomeBanner(state: won, onBack: () => back++));
        expect(find.text(l.outcomeWon), findsOneWidget);
        expect(find.text(l.outcomeStars(1, 2)), findsOneWidget);
        await tester.tap(find.byKey(const Key('outcome-back')));
        expect(back, 1);
      });

      testWidgets('a loss says why, for each kind of loss', (tester) async {
        final reasons = {
          LossReasons.kingCaptured: l.lossKingCaptured,
          LossReasons.seasonEnded: l.lossSeasonEnded,
          '${LossReasons.unityPrefix}clan': l.lossUnity(l.unityClan),
          '${LossReasons.objectivePrefix}x': l.lossObjective,
        };
        for (final e in reasons.entries) {
          final lost = council.copyWith(phase: Phase.ended, outcome: Outcome.lost, lossReason: e.key);
          await pumpOverlay(tester, size, OutcomeBanner(state: lost, onBack: null));
          expect(find.text(l.outcomeLost), findsOneWidget);
          expect(find.text(e.value), findsOneWidget, reason: e.key);
          expect(find.byKey(const Key('outcome-back')), findsNothing);
        }
      });
    });
  }
}
