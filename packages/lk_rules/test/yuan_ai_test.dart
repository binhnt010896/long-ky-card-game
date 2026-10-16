import 'package:lk_rules/lk_rules.dart';
import 'package:lk_rules/src/ai/yuan_ai.dart';
import 'package:lk_rules/src/engine/tx.dart';
import 'package:test/test.dart';

import 'support/fixture.dart';

/// The intent the AI picks for 'y1' at the start of [m], after [edit].
Intent intentFor(MissionDef m, [GameState Function(GameState s)? edit]) {
  final e = engineFor(m);
  final s = e.newGame(1).state;
  final tx = Tx(e.def, e.graph, edit == null ? s : edit(s));
  return chooseIntent(tx, 'y1');
}

GameState evacuate(GameState s, String node) =>
    s.copyWith(nodes: {...s.nodes, node: s.nodes[node]!.copyWith(evacuated: true, riceStock: 0)});

void main() {
  group('rule 1: the mission script', () {
    test('a scripted intent overrides every other rule', () {
      final m = mission(
        armies: [army('pl', morale: 1, supply: 0)],
        yuanScript: holdAll(),
      );
      expect(intentFor(m), const Intent(kind: IntentKind.hold));
    });

    test('a scripted target is approached one edge at a time', () {
      final m = mission(
        armies: [army('hl')],
        yuanScript: const [YuanScriptEntry(turn: 1, armyId: 'y1', intent: IntentKind.assault, targetNodeId: 'cap')],
      );
      expect(intentFor(m), const Intent(kind: IntentKind.assault, moveTo: 'pl', targetNodeId: 'cap'));
    });
  });

  group('rule 2: retreat', () {
    test('morale ≤ 2 retreats toward retreatNodeId', () {
      expect(intentFor(mission(armies: [army('cap', morale: 2)])),
          const Intent(kind: IntentKind.retreat, moveTo: 'pl', targetNodeId: 'hl'));
      expect(intentFor(mission(armies: [army('hl', morale: 2)])),
          const Intent(kind: IntentKind.retreat, targetNodeId: 'hl'));
    });

    test('Supply 0 retreats only from heatStartTurn on', () {
      expect(intentFor(mission(armies: [army('cap', supply: 0)], heatStartTurn: 1)).kind, IntentKind.retreat);
      expect(intentFor(mission(armies: [army('cap', supply: 0)], heatStartTurn: 2)).kind, IntentKind.forage);
      expect(intentFor(mission(armies: [army('cap', supply: 0)])).kind, IntentKind.forage);
    });
  });

  group('rule 3: forage', () {
    test('below 40% Supply: toward the nearest node with rice', () {
      expect(intentFor(mission(armies: [army('hl', supply: 7)])),
          const Intent(kind: IntentKind.forage, moveTo: 'pl', targetNodeId: 'pl'));
      expect(intentFor(mission(armies: [army('hl', supply: 8)])).kind, IntentKind.advance, reason: '8 is 40%');
    });

    test('standing on a node with rice: stay', () {
      expect(intentFor(mission(armies: [army('pl', supply: 7)])), const Intent(kind: IntentKind.forage, targetNodeId: 'pl'));
    });

    test('evacuated nodes are skipped; ties go by node id', () {
      // From hl, with pl evacuated: cap (9) and ms (3) are both 2 edges away.
      expect(intentFor(mission(armies: [army('hl', supply: 7)]), (s) => evacuate(s, 'pl')),
          const Intent(kind: IntentKind.forage, moveTo: 'pl', targetNodeId: 'cap'));
    });

    test('with no rice anywhere, fall through to advance', () {
      GameState empty(GameState s) {
        var out = s;
        for (final id in s.nodes.keys) {
          out = evacuate(out, id);
        }
        return out;
      }

      expect(intentFor(mission(armies: [army('hl', supply: 7)]), empty).kind, IntentKind.advance);
    });
  });

  group('rule 4: assault the king', () {
    test('when the king is adjacent and would be beaten', () {
      expect(intentFor(mission(officers: [at('king', 'pl', 3)], armies: [army('hl')])),
          const Intent(kind: IntentKind.assault, moveTo: 'pl', targetNodeId: 'pl'));
    });

    test('not when the defenders would win; not when the king is further away', () {
      final strong = mission(
        officers: [at('king', 'pl', 12), at('raider', 'pl', 20)],
        armies: [army('hl')],
      );
      expect(intentFor(strong), const Intent(kind: IntentKind.advance, moveTo: 'pl', targetNodeId: 'cap'));
      expect(intentFor(mission(officers: [at('king', 'cap', 1)], armies: [army('hl')])).kind, IntentKind.advance);
    });
  });

  group('rule 5: advance', () {
    test('one edge along the shortest path to the capital', () {
      expect(intentFor(mission(armies: [army('hl')])),
          const Intent(kind: IntentKind.advance, moveTo: 'pl', targetNodeId: 'cap'));
    });

    test('once the capital is taken, toward the king', () {
      expect(intentFor(mission(officers: [at('king', 'rv2', 12)], armies: [army('cap')])),
          const Intent(kind: IntentKind.advance, moveTo: 'rv1', targetNodeId: 'rv2'));
    });

    test('yuanObjectiveNodeId replaces the capital', () {
      expect(intentFor(mission(armies: [army('hl')], yuanObjectiveNodeId: 'ms')),
          const Intent(kind: IntentKind.advance, moveTo: 'pl', targetNodeId: 'ms'));
    });
  });

  group('determinism', () {
    test('the same state always gives the same intents', () {
      final m = mission(
        officers: [at('king', 'cap', 12), at('plain', 'ms', 6)],
        armies: [army('hl'), army('rv2', id: 'y2', supply: 3), army('pl', id: 'y3', morale: 2)],
      );
      final e = engineFor(m);
      final a = e.newGame(1).state;
      final b = e.newGame(1).state;
      expect(stateHash(a), stateHash(b));
      final intents = {for (final id in ['y1', 'y2', 'y3']) id: a.armies[id]!.intent};
      expect(intents, {
        'y1': const Intent(kind: IntentKind.advance, moveTo: 'pl', targetNodeId: 'cap'),
        'y2': const Intent(kind: IntentKind.forage, targetNodeId: 'rv2'),
        'y3': const Intent(kind: IntentKind.retreat, moveTo: 'hl', targetNodeId: 'hl'),
      });
      final tx = Tx(e.def, e.graph, a);
      for (final id in ['y1', 'y2', 'y3']) {
        expect(chooseIntent(tx, id), intents[id]);
      }
    });
  });

  group('borderWatch prediction', () {
    test('on a border node, next turn\'s intents are predicted', () {
      final m = mission(officers: [at('warden', 'hl', 6)], armies: [army('rv2')]);
      final r = engineFor(m).newGame(1);
      final a = r.state.armies['y1']!;
      expect(r.state.revealDepth, 2);
      expect(a.intent, const Intent(kind: IntentKind.advance, moveTo: 'rv1', targetNodeId: 'cap'));
      expect(a.predictedIntent, const Intent(kind: IntentKind.advance, moveTo: 'cap', targetNodeId: 'cap'));
      final revealed = r.events.whereType<IntentRevealed>().toList();
      expect(revealed.map((x) => x.predicted), [false, true]);
    });

    test('no prediction without borderWatch; revealIntent turns it on for the turn', () {
      final m = mission(officers: [at('warden', 'pl', 6)], armies: [army('rv2')]);
      final e = engineFor(m);
      final s = e.newGame(1).state.copyWith(hand: const ['scout']);
      expect(s.armies['y1']!.predictedIntent, isNull);
      final scouted = e.apply(s, const GameAction.playCard(cardId: 'scout')).state;
      expect(scouted.armies['y1']!.predictedIntent, const Intent(kind: IntentKind.advance, moveTo: 'cap', targetNodeId: 'cap'));
      expect(endTurn(e, scouted).state.armies['y1']!.predictedIntent, isNull);
    });
  });

  group('intents drive the Yuan moves', () {
    test('an advancing army walks to the capital and takes it', () {
      final e = engineFor(mission(armies: [army('hl')]));
      var s = e.newGame(1).state;
      final path = <String>[];
      for (var i = 0; i < 2; i++) {
        s = endTurn(e, s).state;
        path.add(s.armies['y1']!.nodeId);
      }
      expect(path, ['pl', 'cap']);
      expect(s.nodes['cap']!.controller, Side.yuan);
    });
  });
}
