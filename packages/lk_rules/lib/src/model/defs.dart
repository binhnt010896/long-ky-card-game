/// Content definitions: the immutable data a mission is played with.
///
/// `lk_content` parses the JSON in `apps/game/assets/content` into these
/// types. Nothing here is hard-coded content; tests build their own fixtures.
library;

import 'enums.dart';

/// Player-facing text in both languages. Vietnamese is the source language.
final class LocalizedText {
  const LocalizedText({required this.vi, required this.en});

  final String vi;
  final String en;

  @override
  String toString() => vi;
}

final class OfficerStats {
  const OfficerStats({
    required this.leadership,
    required this.war,
    required this.intelligence,
    required this.politics,
    required this.loyalty,
  });

  /// Thống: troops commanded at full value, battle tie-breaker.
  final int leadership;

  /// Võ: battle Power multiplier.
  final int war;

  /// Trí.
  final int intelligence;

  /// Chính.
  final int politics;

  /// Trung: resistance to inducements.
  final int loyalty;
}

final class SkillDef {
  const SkillDef({
    required this.id,
    required this.kind,
    required this.name,
    required this.text,
    this.usesPerMission = 0,
    this.target = TargetKind.none,
    this.effects = const [],
  });

  final String id;
  final SkillKind kind;
  final int usesPerMission;
  final TargetKind target;
  final LocalizedText name;
  final LocalizedText text;

  /// Activated skills only. Passive skills are implemented by [id].
  final List<EffectDef> effects;
}

final class FlawDef {
  const FlawDef({required this.id, required this.name, required this.text, this.value});

  final String id;

  /// Parameter of the flaw, e.g. the troop cap for `troopCap`.
  final int? value;
  final LocalizedText name;
  final LocalizedText text;
}

final class OfficerDef {
  const OfficerDef({
    required this.id,
    required this.name,
    required this.stats,
    this.longKyPersonId,
    this.title,
    this.loyaltyLocked = false,
    this.isKing = false,
    this.skill,
    this.flaw,
    this.portraitArt,
    this.cardArt,
    this.sourceRefs = const [],
  });

  final String id;
  final String? longKyPersonId;
  final LocalizedText name;
  final LocalizedText? title;
  final OfficerStats stats;
  final bool loyaltyLocked;
  final bool isKing;
  final SkillDef? skill;
  final FlawDef? flaw;
  final String? portraitArt;
  final String? cardArt;
  final List<String> sourceRefs;

  bool hasPassive(String passiveId) =>
      skill != null && skill!.kind == SkillKind.passive && skill!.id == passiveId;

  /// Maximum troops this officer may have, or null for no cap.
  int? get troopCap => flaw?.id == FlawIds.troopCap ? flaw!.value : null;
}

final class CommanderStats {
  const CommanderStats({required this.leadership, required this.war, required this.intelligence});

  final int leadership;
  final int war;
  final int intelligence;
}

/// A Yuan commander (enemies.json).
final class CommanderDef {
  const CommanderDef({
    required this.id,
    required this.name,
    required this.stats,
    this.longKyPersonId,
    this.title,
    this.portraitArt,
    this.cardArt,
    this.sourceRefs = const [],
  });

  final String id;
  final String? longKyPersonId;
  final LocalizedText name;
  final LocalizedText? title;
  final CommanderStats stats;
  final String? portraitArt;
  final String? cardArt;
  final List<String> sourceRefs;
}

final class CardCost {
  const CardCost({this.rice = 0, this.support = 0});

  final int rice;
  final int support;
}

final class CardDef {
  const CardDef({
    required this.id,
    required this.type,
    required this.name,
    required this.text,
    this.cost = const CardCost(),
    this.target = TargetKind.none,
    this.conditions = const [],
    this.effects = const [],
    this.longKyEventId,
    this.art,
    this.sourceRefs = const [],
  });

  final String id;
  final CardType type;
  final LocalizedText name;
  final LocalizedText text;
  final CardCost cost;
  final TargetKind target;
  final List<ConditionDef> conditions;
  final List<EffectDef> effects;
  final String? longKyEventId;
  final String? art;
  final List<String> sourceRefs;
}

// ---------------------------------------------------------------------------
// Effects (closed set, build-spec section 3).

sealed class EffectDef {
  const EffectDef();

  /// The JSON `op` name.
  String get op;
}

final class ModUnityEffect extends EffectDef {
  const ModUnityEffect(this.pillar, this.delta);
  final Pillar pillar;
  final int delta;
  @override
  String get op => 'modUnity';
}

final class SetUnityEffect extends EffectDef {
  const SetUnityEffect(this.pillar, this.value);
  final Pillar pillar;
  final int value;
  @override
  String get op => 'setUnity';
}

final class ModResourceEffect extends EffectDef {
  const ModResourceEffect(this.resource, this.delta);
  final Resource resource;
  final int delta;
  @override
  String get op => 'modResource';
}

final class EvacuateNodeEffect extends EffectDef {
  const EvacuateNodeEffect(this.target);

  /// A binding such as `$node`.
  final String target;
  @override
  String get op => 'evacuateNode';
}

final class WithdrawOfficerEffect extends EffectDef {
  const WithdrawOfficerEffect(this.target);
  final String target;
  @override
  String get op => 'withdrawOfficer';
}

final class PlaceAmbushEffect extends EffectDef {
  const PlaceAmbushEffect(this.target);
  final String target;
  @override
  String get op => 'placeAmbush';
}

final class PowerMultiplierEffect extends EffectDef {
  const PowerMultiplierEffect(this.target, this.value, {this.enemySupplyBelow});
  final String target;
  final double value;

  /// Only applies if the opposing army is below this fraction of max Supply.
  final double? enemySupplyBelow;
  @override
  String get op => 'powerMultiplier';
}

final class ModArmyEffect extends EffectDef {
  const ModArmyEffect(this.target, this.field, this.delta);

  /// `$army` or [allArmies].
  final String target;
  final ArmyField field;
  final int delta;

  static const String allArmies = 'allArmies';
  @override
  String get op => 'modArmy';
}

final class RevealIntentEffect extends EffectDef {
  const RevealIntentEffect(this.turnsAhead);
  final int turnsAhead;
  @override
  String get op => 'revealIntent';
}

final class SkipTurnEffect extends EffectDef {
  const SkipTurnEffect();
  @override
  String get op => 'skipTurn';
}

final class ChoiceOption {
  const ChoiceOption({required this.label, required this.effects});
  final LocalizedText label;
  final List<EffectDef> effects;
}

/// Player picks one option. Must be the last effect in its list.
final class ChoiceEffect extends EffectDef {
  const ChoiceEffect(this.options);
  final List<ChoiceOption> options;
  @override
  String get op => 'choice';
}

/// All effect op names (closed list).
const Set<String> effectOps = {
  'modUnity',
  'setUnity',
  'modResource',
  'evacuateNode',
  'withdrawOfficer',
  'placeAmbush',
  'powerMultiplier',
  'modArmy',
  'revealIntent',
  'skipTurn',
  'choice',
};

// ---------------------------------------------------------------------------
// Conditions (closed set).

sealed class ConditionDef {
  const ConditionDef();
  String get op;
}

final class ArmySupplyBelowFractionCondition extends ConditionDef {
  const ArmySupplyBelowFractionCondition(this.target, this.value);
  final String target;
  final double value;
  @override
  String get op => 'armySupplyBelowFraction';
}

final class UnityAtLeastCondition extends ConditionDef {
  const UnityAtLeastCondition(this.pillar, this.value);
  final Pillar pillar;
  final int value;
  @override
  String get op => 'unityAtLeast';
}

final class NodeTerrainCondition extends ConditionDef {
  const NodeTerrainCondition(this.target, this.terrain);
  final String target;
  final Terrain terrain;
  @override
  String get op => 'nodeTerrain';
}

const Set<String> conditionOps = {'armySupplyBelowFraction', 'unityAtLeast', 'nodeTerrain'};

// ---------------------------------------------------------------------------
// Map.

final class NodeDef {
  const NodeDef({
    required this.id,
    required this.name,
    required this.terrain,
    required this.x,
    required this.y,
    this.riceYield = 0,
    this.isCapital = false,
    this.isBorder = false,
  });

  final String id;
  final LocalizedText name;
  final Terrain terrain;
  final double x;
  final double y;
  final int riceYield;
  final bool isCapital;
  final bool isBorder;
}

final class EdgeDef {
  const EdgeDef({required this.from, required this.to, required this.kind});

  final String from;
  final String to;
  final EdgeKind kind;

  String get key => edgeKey(from, to);

  bool touches(String nodeId) => from == nodeId || to == nodeId;

  String other(String nodeId) => from == nodeId ? to : from;
}

/// Canonical id of the undirected edge between [a] and [b].
String edgeKey(String a, String b) => a.compareTo(b) <= 0 ? '$a~$b' : '$b~$a';

final class MapDef {
  const MapDef({required this.id, required this.nodes, required this.edges, this.imagePath});

  final String id;

  /// The painted map, under `assets/images/` (for example `maps/ch1.png`).
  /// The board draws a placeholder when the file is not shipped.
  final String? imagePath;
  final List<NodeDef> nodes;
  final List<EdgeDef> edges;
}

// ---------------------------------------------------------------------------
// Missions.

final class StartingUnity {
  const StartingUnity({required this.court, required this.clan, required this.people});
  final int court;
  final int clan;
  final int people;
}

final class MissionStart {
  const MissionStart({required this.rice, required this.support, required this.unity});
  final int rice;
  final int support;
  final StartingUnity unity;
}

final class PlayerOfficerSetup {
  const PlayerOfficerSetup({required this.officerId, required this.nodeId, required this.troops});
  final String officerId;
  final String nodeId;
  final int troops;
}

final class YuanArmySetup {
  const YuanArmySetup({
    required this.id,
    required this.commanderId,
    required this.nodeId,
    required this.troops,
    required this.supply,
    required this.maxSupply,
    required this.morale,
    required this.retreatNodeId,
  });

  final String id;
  final String commanderId;
  final String nodeId;
  final int troops;
  final int supply;
  final int maxSupply;
  final int morale;
  final String retreatNodeId;
}

final class DeckEntry {
  const DeckEntry({required this.cardId, required this.count});
  final String cardId;
  final int count;
}

final class ScriptedEvent {
  const ScriptedEvent({required this.turn, required this.cardId});
  final int turn;
  final String cardId;
}

final class Inducement {
  const Inducement({required this.turn, required this.threshold});
  final int turn;
  final int threshold;
}

final class YuanScriptEntry {
  const YuanScriptEntry({
    required this.turn,
    required this.armyId,
    required this.intent,
    this.targetNodeId,
  });

  final int turn;
  final String armyId;
  final IntentKind intent;
  final String? targetNodeId;
}

final class TutorialStep {
  const TutorialStep({required this.id, required this.text, this.highlight});
  final String id;
  final LocalizedText text;
  final String? highlight;
}

final class MissionDef {
  const MissionDef({
    required this.id,
    required this.chapter,
    required this.order,
    required this.title,
    required this.briefing,
    required this.debrief,
    required this.mapId,
    required this.seasonTurns,
    required this.start,
    required this.playerOfficers,
    required this.yuanArmies,
    required this.deck,
    required this.handSize,
    required this.win,
    required this.loss,
    required this.stars,
    this.heatStartTurn,
    this.scriptedEvents = const [],
    this.inducements = const [],
    this.yuanScript = const [],
    this.yuanObjectiveNodeId,
    this.tutorial = const [],
    this.longKyEventId,
    this.sourceRefs = const [],
  });

  final String id;
  final int chapter;
  final int order;
  final LocalizedText title;
  final LocalizedText briefing;
  final LocalizedText debrief;
  final String mapId;
  final int seasonTurns;
  final int? heatStartTurn;
  final MissionStart start;
  final List<PlayerOfficerSetup> playerOfficers;
  final List<YuanArmySetup> yuanArmies;
  final List<DeckEntry> deck;
  final int handSize;
  final List<ScriptedEvent> scriptedEvents;
  final List<Inducement> inducements;
  final List<YuanScriptEntry> yuanScript;
  final String? yuanObjectiveNodeId;

  /// Satisfied when all are satisfied: the mission is won.
  final List<ObjectiveDef> win;

  /// Conditions that must stay true: the mission is lost when any fails.
  final List<ObjectiveDef> loss;

  /// Three star objectives; star 1 is always [WonObjective].
  final List<ObjectiveDef> stars;
  final List<TutorialStep> tutorial;
  final String? longKyEventId;
  final List<String> sourceRefs;
}

// ---------------------------------------------------------------------------
// Objectives (closed list, build-spec section 3).

sealed class ObjectiveDef {
  const ObjectiveDef();
  String get type;
}

final class AllArmiesBrokenObjective extends ObjectiveDef {
  const AllArmiesBrokenObjective();
  @override
  String get type => 'allArmiesBroken';
}

final class ArmyBrokenObjective extends ObjectiveDef {
  const ArmyBrokenObjective(this.armyId);
  final String armyId;
  @override
  String get type => 'armyBroken';
}

/// Win a battle at [nodeId] that you started, against an army below half Supply.
final class CounterattackAtObjective extends ObjectiveDef {
  const CounterattackAtObjective(this.nodeId);
  final String nodeId;
  @override
  String get type => 'counterattackAt';
}

final class SurviveTurnsObjective extends ObjectiveDef {
  const SurviveTurnsObjective(this.turns);
  final int turns;
  @override
  String get type => 'surviveTurns';
}

/// The king is at [nodeId] at the end of a turn no later than [turn].
final class KingAtObjective extends ObjectiveDef {
  const KingAtObjective(this.nodeId, this.turn);
  final String nodeId;
  final int turn;
  @override
  String get type => 'kingAt';
}

final class ArmySupplyAtMostObjective extends ObjectiveDef {
  const ArmySupplyAtMostObjective(this.armyId, this.fraction);
  final String armyId;
  final double fraction;
  @override
  String get type => 'armySupplyAtMost';
}

final class KingNotCapturedObjective extends ObjectiveDef {
  const KingNotCapturedObjective();
  @override
  String get type => 'kingNotCaptured';
}

final class CapitalHeldObjective extends ObjectiveDef {
  const CapitalHeldObjective();
  @override
  String get type => 'capitalHeld';
}

/// Every pillar strictly above [value].
final class UnityAllAboveObjective extends ObjectiveDef {
  const UnityAllAboveObjective(this.value);
  final int value;
  @override
  String get type => 'unityAllAbove';
}

final class UnityAtLeastAtEndObjective extends ObjectiveDef {
  const UnityAtLeastAtEndObjective(this.pillar, this.value);
  final Pillar pillar;
  final int value;
  @override
  String get type => 'unityAtLeastAtEnd';
}

final class NoDefectionsObjective extends ObjectiveDef {
  const NoDefectionsObjective();
  @override
  String get type => 'noDefections';
}

final class NoCapturesObjective extends ObjectiveDef {
  const NoCapturesObjective();
  @override
  String get type => 'noCaptures';
}

final class TroopsLostAtMostObjective extends ObjectiveDef {
  const TroopsLostAtMostObjective(this.value);
  final int value;
  @override
  String get type => 'troopsLostAtMost';
}

final class WinByTurnObjective extends ObjectiveDef {
  const WinByTurnObjective(this.turn);
  final int turn;
  @override
  String get type => 'winByTurn';
}

/// The mission was won. Used for star 1.
final class WonObjective extends ObjectiveDef {
  const WonObjective();
  @override
  String get type => 'won';
}

final class AnyOfObjective extends ObjectiveDef {
  const AnyOfObjective(this.anyOf);
  final List<ObjectiveDef> anyOf;
  @override
  String get type => 'anyOf';
}

const Set<String> objectiveTypes = {
  'allArmiesBroken',
  'armyBroken',
  'counterattackAt',
  'surviveTurns',
  'kingAt',
  'armySupplyAtMost',
  'kingNotCaptured',
  'capitalHeld',
  'unityAllAbove',
  'unityAtLeastAtEnd',
  'noDefections',
  'noCaptures',
  'troopsLostAtMost',
  'winByTurn',
  'won',
};

// ---------------------------------------------------------------------------

/// Everything the engine needs to play one mission.
final class Ruleset {
  Ruleset({
    required this.mission,
    required this.map,
    required List<OfficerDef> officers,
    required List<CommanderDef> commanders,
    required List<CardDef> cards,
  })  : officers = {for (final o in officers) o.id: o},
        commanders = {for (final c in commanders) c.id: c},
        cards = {for (final c in cards) c.id: c};

  final MissionDef mission;
  final MapDef map;
  final Map<String, OfficerDef> officers;
  final Map<String, CommanderDef> commanders;
  final Map<String, CardDef> cards;
}
