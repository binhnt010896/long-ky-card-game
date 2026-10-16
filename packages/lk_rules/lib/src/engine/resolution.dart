import '../balance.dart';
import '../model/defs.dart';
import '../model/enums.dart';
import '../model/game_state.dart';
import 'combat.dart';
import 'evacuation.dart';
import 'events.dart';
import 'orders.dart';
import 'tx.dart';
import 'unity.dart';

/// What happened earlier in this Resolution, for later steps.
final class ResolutionContext {
  ResolutionContext(this.startController);

  /// Node controllers when Resolution began (combat tie-breaks).
  final Map<String, Side> startController;

  /// Officers that moved by order this turn (not defending).
  final Set<String> movedOfficers = {};

  /// Armies that moved this turn.
  final Set<String> movedArmies = {};

  /// Units that fought a battle this turn.
  final Set<String> foughtOfficers = {};
}

/// Resolution, in the order of build-spec section 4.
void runResolution(Tx tx) {
  final ctx = ResolutionContext({for (final e in tx.s.nodes.entries) e.key: e.value.controller});
  resolveDaiVietOrders(tx, ctx);
  resolveYuanMoves(tx, ctx);
  resolveBattles(tx, ctx);
  resolveRaids(tx, ctx);
  resolveForage(tx);
  updateNodeControl(tx);
}

/// Step 1: Đại Việt moves resolve together; then evacuations, rallies and
/// ambush orders (which must be in place before the Yuan move).
void resolveDaiVietOrders(Tx tx, ResolutionContext ctx) {
  final ids = tx.activeOfficerIds();
  final moves = <String, String>{
    for (final id in ids)
      if (tx.officer(id).order case Order(kind: OrderKind.move, :final target?)) id: target,
  };
  moves.forEach((id, to) {
    final from = tx.officer(id).nodeId;
    tx.updateOfficer(id, (o) => o.copyWith(nodeId: to));
    ctx.movedOfficers.add(id);
    tx.emit(OfficerMoved(id, from, to, MoveReason.order));
  });

  for (final id in ids) {
    if (tx.officer(id).order?.kind != OrderKind.evacuate) continue;
    final nodeId = tx.officer(id).nodeId;
    final cost = evacuateOrderCost(tx);
    if (tx.s.support < cost || tx.node(nodeId).evacuated) continue;
    tx.modResource(Resource.support, -cost);
    evacuateNode(tx, nodeId);
  }

  for (final id in ids) {
    if (tx.officer(id).order?.kind == OrderKind.rally) _rally(tx, id);
  }

  for (final id in ids) {
    if (tx.officer(id).order case Order(kind: OrderKind.ambush, :final target?)) {
      tx.s = tx.s.copyWith(ambushes: [...tx.s.ambushes, Ambush(edge: target, officerId: id)]);
      tx.emit(AmbushPlaced(target, id));
    }
  }
}

void _rally(Tx tx, String officerId) {
  final nodeId = tx.officer(officerId).nodeId;
  for (final id in tx.activeOfficersAt(nodeId)) {
    tx.setOfficerMorale(id, tx.officer(id).morale + Balance.rallyMorale);
  }
  final node = tx.node(nodeId);
  var gained = 0;
  if (node.controller == Side.daiViet && !node.evacuated && tx.s.unity.people >= Balance.unityLowThreshold) {
    final o = tx.officer(officerId);
    final cap = tx.officerDef(officerId).troopCap;
    final troops = o.troops + Balance.rallyTroops;
    final capped = cap != null && troops > cap ? cap : troops;
    gained = capped - o.troops;
    tx.updateOfficer(officerId, (o) => o.copyWith(troops: capped));
  }
  tx.emit(Rallied(officerId, nodeId, gained));
}

/// Step 2: Yuan moves, in army-id order. Crossing an ambushed edge triggers
/// the ambush first; if the ambusher wins, the army stays where it was.
void resolveYuanMoves(Tx tx, ResolutionContext ctx) {
  for (final id in tx.activeArmyIds()) {
    final to = tx.army(id).intent?.moveTo;
    if (to == null) continue;
    final from = tx.army(id).nodeId;
    final key = edgeKey(from, to);
    final ambush = tx.s.ambushes.where((a) {
      if (a.edge != key || !tx.isActiveOfficer(a.officerId)) return false;
      final o = tx.officer(a.officerId);
      return !o.withdrawn && (o.nodeId == from || o.nodeId == to);
    }).firstOrNull;
    if (ambush != null) {
      tx.s = tx.s.copyWith(ambushes: [...tx.s.ambushes]..remove(ambush));
      if (resolveAmbush(tx, ctx, ambush, id, from)) continue;
    }
    tx.updateArmy(id, (a) => a.copyWith(nodeId: to));
    ctx.movedArmies.add(id);
    tx.emit(ArmyMoved(id, from, to, MoveReason.intent));
  }
}

/// Step 4: raids. No battle; the army loses Supply and the raider troops.
void resolveRaids(Tx tx, ResolutionContext ctx) {
  for (final id in tx.activeOfficerIds()) {
    final order = tx.officer(id).order;
    if (order?.kind != OrderKind.raid || ctx.foughtOfficers.contains(id)) continue;
    final armyId = order!.target!;
    if (!tx.isActiveArmy(armyId) || !tx.graph.adjacent(tx.officer(id).nodeId, tx.army(armyId).nodeId)) continue;
    final def = tx.officerDef(id);
    var supplyLoss = Balance.raidSupplyBase + def.stats.war ~/ Balance.raidWarDivisor;
    if (def.hasPassive(PassiveIds.raider)) supplyLoss *= Balance.raiderSupplyMultiplier;
    final a = tx.army(armyId);
    final supplyLost = supplyLoss > a.supply ? a.supply : supplyLoss;
    tx.updateArmy(armyId, (a) => a.copyWith(supply: a.supply - supplyLost));
    final o = tx.officer(id);
    final wanted = a.troops ~/ Balance.raidTroopLossDivisor;
    final troopsLost = wanted > o.troops ? o.troops : wanted;
    tx.updateOfficer(id, (o) => o.copyWith(troops: o.troops - troopsLost));
    tx.updateStats((m) => m.copyWith(raids: m.raids + 1, troopsLost: m.troopsLost + troopsLost));
    tx.emit(Raided(id, armyId, supplyLost, troopsLost));
  }
}

/// Step 5: an army whose intent was `forage`, on a non-evacuated node with
/// rice, gains min(2 × riceStock, maxSupply − supply); the stock becomes 0.
void resolveForage(Tx tx) {
  for (final id in tx.activeArmyIds()) {
    final a = tx.army(id);
    if (a.intent?.kind != IntentKind.forage) continue;
    final n = tx.node(a.nodeId);
    if (n.evacuated || n.riceStock <= 0) continue;
    final room = a.maxSupply - a.supply;
    final wanted = Balance.forageSupplyPerRice * n.riceStock;
    final gained = wanted < room ? wanted : room;
    tx.updateArmy(id, (a) => a.copyWith(supply: a.supply + gained));
    tx.updateNode(a.nodeId, (n) => n.copyWith(riceStock: 0));
    tx.emit(Foraged(id, a.nodeId, gained));
  }
}

/// Step 6: a node with only one side present goes to that side.
void updateNodeControl(Tx tx) {
  for (final id in tx.graph.nodeIds) {
    final dv = tx.activeOfficersAt(id).isNotEmpty;
    final yuan = tx.activeArmiesAt(id).isNotEmpty;
    final to = dv && !yuan
        ? Side.daiViet
        : yuan && !dv
            ? Side.yuan
            : null;
    final from = tx.node(id).controller;
    if (to == null || to == from) continue;
    tx.updateNode(id, (n) => n.copyWith(controller: to));
    tx.emit(NodeControlChanged(id, from, to));
    onNodeControlChanged(tx, id, to);
  }
}
