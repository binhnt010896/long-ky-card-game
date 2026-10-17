import '../model/enums.dart';
import '../model/game_state.dart';

/// Something that happened during a step, in order, for the UI to animate
/// and for the text-mode player to print.
sealed class GameEvent {
  const GameEvent();
}

final class TurnStarted extends GameEvent {
  const TurnStarted(this.turn);
  final int turn;
}

final class PhaseChanged extends GameEvent {
  const PhaseChanged(this.phase);
  final Phase phase;
}

final class IntentRevealed extends GameEvent {
  const IntentRevealed(this.armyId, this.intent, {this.predicted = false});
  final String armyId;
  final Intent intent;
  final bool predicted;
}

final class RevealDepthChanged extends GameEvent {
  const RevealDepthChanged(this.depth);
  final int depth;
}

final class CardPlayed extends GameEvent {
  const CardPlayed(this.cardId, {this.target, this.scripted = false});
  final String cardId;
  final String? target;
  final bool scripted;
}

final class SkillUsed extends GameEvent {
  const SkillUsed(this.officerId, this.skillId, {this.target});
  final String officerId;
  final String skillId;
  final String? target;
}

final class ChoiceRequested extends GameEvent {
  const ChoiceRequested(this.sourceId, this.optionCount);
  final String sourceId;
  final int optionCount;
}

final class ChoiceResolved extends GameEvent {
  const ChoiceResolved(this.sourceId, this.index);
  final String sourceId;
  final int index;
}

final class UnityChanged extends GameEvent {
  const UnityChanged(this.pillar, this.from, this.to);
  final Pillar pillar;
  final int from;
  final int to;
}

final class ResourceChanged extends GameEvent {
  const ResourceChanged(this.resource, this.from, this.to);
  final Resource resource;
  final int from;
  final int to;
}

final class OrdersSkipped extends GameEvent {
  const OrdersSkipped();
}

final class OrderSet extends GameEvent {
  const OrderSet(this.officerId, this.order);
  final String officerId;
  final Order? order;
}

enum MoveReason { order, withdraw, battleWithdraw, retreat, intent }

final class OfficerMoved extends GameEvent {
  const OfficerMoved(this.officerId, this.from, this.to, this.reason);
  final String officerId;
  final String from;
  final String to;
  final MoveReason reason;
}

final class ArmyMoved extends GameEvent {
  const ArmyMoved(this.armyId, this.from, this.to, this.reason);
  final String armyId;
  final String from;
  final String to;
  final MoveReason reason;
}

final class NodeEvacuated extends GameEvent {
  const NodeEvacuated(this.nodeId, this.riceGained);
  final String nodeId;
  final int riceGained;
}

final class Rallied extends GameEvent {
  const Rallied(this.officerId, this.nodeId, this.troopsGained);
  final String officerId;
  final String nodeId;
  final int troopsGained;
}

final class AmbushPlaced extends GameEvent {
  const AmbushPlaced(this.edge, this.officerId);
  final String edge;
  final String officerId;
}

enum BattleKind { field, ambush }

/// Full numbers of one battle, enough for the battle preview and the log.
final class BattleReport {
  const BattleReport({
    required this.kind,
    required this.nodeId,
    required this.officerIds,
    required this.armyIds,
    required this.daiVietPower,
    required this.yuanPower,
    required this.winner,
    required this.officerLosses,
    required this.armyLosses,
    this.edge,
    this.roll,
    this.daiVietStarted = false,
  });

  final BattleKind kind;

  /// Where the battle happened; for an ambush, the ambusher's node.
  final String nodeId;
  final String? edge;
  final List<String> officerIds;
  final List<String> armyIds;
  final double daiVietPower;
  final double yuanPower;
  final Side winner;
  final Map<String, int> officerLosses;
  final Map<String, int> armyLosses;

  /// The ambush roll in [0.9, 1.1).
  final double? roll;
  final bool daiVietStarted;
}

final class BattleResolved extends GameEvent {
  const BattleResolved(this.report);
  final BattleReport report;
}

final class OfficerCaptured extends GameEvent {
  const OfficerCaptured(this.officerId, this.nodeId);
  final String officerId;
  final String nodeId;
}

final class KingShielded extends GameEvent {
  const KingShielded(this.kingId, this.shieldId);
  final String kingId;
  final String shieldId;
}

final class Raided extends GameEvent {
  const Raided(this.officerId, this.armyId, this.supplyLost, this.troopsLost);
  final String officerId;
  final String armyId;
  final int supplyLost;
  final int troopsLost;
}

final class Foraged extends GameEvent {
  const Foraged(this.armyId, this.nodeId, this.supplyGained);
  final String armyId;
  final String nodeId;
  final int supplyGained;
}

final class NodeControlChanged extends GameEvent {
  const NodeControlChanged(this.nodeId, this.from, this.to);
  final String nodeId;
  final Side from;
  final Side to;
}

final class ArmyChanged extends GameEvent {
  const ArmyChanged(this.armyId, this.field, this.from, this.to);
  final String armyId;
  final ArmyField field;
  final int from;
  final int to;
}

final class SupplyConsumed extends GameEvent {
  const SupplyConsumed(this.armyId, this.amount);
  final String armyId;
  final int amount;
}

final class Starvation extends GameEvent {
  const Starvation(this.armyId, this.moraleLost, this.troopsLost);
  final String armyId;
  final int moraleLost;
  final int troopsLost;
}

final class HeatAttrition extends GameEvent {
  const HeatAttrition(this.armyId, this.troopsLost);
  final String armyId;
  final int troopsLost;
}

final class ArmyRouted extends GameEvent {
  const ArmyRouted(this.armyId);
  final String armyId;
}

final class IncomeCollected extends GameEvent {
  const IncomeCollected(this.riceGained, this.riceUpkeep, {required this.shortfall});
  final int riceGained;
  final int riceUpkeep;

  /// Rice went below 0: it was set to 0 and every officer lost morale.
  final bool shortfall;
}

final class OfficerDefected extends GameEvent {
  const OfficerDefected(this.officerId);
  final String officerId;
}

final class InducementResisted extends GameEvent {
  const InducementResisted(this.officerId);
  final String officerId;
}

final class CardsDrawn extends GameEvent {
  const CardsDrawn(this.cardIds);
  final List<String> cardIds;
}

final class DeckShuffled extends GameEvent {
  const DeckShuffled(this.size);
  final int size;
}

final class MissionEnded extends GameEvent {
  const MissionEnded(this.outcome, {this.reason, this.stars = const []});
  final Outcome outcome;
  final String? reason;
  final List<bool> stars;
}

/// The player chose to keep playing after the mission ended.
final class FreePlayStarted extends GameEvent {
  const FreePlayStarted();
}

/// Free play is over: one side has no troops left. [playerWon] is true when
/// it was the Yuan side.
final class FreePlayEnded extends GameEvent {
  const FreePlayEnded({required this.playerWon});
  final bool playerWon;
}
