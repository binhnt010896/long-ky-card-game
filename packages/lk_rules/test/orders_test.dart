import 'package:lk_rules/lk_rules.dart';
import 'package:test/test.dart';

import 'support/fixture.dart';

/// Starts [m] and moves to the Orders phase of turn 1.
(GameEngine, GameState) ordersPhase(MissionDef m) {
  final e = engineFor(m);
  final s = e.apply(e.newGame(1).state, const GameAction.endPhase()).state;
  expect(s.phase, Phase.orders);
  return (e, s);
}

GameState order(GameEngine e, GameState s, String officerId, Order o) =>
    e.apply(s, GameAction.setOrder(officerId: officerId, order: o)).state;

/// Sets orders and ends the phase; returns the Resolution/Upkeep step.
StepResult resolve(GameEngine e, GameState s, Map<String, Order> orders) {
  var st = s;
  orders.forEach((id, o) => st = order(e, st, id, o));
  return e.apply(st, const GameAction.endPhase());
}

void main() {
  group('move', () {
    test('one land edge, or one or two river edges', () {
      final (e, s) = ordersPhase(mission(officers: [at('plain', 'cap', 6)]));
      for (final to in ['pl', 'rv1', 'rv2', 'ms']) {
        expect(e.isLegal(s, GameAction.setOrder(officerId: 'plain', order: Order.move(to))), isTrue, reason: to);
      }
    });

    test('two land edges, land then river, or the own node are illegal', () {
      final (e, s) = ordersPhase(mission(officers: [at('plain', 'hl', 6), at('raider', 'pl', 6)]));
      expect(() => order(e, s, 'plain', Order.move('cap')), throwsIllegal(IllegalCodes.illegalOrder));
      expect(() => order(e, s, 'raider', Order.move('rv1')), throwsIllegal(IllegalCodes.illegalOrder));
      expect(() => order(e, s, 'raider', Order.move('pl')), throwsIllegal(IllegalCodes.illegalOrder));
      expect(() => order(e, s, 'raider', const Order(kind: OrderKind.move)), throwsIllegal(IllegalCodes.illegalOrder));
    });

    test('Đại Việt moves resolve together', () {
      final (e, s) = ordersPhase(mission(officers: [at('plain', 'cap', 6), at('raider', 'pl', 6)]));
      final r = resolve(e, s, {'plain': Order.move('pl'), 'raider': Order.move('cap')});
      expect(r.state.officers['plain']!.nodeId, 'pl');
      expect(r.state.officers['raider']!.nodeId, 'cap');
      final moves = r.events.whereType<OfficerMoved>().toList();
      expect(moves.map((m) => (m.officerId, m.from, m.to)), [('plain', 'cap', 'pl'), ('raider', 'pl', 'cap')]);
    });

    test('river moves can cross two edges in one turn', () {
      final (e, s) = ordersPhase(mission(officers: [at('plain', 'cap', 6)]));
      expect(resolve(e, s, {'plain': Order.move('rv2')}).state.officers['plain']!.nodeId, 'rv2');
    });
  });

  group('hold', () {
    test('takes no target; an officer with no order holds in place', () {
      final (e, s) = ordersPhase(mission(officers: [at('plain', 'cap', 6), at('raider', 'pl', 6)]));
      expect(() => order(e, s, 'plain', const Order(kind: OrderKind.hold, target: 'pl')),
          throwsIllegal(IllegalCodes.illegalOrder));
      final r = resolve(e, s, {'plain': Order.hold});
      expect(r.state.officers['plain']!.nodeId, 'cap');
      expect(r.state.officers['raider']!.nodeId, 'pl');
    });
  });

  group('evacuate', () {
    test('costs 1 Support, marks the node and gives its riceStock as Rice', () {
      final (e, s) = ordersPhase(mission(officers: [at('plain', 'cap', 6)], rice: 4, support: 4));
      final r = resolve(e, s, {'plain': Order.evacuate});
      expect(r.state.support, 3);
      expect(r.state.nodes['cap']!.evacuated, isTrue);
      expect(r.state.nodes['cap']!.riceStock, 0);
      expect(r.events.whereType<NodeEvacuated>().single.riceGained, 9);
      final riceChange = r.events.whereType<ResourceChanged>().firstWhere((c) => c.resource == Resource.rice);
      expect((riceChange.from, riceChange.to), (4, 13));
      expect(r.state.missionStats.evacuations, 1);
    });

    test('costs 2 Support when People < 4', () {
      final (e, s) = ordersPhase(mission(
        officers: [at('plain', 'cap', 6)],
        support: 2,
        unity: const StartingUnity(court: 6, clan: 6, people: 3),
      ));
      expect(resolve(e, s, {'plain': Order.evacuate}).state.support, 0);
    });

    test('needs enough Support for every evacuate order', () {
      final (e, s) = ordersPhase(mission(officers: [at('plain', 'cap', 6), at('raider', 'pl', 6)], support: 1));
      final s1 = order(e, s, 'plain', Order.evacuate);
      expect(() => order(e, s1, 'raider', Order.evacuate), throwsIllegal(IllegalCodes.cannotAfford));
      final (e0, s0) = ordersPhase(mission(officers: [at('plain', 'cap', 6)], support: 0));
      expect(() => order(e0, s0, 'plain', Order.evacuate), throwsIllegal(IllegalCodes.cannotAfford));
    });

    test('each evacuation after the first in a turn costs 1 People', () {
      final (e, s) = ordersPhase(mission(officers: [at('plain', 'cap', 6), at('raider', 'pl', 6)]));
      final r = resolve(e, s, {'plain': Order.evacuate, 'raider': Order.evacuate});
      expect(r.state.unity.people, 5);
      expect(r.state.missionStats.evacuations, 2);
    });

    test('an evacuated node, a node not held, or a second evacuator are illegal', () {
      final (e, s) = ordersPhase(mission(
        officers: [at('plain', 'cap', 6), at('raider', 'cap', 6), at('shield', 'hl', 6)],
        armies: [army('hl')],
        yuanScript: holdAll(),
      ));
      final s1 = order(e, s, 'plain', Order.evacuate);
      expect(() => order(e, s1, 'raider', Order.evacuate), throwsIllegal(IllegalCodes.illegalOrder));
      expect(() => order(e, s, 'shield', Order.evacuate), throwsIllegal(IllegalCodes.illegalOrder),
          reason: 'hl is held by the Yuan');
      expect(() => order(e, s, 'plain', const Order(kind: OrderKind.evacuate, target: 'pl')),
          throwsIllegal(IllegalCodes.illegalOrder));
      final next = endTurn(e, resolve(e, s, {'plain': Order.evacuate}).state).state;
      final nextOrders = e.apply(next, const GameAction.endPhase()).state;
      expect(() => order(e, nextOrders, 'raider', Order.evacuate), throwsIllegal(IllegalCodes.alreadyEvacuated));
    });
  });

  group('rally', () {
    test('+1 morale to officers at the node and +1 troop to the rallier', () {
      final (e, s) = ordersPhase(mission(officers: [at('plain', 'cap', 6), at('raider', 'cap', 5), at('shield', 'pl', 6)]));
      final r = resolve(e, s, {'plain': Order.rally, 'shield': Order.move('cap')});
      expect(r.state.officers['plain']!.morale, 8);
      expect(r.state.officers['raider']!.morale, 8);
      expect(r.state.officers['shield']!.morale, 8, reason: 'arrived before the rally');
      expect(r.state.officers['plain']!.troops, 7);
      expect(r.state.officers['raider']!.troops, 5);
      expect(r.events.whereType<Rallied>().single.troopsGained, 1);
    });

    test('no troop when People < 4, when the node is evacuated, or above the troop cap', () {
      final (e, s) = ordersPhase(mission(
        officers: [at('plain', 'cap', 6)],
        unity: const StartingUnity(court: 6, clan: 6, people: 3),
      ));
      final r = resolve(e, s, {'plain': Order.rally});
      expect(r.state.officers['plain']!.troops, 6);
      expect(r.state.officers['plain']!.morale, 8);

      final (e2, s2) = ordersPhase(mission(officers: [at('warden', 'cap', 6)]));
      expect(resolve(e2, s2, {'warden': Order.rally}).state.officers['warden']!.troops, 6, reason: 'troopCap 6');

      final (e3, s3) = ordersPhase(mission(officers: [at('plain', 'cap', 6), at('raider', 'cap', 6)]));
      final r3 = resolve(e3, s3, {'raider': Order.evacuate, 'plain': Order.rally});
      expect(r3.state.officers['plain']!.troops, 6, reason: 'evacuated before the rally');
    });
  });

  group('raid', () {
    MissionDef raidMission(String officerId) => mission(
          officers: [at(officerId, 'pl', 6)],
          armies: [army('hl', troops: 30, supply: 20)],
          yuanScript: holdAll(),
        );

    test('army loses 2 + floor(war / 3) Supply; raider loses floor(troops / 20)', () {
      final (e, s) = ordersPhase(raidMission('plain'));
      final r = resolve(e, s, {'plain': Order.raid('y1')});
      final raid = r.events.whereType<Raided>().single;
      expect(raid.supplyLost, 2 + 5 ~/ 3);
      expect(raid.troopsLost, 1);
      expect(r.state.officers['plain']!.troops, 5);
      expect(r.state.missionStats.raids, 1);
      expect(r.state.missionStats.troopsLost, 1);
    });

    test('passive raider doubles the Supply damage', () {
      final (e, s) = ordersPhase(raidMission('raider'));
      final r = resolve(e, s, {'raider': Order.raid('y1')});
      expect(r.events.whereType<Raided>().single.supplyLost, (2 + 9 ~/ 3) * 2);
    });

    test('Supply never goes below 0', () {
      final (e, s) = ordersPhase(mission(
        officers: [at('raider', 'pl', 6)],
        armies: [army('hl', supply: 3)],
        yuanScript: holdAll(),
      ));
      final r = resolve(e, s, {'raider': Order.raid('y1')});
      expect(r.events.whereType<Raided>().single.supplyLost, 3);
    });

    test('the army must be on an adjacent node', () {
      final (e, s) = ordersPhase(mission(
        officers: [at('raider', 'cap', 6)],
        armies: [army('hl')],
        yuanScript: holdAll(),
      ));
      expect(() => order(e, s, 'raider', Order.raid('y1')), throwsIllegal(IllegalCodes.illegalOrder));
      expect(() => order(e, s, 'raider', Order.raid('nobody')), throwsIllegal(IllegalCodes.illegalOrder));
    });
  });

  group('ambush order', () {
    test('only on a river edge touching the officer\'s node; placed at Resolution', () {
      final (e, s) = ordersPhase(mission(officers: [at('plain', 'cap', 6)]));
      expect(() => order(e, s, 'plain', Order.ambush(edgeKey('cap', 'pl'))), throwsIllegal(IllegalCodes.illegalOrder));
      expect(() => order(e, s, 'plain', Order.ambush(edgeKey('rv1', 'rv2'))), throwsIllegal(IllegalCodes.illegalOrder));
      expect(() => order(e, s, 'plain', Order.ambush('nowhere')), throwsIllegal(IllegalCodes.illegalOrder));
      final r = resolve(e, s, {'plain': Order.ambush(edgeKey('cap', 'rv1'))});
      expect(r.events.whereType<AmbushPlaced>().single.edge, 'cap~rv1');
      expect(r.state.ambushes, isEmpty, reason: 'ambushes last one turn');
    });
  });

  group('SetOrder and ClearOrder', () {
    test('orders can change freely until EndPhase; ClearOrder removes one', () {
      final (e, s) = ordersPhase(mission(officers: [at('plain', 'cap', 6)]));
      final s1 = order(e, s, 'plain', Order.move('pl'));
      final s2 = order(e, s1, 'plain', Order.rally);
      expect(s2.officers['plain']!.order, Order.rally);
      final s3 = e.apply(s2, const GameAction.clearOrder(officerId: 'plain')).state;
      expect(s3.officers['plain']!.order, isNull);
      expect(() => e.apply(s3, const GameAction.clearOrder(officerId: 'plain')), throwsIllegal(IllegalCodes.noOrder));
    });

    test('unknown or inactive officers cannot take orders', () {
      final (e, s) = ordersPhase(mission(officers: [at('plain', 'cap', 6)]));
      expect(() => order(e, s, 'ghost', Order.hold), throwsIllegal(IllegalCodes.unknownOfficer));
      final captured = s.copyWith(officers: {
        'plain': s.officers['plain']!.copyWith(status: OfficerStatus.captured),
      });
      expect(() => order(e, captured, 'plain', Order.hold), throwsIllegal(IllegalCodes.officerInactive));
    });

    test('orders are cleared at the end of the turn', () {
      final (e, s) = ordersPhase(mission(officers: [at('plain', 'cap', 6)]));
      final r = resolve(e, s, {'plain': Order.rally});
      expect(r.state.officers['plain']!.order, isNull);
    });

    test('every SetOrder from legalActions is legal', () {
      final (e, s) = ordersPhase(mission(
        officers: [at('plain', 'cap', 6), at('raider', 'pl', 6)],
        armies: [army('hl')],
        yuanScript: holdAll(),
      ));
      final legal = e.legalActions(s);
      expect(legal.last, const GameAction.endPhase());
      expect(legal, contains(GameAction.setOrder(officerId: 'raider', order: Order.raid('y1'))));
      expect(legal, isNot(contains(GameAction.setOrder(officerId: 'plain', order: Order.raid('y1')))));
      for (final a in legal) {
        expect(e.isLegal(s, a), isTrue, reason: '$a');
      }
    });
  });
}
