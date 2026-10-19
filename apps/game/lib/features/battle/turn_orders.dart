import 'package:lk_rules/lk_rules.dart';

/// Whether at least one of our officers goes forward or attacks when the turn
/// is resolved: a Raid or an Ambush, or a Move that ends nearer to the
/// closest Yuan army than it starts (a move away from the enemy, a retreat,
/// does not count; nor does a Hold, an Evacuate or a Rally). [beforeResolution]
/// is the state when the player ended the Orders phase, with the orders
/// still set. The king's shout and its callout are for a turn like this; a
/// quiet turn has neither.
bool turnAdvances(Ruleset ruleset, GameState beforeResolution) {
  final graph = MapGraph(ruleset.map);
  final enemies = [
    for (final a in beforeResolution.armies.values)
      if (a.status == ArmyStatus.active) a.nodeId,
  ];
  // Hops from [node] to the nearest Yuan army (unreachable counts as far).
  int toEnemy(String node) {
    var best = 1 << 20;
    for (final e in enemies) {
      final d = graph.distance(node, e);
      if (d != null && d < best) best = d;
    }
    return best;
  }

  for (final o in beforeResolution.officers.values) {
    final order = o.order;
    if (o.status != OfficerStatus.active || order == null) continue;
    switch (order.kind) {
      case OrderKind.raid || OrderKind.ambush:
        return true;
      case OrderKind.move:
        final target = order.target;
        if (target != null && graph.hasNode(target) && toEnemy(target) < toEnemy(o.nodeId)) return true;
      case OrderKind.hold || OrderKind.evacuate || OrderKind.rally:
        break;
    }
  }
  return false;
}
