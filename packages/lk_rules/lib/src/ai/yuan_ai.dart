import '../balance.dart';
import '../engine/combat.dart';
import '../engine/events.dart';
import '../engine/tx.dart';
import '../model/enums.dart';
import '../model/game_state.dart';

/// Picks this turn's intent for every active army, in army-id order, then
/// the predicted intents if `revealDepth` ≥ 2.
void assignIntents(Tx tx) {
  for (final id in tx.activeArmyIds()) {
    final intent = chooseIntent(tx, id);
    tx.updateArmy(id, (a) => a.copyWith(intent: intent, predictedIntent: null));
    tx.emit(IntentRevealed(id, intent));
  }
  assignPredictions(tx);
}

/// The Yuan AI (build-spec section 4). Deterministic: the first rule that
/// applies wins.
Intent chooseIntent(Tx tx, String armyId) {
  final a = tx.army(armyId);
  final turn = tx.s.turn;
  final here = a.nodeId;

  // 1. The mission script names an intent for this army this turn.
  for (final e in tx.mission.yuanScript) {
    if (e.turn != turn || e.armyId != armyId) continue;
    final target = switch (e.intent) {
      IntentKind.hold => null,
      IntentKind.advance || IntentKind.assault => e.targetNodeId ?? _objective(tx),
      IntentKind.retreat => e.targetNodeId ?? a.retreatNodeId,
      IntentKind.forage => e.targetNodeId ?? _nearestForage(tx, here),
    };
    return _toward(tx, e.intent, here, target);
  }

  // 2. Broken morale, or no Supply once the heat has started: retreat.
  final heat = tx.mission.heatStartTurn;
  if (a.morale <= Balance.aiRetreatMorale || (heat != null && turn >= heat && a.supply == 0)) {
    return _toward(tx, IntentKind.retreat, here, a.retreatNodeId);
  }

  // 3. Low Supply: forage at the nearest node that still has rice.
  if (a.supply < Balance.aiForageSupplyFraction * a.maxSupply) {
    final target = _nearestForage(tx, here);
    if (target != null) return _toward(tx, IntentKind.forage, here, target);
  }

  // 4. The king is next door and can be beaten there: assault.
  final kingNode = tx.kingNodeId;
  if (kingNode != null && tx.graph.adjacent(here, kingNode) && _wouldBeat(tx, armyId, kingNode)) {
    return Intent(kind: IntentKind.assault, moveTo: kingNode, targetNodeId: kingNode);
  }

  // 5. Advance one edge toward the objective.
  return _toward(tx, IntentKind.advance, here, _objective(tx));
}

/// The mission objective (the capital by default); once taken, the king.
String? _objective(Tx tx) {
  final objective = tx.mission.yuanObjectiveNodeId ?? tx.graph.capitalId;
  if (objective == null) return tx.kingNodeId;
  if (tx.node(objective).controller == Side.yuan) return tx.kingNodeId ?? objective;
  return objective;
}

/// Nearest non-evacuated node with rice (BFS, ties by id), possibly [from].
String? _nearestForage(Tx tx, String from) => tx.graph.nearest(from, (id) {
      final n = tx.node(id);
      return !n.evacuated && n.riceStock > 0;
    });

Intent _toward(Tx tx, IntentKind kind, String here, String? target) {
  if (target == null || target == here) return Intent(kind: kind, targetNodeId: target);
  return Intent(kind: kind, moveTo: tx.graph.nextHop(here, target), targetNodeId: target);
}

/// Whether [armyId] would beat the officers at [nodeId] if it attacked now
/// (defenders hold, since orders are not set yet).
bool _wouldBeat(Tx tx, String armyId, String nodeId) {
  final defenders = [
    for (final id in tx.activeOfficersAt(nodeId))
      if (!tx.officer(id).withdrawn) OfficerCombatant(officerId: id, defending: true, holding: true),
  ];
  if (defenders.isEmpty) return true;
  final f = forecastFieldBattle(tx, nodeId, defenders, [armyId], heldAtStart: tx.node(nodeId).controller);
  return f.winner == Side.yuan;
}

/// Next turn's intents, shown as "predicted" while `revealDepth` ≥ 2: the AI
/// is run one turn ahead on the current state with every army moved as its
/// current intent says. Nothing else (Supply, battles) is simulated.
void assignPredictions(Tx tx) {
  final ids = tx.activeArmyIds();
  if (tx.s.revealDepth < Balance.borderWatchRevealDepth) {
    for (final id in ids) {
      if (tx.army(id).predictedIntent != null) tx.updateArmy(id, (a) => a.copyWith(predictedIntent: null));
    }
    return;
  }
  final ahead = Tx(tx.def, tx.graph, tx.s.copyWith(turn: tx.s.turn + 1));
  for (final id in ids) {
    final to = ahead.army(id).intent?.moveTo;
    if (to != null) ahead.updateArmy(id, (a) => a.copyWith(nodeId: to));
  }
  for (final id in ids) {
    final predicted = chooseIntent(ahead, id);
    tx.updateArmy(id, (a) => a.copyWith(predictedIntent: predicted));
    tx.emit(IntentRevealed(id, predicted, predicted: true));
  }
}
