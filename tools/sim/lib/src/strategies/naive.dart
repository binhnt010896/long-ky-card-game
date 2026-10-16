import 'package:lk_rules/lk_rules.dart';

import '../strategy.dart';
import '../view.dart';

/// Fights head-on: every officer marches to meet the nearest army where it
/// will stand after its move, and attacks. Never evacuates, raids, ambushes
/// or withdraws; plays Phản công-style multipliers when it can.
final class NaiveStrategy extends PlannedStrategy {
  @override
  String get name => 'naive';

  @override
  List<GameAction> planCouncil(GameView v) {
    final out = <GameAction>[];
    for (final cardId in v.s.hand.toSet()) {
      final card = v.def.cards[cardId]!;
      final boosts = card.effects.any((e) => e is PowerMultiplierEffect);
      if (!boosts || card.target != TargetKind.ownOfficer) continue;
      final strongest = [...v.officerIds]..sort((a, b) => v.officer(b).troops.compareTo(v.officer(a).troops));
      if (strongest.isNotEmpty) out.add(GameAction.playCard(cardId: cardId, target: strongest.first));
    }
    return out;
  }

  @override
  Map<String, Order> planOrders(GameView v) {
    final orders = <String, Order>{};
    for (final id in v.officerIds) {
      final here = v.officer(id).nodeId;
      String? target;
      var best = 99;
      for (final a in v.armyIds) {
        final p = v.projected(a);
        final d = v.distance(here, p);
        if (d < best) {
          best = d;
          target = p;
        }
      }
      if (target == null || target == here) {
        orders[id] = Order.hold;
        continue;
      }
      final moves = v.moveTargets(id).toList()..sort();
      String? step;
      var stepD = v.distance(here, target);
      for (final m in moves) {
        final d = v.distance(m, target);
        if (d < stepD) {
          stepD = d;
          step = m;
        }
      }
      orders[id] = step == null ? Order.hold : Order.move(step);
    }
    return orders;
  }
}
