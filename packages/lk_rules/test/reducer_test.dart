import 'package:lk_rules/lk_rules.dart';
import 'package:lk_rules/src/engine/tx.dart';
import 'package:lk_rules/src/engine/upkeep.dart';
import 'package:test/test.dart';

import 'support/fixture.dart';

void main() {
  group('mission with no units', () {
    test('runs from turn 1 to seasonTurns and ends (won by surviveTurns)', () {
      final e = engineFor(mission(seasonTurns: 3));
      var s = e.newGame(1).state;
      expect(s.turn, 1);
      expect(s.phase, Phase.council);
      final turns = <int>[];
      while (!s.isOver) {
        turns.add(s.turn);
        s = endTurn(e, s).state;
      }
      expect(turns, [1, 2, 3]);
      expect(s.turn, 3);
      expect(s.phase, Phase.ended);
      expect(s.outcome, Outcome.won);
      expect(s.missionStats.wonOnTurn, 3);
      expect(s.stars, [true, true, true]);
    });

    test('ends lost at seasonTurns when the win objectives never hold', () {
      final e = engineFor(mission(seasonTurns: 2, win: const []));
      var s = e.newGame(1).state;
      while (!s.isOver) {
        s = endTurn(e, s).state;
      }
      expect(s.turn, 2);
      expect(s.outcome, Outcome.lost);
      expect(s.lossReason, LossReasons.seasonEnded);
      expect(s.stars, [false, false, false]);
    });
  });

  group('phases', () {
    test('Council → Orders → Resolution, Upkeep, Intel → Council of the next turn', () {
      final e = engineFor(mission());
      final start = e.newGame(1);
      expect(start.events.whereType<PhaseChanged>().map((p) => p.phase), [Phase.intel, Phase.council]);

      final orders = e.apply(start.state, const GameAction.endPhase());
      expect(orders.state.phase, Phase.orders);
      expect(orders.state.turn, 1);

      final next = e.apply(orders.state, const GameAction.endPhase());
      expect(next.state.phase, Phase.council);
      expect(next.state.turn, 2);
      expect(next.events.whereType<PhaseChanged>().map((p) => p.phase),
          [Phase.resolution, Phase.upkeep, Phase.intel, Phase.council]);
      expect(next.events.whereType<TurnStarted>().single.turn, 2);
    });

    test('apply never modifies its input state', () {
      final e = engineFor(mission());
      final s = e.newGame(1).state;
      final hash = stateHash(s);
      e.apply(s, const GameAction.endPhase());
      expect(stateHash(s), hash);
    });
  });

  group('illegal actions', () {
    late GameEngine e;
    late GameState council;
    late GameState orders;

    setUp(() {
      e = engineFor(mission(officers: [at('king', 'cap', 12)]));
      council = e.newGame(1).state;
      orders = e.apply(council, const GameAction.endPhase()).state;
    });

    test('order actions are illegal in Council', () {
      expect(() => e.apply(council, const GameAction.setOrder(officerId: 'king', order: Order.hold)),
          throwsIllegal(IllegalCodes.wrongPhase));
      expect(() => e.apply(council, const GameAction.clearOrder(officerId: 'king')),
          throwsIllegal(IllegalCodes.wrongPhase));
    });

    test('card and skill actions are illegal in Orders', () {
      expect(() => e.apply(orders, const GameAction.playCard(cardId: 'evac', target: 'cap')),
          throwsIllegal(IllegalCodes.wrongPhase));
      expect(() => e.apply(orders, const GameAction.useSkill(officerId: 'king')),
          throwsIllegal(IllegalCodes.wrongPhase));
    });

    test('ResolveChoice without a pending choice is illegal', () {
      expect(() => e.apply(council, const GameAction.resolveChoice(index: 0)),
          throwsIllegal(IllegalCodes.noChoicePending));
      expect(() => e.apply(orders, const GameAction.resolveChoice(index: 0)),
          throwsIllegal(IllegalCodes.noChoicePending));
    });

    test('nothing is legal after the mission ends', () {
      final e1 = engineFor(mission(seasonTurns: 1));
      final over = endTurn(e1, e1.newGame(1).state).state;
      expect(over.isOver, isTrue);
      expect(() => e1.apply(over, const GameAction.endPhase()), throwsIllegal(IllegalCodes.gameOver));
      expect(e1.legalActions(over), isEmpty);
    });
  });

  group('log and replay', () {
    test('every applied action is logged; replay gives the identical state', () {
      final e = engineFor(mission(deck: const [DeckEntry(cardId: 'evac', count: 3)]));
      var s = e.newGame(42).state;
      final actions = <GameAction>[];
      for (var i = 0; i < 5; i++) {
        const a = GameAction.endPhase();
        s = e.apply(s, a).state;
        actions.add(a);
      }
      expect(s.log, actions);
      expect(stateHash(e.replay(42, actions)), stateHash(s));
    });
  });

  group('setup', () {
    test('nodes start Đại Việt except where an army stands; riceStock = yield × 3', () {
      final e = engineFor(mission(armies: [army('pl')]));
      final s = e.newGame(1).state;
      expect(s.nodes['pl']!.controller, Side.yuan);
      expect(s.nodes['cap']!.controller, Side.daiViet);
      expect(s.nodes['cap']!.riceStock, 9);
      expect(s.nodes['hl']!.riceStock, 0);
      expect(s.hasFlag(GameFlags.capitalLost), isFalse);
      expect(engineFor(mission(armies: [army('cap')])).newGame(1).state.hasFlag(GameFlags.capitalLost), isTrue);
    });

    test('officers start at morale 7 with their loyalty, skill uses and troop cap', () {
      final e = engineFor(mission(officers: [at('chancellor', 'cap', 6), at('warden', 'hl', 9)]));
      final s = e.newGame(1).state;
      expect(s.officers['chancellor']!.morale, 7);
      expect(s.officers['chancellor']!.skillUsesLeft, 1);
      expect(s.officers['warden']!.troops, 6, reason: 'troopCap 6');
      expect(s.officers['warden']!.skillUsesLeft, 0, reason: 'passive');
      expect(s.officers['warden']!.loyalty, 10);
    });

    test('the deck is shuffled with the seed and the opening hand is drawn', () {
      final m = mission(deck: const [
        DeckEntry(cardId: 'evac', count: 3),
        DeckEntry(cardId: 'withdraw', count: 2),
        DeckEntry(cardId: 'ambush', count: 2),
      ]);
      final a = engineFor(m).newGame(5).state;
      final b = engineFor(m).newGame(5).state;
      expect(a.hand, hasLength(4));
      expect(a.deck, hasLength(3));
      expect([...a.hand, ...a.deck], b.hand + b.deck);
      final orders = {for (var seed = 0; seed < 20; seed++) (engineFor(m).newGame(seed).state.hand).join(',')};
      expect(orders.length, greaterThan(1), reason: 'different seeds give different hands');
    });

    test('drawing from an empty deck reshuffles the discard', () {
      final e = engineFor(mission(handSize: 3));
      final s = e.newGame(1).state.copyWith(deck: const [], hand: const ['x'], discard: const ['a', 'b', 'c']);
      final tx = Tx(e.def, e.graph, s);
      drawToHandSize(tx);
      expect(tx.s.hand, hasLength(3));
      expect(tx.s.hand.first, 'x');
      expect(tx.s.deck, hasLength(1));
      expect(tx.s.discard, isEmpty);
      expect(tx.events.whereType<DeckShuffled>().single.size, 3);
      expect(tx.s.rng, isNot(s.rng), reason: 'the shuffle used the RNG');
    });
  });
}
