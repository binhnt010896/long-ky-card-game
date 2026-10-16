import 'dart:convert';

import 'package:lk_rules/lk_rules.dart';
import 'package:test/test.dart';

import 'support/fixture.dart';

/// A mission that uses every system: all officers, two armies, every card,
/// scripted events with choices, inducements and heat.
final MissionDef everything = mission(
  seasonTurns: 6,
  heatStartTurn: 3,
  officers: [
    at('king', 'cap', 12),
    at('chancellor', 'cap', 6),
    at('shield', 'cap', 6),
    at('warden', 'hl', 6),
    at('raider', 'ms', 8),
    at('scholar', 'rv1', 4),
    at('plain', 'rv2', 6),
  ],
  armies: [army('hl', troops: 30), army('pl', id: 'y2', troops: 20, supply: 10, retreatNodeId: 'hl')],
  deck: const [
    DeckEntry(cardId: 'evac', count: 3),
    DeckEntry(cardId: 'withdraw', count: 2),
    DeckEntry(cardId: 'ambush', count: 2),
    DeckEntry(cardId: 'counter', count: 2),
    DeckEntry(cardId: 'envoy', count: 1),
    DeckEntry(cardId: 'heat', count: 1),
    DeckEntry(cardId: 'boost', count: 1),
    DeckEntry(cardId: 'scout', count: 1),
    DeckEntry(cardId: 'harass', count: 1),
    DeckEntry(cardId: 'ford', count: 1),
    DeckEntry(cardId: 'nested', count: 1),
  ],
  scriptedEvents: const [
    ScriptedEvent(turn: 1, cardId: 'envoy'),
    ScriptedEvent(turn: 2, cardId: 'heat'),
    ScriptedEvent(turn: 3, cardId: 'nested'),
    ScriptedEvent(turn: 3, cardId: 'envoy'),
  ],
  inducements: const [Inducement(turn: 2, threshold: 8), Inducement(turn: 4, threshold: 9)],
  win: const [
    AnyOfObjective([CounterattackAtObjective('rv1'), AllArmiesBrokenObjective(), SurviveTurnsObjective(6)]),
  ],
);

void checkInvariants(GameEngine e, GameState s, int deckSize) {
  final m = e.def.mission;
  for (final p in Pillar.values) {
    expect(s.unity[p], inInclusiveRange(0, 10), reason: 'Unity ${p.name}');
  }
  expect(s.rice, greaterThanOrEqualTo(0));
  expect(s.support, greaterThanOrEqualTo(0));
  for (final MapEntry(key: id, value: o) in s.officers.entries) {
    expect(o.troops, greaterThanOrEqualTo(0), reason: '$id troops');
    expect(o.morale, inInclusiveRange(0, 10), reason: '$id morale');
    expect(e.graph.hasNode(o.nodeId), isTrue, reason: '$id on exactly one map node');
    final cap = e.def.officers[id]!.troopCap;
    if (cap != null) expect(o.troops, lessThanOrEqualTo(cap));
  }
  for (final MapEntry(key: id, value: a) in s.armies.entries) {
    expect(a.troops, greaterThanOrEqualTo(0), reason: '$id troops');
    expect(a.supply, inInclusiveRange(0, a.maxSupply), reason: '$id supply');
    expect(a.morale, inInclusiveRange(0, 10), reason: '$id morale');
    expect(e.graph.hasNode(a.nodeId), isTrue, reason: '$id on exactly one map node');
  }
  if (s.pendingChoice != null) {
    expect(s.phase, Phase.council, reason: 'a choice waits in Council');
    expect(e.legalActions(s).every((a) => a is ResolveChoice), isTrue, reason: 'only ResolveChoice is legal');
  }
  expect(s.turn, inInclusiveRange(1, m.seasonTurns), reason: 'the game ends by seasonTurns');
  expect(s.hand.length, lessThanOrEqualTo(m.handSize));
  expect(s.hand.length + s.deck.length + s.discard.length, deckSize, reason: 'no card is lost or invented');
  if (!s.isOver) {
    expect(s.phase, anyOf(Phase.council, Phase.orders), reason: 'steps rest in Council or Orders');
  }
}

/// Plays one random-legal game from [seed]; returns the final state.
GameState randomGame(GameEngine e, int seed, int deckSize) {
  final rng = SeededRng(seed * 7919 + 1);
  var s = e.newGame(seed).state;
  checkInvariants(e, s, deckSize);
  var steps = 0;
  while (!s.isOver) {
    final legal = e.legalActions(s);
    expect(legal, isNotEmpty);
    final canEnd = legal.contains(const GameAction.endPhase());
    final action = canEnd && rng.nextDouble() < 0.3 ? const GameAction.endPhase() : legal[rng.nextInt(legal.length)];
    s = e.apply(s, action).state;
    checkInvariants(e, s, deckSize);
    steps++;
    expect(steps, lessThan(2000), reason: 'game must terminate');
  }
  return s;
}

void main() {
  test('1,000 seeded random-legal games keep every invariant and replay identically', () {
    final e = engineFor(everything);
    final deckSize = everything.deck.fold(0, (sum, d) => sum + d.count);
    final outcomes = <Outcome, int>{};
    for (var seed = 0; seed < 1000; seed++) {
      final end = randomGame(e, seed, deckSize);
      outcomes[end.outcome!] = (outcomes[end.outcome!] ?? 0) + 1;

      // Save, reload and replay give the identical state.
      final save = SaveGame(missionId: end.missionId, contentHash: 'test', seed: seed, actions: end.log);
      final loaded = SaveGame.fromJson(jsonDecode(jsonEncode(save.toJson())) as Map<String, Object?>);
      expect(stateHash(e.replay(loaded.seed, loaded.actions)), stateHash(end), reason: 'seed $seed');
    }
    expect(outcomes.keys, containsAll([Outcome.won, Outcome.lost]), reason: 'random play reaches both outcomes');
  });

  test('determinism: same seed and actions give the same hash at every step', () {
    final e = engineFor(everything);
    final deckSize = everything.deck.fold(0, (sum, d) => sum + d.count);
    final end = randomGame(e, 12345, deckSize);
    var a = e.newGame(12345).state;
    var b = e.newGame(12345).state;
    for (final action in end.log) {
      a = e.apply(a, action).state;
      b = e.apply(b, action).state;
      expect(stateHash(a), stateHash(b));
    }
    expect(stateHash(a), stateHash(end));
  });
}
