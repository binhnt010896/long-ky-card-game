import 'package:lk_rules/lk_rules.dart';
import 'package:lk_rules/src/engine/objectives.dart';
import 'package:lk_rules/src/engine/orders.dart';
import 'package:lk_rules/src/engine/tx.dart';
import 'package:lk_rules/src/engine/unity.dart';
import 'package:test/test.dart';

import 'support/fixture.dart';

Tx txFor(MissionDef m, [GameState Function(GameState s)? edit]) {
  final e = engineFor(m);
  final s = e.newGame(1).state;
  return Tx(e.def, e.graph, edit == null ? s : edit(s));
}

GameState withOfficer(GameState s, String id, OfficerState Function(OfficerState o) f) =>
    s.copyWith(officers: {...s.officers, id: f(s.officers[id]!)});

GameState withArmy(GameState s, ArmyState Function(ArmyState a) f, {String id = 'y1'}) =>
    s.copyWith(armies: {...s.armies, id: f(s.armies[id]!)});

MissionDef inducementMission({int clan = 6, int threshold = 6, List<PlayerOfficerSetup>? officers}) => mission(
      officers: officers ?? [at('king', 'cap', 12), at('scholar', 'cap', 4), at('raider', 'pl', 8)],
      unity: StartingUnity(court: 6, clan: clan, people: 6),
      inducements: [Inducement(turn: 1, threshold: threshold)],
    );

void main() {
  group('Unity thresholds', () {
    test('Court < 4: every card costs +1 Support', () {
      final card = testCards.firstWhere((c) => c.id == 'evac');
      expect(cardSupportCost(txFor(mission()), card), 2);
      expect(
        cardSupportCost(txFor(mission(unity: const StartingUnity(court: 3, clan: 6, people: 6))), card),
        3,
      );
      expect(
        cardSupportCost(txFor(mission(unity: const StartingUnity(court: 4, clan: 6, people: 6))), card),
        2,
      );
    });

    test('Court −1 the first time the capital is lost, never again', () {
      final e = engineFor(mission(armies: [army('pl')]));
      var s = e.newGame(1).state;
      s = withArmy(s, (a) => a.copyWith(intent: const Intent(kind: IntentKind.advance, moveTo: 'cap')));
      final r = endTurn(e, s);
      expect(r.state.nodes['cap']!.controller, Side.yuan);
      expect(r.state.unity.court, 5);
      expect(r.state.hasFlag(GameFlags.capitalLost), isTrue);

      final tx = Tx(e.def, e.graph, r.state);
      onNodeControlChanged(tx, 'cap', Side.yuan);
      expect(tx.s.unity.court, 5, reason: 'only the first loss costs Court');
    });

    test('Clan < 4: defection threshold +2', () {
      StepResult run(int clan) => endTurn(engineFor(inducementMission(clan: clan)), engineFor(inducementMission(clan: clan)).newGame(1).state);
      // scholar: loyalty 5. Clan 6: 5 + 3 = 8 ≥ 6. Clan 4: 5 + 2 = 7 ≥ 6.
      expect(run(6).state.officers['scholar']!.status, OfficerStatus.active);
      expect(run(4).state.officers['scholar']!.status, OfficerStatus.active);
      // Clan 3: threshold 8, and 5 + 1 = 6 < 8.
      final low = run(3);
      expect(low.state.officers['scholar']!.status, OfficerStatus.defected);
      expect(low.state.unity.clan, 2);
    });

    test('People < 4: evacuate orders cost 2 (rally troops: see orders_test)', () {
      expect(evacuateOrderCost(txFor(mission(unity: const StartingUnity(court: 6, clan: 6, people: 3)))), 2);
      expect(evacuateOrderCost(txFor(mission(unity: const StartingUnity(court: 6, clan: 6, people: 4)))), 1);
    });

    test('any pillar at 0 loses the mission', () {
      final r = endTurn(
        engineFor(inducementMission(clan: 1)),
        engineFor(inducementMission(clan: 1)).newGame(1).state,
      );
      expect(r.state.unity.clan, 0);
      expect(r.state.outcome, Outcome.lost);
      expect(r.state.lossReason, 'unity:clan');
    });
  });

  group('inducements', () {
    test('the lowest-loyalty unlocked officer defects; troops removed, Clan −1', () {
      final m = inducementMission(threshold: 9);
      final e = engineFor(m);
      final r = endTurn(e, e.newGame(1).state);
      expect(r.state.officers['scholar']!.status, OfficerStatus.defected);
      expect(r.state.officers['scholar']!.troops, 0);
      expect(r.state.officers['raider']!.status, OfficerStatus.active);
      expect(r.state.unity.clan, 5);
      expect(r.state.missionStats.defections, 1);
      expect(r.events.whereType<OfficerDefected>().single.officerId, 'scholar');
    });

    test('locked officers are never chosen; ties go by id', () {
      final e = engineFor(inducementMission(threshold: 20));
      var s = e.newGame(1).state;
      s = withOfficer(s, 'raider', (o) => o.copyWith(loyalty: 5));
      final r = endTurn(e, s);
      expect(r.state.officers['raider']!.status, OfficerStatus.defected, reason: 'raider < scholar');
      expect(r.state.officers['king']!.status, OfficerStatus.active);

      final onlyLocked = engineFor(inducementMission(threshold: 20, officers: [at('king', 'cap', 12)]));
      final r2 = endTurn(onlyLocked, onlyLocked.newGame(1).state);
      expect(r2.state.missionStats.defections, 0);
    });

    test('only on the listed turn', () {
      final e = engineFor(mission(
        officers: [at('scholar', 'cap', 4)],
        inducements: const [Inducement(turn: 2, threshold: 20)],
      ));
      final t1 = endTurn(e, e.newGame(1).state);
      expect(t1.state.officers['scholar']!.status, OfficerStatus.active);
      final t2 = endTurn(e, t1.state);
      expect(t2.state.officers['scholar']!.status, OfficerStatus.defected);
    });
  });

  group('objectives', () {
    final base = mission(
      officers: [at('king', 'cap', 12), at('plain', 'pl', 6)],
      armies: [army('hl'), army('rv2', id: 'y2')],
    );
    bool holds(ObjectiveDef o, [GameState Function(GameState s)? edit]) => objectiveHolds(txFor(base, edit), o);

    GameState route(GameState s, String id) => withArmy(s, (a) => a.copyWith(status: ArmyStatus.routed), id: id);

    test('allArmiesBroken and armyBroken', () {
      expect(holds(const AllArmiesBrokenObjective()), isFalse);
      expect(holds(const AllArmiesBrokenObjective(), (s) => route(s, 'y1')), isFalse);
      expect(holds(const AllArmiesBrokenObjective(), (s) => route(route(s, 'y1'), 'y2')), isTrue);
      expect(holds(const ArmyBrokenObjective('y1'), (s) => route(s, 'y1')), isTrue);
      expect(holds(const ArmyBrokenObjective('y2'), (s) => route(s, 'y1')), isFalse);
    });

    test('counterattackAt', () {
      expect(holds(const CounterattackAtObjective('hl')), isFalse);
      expect(
        holds(const CounterattackAtObjective('hl'),
            (s) => s.copyWith(missionStats: s.missionStats.copyWith(counterattackNodes: ['hl']))),
        isTrue,
      );
    });

    test('surviveTurns', () {
      expect(holds(const SurviveTurnsObjective(2)), isFalse);
      expect(holds(const SurviveTurnsObjective(2), (s) => s.copyWith(turn: 2)), isTrue);
    });

    test('kingAt by end of turn', () {
      expect(holds(const KingAtObjective('cap', 4)), isTrue);
      expect(holds(const KingAtObjective('pl', 4)), isFalse);
      expect(holds(const KingAtObjective('cap', 4), (s) => s.copyWith(turn: 5)), isFalse);
      expect(
        holds(const KingAtObjective('cap', 4),
            (s) => withOfficer(s, 'king', (o) => o.copyWith(status: OfficerStatus.captured))),
        isFalse,
      );
    });

    test('armySupplyAtMost', () {
      expect(holds(const ArmySupplyAtMostObjective('y1', 0.25)), isFalse);
      expect(holds(const ArmySupplyAtMostObjective('y1', 0.25), (s) => withArmy(s, (a) => a.copyWith(supply: 5))), isTrue);
      expect(holds(const ArmySupplyAtMostObjective('y1', 0.25), (s) => withArmy(s, (a) => a.copyWith(supply: 6))), isFalse);
      expect(holds(const ArmySupplyAtMostObjective('y1', 0.25), (s) => route(s, 'y1')), isTrue);
    });

    test('kingNotCaptured and capitalHeld', () {
      expect(holds(const KingNotCapturedObjective()), isTrue);
      expect(
        holds(const KingNotCapturedObjective(),
            (s) => withOfficer(s, 'king', (o) => o.copyWith(status: OfficerStatus.captured))),
        isFalse,
      );
      expect(holds(const CapitalHeldObjective()), isTrue);
      expect(
        holds(const CapitalHeldObjective(),
            (s) => s.copyWith(nodes: {...s.nodes, 'cap': s.nodes['cap']!.copyWith(controller: Side.yuan)})),
        isFalse,
      );
    });

    test('unityAllAbove is strict; unityAtLeastAtEnd is inclusive', () {
      GameState unity(GameState s, int court) => s.copyWith(unity: s.unity.copyWith(court: court));
      expect(holds(const UnityAllAboveObjective(5)), isTrue);
      expect(holds(const UnityAllAboveObjective(5), (s) => unity(s, 5)), isFalse);
      expect(holds(const UnityAtLeastAtEndObjective(Pillar.court, 7), (s) => unity(s, 7)), isTrue);
      expect(holds(const UnityAtLeastAtEndObjective(Pillar.court, 7), (s) => unity(s, 6)), isFalse);
    });

    test('noDefections, noCaptures, troopsLostAtMost', () {
      GameState stats(GameState s, MissionStats Function(MissionStats m) f) => s.copyWith(missionStats: f(s.missionStats));
      expect(holds(const NoDefectionsObjective()), isTrue);
      expect(holds(const NoDefectionsObjective(), (s) => stats(s, (m) => m.copyWith(defections: 1))), isFalse);
      expect(holds(const NoCapturesObjective()), isTrue);
      expect(holds(const NoCapturesObjective(), (s) => stats(s, (m) => m.copyWith(captures: 1))), isFalse);
      expect(holds(const TroopsLostAtMostObjective(10), (s) => stats(s, (m) => m.copyWith(troopsLost: 10))), isTrue);
      expect(holds(const TroopsLostAtMostObjective(10), (s) => stats(s, (m) => m.copyWith(troopsLost: 11))), isFalse);
    });

    test('winByTurn, won and anyOf', () {
      expect(holds(const WinByTurnObjective(4), (s) => s.copyWith(missionStats: s.missionStats.copyWith(wonOnTurn: 4))), isTrue);
      expect(holds(const WinByTurnObjective(4), (s) => s.copyWith(missionStats: s.missionStats.copyWith(wonOnTurn: 5))), isFalse);
      expect(holds(const WonObjective()), isFalse);
      expect(holds(const WonObjective(), (s) => s.copyWith(outcome: Outcome.won)), isTrue);
      const either = AnyOfObjective([KingAtObjective('pl', 4), KingAtObjective('cap', 4)]);
      expect(holds(either), isTrue);
      expect(holds(const AnyOfObjective([KingAtObjective('pl', 4), KingAtObjective('rv1', 4)])), isFalse);
    });
  });

  group('win, loss and stars', () {
    test('win objectives are checked at the end of each turn', () {
      final e = engineFor(mission(
        officers: [at('king', 'pl', 12)],
        win: const [AnyOfObjective([KingAtObjective('cap', 4), KingAtObjective('hl', 4)])],
        stars: const [WonObjective(), WinByTurnObjective(1), TroopsLostAtMostObjective(0)],
      ));
      var s = e.apply(e.newGame(1).state, const GameAction.endPhase()).state;
      s = e.apply(s, const GameAction.setOrder(officerId: 'king', order: Order(kind: OrderKind.move, target: 'cap'))).state;
      final r = e.apply(s, const GameAction.endPhase());
      expect(r.state.outcome, Outcome.won);
      expect(r.state.turn, 1);
      expect(r.state.stars, [true, true, true]);
      expect(r.events.whereType<MissionEnded>().single.stars, [true, true, true]);
    });

    test('a failed loss objective loses at once, with its type as the reason', () {
      final e = engineFor(mission(
        officers: [at('king', 'rv2', 12)],
        armies: [army('pl')],
        loss: const [KingNotCapturedObjective(), UnityAllAboveObjective(0), CapitalHeldObjective()],
      ));
      var s = e.newGame(1).state;
      s = withArmy(s, (a) => a.copyWith(intent: const Intent(kind: IntentKind.advance, moveTo: 'cap')));
      final r = endTurn(e, s);
      expect(r.state.outcome, Outcome.lost);
      expect(r.state.lossReason, 'objective:capitalHeld');
      expect(r.state.stars, [false, false, false]);
    });

    test('losses are checked before wins', () {
      // Turn 1 survives (win) but the defection drops Clan to 0 (loss).
      final e = engineFor(mission(
        seasonTurns: 1,
        officers: [at('king', 'cap', 4), at('scholar', 'cap', 4)],
        unity: const StartingUnity(court: 6, clan: 1, people: 6),
        inducements: const [Inducement(turn: 1, threshold: 20)],
      ));
      final s = endTurn(e, e.newGame(1).state).state;
      expect(s.outcome, Outcome.lost);
      expect(s.lossReason, 'unity:clan');
    });

    test('stars are only earned on a win', () {
      final e = engineFor(mission(seasonTurns: 1, win: const [], stars: const [WonObjective(), NoDefectionsObjective(), NoCapturesObjective()]));
      final s = endTurn(e, e.newGame(1).state).state;
      expect(s.outcome, Outcome.lost);
      expect(s.stars, [false, false, false]);
    });
  });
}
