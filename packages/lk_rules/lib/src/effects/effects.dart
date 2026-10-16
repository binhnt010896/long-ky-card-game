import '../ai/yuan_ai.dart';
import '../balance.dart';
import '../engine/combat.dart';
import '../engine/evacuation.dart';
import '../engine/events.dart';
import '../engine/tx.dart';
import '../model/defs.dart';
import '../model/enums.dart';
import '../model/game_state.dart';

/// Where a list of effects comes from, and what its `$` variables mean.
final class EffectScope {
  const EffectScope({
    required this.source,
    required this.sourceId,
    this.bindings = const {},
    this.path = const [],
  });

  final ChoiceSource source;

  /// The card id, or for a skill the officer id.
  final String sourceId;
  final Map<String, String> bindings;

  /// Location of this effect list inside the source (see [PendingChoice.path]).
  final List<int> path;

  String bind(String ref) {
    final v = bindings[ref];
    if (v == null) throw IllegalAction(IllegalCodes.badTarget, 'no value for $ref');
    return v;
  }
}

/// Applies [effects] in order. A `choice` sets the pending choice and stops
/// (the validator requires it to be the last effect in its list).
void runEffects(Tx tx, List<EffectDef> effects, EffectScope scope) {
  for (var i = 0; i < effects.length; i++) {
    final effect = effects[i];
    if (effect is ChoiceEffect) {
      tx.s = tx.s.copyWith(
        pendingChoice: PendingChoice(
          source: scope.source,
          sourceId: scope.sourceId,
          path: [...scope.path, i],
          optionCount: effect.options.length,
          bindings: scope.bindings,
        ),
      );
      tx.emit(ChoiceRequested(scope.sourceId, effect.options.length));
      return;
    }
    applyEffect(tx, effect, scope);
  }
}

void applyEffect(Tx tx, EffectDef effect, EffectScope scope) {
  switch (effect) {
    case ModUnityEffect(:final pillar, :final delta):
      tx.modUnity(pillar, delta);
    case SetUnityEffect(:final pillar, :final value):
      tx.setUnity(pillar, value);
    case ModResourceEffect(:final resource, :final delta):
      tx.modResource(resource, delta);
    case EvacuateNodeEffect(:final target):
      evacuateNode(tx, scope.bind(target));
    case WithdrawOfficerEffect(:final target):
      _withdraw(tx, scope.bind(target));
    case PlaceAmbushEffect(:final target):
      _placeAmbush(tx, scope.bind(target));
    case PowerMultiplierEffect(:final target, :final value, :final enemySupplyBelow):
      tx.updateOfficer(
        scope.bind(target),
        (o) => o.copyWith(
          nextBattleMultiplier: o.nextBattleMultiplier * value,
          multiplierEnemySupplyBelow: enemySupplyBelow,
        ),
      );
    case ModArmyEffect(:final target, :final field, :final delta):
      final ids = target == ModArmyEffect.allArmies ? tx.activeArmyIds() : [scope.bind(target)];
      for (final id in ids) {
        _modArmy(tx, id, field, delta);
      }
    case RevealIntentEffect(:final turnsAhead):
      final depth = Balance.baseRevealDepth + turnsAhead;
      if (depth > tx.s.revealDepth) {
        tx.s = tx.s.copyWith(revealDepth: depth);
        tx.emit(RevealDepthChanged(depth));
        assignPredictions(tx);
      }
    case SkipTurnEffect():
      tx.addFlag(GameFlags.skipOrders);
    case ChoiceEffect():
      throw StateError('choice is handled by runEffects');
  }
}

void _withdraw(Tx tx, String officerId) {
  final from = tx.officer(officerId).nodeId;
  final to = withdrawalNode(tx, officerId);
  if (to == null) throw IllegalAction(IllegalCodes.noWithdrawal, '$officerId has no free node');
  tx.updateOfficer(officerId, (o) => o.copyWith(nodeId: to, withdrawn: true, order: null));
  tx.emit(OfficerMoved(officerId, from, to, MoveReason.withdraw));
}

/// The ambush is manned by the highest-War active officer on either end of
/// the edge (ties by id).
void _placeAmbush(Tx tx, String edgeKey) {
  final edge = tx.graph.edges[edgeKey];
  if (edge == null) throw IllegalAction(IllegalCodes.badTarget, edgeKey);
  final candidates = [
    for (final id in tx.activeOfficerIds())
      if (!tx.officer(id).withdrawn && edge.touches(tx.officer(id).nodeId)) id,
  ];
  if (candidates.isEmpty) throw IllegalAction(IllegalCodes.noAmbusher, edgeKey);
  var best = candidates.first;
  for (final id in candidates.skip(1)) {
    if (tx.officerDef(id).stats.war > tx.officerDef(best).stats.war) best = id;
  }
  tx.s = tx.s.copyWith(ambushes: [...tx.s.ambushes, Ambush(edge: edgeKey, officerId: best)]);
  tx.emit(AmbushPlaced(edgeKey, best));
}

void _modArmy(Tx tx, String armyId, ArmyField field, int delta) {
  final a = tx.army(armyId);
  final (from, to) = switch (field) {
    ArmyField.troops => (a.troops, (a.troops + delta).clamp(0, 1 << 30)),
    ArmyField.supply => (a.supply, (a.supply + delta).clamp(0, a.maxSupply)),
    ArmyField.morale => (a.morale, (a.morale + delta).clamp(Balance.moraleMin, Balance.moraleMax)),
  };
  tx.updateArmy(
    armyId,
    (a) => switch (field) {
      ArmyField.troops => a.copyWith(troops: to),
      ArmyField.supply => a.copyWith(supply: to),
      ArmyField.morale => a.copyWith(morale: to),
    },
  );
  tx.emit(ArmyChanged(armyId, field, from, to));
}

/// Whether every condition holds with [bindings].
bool conditionsHold(Tx tx, List<ConditionDef> conditions, Map<String, String> bindings) {
  final scope = EffectScope(source: ChoiceSource.card, sourceId: '', bindings: bindings);
  return conditions.every((c) => switch (c) {
        ArmySupplyBelowFractionCondition(:final target, :final value) => () {
            final a = tx.army(scope.bind(target));
            return a.supply < value * a.maxSupply;
          }(),
        UnityAtLeastCondition(:final pillar, :final value) => tx.s.unity[pillar] >= value,
        NodeTerrainCondition(:final target, :final terrain) =>
          tx.graph.node(scope.bind(target)).terrain == terrain,
      });
}
