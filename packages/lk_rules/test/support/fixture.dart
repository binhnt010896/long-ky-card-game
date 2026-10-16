/// Test fixtures: a small map, officers, cards and a mission builder.
///
/// These are test data only. Real content lives in apps/game/assets/content.
///
/// Map (terrain, riceYield):
///
///     hl (hill, 0, border) --land-- pl (plain, 2) --land-- cap (city, 3, capital)
///                                    |land                   |river
///                                   ms (marsh, 1) --river-- rv1 (river, 1) --river-- rv2 (river, 2)
library;

import 'package:lk_rules/lk_rules.dart';
import 'package:test/test.dart';

LocalizedText t(String s) => LocalizedText(vi: s, en: s);

const _mapNodes = [
  ('hl', Terrain.hill, 0, false, true),
  ('pl', Terrain.plain, 2, false, false),
  ('cap', Terrain.city, 3, true, false),
  ('ms', Terrain.marsh, 1, false, false),
  ('rv1', Terrain.river, 1, false, false),
  ('rv2', Terrain.river, 2, false, false),
];

final MapDef testMap = MapDef(
  id: 'test',
  nodes: [
    for (final (id, terrain, rice, capital, border) in _mapNodes)
      NodeDef(
        id: id,
        name: t(id),
        terrain: terrain,
        x: 0,
        y: 0,
        riceYield: rice,
        isCapital: capital,
        isBorder: border,
      ),
  ],
  edges: const [
    EdgeDef(from: 'hl', to: 'pl', kind: EdgeKind.land),
    EdgeDef(from: 'pl', to: 'cap', kind: EdgeKind.land),
    EdgeDef(from: 'pl', to: 'ms', kind: EdgeKind.land),
    EdgeDef(from: 'cap', to: 'rv1', kind: EdgeKind.river),
    EdgeDef(from: 'ms', to: 'rv1', kind: EdgeKind.river),
    EdgeDef(from: 'rv1', to: 'rv2', kind: EdgeKind.river),
  ],
);

OfficerStats stats(int l, int w, int i, int p, int loyalty) =>
    OfficerStats(leadership: l, war: w, intelligence: i, politics: p, loyalty: loyalty);

SkillDef passive(String id) => SkillDef(id: id, kind: SkillKind.passive, name: t(id), text: t(id));

final List<OfficerDef> testOfficers = [
  OfficerDef(
    id: 'king',
    name: t('king'),
    stats: stats(7, 6, 6, 8, 10),
    loyaltyLocked: true,
    isKing: true,
    skill: passive(PassiveIds.kingPresence),
    flaw: FlawDef(id: FlawIds.isKing, name: t('isKing'), text: t('isKing')),
  ),
  OfficerDef(
    id: 'chancellor',
    name: t('chancellor'),
    stats: stats(8, 5, 8, 9, 10),
    loyaltyLocked: true,
    skill: SkillDef(
      id: 'restore-court',
      kind: SkillKind.activated,
      usesPerMission: 1,
      name: t('restore'),
      text: t('restore'),
      effects: const [SetUnityEffect(Pillar.court, 10)],
    ),
  ),
  OfficerDef(
    id: 'shield',
    name: t('shield'),
    stats: stats(6, 7, 6, 6, 9),
    loyaltyLocked: true,
    skill: passive(PassiveIds.shieldKing),
  ),
  OfficerDef(
    id: 'warden',
    name: t('warden'),
    stats: stats(9, 8, 10, 7, 10),
    loyaltyLocked: true,
    skill: passive(PassiveIds.borderWatch),
    flaw: FlawDef(id: FlawIds.troopCap, value: 6, name: t('cap'), text: t('cap')),
  ),
  OfficerDef(
    id: 'raider',
    name: t('raider'),
    stats: stats(7, 9, 7, 4, 8),
    skill: passive(PassiveIds.raider),
  ),
  OfficerDef(
    id: 'scholar',
    name: t('scholar'),
    stats: stats(4, 3, 6, 6, 5),
    skill: SkillDef(
      id: 'abandon',
      kind: SkillKind.activated,
      usesPerMission: 2,
      target: TargetKind.ownNode,
      name: t('abandon'),
      text: t('abandon'),
      effects: const [EvacuateNodeEffect(r'$node'), ModUnityEffect(Pillar.court, -1)],
    ),
  ),
  // A plain officer with no skill, for neutral combat numbers.
  OfficerDef(id: 'plain', name: t('plain'), stats: stats(5, 5, 5, 5, 6)),
];

const CommanderDef testCommander = CommanderDef(
  id: 'khan',
  name: LocalizedText(vi: 'khan', en: 'khan'),
  stats: CommanderStats(leadership: 9, war: 9, intelligence: 7),
);

final List<CardDef> testCards = [
  CardDef(
    id: 'evac',
    type: CardType.stratagem,
    name: t('evac'),
    text: t('evac'),
    cost: const CardCost(support: 2),
    target: TargetKind.ownNode,
    effects: const [EvacuateNodeEffect(r'$node')],
  ),
  CardDef(
    id: 'withdraw',
    type: CardType.stratagem,
    name: t('withdraw'),
    text: t('withdraw'),
    cost: const CardCost(rice: 1),
    target: TargetKind.ownOfficer,
    effects: const [WithdrawOfficerEffect(r'$officer')],
  ),
  CardDef(
    id: 'ambush',
    type: CardType.stratagem,
    name: t('ambush'),
    text: t('ambush'),
    cost: const CardCost(rice: 2),
    target: TargetKind.riverEdge,
    effects: const [PlaceAmbushEffect(r'$edge')],
  ),
  CardDef(
    id: 'counter',
    type: CardType.stratagem,
    name: t('counter'),
    text: t('counter'),
    cost: const CardCost(rice: 2, support: 1),
    target: TargetKind.ownOfficer,
    effects: const [PowerMultiplierEffect(r'$officer', 2.0, enemySupplyBelow: 0.5)],
  ),
  CardDef(
    id: 'envoy',
    type: CardType.event,
    name: t('envoy'),
    text: t('envoy'),
    effects: [
      ChoiceEffect([
        ChoiceOption(label: t('refuse'), effects: const [ModUnityEffect(Pillar.people, 1)]),
        ChoiceOption(
          label: t('accept'),
          effects: const [SkipTurnEffect(), ModUnityEffect(Pillar.court, -2)],
        ),
      ]),
    ],
  ),
  CardDef(
    id: 'heat',
    type: CardType.event,
    name: t('heat'),
    text: t('heat'),
    effects: const [ModArmyEffect(ModArmyEffect.allArmies, ArmyField.troops, -1)],
  ),
];

PlayerOfficerSetup at(String officerId, String nodeId, int troops) =>
    PlayerOfficerSetup(officerId: officerId, nodeId: nodeId, troops: troops);

YuanArmySetup army(
  String nodeId, {
  String id = 'y1',
  int troops = 30,
  int supply = 20,
  int maxSupply = 20,
  int morale = 8,
  String retreatNodeId = 'hl',
}) =>
    YuanArmySetup(
      id: id,
      commanderId: 'khan',
      nodeId: nodeId,
      troops: troops,
      supply: supply,
      maxSupply: maxSupply,
      morale: morale,
      retreatNodeId: retreatNodeId,
    );

MissionDef mission({
  List<PlayerOfficerSetup> officers = const [],
  List<YuanArmySetup> armies = const [],
  int seasonTurns = 5,
  int? heatStartTurn,
  int rice = 4,
  int support = 4,
  StartingUnity unity = const StartingUnity(court: 6, clan: 6, people: 6),
  List<DeckEntry> deck = const [],
  int handSize = 4,
  List<ScriptedEvent> scriptedEvents = const [],
  List<Inducement> inducements = const [],
  List<YuanScriptEntry> yuanScript = const [],
  String? yuanObjectiveNodeId,
  List<ObjectiveDef>? win,
  List<ObjectiveDef> loss = const [KingNotCapturedObjective(), UnityAllAboveObjective(0)],
  List<ObjectiveDef> stars = const [WonObjective(), NoDefectionsObjective(), NoCapturesObjective()],
}) =>
    MissionDef(
      id: 'test_m',
      chapter: 1,
      order: 1,
      title: t('test'),
      briefing: t('briefing'),
      debrief: t('debrief'),
      mapId: 'test',
      seasonTurns: seasonTurns,
      heatStartTurn: heatStartTurn,
      start: MissionStart(rice: rice, support: support, unity: unity),
      playerOfficers: officers,
      yuanArmies: armies,
      deck: deck,
      handSize: handSize,
      scriptedEvents: scriptedEvents,
      inducements: inducements,
      yuanScript: yuanScript,
      yuanObjectiveNodeId: yuanObjectiveNodeId,
      win: win ?? [SurviveTurnsObjective(seasonTurns)],
      loss: loss,
      stars: stars,
    );

GameEngine engineFor(MissionDef m) => GameEngine(
      Ruleset(
        mission: m,
        map: testMap,
        officers: testOfficers,
        commanders: const [testCommander],
        cards: testCards,
      ),
    );

/// Script entries that make army [armyId] hold on every turn up to [turns].
List<YuanScriptEntry> holdAll({String armyId = 'y1', int turns = 10}) => [
      for (var turn = 1; turn <= turns; turn++)
        YuanScriptEntry(turn: turn, armyId: armyId, intent: IntentKind.hold),
    ];

/// Applies [actions] in order and returns the last result.
StepResult play(GameEngine e, GameState s, List<GameAction> actions) {
  var r = StepResult(s, const []);
  for (final a in actions) {
    r = e.apply(r.state, a);
  }
  return r;
}

/// Ends the current turn from Council or Orders (Council skips straight to
/// Resolution when Orders are skipped).
StepResult endTurn(GameEngine e, GameState s) {
  final r = e.apply(s, const GameAction.endPhase());
  if (r.state.phase == Phase.orders) return e.apply(r.state, const GameAction.endPhase());
  return r;
}

Matcher throwsIllegal(String code) => throwsA(isA<IllegalAction>().having((e) => e.code, 'code', code));
