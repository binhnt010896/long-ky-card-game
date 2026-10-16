import 'package:lk_rules/lk_rules.dart';

/// The invariant checks of build-spec section 7, run after every step.
/// Returns a description of each violation (empty when all hold).
List<String> checkInvariants(GameEngine e, GameState s, {required int deckSize}) {
  final out = <String>[];
  final m = e.def.mission;
  void check(bool ok, String what) {
    if (!ok) out.add('turn ${s.turn} ${s.phase.name}: $what');
  }

  for (final p in Pillar.values) {
    check(s.unity[p] >= 0 && s.unity[p] <= 10, 'Unity ${p.name} = ${s.unity[p]} outside 0–10');
  }
  check(s.rice >= 0, 'Rice ${s.rice} < 0');
  check(s.support >= 0, 'Support ${s.support} < 0');
  for (final MapEntry(key: id, value: o) in s.officers.entries) {
    check(o.troops >= 0, '$id troops ${o.troops} < 0');
    check(o.morale >= 0 && o.morale <= 10, '$id morale ${o.morale} outside 0–10');
    check(e.graph.hasNode(o.nodeId), '$id is not on a map node (${o.nodeId})');
  }
  for (final MapEntry(key: id, value: a) in s.armies.entries) {
    check(a.troops >= 0, '$id troops ${a.troops} < 0');
    check(a.supply >= 0 && a.supply <= a.maxSupply, '$id Supply ${a.supply} outside 0–${a.maxSupply}');
    check(a.morale >= 0 && a.morale <= 10, '$id morale ${a.morale} outside 0–10');
    check(e.graph.hasNode(a.nodeId), '$id is not on a map node (${a.nodeId})');
  }
  if (s.pendingChoice != null) {
    check(!s.isOver, 'a choice is pending after the mission ended');
    check(s.phase == Phase.council, 'a choice is pending outside Council');
  }
  check(s.turn >= 1 && s.turn <= m.seasonTurns, 'turn ${s.turn} beyond seasonTurns ${m.seasonTurns}');
  check(s.hand.length <= m.handSize, 'hand of ${s.hand.length} above handSize');
  check(s.hand.length + s.deck.length + s.discard.length == deckSize, 'cards lost or invented');
  check(s.isOver || s.phase == Phase.council || s.phase == Phase.orders, 'step stopped in ${s.phase.name}');
  return out;
}
