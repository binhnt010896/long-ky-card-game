import '../balance.dart';
import '../model/enums.dart';
import '../model/game_state.dart';
import 'events.dart';
import 'resolution.dart';
import 'tx.dart';

/// Troops at full value up to `leadership × 3`; troops above count half.
double effectiveTroops(int troops, int leadership) {
  final cap = leadership * Balance.troopsPerLeadership;
  if (troops <= cap) return troops.toDouble();
  return cap + (troops - cap) * Balance.overCapTroopValue;
}

double _moraleFactor(int morale) => Balance.moraleBase + morale / Balance.moraleDivisor;

/// How one officer fights in one battle.
final class OfficerCombatant {
  const OfficerCombatant({
    required this.officerId,
    required this.defending,
    required this.holding,
    this.ambusher = false,
  });

  final String officerId;

  /// Did not move this turn (city terrain bonus).
  final bool defending;

  /// Has a hold order, or no order (+20%).
  final bool holding;
  final bool ambusher;
}

/// Power of one officer: effective troops × (1 + War/10) × terrain ×
/// (0.5 + morale/20) × modifiers (build-spec section 4).
double officerPower(
  Tx tx,
  OfficerCombatant c,
  Terrain terrain, {
  required bool kingPresent,
  required List<String> opposingArmies,
  double roll = 1.0,
}) {
  final o = tx.officer(c.officerId);
  final d = tx.officerDef(c.officerId);
  final morale = (o.morale + (kingPresent ? Balance.kingPresenceMorale : 0)).clamp(0, Balance.moraleMax);
  var power = effectiveTroops(o.troops, d.stats.leadership) *
      (1 + d.stats.war / Balance.warDivisor) *
      Balance.daiVietTerrain(terrain, defending: c.defending) *
      _moraleFactor(morale);
  if (c.holding && c.defending) power *= Balance.holdPowerMultiplier;
  if (multiplierApplies(tx, c.officerId, opposingArmies)) power *= o.nextBattleMultiplier;
  if (c.ambusher) power *= Balance.ambusherPowerMultiplier * roll;
  return power;
}

/// Whether the officer's `nextBattleMultiplier` counts against [opposingArmies].
bool multiplierApplies(Tx tx, String officerId, List<String> opposingArmies) {
  final o = tx.officer(officerId);
  final below = o.multiplierEnemySupplyBelow;
  if (below == null) return true;
  return opposingArmies.every((id) {
    final a = tx.army(id);
    return a.supply < below * a.maxSupply;
  });
}

/// Power of one Yuan army: same formula, commander stats, Yuan terrain.
double armyPower(Tx tx, String armyId, Terrain terrain) {
  final a = tx.army(armyId);
  final c = tx.commanderDef(armyId);
  return effectiveTroops(a.troops, c.stats.leadership) *
      (1 + c.stats.war / Balance.warDivisor) *
      Balance.yuanTerrain(terrain) *
      _moraleFactor(a.morale);
}

bool _kingPresent(Tx tx, Iterable<String> officerIds) =>
    officerIds.any((id) => tx.officerDef(id).hasPassive(PassiveIds.kingPresence));

/// Higher Power wins; a tie goes to the higher leadership, then to the side
/// that held the node at turn start (the Yuan if nobody did).
Side battleWinner(
  Tx tx, {
  required double daiVietPower,
  required double yuanPower,
  required List<String> officerIds,
  required List<String> armyIds,
  required Side heldAtStart,
}) {
  if (daiVietPower > yuanPower) return Side.daiViet;
  if (yuanPower > daiVietPower) return Side.yuan;
  int maxLead(Iterable<int> xs) => xs.fold(0, (m, x) => x > m ? x : m);
  final dvLead = maxLead(officerIds.map((id) => tx.officerDef(id).stats.leadership));
  final yLead = maxLead(armyIds.map((id) => tx.commanderDef(id).stats.leadership));
  if (dvLead != yLead) return dvLead > yLead ? Side.daiViet : Side.yuan;
  return heldAtStart == Side.daiViet ? Side.daiViet : Side.yuan;
}

/// Forecast of a field battle at [nodeId] (no state change). Used by the
/// Yuan AI and by the battle preview.
({double daiViet, double yuan, Side winner}) forecastFieldBattle(
  Tx tx,
  String nodeId,
  List<OfficerCombatant> officers,
  List<String> armyIds, {
  required Side heldAtStart,
}) {
  final terrain = tx.graph.node(nodeId).terrain;
  final ids = [for (final c in officers) c.officerId];
  final king = _kingPresent(tx, ids);
  final dv = officers.fold(
      0.0, (sum, c) => sum + officerPower(tx, c, terrain, kingPresent: king, opposingArmies: armyIds));
  final y = armyIds.fold(0.0, (sum, id) => sum + armyPower(tx, id, terrain));
  final w = battleWinner(tx,
      daiVietPower: dv, yuanPower: y, officerIds: ids, armyIds: armyIds, heldAtStart: heldAtStart);
  return (daiViet: dv, yuan: y, winner: w);
}

/// Step 3: a battle at every node holding both an active officer and an
/// active army. Participants are fixed when the step starts; units that
/// withdraw or retreat into another node do not fight again this turn.
void resolveBattles(Tx tx, ResolutionContext ctx) {
  final battles = <String, (List<String>, List<String>)>{};
  for (final nodeId in tx.graph.nodeIds) {
    final officers = [
      for (final id in tx.activeOfficersAt(nodeId))
        if (!tx.officer(id).withdrawn) id,
    ];
    final armies = tx.activeArmiesAt(nodeId);
    if (officers.isNotEmpty && armies.isNotEmpty) battles[nodeId] = (officers, armies);
  }
  battles.forEach((nodeId, units) {
    final (officers, armies) = units;
    _fieldBattle(tx, ctx, nodeId, officers, armies);
  });
}

void _fieldBattle(Tx tx, ResolutionContext ctx, String nodeId, List<String> officerIds, List<String> armyIds) {
  final combatants = [
    for (final id in officerIds)
      OfficerCombatant(
        officerId: id,
        defending: !ctx.movedOfficers.contains(id),
        holding: tx.officer(id).order == null || tx.officer(id).order!.kind == OrderKind.hold,
      ),
  ];
  final f = forecastFieldBattle(tx, nodeId, combatants, armyIds,
      heldAtStart: ctx.startController[nodeId] ?? Side.none);
  final started = officerIds.any(ctx.movedOfficers.contains) && !armyIds.any(ctx.movedArmies.contains);
  final suppliesLow = armyIds.every((id) {
    final a = tx.army(id);
    return a.supply < Balance.counterattackSupplyFraction * a.maxSupply;
  });

  final report = _applyBattle(
    tx,
    kind: BattleKind.field,
    nodeId: nodeId,
    officerIds: officerIds,
    armyIds: armyIds,
    daiVietPower: f.daiViet,
    yuanPower: f.yuan,
    winner: f.winner,
    daiVietStarted: started,
  );
  ctx.foughtOfficers.addAll(officerIds);

  if (report.winner == Side.daiViet && started && suppliesLow) {
    final nodes = tx.s.missionStats.counterattackNodes;
    if (!nodes.contains(nodeId)) {
      tx.updateStats((m) => m.copyWith(counterattackNodes: [...nodes, nodeId]));
    }
  }

  if (report.winner == Side.daiViet) {
    for (final id in armyIds) {
      retreatArmy(tx, id);
    }
  } else {
    withdrawLosers(tx, officerIds);
  }
}

/// An ambush on [edge] as army [armyId] crosses it from [from]. Returns
/// whether the army is stopped (the ambusher won).
bool resolveAmbush(Tx tx, ResolutionContext ctx, Ambush ambush, String armyId, String from) {
  final officerId = ambush.officerId;
  final terrain = Balance.ambushTerrain;
  final roll = tx.withRng((rng) => rng.nextRange(Balance.ambushRollMin, Balance.ambushRollMax));
  final c = OfficerCombatant(officerId: officerId, defending: true, holding: false, ambusher: true);
  final dv = officerPower(tx, c, terrain,
      kingPresent: _kingPresent(tx, [officerId]), opposingArmies: [armyId], roll: roll);
  final y = armyPower(tx, armyId, terrain);
  final nodeId = tx.officer(officerId).nodeId;
  final winner = battleWinner(tx,
      daiVietPower: dv,
      yuanPower: y,
      officerIds: [officerId],
      armyIds: [armyId],
      heldAtStart: ctx.startController[nodeId] ?? Side.none);

  tx.updateStats((m) => m.copyWith(ambushesTriggered: m.ambushesTriggered + 1));
  _applyBattle(
    tx,
    kind: BattleKind.ambush,
    nodeId: nodeId,
    edge: ambush.edge,
    officerIds: [officerId],
    armyIds: [armyId],
    daiVietPower: dv,
    yuanPower: y,
    winner: winner,
    roll: roll,
    daiVietStarted: true,
  );
  ctx.foughtOfficers.add(officerId);

  if (winner == Side.daiViet) {
    tx.setArmyMorale(armyId, tx.army(armyId).morale - Balance.ambushExtraMoraleLoss);
    return true;
  }
  withdrawLosers(tx, [officerId]);
  return false;
}

/// Losses, morale, stats and the People bonus for one decided battle.
BattleReport _applyBattle(
  Tx tx, {
  required BattleKind kind,
  required String nodeId,
  required List<String> officerIds,
  required List<String> armyIds,
  required double daiVietPower,
  required double yuanPower,
  required Side winner,
  String? edge,
  double? roll,
  bool daiVietStarted = false,
}) {
  final dvWon = winner == Side.daiViet;
  final losses = battleLosses(
    tx,
    officerIds: officerIds,
    armyIds: armyIds,
    daiVietPower: daiVietPower,
    yuanPower: yuanPower,
    winner: winner,
  );
  final officerLosses = losses.officers;
  for (final id in officerIds) {
    final o = tx.officer(id);
    final loss = officerLosses[id]!;
    tx.updateOfficer(
      id,
      (o) => o.copyWith(troops: o.troops - loss, nextBattleMultiplier: 1.0, multiplierEnemySupplyBelow: null),
    );
    tx.setOfficerMorale(id, o.morale + (dvWon ? Balance.winnerMoraleGain : -Balance.loserMoraleLoss));
  }
  final armyLosses = losses.armies;
  for (final id in armyIds) {
    final a = tx.army(id);
    final loss = armyLosses[id]!;
    tx.updateArmy(id, (a) => a.copyWith(troops: a.troops - loss));
    tx.setArmyMorale(id, a.morale + (dvWon ? -Balance.loserMoraleLoss : Balance.winnerMoraleGain));
  }

  final dvLost = officerLosses.values.fold(0, (s, x) => s + x);
  tx.updateStats((m) => m.copyWith(
        troopsLost: m.troopsLost + dvLost,
        battlesWon: m.battlesWon + (dvWon ? 1 : 0),
        battlesLost: m.battlesLost + (dvWon ? 0 : 1),
      ));

  final report = BattleReport(
    kind: kind,
    nodeId: nodeId,
    edge: edge,
    officerIds: officerIds,
    armyIds: armyIds,
    daiVietPower: daiVietPower,
    yuanPower: yuanPower,
    winner: winner,
    officerLosses: officerLosses,
    armyLosses: armyLosses,
    roll: roll,
    daiVietStarted: daiVietStarted,
  );
  tx.emit(BattleResolved(report));
  if (dvWon) tx.modUnity(Pillar.people, Balance.battleWonPeopleGain);
  return report;
}

/// Troops each side loses in a decided battle (build-spec section 4): with
/// `r = loser Power / winner Power`, the loser loses `ceil(troops × (0.5 −
/// 0.3r))` and the winner `ceil(troops × 0.25r)`. Used by the engine and by
/// the battle preview, so the two cannot differ.
({Map<String, int> officers, Map<String, int> armies}) battleLosses(
  Tx tx, {
  required List<String> officerIds,
  required List<String> armyIds,
  required double daiVietPower,
  required double yuanPower,
  required Side winner,
}) {
  final dvWon = winner == Side.daiViet;
  final winnerPower = dvWon ? daiVietPower : yuanPower;
  final loserPower = dvWon ? yuanPower : daiVietPower;
  final r = winnerPower <= 0 ? 1.0 : loserPower / winnerPower;
  final loserFraction = Balance.loserLossBase - Balance.loserLossRatio * r;
  final winnerFraction = Balance.winnerLossRatio * r;
  return (
    officers: {for (final id in officerIds) id: _loss(tx.officer(id).troops, dvWon ? winnerFraction : loserFraction)},
    armies: {for (final id in armyIds) id: _loss(tx.army(id).troops, dvWon ? loserFraction : winnerFraction)},
  );
}

int _loss(int troops, double fraction) {
  final loss = ceilSafe(troops * fraction);
  if (loss < 0) return 0;
  return loss > troops ? troops : loss;
}

/// Where [officerId] withdraws to: a neighbouring node with no active army,
/// closest to the king's node (for the king himself, or an officer already
/// with the king, toward the capital), ties by id. Null if none is free.
String? withdrawalNode(Tx tx, String officerId) {
  final from = tx.officer(officerId).nodeId;
  final free = [
    for (final n in tx.graph.neighbors(from))
      if (tx.activeArmiesAt(n).isEmpty) n,
  ];
  if (free.isEmpty) return null;

  final isKing = tx.officerDef(officerId).isKing;
  final kingNode = tx.kingNodeId;
  final capital = tx.graph.capitalId;
  String? target;
  if (!isKing && kingNode != null && kingNode != from) {
    target = kingNode;
  } else if (capital != null && capital != from) {
    target = capital;
  }
  if (target == null) return free.first;

  String? best;
  int? bestD;
  for (final n in free) {
    final d = tx.graph.distance(n, target);
    if (d == null) continue;
    if (bestD == null || d < bestD) {
      best = n;
      bestD = d;
    }
  }
  return best ?? free.first;
}

/// Losing officers withdraw one edge; with no free node they are captured.
/// The king goes first: if he cannot withdraw and a `shieldKing` officer is
/// with him, that officer is captured instead and the king stays.
void withdrawLosers(Tx tx, List<String> officerIds) {
  final ordered = [
    ...officerIds.where((id) => tx.officerDef(id).isKing),
    ...officerIds.where((id) => !tx.officerDef(id).isKing),
  ];
  for (final id in ordered) {
    if (!tx.isActiveOfficer(id)) continue;
    final from = tx.officer(id).nodeId;
    final to = withdrawalNode(tx, id);
    if (to != null) {
      tx.updateOfficer(id, (o) => o.copyWith(nodeId: to));
      tx.emit(OfficerMoved(id, from, to, MoveReason.battleWithdraw));
      continue;
    }
    if (tx.officerDef(id).isKing) {
      final shieldId = ordered
          .where((s) => s != id && tx.isActiveOfficer(s) && tx.officerDef(s).hasPassive(PassiveIds.shieldKing))
          .firstOrNull;
      if (shieldId != null) {
        captureOfficer(tx, shieldId);
        tx.emit(KingShielded(id, shieldId));
        continue;
      }
    }
    captureOfficer(tx, id);
  }
}

void captureOfficer(Tx tx, String officerId) {
  final o = tx.officer(officerId);
  tx.updateOfficer(officerId, (o) => o.copyWith(status: OfficerStatus.captured, troops: 0, order: null));
  tx.updateStats((m) => m.copyWith(captures: m.captures + 1, troopsLost: m.troopsLost + o.troops));
  tx.emit(OfficerCaptured(officerId, o.nodeId));
}

/// A losing army retreats one edge toward its `retreatNodeId`.
void retreatArmy(Tx tx, String armyId) {
  final a = tx.army(armyId);
  final to = tx.graph.nextHop(a.nodeId, a.retreatNodeId);
  if (to == null) return;
  tx.updateArmy(armyId, (a) => a.copyWith(nodeId: to));
  tx.emit(ArmyMoved(armyId, a.nodeId, to, MoveReason.retreat));
}
