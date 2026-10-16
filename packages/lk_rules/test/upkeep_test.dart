import 'package:lk_rules/lk_rules.dart';
import 'package:test/test.dart';

import 'support/fixture.dart';

StepResult oneTurn(MissionDef m, {GameState Function(GameState s)? prepare, Map<String, Order> orders = const {}}) {
  final e = engineFor(m);
  var s = e.newGame(1).state;
  if (prepare != null) s = prepare(s);
  s = e.apply(s, const GameAction.endPhase()).state;
  orders.forEach((id, o) => s = e.apply(s, GameAction.setOrder(officerId: id, order: o)).state);
  return e.apply(s, const GameAction.endPhase());
}

GameState withIntent(GameState s, Intent intent, {String id = 'y1'}) =>
    s.copyWith(armies: {...s.armies, id: s.armies[id]!.copyWith(intent: intent)});

GameState withArmy(GameState s, ArmyState Function(ArmyState a) f, {String id = 'y1'}) =>
    s.copyWith(armies: {...s.armies, id: f(s.armies[id]!)});

const forage = Intent(kind: IntentKind.forage);

void main() {
  group('forage (Resolution step 5)', () {
    test('gains min(2 × riceStock, maxSupply − supply); the stock becomes 0', () {
      // pl: riceYield 2, riceStock 6 → up to 12 Supply.
      final r = oneTurn(mission(armies: [army('pl', supply: 4)]), prepare: (s) => withIntent(s, forage));
      expect(r.events.whereType<Foraged>().single.supplyGained, 12);
      expect(r.state.nodes['pl']!.riceStock, 0);
      // Then upkeep uses ceil(30 / 10) = 3.
      expect(r.state.armies['y1']!.supply, 4 + 12 - 3);
    });

    test('capped by maxSupply', () {
      final r = oneTurn(mission(armies: [army('pl', supply: 15)]), prepare: (s) => withIntent(s, forage));
      expect(r.events.whereType<Foraged>().single.supplyGained, 5);
      expect(r.state.nodes['pl']!.riceStock, 0);
    });

    test('evacuated nodes and other intents give nothing', () {
      final evac = oneTurn(
        mission(armies: [army('pl', supply: 4)]),
        prepare: (s) => withIntent(s, forage).copyWith(nodes: {
          ...s.nodes,
          'pl': s.nodes['pl']!.copyWith(evacuated: true),
        }),
      );
      expect(evac.events.whereType<Foraged>(), isEmpty);
      final hold = oneTurn(mission(armies: [army('pl', supply: 4)], yuanScript: holdAll()));
      expect(hold.events.whereType<Foraged>(), isEmpty);
      expect(hold.state.nodes['pl']!.riceStock, 6);
    });

    test('an army that moves onto a rice node with intent forage forages the same turn', () {
      final r = oneTurn(
        mission(armies: [army('hl', supply: 4)]),
        prepare: (s) => withIntent(s, const Intent(kind: IntentKind.forage, moveTo: 'pl', targetNodeId: 'pl')),
      );
      expect(r.events.whereType<Foraged>().single.nodeId, 'pl');
    });
  });

  group('Upkeep', () {
    test('each army uses ceil(troops / 10) Supply', () {
      final r = oneTurn(mission(armies: [army('hl', troops: 25, supply: 10)], yuanScript: holdAll()));
      expect(r.events.whereType<SupplyConsumed>().single.amount, 3);
      expect(r.state.armies['y1']!.supply, 7);
    });

    test('starvation at 0 Supply: −2 morale and ceil(troops × 0.1) troops', () {
      final r = oneTurn(mission(armies: [army('hl', troops: 25, supply: 2)], yuanScript: holdAll()));
      final starve = r.events.whereType<Starvation>().single;
      expect(starve.troopsLost, 3);
      expect(starve.moraleLost, 2);
      expect(r.state.armies['y1']!.troops, 22);
      expect(r.state.armies['y1']!.morale, 6);
    });

    test('heat from heatStartTurn: turn − heatStartTurn + 1 troops', () {
      final e = engineFor(mission(armies: [army('hl', troops: 30)], heatStartTurn: 2, yuanScript: holdAll()));
      var s = e.newGame(1).state;
      final losses = <int>[];
      for (var i = 0; i < 3; i++) {
        final r = endTurn(e, s);
        losses.add(r.events.whereType<HeatAttrition>().fold(0, (sum, h) => sum + h.troopsLost));
        s = r.state;
      }
      expect(losses, [0, 1, 2]);
    });

    test('an army at morale 0 or troops 0 is routed and removed', () {
      final low = oneTurn(mission(armies: [army('hl', morale: 2, supply: 1)], yuanScript: holdAll()));
      expect(low.state.armies['y1']!.status, ArmyStatus.routed);
      expect(low.events.whereType<ArmyRouted>().single.armyId, 'y1');

      final none = oneTurn(mission(armies: [army('hl', troops: 1, supply: 0)], heatStartTurn: 1, yuanScript: holdAll()));
      expect(none.state.armies['y1']!.troops, 0);
      expect(none.state.armies['y1']!.status, ArmyStatus.routed);
    });

    test('a routed army takes no further part', () {
      final e = engineFor(mission(
        officers: [at('plain', 'pl', 6)],
        armies: [army('hl', morale: 2, supply: 1)],
        yuanScript: holdAll(),
      ));
      final s = endTurn(e, e.newGame(1).state).state;
      expect(s.armies['y1']!.status, ArmyStatus.routed);
      expect(e.legalActions(e.apply(s, const GameAction.endPhase()).state),
          isNot(contains(GameAction.setOrder(officerId: 'plain', order: Order.raid('y1')))));
      final next = endTurn(e, s);
      expect(next.events.whereType<SupplyConsumed>(), isEmpty);
    });

    test('income: riceYield of held, non-evacuated nodes, minus ceil(troops / 10)', () {
      // Army on pl (yield 2): held nodes are hl 0, cap 3, ms 1, rv1 1, rv2 2 = 7.
      final r = oneTurn(mission(
        officers: [at('plain', 'cap', 11)],
        armies: [army('pl')],
        rice: 4,
        yuanScript: holdAll(),
      ));
      final income = r.events.whereType<IncomeCollected>().single;
      expect(income.riceGained, 7);
      expect(income.riceUpkeep, 2);
      expect(r.state.rice, 4 + 7 - 2);
    });

    test('evacuated nodes give no income', () {
      final r = oneTurn(mission(officers: [at('plain', 'cap', 1)], rice: 0), orders: {'plain': Order.evacuate});
      // Held: hl 0, pl 2, ms 1, rv1 1, rv2 2 (cap evacuated) = 6; +9 from evacuating.
      expect(r.events.whereType<IncomeCollected>().single.riceGained, 6);
      expect(r.state.rice, 9 + 6 - 1);
    });

    test('a Rice shortfall sets Rice to 0 and costs every officer 1 morale', () {
      final r = oneTurn(mission(
        officers: [at('plain', 'hl', 40), at('raider', 'hl', 40)],
        armies: [army('pl'), army('cap', id: 'y2'), army('rv1', id: 'y3'), army('rv2', id: 'y4'), army('ms', id: 'y5')],
        rice: 2,
        yuanScript: [for (final id in ['y1', 'y2', 'y3', 'y4', 'y5']) ...holdAll(armyId: id)],
      ));
      final income = r.events.whereType<IncomeCollected>().single;
      expect(income.riceGained, 0);
      expect(income.riceUpkeep, 8);
      expect(income.shortfall, isTrue);
      expect(r.state.rice, 0);
      expect(r.state.officers['plain']!.morale, 6);
      expect(r.state.officers['raider']!.morale, 6);
    });

    test('steps run in the documented order', () {
      final r = oneTurn(mission(
        officers: [at('plain', 'cap', 6)],
        armies: [army('hl', troops: 30, supply: 1, morale: 2)],
        heatStartTurn: 1,
        deck: const [DeckEntry(cardId: 'evac', count: 6)],
        yuanScript: holdAll(),
      ), prepare: (s) => s.copyWith(hand: const [], deck: const ['evac']));
      final kinds = r.events
          .where((e) =>
              e is SupplyConsumed ||
              e is Starvation ||
              e is HeatAttrition ||
              e is ArmyRouted ||
              e is IncomeCollected ||
              e is CardsDrawn ||
              e is MissionEnded)
          .map((e) => e.runtimeType)
          .toList();
      expect(kinds, [SupplyConsumed, Starvation, HeatAttrition, ArmyRouted, IncomeCollected, CardsDrawn]);
      final a = r.state.armies['y1']!;
      expect(a.supply, 0);
      expect(a.morale, 0);
      expect(a.troops, 30 - 3 - 1);
    });
  });
}
