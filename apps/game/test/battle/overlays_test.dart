import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lk_rules/lk_rules.dart';
import 'package:long_ky_game/features/battle/board/board_scene.dart';
import 'package:long_ky_game/features/battle/labels.dart';
import 'package:long_ky_game/features/battle/overlays/event_log.dart';
import 'package:long_ky_game/features/cards/card_frame.dart';
import 'package:long_ky_game/features/battle/overlays/hand.dart';
import 'package:long_ky_game/features/battle/overlays/inspector.dart';
import 'package:long_ky_game/features/battle/overlays/officer_strip.dart';
import 'package:long_ky_game/features/battle/overlays/phase_button.dart';
import 'package:long_ky_game/features/battle/overlays/top_bar.dart';

import 'overlay_support.dart';

/// Widget tests for each battle overlay on its own, at both layouts.
void main() {
  final rules = ruleset(mission);
  final start = startState(mission);

  for (final (name, size, mode) in layouts) {
    group('top bar ($name)', () {
      testWidgets('shows the turn clock, Rice, Support and three Unity gauges', (tester) async {
        await pumpOverlay(
          tester,
          size,
          SizedBox(
            width: size.width,
            child: BattleTopBar(state: start, seasonTurns: rules.mission.seasonTurns, mode: mode),
          ),
        );
        final l = strings('vi');
        expect(tester.takeException(), isNull);
        expect(find.text(l.battleTurnClock(1, rules.mission.seasonTurns)), findsOneWidget);
        expect(find.text(l.phaseCouncil), findsOneWidget);
        // One pip per turn of the season, the first filled.
        for (var i = 1; i <= rules.mission.seasonTurns; i++) {
          expect(find.byKey(Key('clock-pip-$i')), findsOneWidget);
        }
        expect(find.byKey(Key('clock-pip-${rules.mission.seasonTurns + 1}')), findsNothing);
        expect(
          find.descendant(of: find.byKey(const Key('rice')), matching: find.text('${start.rice}')),
          findsOneWidget,
        );
        expect(
          find.descendant(of: find.byKey(const Key('support')), matching: find.text('${start.support}')),
          findsOneWidget,
        );
        for (final p in Pillar.values) {
          final gauge = find.byKey(Key('unity-${p.name}'));
          expect(gauge, findsOneWidget);
          expect(find.descendant(of: gauge, matching: find.text(l.pillarName(p))), findsOneWidget);
          expect(find.descendant(of: gauge, matching: find.text('${start.unity[p]}')), findsOneWidget);
        }
        // The bar spans the width and has the height of its layout.
        expect(tester.getSize(find.byKey(const Key('top-bar'))), Size(size.width, BattleTopBar.heightFor(mode)));
      });

      testWidgets('is in English when the language is English', (tester) async {
        await pumpOverlay(
          tester,
          size,
          SizedBox(
            width: size.width,
            child: BattleTopBar(state: start, seasonTurns: rules.mission.seasonTurns, mode: mode),
          ),
          lang: 'en',
        );
        final l = strings('en');
        expect(find.text(l.battleTurnClock(1, rules.mission.seasonTurns)), findsOneWidget);
        expect(find.text('Court'), findsOneWidget);
        expect(find.text('Clan'), findsOneWidget);
        expect(find.text('People'), findsOneWidget);
      });

      testWidgets('a Unity pillar below 4 shows a warning mark, not just a colour', (tester) async {
        final semantics = tester.ensureSemantics();
        await pumpOverlay(
          tester,
          size,
          SizedBox(
            width: size.width,
            child: BattleTopBar(state: withUnity(start, court: 3), seasonTurns: rules.mission.seasonTurns, mode: mode),
          ),
        );
        expect(
          find.descendant(of: find.byKey(const Key('unity-court')), matching: find.byIcon(Icons.warning_amber)),
          findsOneWidget,
        );
        expect(
          find.descendant(of: find.byKey(const Key('unity-clan')), matching: find.byIcon(Icons.warning_amber)),
          findsNothing,
        );
        expect(find.bySemanticsLabel(strings('vi').unitySemanticsLow(strings('vi').unityCourt, 3)), findsOneWidget);
        expect(find.bySemanticsLabel(strings('vi').unitySemantics(strings('vi').unityClan, 6)), findsOneWidget);
        semantics.dispose();
      });

      testWidgets('the clock follows the turn and never runs past the season', (tester) async {
        final late = start.copyWith(turn: rules.mission.seasonTurns + 2, phase: Phase.ended);
        await pumpOverlay(
          tester,
          size,
          SizedBox(
            width: size.width,
            child: BattleTopBar(state: late, seasonTurns: rules.mission.seasonTurns, mode: mode),
          ),
        );
        final total = rules.mission.seasonTurns;
        expect(find.text(strings('vi').battleTurnClock(total, total)), findsOneWidget);
      });

      testWidgets('150% text still fits without overflow', (tester) async {
        await pumpOverlay(
          tester,
          size,
          SizedBox(
            width: size.width,
            child: BattleTopBar(state: start, seasonTurns: rules.mission.seasonTurns, mode: mode),
          ),
          textScale: 1.5,
        );
        expect(tester.takeException(), isNull);
        expect(tester.getRect(find.byKey(const Key('unity-people'))).right, lessThanOrEqualTo(size.width));
      });
    });

    group('officer strip ($name)', () {
      Widget strip(GameState s, {Selection? selection, ValueChanged<Selection>? onSelect}) => SizedBox(
        width: size.width,
        child: OfficerStrip(state: s, ruleset: rules, mode: mode, selection: selection, onSelect: onSelect ?? (_) {}),
      );

      testWidgets('has one tile per officer with name, troops and morale', (tester) async {
        await pumpOverlay(tester, size, strip(start));
        final l = strings('vi');
        expect(tester.takeException(), isNull);
        expect(start.officers, hasLength(3));
        for (final e in start.officers.entries) {
          final tile = find.byKey(Key('officer-${e.key}'));
          expect(tile, findsOneWidget);
          expect(
            find.descendant(of: tile, matching: find.text(l.content(rules.officers[e.key]!.name))),
            findsOneWidget,
          );
          expect(
            find.descendant(
              of: tile,
              matching: find.textContaining('${l.troopsShort(e.value.troops)} · ${l.moraleShort(e.value.morale)}'),
            ),
            findsOneWidget,
          );
        }
        // 12, 6 and 6 thousand men, as in the mission.
        expect(find.textContaining(l.troopsShort(12)), findsOneWidget);
        expect(find.textContaining(l.troopsShort(6)), findsNWidgets(2));
      });

      testWidgets('tiles are at least 48 px tall and the strip has its layout height', (tester) async {
        await pumpOverlay(tester, size, strip(start));
        for (final id in start.officers.keys) {
          expect(tester.getSize(find.byKey(Key('officer-$id'))).height, greaterThanOrEqualTo(48));
        }
        expect(tester.getSize(find.byKey(const Key('officer-strip'))).height, OfficerStrip.heightFor(mode));
      });

      testWidgets('tapping a tile selects that officer', (tester) async {
        final picked = <Selection>[];
        await pumpOverlay(tester, size, strip(start, onSelect: picked.add));
        await tester.tap(find.byKey(const Key('officer-le-phu-tran')));
        expect(picked, [const Selection(SelectionKind.officer, 'le-phu-tran')]);
      });

      testWidgets('the selected officer is marked for screen readers', (tester) async {
        final semantics = tester.ensureSemantics();
        await pumpOverlay(tester, size, strip(start, selection: const Selection(SelectionKind.officer, 'tran-thu-do')));
        expect(
          tester.getSemantics(find.byKey(const Key('officer-tran-thu-do'))).flagsCollection.isSelected.name,
          'isTrue',
        );
        expect(
          tester.getSemantics(find.byKey(const Key('officer-le-phu-tran'))).flagsCollection.isSelected.name,
          'isFalse',
        );
        semantics.dispose();
      });

      testWidgets('shows orders in the Orders phase and ignores taps on a captured officer', (tester) async {
        final engine = GameEngine(rules);
        var s = engine.apply(start, const GameAction.endPhase()).state;
        expect(s.phase, Phase.orders);
        s = engine.apply(s, const GameAction.setOrder(officerId: 'tran-thu-do', order: Order.hold)).state;
        s = s.copyWith(
          officers: {
            ...s.officers,
            'le-phu-tran': s.officers['le-phu-tran']!.copyWith(status: OfficerStatus.captured),
          },
        );
        final picked = <Selection>[];
        await pumpOverlay(tester, size, strip(s, onSelect: picked.add));
        final l = strings('vi');
        expect(find.textContaining(l.orderHold), findsOneWidget);
        expect(find.textContaining(l.orderNone), findsOneWidget, reason: 'the king has no order yet');
        expect(find.textContaining(l.statusCaptured), findsOneWidget);
        await tester.tap(find.byKey(const Key('officer-le-phu-tran')));
        expect(picked, isEmpty);
      });

      testWidgets('scrolls instead of overflowing when officers do not fit', (tester) async {
        await pumpOverlay(tester, const Size(300, 80), SizedBox(width: 300, child: strip(start)));
        expect(tester.takeException(), isNull);
      });
    });

    group('hand ($name)', () {
      testWidgets(
        mode.isCompact ? 'the handle shows the hand size; the fan fans the cards out' : 'the column lists the hand',
        (tester) async {
          final l = strings('vi');
          final cards = handCards(start, rules);
          expect(cards, hasLength(rules.mission.handSize));
          if (mode.isCompact) {
            var open = false;
            late StateSetter set;
            await pumpOverlay(
              tester,
              size,
              StatefulBuilder(
                builder: (context, setState) {
                  set = setState;
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (open) HandFan(state: start, ruleset: rules, availableWidth: size.width - 16),
                      HandDrawer(state: start, ruleset: rules, open: open, onToggle: () => set(() => open = !open)),
                    ],
                  );
                },
              ),
            );
            expect(find.text(l.handTitle(cards.length)), findsOneWidget);
            expect(find.byKey(const Key('hand-fan')), findsNothing, reason: 'closed until tapped');
            await tester.tap(find.byKey(const Key('hand-handle')));
            await tester.pump();
            expect(find.byKey(const Key('hand-fan')), findsOneWidget);
            for (var i = 0; i < cards.length; i++) {
              expect(find.byKey(Key('card-$i-${cards[i].id}')), findsOneWidget);
            }
            // The fan stays inside the screen.
            expect(tester.getRect(find.byKey(const Key('hand-fan'))).width, lessThanOrEqualTo(size.width));
            await tester.tap(find.byKey(const Key('hand-handle')));
            await tester.pump();
            expect(find.byKey(const Key('hand-fan')), findsNothing);
          } else {
            await pumpOverlay(
              tester,
              size,
              SizedBox(
                height: size.height,
                child: HandColumn(state: start, ruleset: rules),
              ),
            );
            expect(find.byKey(const Key('hand-column')), findsOneWidget);
            expect(find.text(l.handTitle(cards.length)), findsOneWidget);
            for (var i = 0; i < cards.length; i++) {
              final tile = find.byKey(Key('card-$i-${cards[i].id}'));
              expect(tile, findsOneWidget);
              expect(find.descendant(of: tile, matching: find.text(l.content(cards[i].name))), findsOneWidget);
            }
          }
          expect(tester.takeException(), isNull);
        },
      );

      testWidgets('a card is a lacquer frame in 3:4: type, name, a cost row and the text in its tooltip', (
        tester,
      ) async {
        final card = rules.cards['vuon-khong-nha-trong']!;
        final s = start.copyWith(hand: ['vuon-khong-nha-trong']);
        final l = strings('vi');
        late StateSetter set;
        var selected = false;
        await pumpOverlay(
          tester,
          size,
          StatefulBuilder(
            builder: (context, setState) {
              set = setState;
              return CardTile(
                card: card,
                state: s,
                width: 140,
                selected: selected,
                onTap: () => set(() => selected = !selected),
              );
            },
          ),
        );
        expect(find.text(l.content(card.name)), findsOneWidget);
        expect(find.text(l.cardTypeName(CardType.stratagem)), findsOneWidget);
        expect(find.byIcon(Icons.favorite), findsOneWidget, reason: 'Support 2, as a glyph and a number');
        expect(find.text('2'), findsOneWidget);
        final frame = tester.getSize(find.byKey(const Key('card-frame')));
        expect(frame.width / frame.height, closeTo(3 / 4, 0.001));
        expect(CardTile.heightFor(140), closeTo(140 * 4 / 3, 1e-9));
        // Small frames leave the effect text to the tooltip.
        expect(find.text(l.content(card.text)), findsNothing);
        expect(tester.widget<Tooltip>(find.byType(Tooltip)).message, contains(l.content(card.text)));

        await tester.tap(find.byType(CardTile));
        await tester.pump();
        expect(tester.widget<CardFrame>(find.byType(CardFrame)).selected, isTrue);
        expect(tester.takeException(), isNull);
      });

      testWidgets('a card the player cannot afford says so', (tester) async {
        final card = rules.cards['vuon-khong-nha-trong']!;
        final broke = start.copyWith(support: 0);
        await pumpOverlay(tester, size, CardTile(card: card, state: broke, width: 200, selected: false, onTap: () {}));
        expect(find.textContaining(strings('vi').cardCannotAfford), findsWidgets);
      });

      testWidgets('an empty hand says so', (tester) async {
        final empty = start.copyWith(hand: const []);
        if (mode.isCompact) {
          await pumpOverlay(tester, size, HandFan(state: empty, ruleset: rules, availableWidth: size.width));
        } else {
          await pumpOverlay(
            tester,
            size,
            SizedBox(
              height: size.height,
              child: HandColumn(state: empty, ruleset: rules),
            ),
          );
        }
        expect(find.text(strings('vi').handEmpty), findsOneWidget);
      });

      testWidgets('low Court adds a Support surcharge to every card, and says so', (tester) async {
        final l = strings('vi');
        final low = withUnity(start, court: 3);
        if (mode.isCompact) {
          await pumpOverlay(tester, size, HandFan(state: low, ruleset: rules, availableWidth: size.width));
        } else {
          await pumpOverlay(
            tester,
            size,
            SizedBox(
              height: size.height,
              child: HandColumn(state: low, ruleset: rules),
            ),
          );
          expect(find.text(l.handCourtSurcharge(1)), findsOneWidget);
        }
        final card = rules.cards['vuon-khong-nha-trong']!;
        expect(cardCostNow(low, card).support, card.cost.support + 1);
        expect(cardCostNow(start, card).support, card.cost.support);
      });
    });

    group('inspector ($name)', () {
      Widget inspector(Selection s, GameState state, {VoidCallback? onClose}) => SizedBox(
        width: 360,
        child: InspectorPanel(selection: s, state: state, ruleset: rules, mode: mode, onClose: onClose ?? () {}),
      );

      testWidgets('a node: terrain, control, rice and who is there', (tester) async {
        await pumpOverlay(tester, size, inspector(const Selection(SelectionKind.node, 'binh-le-nguyen'), start));
        final l = strings('vi');
        final def = rules.map.nodes.firstWhere((n) => n.id == 'binh-le-nguyen');
        expect(find.byKey(const Key('inspector-node')), findsOneWidget);
        expect(find.text(l.content(def.name)), findsOneWidget);
        expect(find.textContaining(l.terrainName(def.terrain)), findsOneWidget);
        expect(find.text(l.nodeControlledBy(l.sideDaiViet)), findsOneWidget);
        expect(find.text(l.nodeRiceStock(start.nodes['binh-le-nguyen']!.riceStock)), findsOneWidget);
        for (final id in ['tran-thai-tong', 'le-phu-tran', 'tran-thu-do']) {
          expect(find.text(l.content(rules.officers[id]!.name)), findsOneWidget);
        }
      });

      testWidgets('an empty node says nobody is there', (tester) async {
        await pumpOverlay(tester, size, inspector(const Selection(SelectionKind.node, 'thang-long'), start));
        expect(find.text(strings('vi').nodeNoUnits), findsOneWidget);
      });

      testWidgets('an officer: troops, morale, stats, order, skill and flaw', (tester) async {
        await pumpOverlay(tester, size, inspector(const Selection(SelectionKind.officer, 'tran-thai-tong'), start));
        final l = strings('vi');
        final def = rules.officers['tran-thai-tong']!;
        final o = start.officers['tran-thai-tong']!;
        expect(find.byKey(const Key('inspector-officer')), findsOneWidget);
        expect(find.text(l.content(def.name)), findsOneWidget);
        expect(find.textContaining(l.officerIsKing), findsOneWidget);
        expect(find.text('${l.troopsFull(12)} · ${l.moraleShort(o.morale)}'), findsOneWidget);
        expect(find.textContaining(l.statLeadership), findsOneWidget);
        expect(find.text(l.orderNone), findsOneWidget);
        if (def.skill != null) {
          expect(find.textContaining(l.content(def.skill!.name)), findsOneWidget);
          expect(find.text(l.content(def.skill!.text)), findsOneWidget);
        }
        if (def.flaw != null) expect(find.text(l.content(def.flaw!.text)), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('an officer in English', (tester) async {
        await pumpOverlay(
          tester,
          size,
          inspector(const Selection(SelectionKind.officer, 'tran-thai-tong'), start),
          lang: 'en',
        );
        final l = strings('en');
        expect(find.text(l.content(rules.officers['tran-thai-tong']!.name)), findsOneWidget);
        expect(find.textContaining('12,000 troops'), findsOneWidget);
        expect(find.textContaining('Leadership'), findsOneWidget);
      });

      testWidgets('an army: commander, troops, supply and its intent', (tester) async {
        await pumpOverlay(tester, size, inspector(const Selection(SelectionKind.army, 'mong-co-1258'), start));
        final l = strings('vi');
        final a = start.armies.values.single;
        expect(find.byKey(const Key('inspector-army')), findsOneWidget);
        expect(find.text('${l.troopsFull(a.troops)} · ${l.moraleShort(a.morale)}'), findsOneWidget);
        expect(find.text(l.inspectorSupply(a.supply, a.maxSupply)), findsOneWidget);
        expect(
          find.text('${l.inspectorCommander}: ${l.content(rules.commanders[a.commanderId]!.name)}'),
          findsOneWidget,
        );
        // The Yuan assault Bình Lệ Nguyên on turn 1 (mission table).
        expect(a.intent!.kind, IntentKind.assault);
        expect(
          find.text(
            l.intentToward(
              l.intentAssault,
              l.content(rules.map.nodes.firstWhere((n) => n.id == 'binh-le-nguyen').name),
            ),
          ),
          findsOneWidget,
        );
      });

      testWidgets('the close button calls onClose and is at least 48 px', (tester) async {
        var closed = 0;
        await pumpOverlay(
          tester,
          size,
          inspector(const Selection(SelectionKind.node, 'binh-le-nguyen'), start, onClose: () => closed++),
        );
        final close = find.byKey(const Key('inspector-close'));
        expect(tester.getSize(close).width, greaterThanOrEqualTo(48));
        expect(tester.getSize(close).height, greaterThanOrEqualTo(48));
        await tester.tap(close);
        expect(closed, 1);
      });

      testWidgets('long content scrolls instead of overflowing a short panel', (tester) async {
        await pumpOverlay(
          tester,
          size,
          SizedBox(
            width: 300,
            height: 120,
            child: InspectorPanel(
              selection: const Selection(SelectionKind.officer, 'tran-thu-do'),
              state: start,
              ruleset: rules,
              mode: mode,
              onClose: () {},
            ),
          ),
          textScale: 1.5,
        );
        expect(tester.takeException(), isNull);
      });
    });

    group('phase button ($name)', () {
      Widget button(GameState s, VoidCallback onPressed) => SizedBox(
        width: 240,
        child: PhaseButton(state: s, mode: mode, onPressed: onPressed),
      );

      testWidgets('Council: moves to Orders when pressed', (tester) async {
        var pressed = 0;
        await pumpOverlay(tester, size, button(start, () => pressed++));
        final l = strings('vi');
        expect(find.text(l.phaseButtonCouncil), findsOneWidget);
        expect(tester.getSize(find.byKey(const Key('phase-button'))).height, greaterThanOrEqualTo(48));
        await tester.tap(find.byKey(const Key('phase-button')));
        expect(pressed, 1);
      });

      testWidgets('Orders: resolves the turn', (tester) async {
        final orders = GameEngine(rules).apply(start, const GameAction.endPhase()).state;
        var pressed = 0;
        await pumpOverlay(tester, size, button(orders, () => pressed++));
        expect(find.text(strings('vi').phaseButtonOrders), findsOneWidget);
        await tester.tap(find.byKey(const Key('phase-button')));
        expect(pressed, 1);
      });

      testWidgets('is disabled while a choice is pending', (tester) async {
        final pending = start.copyWith(
          pendingChoice: const PendingChoice(source: ChoiceSource.card, sourceId: 'x', path: [0], optionCount: 2),
        );
        var pressed = 0;
        await pumpOverlay(tester, size, button(pending, () => pressed++));
        expect(find.text(strings('vi').phaseButtonChoice), findsOneWidget);
        await tester.tap(find.byKey(const Key('phase-button')), warnIfMissed: false);
        expect(pressed, 0);
        expect(PhaseButton.canEnd(pending), isFalse);
      });

      testWidgets('is disabled once the mission has ended', (tester) async {
        final over = start.copyWith(phase: Phase.ended, outcome: Outcome.won);
        var pressed = 0;
        await pumpOverlay(tester, size, button(over, () => pressed++));
        expect(find.text(strings('vi').phaseButtonEnded), findsOneWidget);
        await tester.tap(find.byKey(const Key('phase-button')), warnIfMissed: false);
        expect(pressed, 0);
      });

      testWidgets('English labels', (tester) async {
        await pumpOverlay(tester, size, button(start, () {}), lang: 'en');
        expect(find.text('To Orders'), findsOneWidget);
        expect(find.text('Council'), findsOneWidget);
      });
    });

    group('event log ($name)', () {
      final engine = GameEngine(rules);
      final played = () {
        final first = engine.newGame(1);
        final r = endTurnFrom(engine, first.state);
        return (state: r.state, events: [...first.events, ...r.events]);
      }();

      testWidgets(mode.isCompact ? 'the popover lists the events and closes' : 'the side panel lists the events', (
        tester,
      ) async {
        final l = strings('vi');
        final lines = logLines(l, rules, played.state, played.events);
        expect(lines, isNotEmpty);
        var closed = 0;
        await pumpOverlay(
          tester,
          size,
          mode.isCompact
              ? SizedBox(
                  width: 320,
                  height: 200,
                  child: LogPopover(lines: lines, onClose: () => closed++),
                )
              : SizedBox(
                  height: size.height,
                  child: LogSidePanel(lines: lines, expanded: true, onToggle: () => closed++),
                ),
        );
        expect(find.text(l.logTitle), findsOneWidget);
        // Newest at the bottom, in view.
        // (The same phase line comes back every turn, so it may appear more than once.)
        expect(find.text(lines.last), findsWidgets);
        await tester.tap(find.byKey(Key(mode.isCompact ? 'log-close' : 'log-toggle')));
        expect(closed, 1);
      });

      testWidgets('an empty log says nothing has happened', (tester) async {
        await pumpOverlay(
          tester,
          size,
          SizedBox(
            width: 320,
            height: 200,
            child: LogPopover(lines: const [], onClose: () {}),
          ),
        );
        expect(find.text(strings('vi').logEmpty), findsOneWidget);
      });

      test('events read as sentences in both languages', () {
        for (final lang in ['vi', 'en']) {
          final l = strings(lang);
          final lines = logLines(l, rules, played.state, played.events);
          expect(lines, contains(l.logTurnStarted(1)));
          expect(lines, contains(l.logPhaseChanged(l.phaseOrders)));
          // The Yuan assault on turn 1 resolves into a battle at Bình Lệ Nguyên.
          final node = l.content(rules.map.nodes.firstWhere((n) => n.id == 'binh-le-nguyen').name);
          expect(lines.where((s) => s.contains(node)), isNotEmpty);
          for (final line in lines) {
            expect(line, isNot(contains('{')), reason: 'unfilled placeholder in "$line"');
          }
        }
      });

      test('every line a mission can produce is non-empty in both languages', () {
        // Play several seeds to the end so most event kinds occur.
        final seen = <Type>{};
        for (var seed = 1; seed <= 20; seed++) {
          final r = engine.newGame(seed);
          final events = [...r.events];
          var s = r.state;
          for (var i = 0; i < 12 && !s.isOver; i++) {
            final step = endTurnFrom(engine, s);
            events.addAll(step.events);
            s = step.state;
          }
          for (final e in events) {
            seen.add(e.runtimeType);
            for (final lang in ['vi', 'en']) {
              final line = describeEvent(strings(lang), rules, s, e);
              if (line != null) {
                expect(line.trim(), isNotEmpty);
                expect(line, isNot(contains('{')), reason: '$e → "$line"');
              }
            }
          }
        }
        expect(seen, containsAll([TurnStarted, PhaseChanged, BattleResolved]));
      });
    });
  }

  group('card cost matches the engine', () {
    test('Support paid with Court at 6, 4, 3 and 1', () {
      final engine = GameEngine(rules);
      final card = rules.cards['vuon-khong-nha-trong']!;
      for (final court in [6, 4, 3, 1]) {
        final s = withUnity(start, court: court).copyWith(hand: [card.id], support: 10, rice: 10);
        final after = engine.apply(s, GameAction.playCard(cardId: card.id, target: 'binh-le-nguyen')).state;
        expect(s.support - after.support, cardCostNow(s, card).support, reason: 'court $court');
      }
    });

    test('canAffordCard agrees with the engine about what can be paid for', () {
      final engine = GameEngine(rules);
      final card = rules.cards['vuon-khong-nha-trong']!;
      for (final court in [6, 3]) {
        for (var support = 0; support <= 4; support++) {
          final s = withUnity(start, court: court).copyWith(hand: [card.id], support: support);
          final legal = engine.isLegal(s, GameAction.playCard(cardId: card.id, target: 'binh-le-nguyen'));
          expect(canAffordCard(s, card), legal, reason: 'court $court, support $support');
        }
      }
    });
  });
}

/// Ends the current turn from Council or Orders, returning the last step's events together.
StepResult endTurnFrom(GameEngine e, GameState s) {
  final first = e.apply(s, const GameAction.endPhase());
  if (first.state.phase != Phase.orders) return first;
  final second = e.apply(first.state, const GameAction.endPhase());
  return StepResult(second.state, [...first.events, ...second.events]);
}
