import 'package:lk_rules/lk_rules.dart';

import '../strategy.dart';
import '../view.dart';

/// The historical approach (build-spec section 7): retreat, evacuate ahead
/// of the army, raid its Supply, and counterattack late.
///
/// The plan for each mission is read from the mission itself, so it follows
/// content changes: `kingAt` objectives give the king's havens and a
/// `counterattackAt` objective gives the node to strike at once the army is
/// below half Supply. Every decision about fighting uses the engine's own
/// battle forecast.
final class ExpertStrategy extends PlannedStrategy {
  @override
  String get name => 'expert';

  /// A held node is defended only when the forecast wins by this margin.
  static const double holdMargin = 1.1;

  /// A counterattack is launched only when the forecast wins by this margin.
  static const double attackMargin = 1.15;

  @override
  int choose(GameView v) {
    // Prefer the option that does not skip Orders and costs no Unity.
    final pc = v.s.pendingChoice!;
    final card = pc.source == ChoiceSource.card ? v.def.cards[pc.sourceId] : null;
    final choice = card?.effects.whereType<ChoiceEffect>().firstOrNull;
    if (choice == null) return 0;
    var best = 0;
    var bestScore = -1 << 30;
    for (var i = 0; i < choice.options.length; i++) {
      var score = 0;
      for (final e in choice.options[i].effects) {
        if (e is ModUnityEffect) score += e.delta * 10;
        if (e is SkipTurnEffect) score -= 15;
        if (e is ModResourceEffect) score += e.delta;
      }
      if (score > bestScore) {
        bestScore = score;
        best = i;
      }
    }
    return best;
  }

  // -- Mission goals -----------------------------------------------------------

  Iterable<ObjectiveDef> _flatten(Iterable<ObjectiveDef> list) sync* {
    for (final o in list) {
      if (o is AnyOfObjective) {
        yield* _flatten(o.anyOf);
      } else {
        yield o;
      }
    }
  }

  List<String> _havens(GameView v) => [
        for (final o in _flatten(v.mission.win))
          if (o is KingAtObjective) o.nodeId,
      ];

  String? _counterNode(GameView v) =>
      _flatten(v.mission.win).whereType<CounterattackAtObjective>().firstOrNull?.nodeId;

  // -- Council -----------------------------------------------------------------

  @override
  List<GameAction> planCouncil(GameView v) {
    final out = <GameAction>[];
    final counter = _counterNode(v);

    // 1. Restore the Court when it is low (Trần Thủ Độ's skill, by effect).
    if (v.s.unity.court < Balance.unityLowThreshold + 1) {
      for (final id in v.officerIds) {
        final skill = v.officerDef(id).skill;
        if (skill == null || skill.kind != SkillKind.activated || v.officer(id).skillUsesLeft <= 0) continue;
        if (skill.effects.any((e) => e is SetUnityEffect && e.pillar == Pillar.court)) {
          out.add(GameAction.useSkill(officerId: id));
        }
      }
    }

    // 2. Empty the land ahead of the army: evacuate where it will forage or
    //    stand, unless the army should be kept in place for a counterattack.
    final deny = <String>{};
    for (final a in v.armyIds) {
      final intent = v.army(a).intent;
      final forage = intent?.kind == IntentKind.forage ? intent?.targetNodeId : null;
      if (forage != null && forage != counter && v.held(forage) && v.hasRice(forage)) deny.add(forage);
      // The node it walks into, unless a defending group will throw it back.
      final p = v.projected(a);
      if (p != counter && v.held(p) && v.hasRice(p) && !_holds(v, p, const {})) deny.add(p);
    }
    var support = v.s.support;
    var court = v.s.unity.court;
    for (final node in deny.toList()..sort()) {
      final skillUser = v.officerIds.where((id) {
        final skill = v.officerDef(id).skill;
        return skill != null &&
            skill.kind == SkillKind.activated &&
            skill.target == TargetKind.ownNode &&
            v.officer(id).skillUsesLeft > 0 &&
            skill.effects.any((e) => e is EvacuateNodeEffect);
      }).firstOrNull;
      final card = _cardWith<EvacuateNodeEffect>(v);
      if (skillUser != null && court >= Balance.unityLowThreshold + 2) {
        out.add(GameAction.useSkill(officerId: skillUser, target: node));
        court--;
      } else if (card != null && support >= v.cardSupportCost(v.def.cards[card]!)) {
        out.add(GameAction.playCard(cardId: card, target: node));
        support -= v.cardSupportCost(v.def.cards[card]!);
      }
    }

    // 3. Ambush an army crossing a river edge, if the ambush wins even at
    //    the lowest roll.
    final ambushCard = _cardWith<PlaceAmbushEffect>(v);
    if (ambushCard != null) {
      for (final a in v.armyIds) {
        final from = v.army(a).nodeId;
        final to = v.army(a).intent?.moveTo;
        if (to == null) continue;
        final edge = v.graph.edge(from, to);
        if (edge == null || edge.kind != EdgeKind.river) continue;
        final manning = [...v.officersAt(from), ...v.officersAt(to)]
          ..sort((x, y) => v.officerDef(y).stats.war.compareTo(v.officerDef(x).stats.war));
        if (manning.isEmpty) continue;
        if (v.engine.forecastAmbush(v.s, manning.first, a).winner == Side.daiViet) {
          out.add(GameAction.playCard(cardId: ambushCard, target: edge.key));
          break;
        }
      }
    }

    // 4. Double the strongest attacker's Power before a counterattack.
    final attack = _attackPlan(v);
    final boost = _cardWith<PowerMultiplierEffect>(v);
    if (attack != null && boost != null) {
      final strongest = [...attack.attackers]..sort((x, y) => v.officer(y).troops.compareTo(v.officer(x).troops));
      out.add(GameAction.playCard(cardId: boost, target: strongest.first));
    }

    // 5. A king who must stay where he would lose is pulled out by card.
    final withdraw = _cardWith<WithdrawOfficerEffect>(v);
    final king = v.kingId;
    if (withdraw != null && king != null) {
      final orders = planOrders(v);
      final node = v.officer(king).nodeId;
      if (orders[king] == Order.hold && v.dangerNodes.contains(node) && !_holds(v, node, orders)) {
        out.add(GameAction.playCard(cardId: withdraw, target: king));
      }
    }
    return out;
  }

  String? _cardWith<T extends EffectDef>(GameView v) {
    for (final id in v.s.hand) {
      final card = v.def.cards[id]!;
      if (card.effects.any((e) => e is T) && v.canAfford(id)) return id;
    }
    return null;
  }

  // -- Orders ------------------------------------------------------------------

  @override
  Map<String, Order> planOrders(GameView v) {
    final orders = <String, Order>{};
    final counter = _counterNode(v);
    final danger = v.dangerNodes;

    // A counterattack, when one wins.
    final attack = _attackPlan(v);
    if (attack != null) {
      for (final id in attack.attackers) {
        orders[id] = v.officer(id).nodeId == attack.node ? Order.hold : Order.move(attack.node);
      }
    }

    // Keep the counterattack node empty while the army walks into it, so the
    // army settles there and the battle can be started by Đại Việt.
    if (counter != null && attack == null) {
      final arriving = v.armyIds.any((a) => v.projected(a) == counter && v.army(a).nodeId != counter);
      if (arriving) {
        for (final id in v.officersAt(counter)) {
          final to = _safeMove(v, id, towards: v.kingNode ?? counter, avoid: danger, keepNear: counter);
          if (to != null) orders[id] = Order.move(to);
        }
      }
    }

    // Groups standing where an army will be: hold if they win, else fall back.
    final groups = <String, List<String>>{};
    for (final id in v.officerIds) {
      if (orders.containsKey(id)) continue;
      final node = v.officer(id).nodeId;
      if (danger.contains(node)) groups.putIfAbsent(node, () => []).add(id);
    }
    final kingTarget = _kingDestination(v, danger);
    groups.forEach((node, ids) {
      if (_holds(v, node, {for (final id in ids) id: Order.hold}, officerIds: ids)) {
        for (final id in ids) {
          orders[id] = Order.hold;
        }
        return;
      }
      for (final id in ids) {
        final towards = v.officerDef(id).isKing ? kingTarget : (kingTarget ?? v.kingNode);
        final to = _safeMove(v, id, towards: towards, avoid: danger);
        orders[id] = to == null ? Order.hold : Order.move(to);
      }
    });

    // Everyone else: the king heads for his haven; raid, evacuate or rally.
    var support = v.s.support;
    final evacuating = <String>{};
    final raidDamage = <String, int>{};
    for (final id in v.officerIds) {
      if (orders.containsKey(id)) continue;
      final here = v.officer(id).nodeId;
      final isKing = v.officerDef(id).isKing;

      if (isKing && kingTarget != null && kingTarget != here) {
        final to = _safeMove(v, id, towards: kingTarget, avoid: danger);
        if (to != null && v.distance(to, kingTarget) < v.distance(here, kingTarget)) {
          orders[id] = Order.move(to);
          continue;
        }
      }

      if (!isKing) {
        final raidTarget = v.armyIds.where((a) {
          return v.graph.adjacent(here, v.army(a).nodeId) &&
              v.graph.adjacent(here, v.projected(a)) &&
              (raidDamage[a] ?? 0) < v.army(a).supply &&
              _raidPays(v, a);
        }).firstOrNull;
        if (raidTarget != null && v.officer(id).troops > 1) {
          orders[id] = Order.raid(raidTarget);
          raidDamage[raidTarget] = (raidDamage[raidTarget] ?? 0) + _raidSupply(v, id);
          continue;
        }
      }

      final cost = v.s.unity.people < Balance.unityLowThreshold
          ? Balance.evacuateSupportCostLowPeople
          : Balance.evacuateSupportCost;
      if (here != counter &&
          v.held(here) &&
          v.hasRice(here) &&
          !evacuating.contains(here) &&
          v.armyDistance(here) <= 2 &&
          support >= cost) {
        orders[id] = Order.evacuate;
        evacuating.add(here);
        support -= cost;
        continue;
      }

      if (v.officer(id).morale < 6 && v.held(here) && !v.s.nodes[here]!.evacuated) {
        orders[id] = Order.rally;
        continue;
      }
      orders[id] = Order.hold;
    }
    return orders;
  }

  /// Supply an order to raid by [officerId] takes.
  int _raidSupply(GameView v, String officerId) {
    final d = v.officerDef(officerId);
    final base = Balance.raidSupplyBase + d.stats.war ~/ Balance.raidWarDivisor;
    return d.hasPassive(PassiveIds.raider) ? base * Balance.raiderSupplyMultiplier : base;
  }

  /// Raiding only pays once the army cannot simply forage the Supply back:
  /// no rice left within one edge of where it will stand, or the season is
  /// nearly over.
  bool _raidPays(GameView v, String armyId) {
    if (v.s.turn >= v.mission.seasonTurns - 1) return true;
    final p = v.projected(armyId);
    final nearby = [p, ...v.graph.neighbors(p)];
    return !nearby.any(v.hasRice);
  }

  /// Whether the officers at [node] (default: all of them) beat the armies
  /// that will be there, by [holdMargin].
  bool _holds(GameView v, String node, Map<String, Order> orders, {List<String>? officerIds}) {
    final armies = [for (final a in v.armyIds) if (v.projected(a) == node) a];
    if (armies.isEmpty) return true;
    final ids = officerIds ?? v.officersAt(node);
    if (ids.isEmpty) return false;
    final f = v.engine.forecastBattle(v.s, node, officerIds: ids, armyIds: armies, orders: orders);
    return f.winner == Side.daiViet && f.daiVietPower >= f.yuanPower * holdMargin;
  }

  /// Where the king should go: his nearest safe haven from the objectives,
  /// else stay unless in danger.
  String? _kingDestination(GameView v, Set<String> danger) {
    final havens = _havens(v).where((h) => !danger.contains(h)).toList();
    final here = v.kingNode;
    if (here == null) return null;
    if (havens.isEmpty) return null;
    havens.sort((a, b) => v.distance(here, a).compareTo(v.distance(here, b)));
    return havens.first;
  }

  /// The best move for [officerId] out of danger: not into [avoid] or an
  /// army, closest to [towards], then furthest from the armies. With
  /// [keepNear], only nodes one move from that node.
  String? _safeMove(GameView v, String officerId, {String? towards, required Set<String> avoid, String? keepNear}) {
    final armyNow = {for (final a in v.armyIds) v.army(a).nodeId};
    final options = v.moveTargets(officerId).where((n) {
      if (avoid.contains(n) || armyNow.contains(n)) return false;
      if (keepNear != null && !v.graph.moveTargets(n, maxRiverEdges: Balance.maxRiverEdgesPerMove).contains(keepNear)) {
        return false;
      }
      return true;
    }).toList()
      ..sort();
    if (options.isEmpty) return null;
    int score(String n) {
      final toward = towards == null ? 0 : v.distance(n, towards);
      return toward * 100 - v.armyDistance(n);
    }

    options.sort((a, b) {
      final c = score(a).compareTo(score(b));
      return c != 0 ? c : a.compareTo(b);
    });
    return options.first;
  }

  /// A counterattack this turn: an army that stays put, below half Supply,
  /// that the reachable officers beat by [attackMargin]. With a
  /// `counterattackAt` objective only that node is attacked.
  ({String node, List<String> attackers})? _attackPlan(GameView v) {
    final counter = _counterNode(v);
    for (final a in v.armyIds) {
      final army = v.army(a);
      final node = army.nodeId;
      if (v.projected(a) != node) continue;
      if (army.supply >= Balance.counterattackSupplyFraction * army.maxSupply) continue;
      if (counter != null && node != counter) continue;
      final attackers = [
        for (final id in v.officerIds)
          if (v.moveTargets(id).contains(node) || v.officer(id).nodeId == node) id,
      ];
      if (attackers.isEmpty) continue;
      // Leave the king out of a generic attack when the others suffice.
      final withoutKing = attackers.where((id) => !v.officerDef(id).isKing).toList();
      for (final group in [if (counter == null && withoutKing.isNotEmpty) withoutKing, attackers]) {
        final moving = {for (final id in group) if (v.officer(id).nodeId != node) id};
        final f = v.engine.forecastBattle(v.s, node,
            officerIds: group, armyIds: v.armiesAt(node), moving: moving, orders: {for (final id in group) id: null});
        if (f.winner == Side.daiViet && f.daiVietPower >= f.yuanPower * attackMargin) {
          return (node: node, attackers: group);
        }
      }
    }
    return null;
  }
}
