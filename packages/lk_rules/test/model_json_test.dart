import 'dart:convert';

import 'package:lk_rules/lk_rules.dart';
import 'package:test/test.dart';

GameState sampleState() => const GameState(
      missionId: 'm',
      seed: 17,
      rng: -1234567890123,
      turn: 3,
      phase: Phase.orders,
      outcome: null,
      rice: 4,
      support: 2,
      unity: Unity(court: 6, clan: 5, people: 7),
      nodes: {
        'a': NodeState(controller: Side.daiViet, riceStock: 6),
        'b': NodeState(controller: Side.yuan, evacuated: true, riceStock: 0),
      },
      officers: {
        'o1': OfficerState(
          nodeId: 'a',
          troops: 12,
          morale: 7,
          loyalty: 10,
          order: Order(kind: OrderKind.move, target: 'b'),
          skillUsesLeft: 1,
          nextBattleMultiplier: 2.0,
          multiplierEnemySupplyBelow: 0.5,
        ),
        'o2': OfficerState(nodeId: 'a', troops: 0, morale: 3, loyalty: 5, status: OfficerStatus.defected),
      },
      armies: {
        'y1': ArmyState(
          commanderId: 'c',
          nodeId: 'b',
          troops: 30,
          supply: 14,
          maxSupply: 20,
          morale: 8,
          retreatNodeId: 'b',
          intent: Intent(kind: IntentKind.advance, moveTo: 'a', targetNodeId: 'a'),
          predictedIntent: Intent(kind: IntentKind.forage),
        ),
      },
      ambushes: [Ambush(edge: 'a~b', officerId: 'o1')],
      deck: ['x', 'y'],
      hand: ['z'],
      discard: ['w'],
      pendingChoice: PendingChoice(
        source: ChoiceSource.card,
        sourceId: 'z',
        path: [0],
        optionCount: 2,
        bindings: {r'$node': 'a'},
      ),
      scriptedQueue: ['e'],
      revealDepth: 2,
      flags: [GameFlags.capitalLost],
      evacuationsThisTurn: 1,
      missionStats: MissionStats(
        troopsLost: 3,
        cardsPlayed: {'x': 2},
        counterattackNodes: ['a'],
        wonOnTurn: 2,
      ),
      stars: [true, false, true],
      log: [
        GameAction.playCard(cardId: 'x', target: 'a'),
        GameAction.endPhase(),
      ],
    );

T roundTrip<T>(T value, Map<String, Object?> Function(T) toJson, T Function(Map<String, Object?>) fromJson) {
  final text = jsonEncode(toJson(value));
  return fromJson(jsonDecode(text) as Map<String, Object?>);
}

void main() {
  group('JSON', () {
    test('GameState round-trips through JSON text', () {
      final s = sampleState();
      final back = roundTrip(s, (v) => v.toJson(), GameState.fromJson);
      expect(back, s);
      expect(stateHash(back), stateHash(s));
    });

    test('every GameAction round-trips with a type key', () {
      const actions = <GameAction>[
        GameAction.playCard(cardId: 'c', target: 'n'),
        GameAction.playCard(cardId: 'c'),
        GameAction.useSkill(officerId: 'o', target: 'n'),
        GameAction.resolveChoice(index: 1),
        GameAction.setOrder(officerId: 'o', order: Order(kind: OrderKind.ambush, target: 'a~b')),
        GameAction.clearOrder(officerId: 'o'),
        GameAction.endPhase(),
      ];
      for (final a in actions) {
        final json = a.toJson();
        expect(json['type'], isA<String>());
        expect(roundTrip(a, (v) => v.toJson(), GameAction.fromJson), a);
      }
    });

    test('SaveGame round-trips and defaults saveVersion to 1', () {
      const save = SaveGame(
        missionId: 'ch1_m2',
        contentHash: 'abc',
        seed: 9,
        actions: [GameAction.endPhase(), GameAction.resolveChoice(index: 0)],
      );
      expect(save.saveVersion, 1);
      expect(roundTrip(save, (v) => v.toJson(), SaveGame.fromJson), save);
      expect(save.toJson().keys, containsAll(['saveVersion', 'missionId', 'contentHash', 'seed', 'actions']));
    });

    test('unknown keys are rejected', () {
      final json = const NodeState(controller: Side.none, riceStock: 1).toJson()..['extra'] = 1;
      expect(() => NodeState.fromJson(json), throwsA(anything));
    });

    test('Unity indexes by pillar', () {
      const u = Unity(court: 1, clan: 2, people: 3);
      expect(u[Pillar.court], 1);
      expect(u[Pillar.clan], 2);
      expect(u[Pillar.people], 3);
      expect(u.withPillar(Pillar.clan, 9), const Unity(court: 1, clan: 9, people: 3));
    });
  });

  group('state hash', () {
    test('FNV-1a 64 matches the reference vectors', () {
      expect(fnv1a64Hex(''), 'cbf29ce484222325');
      expect(fnv1a64Hex('a'), 'af63dc4c8601ec8c');
      expect(fnv1a64Hex('foobar'), '85944171f73967e8');
    });

    test('canonical JSON sorts keys at every level', () {
      expect(canonicalJson({'b': 1, 'a': {'d': 2, 'c': 3}}), '{"a":{"c":3,"d":2},"b":1}');
    });

    test('equal states hash equal; any change changes the hash', () {
      final s = sampleState();
      expect(stateHash(s), stateHash(sampleState()));
      expect(stateHash(s.copyWith(rice: 5)), isNot(stateHash(s)));
      expect(stateHash(s.copyWith(unity: s.unity.copyWith(people: 6))), isNot(stateHash(s)));
      expect(stateHash(s), matches(RegExp(r'^[0-9a-f]{16}$')));
    });
  });

  group('balance tables', () {
    test('terrain multipliers match build-spec section 4', () {
      expect(Balance.daiVietTerrain(Terrain.city, defending: true), 1.2);
      expect(Balance.daiVietTerrain(Terrain.city, defending: false), 1.0);
      expect(Balance.daiVietTerrain(Terrain.plain, defending: true), 1.0);
      expect(Balance.daiVietTerrain(Terrain.river, defending: false), 1.2);
      expect(Balance.daiVietTerrain(Terrain.marsh, defending: false), 1.2);
      expect(Balance.daiVietTerrain(Terrain.hill, defending: false), 1.1);
      expect(Balance.yuanTerrain(Terrain.city), 1.0);
      expect(Balance.yuanTerrain(Terrain.plain), 1.2);
      expect(Balance.yuanTerrain(Terrain.river), 0.9);
      expect(Balance.yuanTerrain(Terrain.marsh), 0.8);
      expect(Balance.yuanTerrain(Terrain.hill), 1.0);
    });
  });
}
