import 'package:freezed_annotation/freezed_annotation.dart';

import '../actions/game_action.dart';
import 'enums.dart';

part 'game_state.freezed.dart';
part 'game_state.g.dart';

@freezed
abstract class Unity with _$Unity {
  const Unity._();

  const factory Unity({required int court, required int clan, required int people}) = _Unity;

  factory Unity.fromJson(Map<String, Object?> json) => _$UnityFromJson(json);

  int operator [](Pillar p) => switch (p) {
        Pillar.court => court,
        Pillar.clan => clan,
        Pillar.people => people,
      };

  Unity withPillar(Pillar p, int value) => switch (p) {
        Pillar.court => copyWith(court: value),
        Pillar.clan => copyWith(clan: value),
        Pillar.people => copyWith(people: value),
      };
}

@freezed
abstract class NodeState with _$NodeState {
  const factory NodeState({
    required Side controller,
    @Default(false) bool evacuated,
    required int riceStock,
  }) = _NodeState;

  factory NodeState.fromJson(Map<String, Object?> json) => _$NodeStateFromJson(json);
}

/// An officer's order for this turn. [target] is a node id (move), an army id
/// (raid) or an edge key (ambush); null for the others.
@freezed
abstract class Order with _$Order {
  const factory Order({required OrderKind kind, String? target}) = _Order;

  factory Order.fromJson(Map<String, Object?> json) => _$OrderFromJson(json);

  static const Order hold = Order(kind: OrderKind.hold);
  static const Order evacuate = Order(kind: OrderKind.evacuate);
  static const Order rally = Order(kind: OrderKind.rally);
  static Order move(String nodeId) => Order(kind: OrderKind.move, target: nodeId);
  static Order raid(String armyId) => Order(kind: OrderKind.raid, target: armyId);
  static Order ambush(String edgeKey) => Order(kind: OrderKind.ambush, target: edgeKey);
}

@freezed
abstract class OfficerState with _$OfficerState {
  const factory OfficerState({
    required String nodeId,
    required int troops,
    required int morale,
    required int loyalty,
    @Default(OfficerStatus.active) OfficerStatus status,
    Order? order,
    @Default(0) int skillUsesLeft,
    @Default(1.0) double nextBattleMultiplier,

    /// Condition of [nextBattleMultiplier]: the opposing army must be below
    /// this fraction of its max Supply.
    double? multiplierEnemySupplyBelow,

    /// Withdrawn by a card this turn: no battle and no orders until next turn.
    @Default(false) bool withdrawn,
  }) = _OfficerState;

  factory OfficerState.fromJson(Map<String, Object?> json) => _$OfficerStateFromJson(json);
}

/// A Yuan army's intent. [moveTo] is the adjacent node it moves to this turn,
/// or null if it stays; [targetNodeId] is where it is heading.
@freezed
abstract class Intent with _$Intent {
  const factory Intent({required IntentKind kind, String? moveTo, String? targetNodeId}) = _Intent;

  factory Intent.fromJson(Map<String, Object?> json) => _$IntentFromJson(json);
}

@freezed
abstract class ArmyState with _$ArmyState {
  const factory ArmyState({
    required String commanderId,
    required String nodeId,
    required int troops,
    required int supply,
    required int maxSupply,
    required int morale,
    required String retreatNodeId,
    Intent? intent,

    /// Next turn's intent, shown as "predicted" when `revealDepth` ≥ 2.
    Intent? predictedIntent,
    @Default(ArmyStatus.active) ArmyStatus status,
  }) = _ArmyState;

  factory ArmyState.fromJson(Map<String, Object?> json) => _$ArmyStateFromJson(json);
}

@freezed
abstract class Ambush with _$Ambush {
  const factory Ambush({required String edge, required String officerId}) = _Ambush;

  factory Ambush.fromJson(Map<String, Object?> json) => _$AmbushFromJson(json);
}

enum ChoiceSource { card, skill }

/// A `choice` effect waiting for `ResolveChoice`.
///
/// [path] locates the choice inside the source's effects:
/// `[effectIndex, optionIndex, effectIndex, ...]`, ending at the choice.
@freezed
abstract class PendingChoice with _$PendingChoice {
  const factory PendingChoice({
    required ChoiceSource source,
    required String sourceId,
    required List<int> path,
    required int optionCount,
    @Default(<String, String>{}) Map<String, String> bindings,
  }) = _PendingChoice;

  factory PendingChoice.fromJson(Map<String, Object?> json) => _$PendingChoiceFromJson(json);
}

@freezed
abstract class MissionStats with _$MissionStats {
  const factory MissionStats({
    @Default(0) int troopsLost,
    @Default(0) int defections,
    @Default(0) int captures,
    @Default(0) int battlesWon,
    @Default(0) int battlesLost,
    @Default(0) int evacuations,
    @Default(0) int raids,
    @Default(0) int ambushesTriggered,
    @Default(<String, int>{}) Map<String, int> cardsPlayed,
    @Default(<String, int>{}) Map<String, int> skillsUsed,

    /// Nodes where a `counterattackAt` battle was won.
    @Default(<String>[]) List<String> counterattackNodes,
    int? wonOnTurn,
  }) = _MissionStats;

  factory MissionStats.fromJson(Map<String, Object?> json) => _$MissionStatsFromJson(json);
}

@freezed
abstract class GameState with _$GameState {
  const GameState._();

  const factory GameState({
    required String missionId,
    required int seed,

    /// SplitMix64 state of the game's [SeededRng].
    required int rng,
    required int turn,
    required Phase phase,
    Outcome? outcome,
    String? lossReason,
    required int rice,
    required int support,
    required Unity unity,
    required Map<String, NodeState> nodes,
    required Map<String, OfficerState> officers,
    required Map<String, ArmyState> armies,
    @Default(<Ambush>[]) List<Ambush> ambushes,
    @Default(<String>[]) List<String> deck,
    @Default(<String>[]) List<String> hand,
    @Default(<String>[]) List<String> discard,
    PendingChoice? pendingChoice,

    /// Free play: after the mission ended the player kept playing, until
    /// either side has no troops left. [outcome] stays the mission's own
    /// result; [freePlayOutcome] is how the free play itself ended.
    @Default(false) bool freePlay,
    Outcome? freePlayOutcome,

    /// The phase the mission ended in, so that free play can carry on from there.
    Phase? endedIn,

    /// Scripted event cards of this turn still waiting behind a choice.
    @Default(<String>[]) List<String> scriptedQueue,
    @Default(1) int revealDepth,

    /// Mission flags, e.g. [GameFlags.capitalLost].
    @Default(<String>[]) List<String> flags,
    @Default(0) int evacuationsThisTurn,
    @Default(MissionStats()) MissionStats missionStats,

    /// Stars earned, one entry per star objective; set when the mission is won.
    @Default(<bool>[]) List<bool> stars,

    /// Every action applied since the mission start (the save file's log).
    @Default(<GameAction>[]) List<GameAction> log,
  }) = _GameState;

  factory GameState.fromJson(Map<String, Object?> json) => _$GameStateFromJson(json);

  bool get isOver => phase == Phase.ended;

  bool hasFlag(String flag) => flags.contains(flag);

  Iterable<MapEntry<String, OfficerState>> get activeOfficers =>
      officers.entries.where((e) => e.value.status == OfficerStatus.active);

  Iterable<MapEntry<String, ArmyState>> get activeArmies =>
      armies.entries.where((e) => e.value.status == ArmyStatus.active);
}

abstract final class GameFlags {
  /// The capital has been lost at least once (Court −1 applies only once).
  static const String capitalLost = 'capitalLost';

  /// A `skipTurn` effect: Orders are skipped this turn.
  static const String skipOrders = 'skipOrders';
}
