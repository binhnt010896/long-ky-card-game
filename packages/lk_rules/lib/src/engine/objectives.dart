import '../model/defs.dart';
import '../model/enums.dart';
import 'events.dart';
import 'tx.dart';

/// Whether [o] holds in the current state (build-spec section 3).
bool objectiveHolds(Tx tx, ObjectiveDef o) {
  final s = tx.s;
  final stats = s.missionStats;
  switch (o) {
    case AllArmiesBrokenObjective():
      return s.armies.values.every((a) => a.status == ArmyStatus.routed);
    case ArmyBrokenObjective(:final armyId):
      return s.armies[armyId]?.status == ArmyStatus.routed;
    case CounterattackAtObjective(:final nodeId):
      return stats.counterattackNodes.contains(nodeId);
    case SurviveTurnsObjective(:final turns):
      return s.turn >= turns;
    case KingAtObjective(:final nodeId, :final turn):
      return s.turn <= turn && tx.kingNodeId == nodeId;
    case ArmySupplyAtMostObjective(:final armyId, :final fraction):
      final a = s.armies[armyId];
      if (a == null) return false;
      // A routed army has no Supply left to worry about.
      return a.status == ArmyStatus.routed || a.supply <= fraction * a.maxSupply;
    case KingNotCapturedObjective():
      return !kingCaptured(tx);
    case CapitalHeldObjective():
      final cap = tx.graph.capitalId;
      return cap != null && s.nodes[cap]?.controller == Side.daiViet;
    case UnityAllAboveObjective(:final value):
      return Pillar.values.every((p) => s.unity[p] > value);
    case UnityAtLeastAtEndObjective(:final pillar, :final value):
      return s.unity[pillar] >= value;
    case NoDefectionsObjective():
      return stats.defections == 0;
    case NoCapturesObjective():
      return stats.captures == 0;
    case TroopsLostAtMostObjective(:final value):
      return stats.troopsLost <= value;
    case WinByTurnObjective(:final turn):
      return (stats.wonOnTurn ?? s.turn) <= turn;
    case WonObjective():
      return s.outcome == Outcome.won;
    case AnyOfObjective(:final anyOf):
      return anyOf.any((x) => objectiveHolds(tx, x));
  }
}

bool allHold(Tx tx, List<ObjectiveDef> list) => list.every((o) => objectiveHolds(tx, o));

bool kingCaptured(Tx tx) => tx.s.officers.entries.any(
    (e) => e.value.status == OfficerStatus.captured && (tx.def.officers[e.key]?.isKing ?? false));

/// Ends the mission if a loss holds, or, at the end of a turn, if the win
/// objectives hold or the season is over. Losses are checked first.
void checkEnd(Tx tx, {required bool endOfTurn}) {
  if (tx.s.isOver) return;
  if (tx.s.freePlay) {
    checkFreePlayEnd(tx);
    return;
  }
  final lossReason = _lossReason(tx);
  if (lossReason != null) {
    endMission(tx, Outcome.lost, lossReason);
    return;
  }
  if (!endOfTurn) return;
  final win = tx.mission.win;
  if (win.isNotEmpty && allHold(tx, win)) {
    endMission(tx, Outcome.won, null);
  } else if (tx.s.turn >= tx.mission.seasonTurns) {
    endMission(tx, Outcome.lost, LossReasons.seasonEnded);
  }
}

String? _lossReason(Tx tx) {
  if (kingCaptured(tx)) return LossReasons.kingCaptured;
  for (final p in Pillar.values) {
    if (tx.s.unity[p] <= 0) return '${LossReasons.unityPrefix}${p.name}';
  }
  for (final o in tx.mission.loss) {
    if (!objectiveHolds(tx, o)) return '${LossReasons.objectivePrefix}${o.type}';
  }
  return null;
}

/// Free play ends when one side has no troops left: the Yuan armies (the
/// side that is still standing) or the Đại Việt officers. The Yuan are
/// checked first, so if both are gone it is a win.
void checkFreePlayEnd(Tx tx) {
  if (tx.s.isOver) return;
  final yuan = tx.s.armies.values.where((a) => a.status == ArmyStatus.active).fold(0, (n, a) => n + a.troops);
  final ours = tx.s.officers.values.where((o) => o.status == OfficerStatus.active).fold(0, (n, o) => n + o.troops);
  if (yuan > 0 && ours > 0) return;
  final won = yuan <= 0;
  tx.s = tx.s.copyWith(
    phase: Phase.ended,
    pendingChoice: null,
    scriptedQueue: const [],
    freePlayOutcome: won ? Outcome.won : Outcome.lost,
  );
  tx.emit(FreePlayEnded(playerWon: won));
}

void endMission(Tx tx, Outcome outcome, String? reason) {
  tx.s = tx.s.copyWith(
    endedIn: tx.s.phase,
    phase: Phase.ended,
    pendingChoice: null,
    scriptedQueue: const [],
    outcome: outcome,
    lossReason: reason,
    missionStats: outcome == Outcome.won
        ? tx.s.missionStats.copyWith(wonOnTurn: tx.s.turn)
        : tx.s.missionStats,
  );
  final stars = outcome == Outcome.won
      ? [for (final o in tx.mission.stars) objectiveHolds(tx, o)]
      : [for (final _ in tx.mission.stars) false];
  tx.s = tx.s.copyWith(stars: stars);
  tx.emit(MissionEnded(outcome, reason: reason, stars: stars));
}

abstract final class LossReasons {
  static const String kingCaptured = 'kingCaptured';
  static const String seasonEnded = 'seasonEnded';
  static const String unityPrefix = 'unity:';
  static const String objectivePrefix = 'objective:';
}
