import 'package:lk_rules/lk_rules.dart';
import 'package:test/test.dart';

import 'support/fixture.dart';

/// Council state of [m] with [hand] in hand.
(GameEngine, GameState) council(MissionDef m, {List<String> hand = const [], int seed = 1}) {
  final e = engineFor(m);
  final s = e.newGame(seed).state.copyWith(hand: hand);
  expect(s.phase, Phase.council);
  return (e, s);
}

GameState playCard(GameEngine e, GameState s, String cardId, [String? target]) =>
    e.apply(s, GameAction.playCard(cardId: cardId, target: target)).state;

final standard = mission(
  officers: [at('king', 'cap', 12), at('plain', 'pl', 6), at('raider', 'rv1', 8)],
  armies: [army('hl', supply: 8)],
  yuanScript: holdAll(),
);

void main() {
  group('PlayCard', () {
    test('pays the cost, discards the card and counts it', () {
      final (e, s) = council(standard, hand: ['withdraw', 'evac']);
      final r = e.apply(s, const GameAction.playCard(cardId: 'withdraw', target: 'plain'));
      expect(r.state.rice, 3);
      expect(r.state.hand, ['evac']);
      expect(r.state.discard, ['withdraw']);
      expect(r.state.missionStats.cardsPlayed, {'withdraw': 1});
      expect(r.events.whereType<CardPlayed>().single.cardId, 'withdraw');
    });

    test('card not in hand, unaffordable, or an enemy intent card is illegal', () {
      final (e, s) = council(standard, hand: ['evac', 'omen']);
      expect(() => playCard(e, s, 'withdraw', 'plain'), throwsIllegal(IllegalCodes.cardNotInHand));
      expect(() => playCard(e, s.copyWith(support: 1), 'evac', 'cap'), throwsIllegal(IllegalCodes.cannotAfford));
      expect(() => playCard(e, s, 'omen'), throwsIllegal(IllegalCodes.badTarget));
    });

    test('Court < 4 adds 1 Support to the cost', () {
      final (e, s) = council(standard, hand: ['evac']);
      final low = s.copyWith(unity: s.unity.copyWith(court: 3));
      expect(() => playCard(e, low.copyWith(support: 2), 'evac', 'cap'), throwsIllegal(IllegalCodes.cannotAfford));
      expect(playCard(e, low.copyWith(support: 3), 'evac', 'cap').support, 0);
    });

    test('targets are checked against the card target kind', () {
      final (e, s) = council(standard, hand: ['evac', 'withdraw', 'ambush', 'harass', 'ford', 'boost']);
      expect(() => playCard(e, s, 'evac'), throwsIllegal(IllegalCodes.badTarget));
      expect(() => playCard(e, s, 'evac', 'hl'), throwsIllegal(IllegalCodes.badTarget), reason: 'Yuan-held');
      expect(() => playCard(e, s, 'withdraw', 'ghost'), throwsIllegal(IllegalCodes.badTarget));
      expect(() => playCard(e, s, 'ambush', edgeKey('pl', 'cap')), throwsIllegal(IllegalCodes.badTarget), reason: 'land');
      expect(() => playCard(e, s, 'harass', 'plain'), throwsIllegal(IllegalCodes.badTarget));
      expect(() => playCard(e, s, 'ford', 'nowhere'), throwsIllegal(IllegalCodes.badTarget));
      expect(() => playCard(e, s, 'boost', 'cap'), throwsIllegal(IllegalCodes.badTarget), reason: 'target none');
    });

    test('a failed step leaves the state untouched', () {
      final (e, s) = council(mission(officers: [at('plain', 'pl', 6)]), hand: ['ambush']);
      expect(() => playCard(e, s, 'ambush', edgeKey('ms', 'rv1')), throwsIllegal(IllegalCodes.noAmbusher));
      expect(s.hand, ['ambush']);
      expect(s.rice, 4);
    });
  });

  group('conditions', () {
    test('armySupplyBelowFraction', () {
      final (e, s) = council(standard, hand: ['harass']);
      expect(() => playCard(e, s.copyWith(armies: {'y1': s.armies['y1']!.copyWith(supply: 10)}), 'harass', 'y1'),
          throwsIllegal(IllegalCodes.conditionFailed));
      expect(playCard(e, s, 'harass', 'y1').armies['y1']!.supply, 3);
    });

    test('nodeTerrain and unityAtLeast', () {
      final (e, s) = council(standard, hand: ['ford']);
      expect(playCard(e, s, 'ford', 'rv1').rice, 5);
      expect(() => playCard(e, s, 'ford', 'pl'), throwsIllegal(IllegalCodes.conditionFailed));
      expect(() => playCard(e, s.copyWith(unity: s.unity.copyWith(court: 4)), 'ford', 'rv1'),
          throwsIllegal(IllegalCodes.conditionFailed));
    });
  });

  group('effect ops', () {
    test('modUnity clamps to 0–10, setUnity sets, modResource floors at 0', () {
      final (e, s) = council(standard, hand: ['boost']);
      final r = playCard(e, s, 'boost');
      expect(r.rice, 7);
      expect(r.support, 0);
      expect(r.unity.clan, 10);
      expect(r.unity.people, 2);
    });

    test('evacuateNode: evacuated, Rice += riceStock; a second one this turn costs People', () {
      final (e, s) = council(standard, hand: ['evac', 'evac']);
      final s1 = playCard(e, s.copyWith(support: 4), 'evac', 'cap');
      expect(s1.nodes['cap']!.evacuated, isTrue);
      expect(s1.rice, 4 + 9);
      expect(s1.unity.people, 6);
      expect(() => playCard(e, s1, 'evac', 'cap'), throwsIllegal(IllegalCodes.alreadyEvacuated));
      final s2 = playCard(e, s1, 'evac', 'pl');
      expect(s2.unity.people, 5);
    });

    test('withdrawOfficer: one edge toward the king, no battle there this turn, no orders', () {
      final m = mission(
        officers: [at('king', 'cap', 12), at('plain', 'pl', 6)],
        armies: [army('hl')],
        yuanScript: [const YuanScriptEntry(turn: 1, armyId: 'y1', intent: IntentKind.advance, targetNodeId: 'pl')],
      );
      final (e, s) = council(m, hand: ['withdraw']);
      // Make the army walk into pl this turn.
      final moving = s.copyWith(armies: {
        'y1': s.armies['y1']!.copyWith(intent: const Intent(kind: IntentKind.advance, moveTo: 'pl')),
      });
      final s1 = playCard(e, moving, 'withdraw', 'plain');
      expect(s1.officers['plain']!.nodeId, 'cap');
      expect(s1.officers['plain']!.withdrawn, isTrue);
      final orders = e.apply(s1, const GameAction.endPhase()).state;
      expect(() => e.apply(orders, const GameAction.setOrder(officerId: 'plain', order: Order.hold)),
          throwsIllegal(IllegalCodes.officerWithdrawn));
      final r = e.apply(orders, const GameAction.endPhase());
      expect(r.events.whereType<BattleResolved>(), isEmpty);
      expect(r.state.officers['plain']!.withdrawn, isFalse, reason: 'cleared next turn');
    });

    test('withdrawOfficer with no free node is illegal', () {
      final m = mission(
        officers: [at('plain', 'hl', 6)],
        armies: [army('pl')],
        yuanScript: holdAll(),
      );
      final (e, s) = council(m, hand: ['withdraw']);
      expect(() => playCard(e, s, 'withdraw', 'plain'), throwsIllegal(IllegalCodes.noWithdrawal));
    });

    test('placeAmbush: manned by the highest-War officer at either end; triggers on crossing', () {
      final m = mission(
        officers: [at('plain', 'cap', 6), at('raider', 'rv1', 12)],
        armies: [army('rv2', troops: 10)],
        yuanScript: holdAll(),
      );
      final (e, s) = council(m, hand: ['ambush']);
      final s1 = playCard(e, s, 'ambush', edgeKey('cap', 'rv1'));
      expect(s1.ambushes, [const Ambush(edge: 'cap~rv1', officerId: 'raider')]);

      final (e2, s2) = council(m, hand: ['ambush']);
      var st = playCard(e2, s2, 'ambush', edgeKey('rv1', 'rv2'));
      st = st.copyWith(armies: {'y1': st.armies['y1']!.copyWith(intent: const Intent(kind: IntentKind.advance, moveTo: 'rv1'))});
      final r = endTurn(e2, st);
      final b = r.events.whereType<BattleResolved>().first.report;
      expect(b.kind, BattleKind.ambush);
      expect(b.officerIds, ['raider']);
    });

    test('powerMultiplier sets the next-battle multiplier and its condition', () {
      final (e, s) = council(standard, hand: ['counter']);
      final s1 = playCard(e, s, 'counter', 'plain');
      expect(s1.officers['plain']!.nextBattleMultiplier, 2);
      expect(s1.officers['plain']!.multiplierEnemySupplyBelow, 0.5);
      expect(s1.rice, 2);
      expect(s1.support, 3);
    });

    test('modArmy on one army and on all armies, clamped', () {
      final m = mission(armies: [army('hl', troops: 1), army('pl', id: 'y2', troops: 10)], yuanScript: holdAll());
      final (e, s) = council(m, hand: ['heat', 'harass']);
      final s1 = playCard(e, s, 'heat');
      expect(s1.armies['y1']!.troops, 0);
      expect(s1.armies['y2']!.troops, 9);
      final low = s1.copyWith(armies: {...s1.armies, 'y2': s1.armies['y2']!.copyWith(supply: 3, morale: 8)});
      final s2 = playCard(e, low, 'harass', 'y2');
      expect(s2.armies['y2']!.supply, 0);
      expect(s2.armies['y2']!.morale, 10);
    });

    test('revealIntent raises revealDepth for this turn', () {
      final (e, s) = council(standard, hand: ['scout']);
      expect(s.revealDepth, 1);
      final s1 = playCard(e, s, 'scout');
      expect(s1.revealDepth, 2);
      expect(endTurn(e, s1).state.revealDepth, 1);
    });

    test('skipTurn: Council goes straight to Resolution', () {
      final m = mission(officers: [at('king', 'cap', 12)], scriptedEvents: const [ScriptedEvent(turn: 1, cardId: 'envoy')]);
      final e = engineFor(m);
      final s = e.newGame(1).state;
      final accepted = e.apply(s, const GameAction.resolveChoice(index: 1)).state;
      expect(accepted.unity.court, 4);
      expect(accepted.hasFlag(GameFlags.skipOrders), isTrue);
      final r = e.apply(accepted, const GameAction.endPhase());
      expect(r.events.whereType<OrdersSkipped>(), hasLength(1));
      expect(r.state.turn, 2);
      expect(r.state.phase, Phase.council);
      expect(r.state.hasFlag(GameFlags.skipOrders), isFalse);
    });
  });

  group('choice', () {
    test('a choice blocks every other action until resolved', () {
      final (e, s) = council(standard, hand: ['envoy', 'evac']);
      final s1 = playCard(e, s, 'envoy');
      expect(s1.pendingChoice, isNotNull);
      expect(e.legalActions(s1), const [GameAction.resolveChoice(index: 0), GameAction.resolveChoice(index: 1)]);
      expect(() => playCard(e, s1, 'evac', 'cap'), throwsIllegal(IllegalCodes.choicePending));
      expect(() => e.apply(s1, const GameAction.endPhase()), throwsIllegal(IllegalCodes.choicePending));
      expect(() => e.apply(s1, const GameAction.resolveChoice(index: 2)), throwsIllegal(IllegalCodes.badChoiceIndex));
      final refused = e.apply(s1, const GameAction.resolveChoice(index: 0)).state;
      expect(refused.pendingChoice, isNull);
      expect(refused.unity.people, 7);
    });

    test('nested choices follow their path', () {
      final (e, s) = council(standard, hand: ['nested']);
      final s1 = playCard(e, s, 'nested');
      expect(s1.rice, 5);
      expect(s1.pendingChoice!.path, [1]);
      final s2 = e.apply(s1, const GameAction.resolveChoice(index: 1)).state;
      expect(s2.support, 5);
      expect(s2.pendingChoice!.path, [1, 1, 1]);
      final s3 = e.apply(s2, const GameAction.resolveChoice(index: 0)).state;
      expect(s3.unity.court, 7);
      expect(s3.pendingChoice, isNull);
    });

    test('choiceEffectOf finds the choice a pending choice waits on, nested or not', () {
      final (e, s) = council(standard, hand: ['nested']);
      final s1 = playCard(e, s, 'nested');
      final first = choiceEffectOf(e.def, s1.pendingChoice!);
      expect(first.options, hasLength(s1.pendingChoice!.optionCount));
      final s2 = e.apply(s1, const GameAction.resolveChoice(index: 1)).state;
      final inner = choiceEffectOf(e.def, s2.pendingChoice!);
      expect(inner, same((first.options[1].effects[1] as ChoiceEffect)));
      expect(inner.options, hasLength(s2.pendingChoice!.optionCount));
    });
  });

  group('scripted events', () {
    test('play at Intel of their turn; a choice is pending at Council; not added to the discard', () {
      final m = mission(
        officers: [at('king', 'cap', 12)],
        armies: [army('hl', troops: 10)],
        scriptedEvents: const [ScriptedEvent(turn: 2, cardId: 'heat')],
        yuanScript: holdAll(),
      );
      final e = engineFor(m);
      final t1 = e.newGame(1).state;
      expect(t1.armies['y1']!.troops, 10);
      final t2 = endTurn(e, t1).state;
      expect(t2.armies['y1']!.troops, 9);
      expect(t2.discard, isEmpty);
      expect(t2.missionStats.cardsPlayed, {'heat': 1});
    });

    test('events queued behind a choice play after it is resolved', () {
      final m = mission(
        armies: [army('hl', troops: 10)],
        scriptedEvents: const [
          ScriptedEvent(turn: 1, cardId: 'envoy'),
          ScriptedEvent(turn: 1, cardId: 'heat'),
        ],
        yuanScript: holdAll(),
      );
      final e = engineFor(m);
      final s = e.newGame(1).state;
      expect(s.pendingChoice, isNotNull);
      expect(s.scriptedQueue, ['heat']);
      expect(s.armies['y1']!.troops, 10);
      final r = e.apply(s, const GameAction.resolveChoice(index: 0)).state;
      expect(r.scriptedQueue, isEmpty);
      expect(r.armies['y1']!.troops, 9);
    });
  });

  group('scripted events and losses', () {
    test('a loss from a choice stops the rest of the scripted queue', () {
      // Found by the invariant run: Court hit 0 in a choice, and the next
      // queued event then opened another choice on a finished mission.
      final m = mission(
        officers: [at('king', 'cap', 12)],
        unity: const StartingUnity(court: 1, clan: 6, people: 6),
        scriptedEvents: const [ScriptedEvent(turn: 1, cardId: 'nested'), ScriptedEvent(turn: 1, cardId: 'envoy')],
      );
      final e = engineFor(m);
      var s = e.newGame(1).state;
      s = e.apply(s, const GameAction.resolveChoice(index: 1)).state;
      final r = e.apply(s, const GameAction.resolveChoice(index: 1));
      expect(r.state.outcome, Outcome.lost);
      expect(r.state.lossReason, 'unity:court');
      expect(r.state.pendingChoice, isNull);
      expect(r.state.scriptedQueue, isEmpty);
      expect(r.events.whereType<CardPlayed>(), isEmpty, reason: 'envoy is never played');
    });
  });

  group('activated skills', () {
    test('setUnity court 10, once per mission', () {
      final m = mission(officers: [at('chancellor', 'cap', 6)], unity: const StartingUnity(court: 3, clan: 6, people: 6));
      final (e, s) = council(m);
      final r = e.apply(s, const GameAction.useSkill(officerId: 'chancellor'));
      expect(r.state.unity.court, 10);
      expect(r.state.officers['chancellor']!.skillUsesLeft, 0);
      expect(r.state.missionStats.skillsUsed, {'restore-court': 1});
      expect(() => e.apply(r.state, const GameAction.useSkill(officerId: 'chancellor')),
          throwsIllegal(IllegalCodes.noUsesLeft));
    });

    test('a targeted skill: evacuate a held node at no Support cost, then Court −1; twice', () {
      final m = mission(officers: [at('scholar', 'cap', 4)], support: 0);
      final (e, s) = council(m);
      final s1 = e.apply(s, const GameAction.useSkill(officerId: 'scholar', target: 'cap')).state;
      expect(s1.nodes['cap']!.evacuated, isTrue);
      expect(s1.unity.court, 5);
      expect(s1.support, 0);
      final s2 = e.apply(s1, const GameAction.useSkill(officerId: 'scholar', target: 'pl')).state;
      expect(s2.unity.court, 4);
      expect(() => e.apply(s2, const GameAction.useSkill(officerId: 'scholar', target: 'ms')),
          throwsIllegal(IllegalCodes.noUsesLeft));
      expect(() => e.apply(s, const GameAction.useSkill(officerId: 'scholar')), throwsIllegal(IllegalCodes.badTarget));
    });

    test('passive or missing skills cannot be used; nor by inactive officers', () {
      final (e, s) = council(mission(officers: [at('king', 'cap', 12), at('plain', 'pl', 6), at('chancellor', 'cap', 6)]));
      expect(() => e.apply(s, const GameAction.useSkill(officerId: 'king')), throwsIllegal(IllegalCodes.noActivatedSkill));
      expect(() => e.apply(s, const GameAction.useSkill(officerId: 'plain')), throwsIllegal(IllegalCodes.noActivatedSkill));
      expect(() => e.apply(s, const GameAction.useSkill(officerId: 'ghost')), throwsIllegal(IllegalCodes.unknownOfficer));
      final gone = s.copyWith(officers: {
        ...s.officers,
        'chancellor': s.officers['chancellor']!.copyWith(status: OfficerStatus.defected),
      });
      expect(() => e.apply(gone, const GameAction.useSkill(officerId: 'chancellor')),
          throwsIllegal(IllegalCodes.officerInactive));
    });
  });

  group('passive skills', () {
    test('borderWatch: revealDepth 2 while on a border node', () {
      final onBorder = engineFor(mission(officers: [at('warden', 'hl', 6)])).newGame(1).state;
      expect(onBorder.revealDepth, 2);
      final inland = engineFor(mission(officers: [at('warden', 'pl', 6)])).newGame(1).state;
      expect(inland.revealDepth, 1);
      final notWarden = engineFor(mission(officers: [at('plain', 'hl', 6)])).newGame(1).state;
      expect(notWarden.revealDepth, 1);
    });

    // kingPresence and shieldKing: combat_test.dart; raider: orders_test.dart.
  });

  group('legal Council actions', () {
    test('every listed card play and skill use is legal', () {
      final m = mission(
        officers: [at('king', 'cap', 12), at('chancellor', 'cap', 6), at('raider', 'rv1', 8)],
        armies: [army('hl', supply: 8)],
        yuanScript: holdAll(),
      );
      final (e, s) = council(m, hand: ['evac', 'withdraw', 'ambush', 'counter']);
      final legal = e.legalActions(s);
      expect(legal.last, const GameAction.endPhase());
      expect(legal, contains(const GameAction.useSkill(officerId: 'chancellor')));
      expect(legal, contains(GameAction.playCard(cardId: 'ambush', target: edgeKey('cap', 'rv1'))));
      expect(legal, isNot(contains(const GameAction.playCard(cardId: 'evac', target: 'hl'))));
      for (final a in legal) {
        expect(e.isLegal(s, a), isTrue, reason: '$a');
      }
    });
  });
}
