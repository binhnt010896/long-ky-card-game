import 'package:lk_rules/lk_rules.dart';
import 'package:lk_rules/src/engine/combat.dart';
import 'package:lk_rules/src/engine/tx.dart';
import 'package:test/test.dart';

import 'support/fixture.dart';

/// Runs one turn of [m] with [orders]; [prepare] may edit the Council state.
StepResult turn(
  MissionDef m, {
  Map<String, Order> orders = const {},
  GameState Function(GameState s)? prepare,
  int seed = 1,
}) {
  final e = engineFor(m);
  var s = e.newGame(seed).state;
  if (prepare != null) s = prepare(s);
  s = e.apply(s, const GameAction.endPhase()).state;
  orders.forEach((id, o) => s = e.apply(s, GameAction.setOrder(officerId: id, order: o)).state);
  return e.apply(s, const GameAction.endPhase());
}

BattleReport battle(StepResult r) => r.events.whereType<BattleResolved>().single.report;

GameState moveArmy(GameState s, String to, {String id = 'y1'}) => s.copyWith(armies: {
      ...s.armies,
      id: s.armies[id]!.copyWith(intent: Intent(kind: IntentKind.advance, moveTo: to, targetNodeId: to)),
    });

/// One 'plain' officer (Thống 5, Võ 5, morale 7) holding at [node] with 10
/// troops, against a 10-troop army (Thống 9, Võ 9, morale 8) holding there.
MissionDef duel(String node) => mission(
      officers: [at('plain', node, 10)],
      armies: [army(node, troops: 10)],
      yuanScript: holdAll(),
    );

void main() {
  group('Power, hand-computed for every terrain', () {
    // Officer: 10 × (1 + 5/10) × terrain × (0.5 + 7/20) × 1.2 (hold, defending)
    // Army:    10 × (1 + 9/10) × terrain × (0.5 + 8/20)
    test('city, defending: 10×1.5×1.2×0.85×1.2 = 18.36 vs 10×1.9×1.0×0.9 = 17.1', () {
      final r = battle(turn(duel('cap')));
      expect(r.daiVietPower, closeTo(18.36, 1e-9));
      expect(r.yuanPower, closeTo(17.1, 1e-9));
      expect(r.winner, Side.daiViet);
      // r = 17.1 / 18.36 = 0.93137: loser ceil(10 × (0.5 − 0.3r)) = 3,
      // winner ceil(10 × 0.25r) = 3.
      expect(r.armyLosses, {'y1': 3});
      expect(r.officerLosses, {'plain': 3});
    });

    test('city, attacking (moved in): no city bonus, no hold bonus', () {
      final r = turn(
        mission(officers: [at('plain', 'pl', 10)], armies: [army('cap', troops: 10)], yuanScript: holdAll()),
        orders: {'plain': Order.move('cap')},
      );
      final b = battle(r);
      expect(b.daiVietPower, closeTo(10 * 1.5 * 1.0 * 0.85, 1e-9));
      expect(b.yuanPower, closeTo(17.1, 1e-9));
      expect(b.winner, Side.yuan);
      // r = 12.75 / 17.1 = 0.74561: loser 3, winner 2.
      expect(b.officerLosses, {'plain': 3});
      expect(b.armyLosses, {'y1': 2});
      expect(b.daiVietStarted, isTrue);
      expect(r.state.officers['plain']!.nodeId, 'pl', reason: 'withdrew one edge');
    });

    test('plain: 15.3 vs 10×1.9×1.2×0.9 = 20.52', () {
      final b = battle(turn(duel('pl')));
      expect(b.daiVietPower, closeTo(15.3, 1e-9));
      expect(b.yuanPower, closeTo(20.52, 1e-9));
      expect(b.winner, Side.yuan);
      expect(b.officerLosses, {'plain': 3});
      expect(b.armyLosses, {'y1': 2});
    });

    test('river: 18.36 vs 10×1.9×0.9×0.9 = 15.39', () {
      final b = battle(turn(duel('rv1')));
      expect(b.daiVietPower, closeTo(18.36, 1e-9));
      expect(b.yuanPower, closeTo(15.39, 1e-9));
      expect(b.winner, Side.daiViet);
      // r = 0.83824: loser ceil(2.485) = 3, winner ceil(2.096) = 3.
      expect(b.armyLosses, {'y1': 3});
      expect(b.officerLosses, {'plain': 3});
    });

    test('marsh: 18.36 vs 10×1.9×0.8×0.9 = 13.68', () {
      final b = battle(turn(duel('ms')));
      expect(b.daiVietPower, closeTo(18.36, 1e-9));
      expect(b.yuanPower, closeTo(13.68, 1e-9));
      expect(b.winner, Side.daiViet);
      // r = 0.74510: loser ceil(2.765) = 3, winner ceil(1.863) = 2.
      expect(b.armyLosses, {'y1': 3});
      expect(b.officerLosses, {'plain': 2});
    });

    test('hill: 10×1.5×1.1×0.85×1.2 = 16.83 vs 17.1', () {
      final r = turn(duel('hl'));
      final b = battle(r);
      expect(b.daiVietPower, closeTo(16.83, 1e-9));
      expect(b.yuanPower, closeTo(17.1, 1e-9));
      expect(b.winner, Side.yuan);
      // r = 0.98421: loser ceil(2.047) = 3, winner ceil(2.461) = 3.
      expect(b.officerLosses, {'plain': 3});
      expect(b.armyLosses, {'y1': 3});
      expect(r.state.officers['plain']!.nodeId, 'pl');
    });
  });

  group('combat rules', () {
    test('effective troops: full value up to leadership × 3, half above', () {
      expect(effectiveTroops(12, 7), 12);
      expect(effectiveTroops(20, 5), 17.5);
      expect(effectiveTroops(30, 9), 28.5);
    });

    test('several officers at one node add their Power; kingPresence adds +1 morale to all', () {
      final b = battle(turn(mission(
        officers: [at('king', 'rv1', 12), at('plain', 'rv1', 10)],
        armies: [army('rv1', troops: 30)],
        yuanScript: holdAll(),
      )));
      final king = 12 * 1.6 * 1.2 * 0.9 * 1.2;
      final plain = 10 * 1.5 * 1.2 * 0.9 * 1.2;
      expect(b.daiVietPower, closeTo(king + plain, 1e-9));
      expect(b.yuanPower, closeTo(28.5 * 1.9 * 0.9 * 0.9, 1e-9));
    });

    test('winner +1 morale, loser −2 morale; People +1 per battle won', () {
      final r = turn(duel('rv1'));
      final s = r.state;
      expect(s.officers['plain']!.morale, 8);
      expect(r.events.whereType<UnityChanged>().first, isA<UnityChanged>().having((u) => u.to, 'to', 7));
      expect(s.missionStats.battlesWon, 1);
      expect(s.missionStats.troopsLost, 3);
      // The army also retreated one edge toward its retreat node (hl).
      expect(r.events.whereType<ArmyMoved>().single.to, 'cap');
    });

    test('tie goes to the higher leadership, then to the side holding the node', () {
      final e = engineFor(mission(officers: [at('plain', 'cap', 1), at('warden', 'cap', 1)], armies: [army('pl')]));
      final tx = Tx(e.def, e.graph, e.newGame(1).state);
      Side winner(String officerId, Side held) => battleWinner(tx,
          daiVietPower: 5, yuanPower: 5, officerIds: [officerId], armyIds: ['y1'], heldAtStart: held);
      expect(winner('plain', Side.daiViet), Side.yuan, reason: 'Thống 5 < 9');
      expect(winner('warden', Side.daiViet), Side.daiViet, reason: 'Thống 9 = 9, held by Đại Việt');
      expect(winner('warden', Side.yuan), Side.yuan);
      expect(winner('warden', Side.none), Side.yuan);
    });

    test('nextBattleMultiplier applies if the enemy is below the Supply fraction, then resets', () {
      GameState boost(GameState s) => s.copyWith(officers: {
            ...s.officers,
            'plain': s.officers['plain']!.copyWith(nextBattleMultiplier: 2, multiplierEnemySupplyBelow: 0.5),
          });
      final low = turn(
        mission(officers: [at('plain', 'pl', 10)], armies: [army('pl', troops: 10, supply: 9)], yuanScript: holdAll()),
        prepare: boost,
      );
      expect(battle(low).daiVietPower, closeTo(15.3 * 2, 1e-9));
      expect(low.state.officers['plain']!.nextBattleMultiplier, 1);
      expect(low.state.officers['plain']!.multiplierEnemySupplyBelow, isNull);

      final high = turn(
        mission(officers: [at('plain', 'pl', 10)], armies: [army('pl', troops: 10, supply: 10)], yuanScript: holdAll()),
        prepare: boost,
      );
      expect(battle(high).daiVietPower, closeTo(15.3, 1e-9), reason: 'Supply 10 is not below 50% of 20');
    });
  });

  group('withdrawal and capture', () {
    test('losing officers withdraw one edge toward the king', () {
      final r = turn(mission(
        officers: [at('king', 'cap', 12), at('plain', 'pl', 3)],
        armies: [army('pl')],
        yuanScript: holdAll(),
      ));
      expect(battle(r).winner, Side.yuan);
      expect(r.state.officers['plain']!.nodeId, 'cap');
    });

    test('with no free node the loser is captured', () {
      final r = turn(mission(
        officers: [at('plain', 'hl', 3)],
        armies: [army('hl'), army('pl', id: 'y2')],
        yuanScript: [...holdAll(), ...holdAll(armyId: 'y2')],
      ));
      expect(r.state.officers['plain']!.status, OfficerStatus.captured);
      expect(r.state.officers['plain']!.troops, 0);
      expect(r.state.missionStats.captures, 1);
      expect(r.events.whereType<OfficerCaptured>().single.officerId, 'plain');
    });

    test('a captured king loses the mission', () {
      final r = turn(mission(
        officers: [at('king', 'hl', 3)],
        armies: [army('hl'), army('pl', id: 'y2')],
        yuanScript: [...holdAll(), ...holdAll(armyId: 'y2')],
      ));
      expect(r.state.outcome, Outcome.lost);
      expect(r.state.lossReason, LossReasons.kingCaptured);
    });

    test('shieldKing: the shield is captured instead and the king stays', () {
      final r = turn(mission(
        officers: [at('king', 'hl', 12), at('shield', 'hl', 6)],
        armies: [army('hl'), army('pl', id: 'y2')],
        yuanScript: [...holdAll(), ...holdAll(armyId: 'y2')],
      ));
      expect(battle(r).winner, Side.yuan);
      expect(r.state.officers['shield']!.status, OfficerStatus.captured);
      expect(r.state.officers['king']!.status, OfficerStatus.active);
      expect(r.state.officers['king']!.nodeId, 'hl');
      expect(r.events.whereType<KingShielded>().single.shieldId, 'shield');
      expect(r.state.outcome, isNot(Outcome.lost));
    });

    test('with a free node the king simply withdraws, toward the capital', () {
      final r = turn(mission(
        officers: [at('king', 'pl', 3), at('shield', 'pl', 2)],
        armies: [army('pl')],
        yuanScript: holdAll(),
      ));
      expect(r.state.officers['king']!.nodeId, 'cap');
      expect(r.state.officers['shield']!.nodeId, 'cap');
      expect(r.state.missionStats.captures, 0);
    });
  });

  group('ambush', () {
    MissionDef ambushMission(String officerId, int troops, {int armyTroops = 10}) => mission(
          officers: [at(officerId, 'cap', troops)],
          armies: [army('rv1', troops: armyTroops)],
          yuanScript: holdAll(),
        );

    test('ambusher wins: army stops at its starting node and loses 2 extra morale', () {
      final r = turn(
        ambushMission('raider', 12),
        orders: {'raider': Order.ambush(edgeKey('cap', 'rv1'))},
        prepare: (s) => moveArmy(s, 'cap'),
      );
      final b = battle(r);
      expect(b.kind, BattleKind.ambush);
      expect(b.roll, inInclusiveRange(0.9, 1.1));
      // Raider: 12 × 1.9 × 1.2 (river) × 0.85 × 1.5 (ambusher) × roll.
      expect(b.daiVietPower, closeTo(12 * 1.9 * 1.2 * 0.85 * 1.5 * b.roll!, 1e-9));
      expect(b.yuanPower, closeTo(10 * 1.9 * 0.9 * 0.9, 1e-9));
      expect(b.winner, Side.daiViet);
      expect(r.state.armies['y1']!.nodeId, 'rv1');
      expect(r.state.armies['y1']!.morale, 8 - 2 - 2);
      expect(r.state.missionStats.ambushesTriggered, 1);
      expect(r.events.whereType<ArmyMoved>(), isEmpty);
    });

    test('ambusher loses: the army moves on and the ambusher withdraws', () {
      final r = turn(
        ambushMission('plain', 2, armyTroops: 30),
        orders: {'plain': Order.ambush(edgeKey('cap', 'rv1'))},
        prepare: (s) => moveArmy(s, 'cap'),
      );
      expect(battle(r).winner, Side.yuan);
      expect(r.state.officers['plain']!.nodeId, 'pl');
      expect(r.state.armies['y1']!.nodeId, 'cap');
    });

    test('an ambush on another edge does not trigger', () {
      final r = turn(
        ambushMission('raider', 12),
        orders: {'raider': Order.ambush(edgeKey('cap', 'rv1'))},
        prepare: (s) => moveArmy(s, 'rv2'),
      );
      expect(r.events.whereType<BattleResolved>(), isEmpty);
      expect(r.state.armies['y1']!.nodeId, 'rv2');
    });

    test('the ambush roll is the only random step and is seeded', () {
      final noAmbush = turn(duel('rv1'), seed: 3);
      final start = engineFor(duel('rv1')).newGame(3).state;
      expect(noAmbush.state.rng, start.rng, reason: 'a field battle uses no randomness');

      StepResult run(int seed) => turn(
            ambushMission('raider', 12),
            orders: {'raider': Order.ambush(edgeKey('cap', 'rv1'))},
            prepare: (s) => moveArmy(s, 'cap'),
            seed: seed,
          );
      expect(battle(run(3)).roll, battle(run(3)).roll);
      final rolls = {for (var seed = 0; seed < 10; seed++) battle(run(seed)).roll};
      expect(rolls.length, greaterThan(1));
    });
  });

  group('counterattack', () {
    test('winning a battle you started against an army below half Supply is recorded', () {
      final r = turn(
        mission(officers: [at('raider', 'cap', 12)], armies: [army('rv1', troops: 10, supply: 9)], yuanScript: holdAll()),
        orders: {'raider': Order.move('rv1')},
      );
      final b = battle(r);
      expect(b.winner, Side.daiViet);
      expect(b.daiVietStarted, isTrue);
      expect(r.state.missionStats.counterattackNodes, ['rv1']);
    });

    test('a battle the army started does not count', () {
      final r = turn(
        mission(officers: [at('raider', 'cap', 12)], armies: [army('rv1', troops: 10, supply: 9)], yuanScript: holdAll()),
        prepare: (s) => moveArmy(s, 'cap'),
      );
      expect(battle(r).winner, Side.daiViet);
      expect(r.state.missionStats.counterattackNodes, isEmpty);
    });
  });
}
