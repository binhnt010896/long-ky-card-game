// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Unity _$UnityFromJson(Map<String, dynamic> json) {
  $checkKeys(json, allowedKeys: const ['court', 'clan', 'people']);
  return _Unity(
    court: (json['court'] as num).toInt(),
    clan: (json['clan'] as num).toInt(),
    people: (json['people'] as num).toInt(),
  );
}

Map<String, dynamic> _$UnityToJson(_Unity instance) => <String, dynamic>{
  'court': instance.court,
  'clan': instance.clan,
  'people': instance.people,
};

_NodeState _$NodeStateFromJson(Map<String, dynamic> json) {
  $checkKeys(json, allowedKeys: const ['controller', 'evacuated', 'riceStock']);
  return _NodeState(
    controller: $enumDecode(_$SideEnumMap, json['controller']),
    evacuated: json['evacuated'] as bool? ?? false,
    riceStock: (json['riceStock'] as num).toInt(),
  );
}

Map<String, dynamic> _$NodeStateToJson(_NodeState instance) =>
    <String, dynamic>{
      'controller': _$SideEnumMap[instance.controller]!,
      'evacuated': instance.evacuated,
      'riceStock': instance.riceStock,
    };

const _$SideEnumMap = {
  Side.daiViet: 'daiViet',
  Side.yuan: 'yuan',
  Side.none: 'none',
};

_Order _$OrderFromJson(Map<String, dynamic> json) {
  $checkKeys(json, allowedKeys: const ['kind', 'target']);
  return _Order(
    kind: $enumDecode(_$OrderKindEnumMap, json['kind']),
    target: json['target'] as String?,
  );
}

Map<String, dynamic> _$OrderToJson(_Order instance) => <String, dynamic>{
  'kind': _$OrderKindEnumMap[instance.kind]!,
  'target': instance.target,
};

const _$OrderKindEnumMap = {
  OrderKind.hold: 'hold',
  OrderKind.move: 'move',
  OrderKind.evacuate: 'evacuate',
  OrderKind.raid: 'raid',
  OrderKind.ambush: 'ambush',
  OrderKind.rally: 'rally',
};

_OfficerState _$OfficerStateFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    allowedKeys: const [
      'nodeId',
      'troops',
      'morale',
      'loyalty',
      'status',
      'order',
      'skillUsesLeft',
      'nextBattleMultiplier',
      'multiplierEnemySupplyBelow',
      'withdrawn',
    ],
  );
  return _OfficerState(
    nodeId: json['nodeId'] as String,
    troops: (json['troops'] as num).toInt(),
    morale: (json['morale'] as num).toInt(),
    loyalty: (json['loyalty'] as num).toInt(),
    status:
        $enumDecodeNullable(_$OfficerStatusEnumMap, json['status']) ??
        OfficerStatus.active,
    order: json['order'] == null
        ? null
        : Order.fromJson(json['order'] as Map<String, dynamic>),
    skillUsesLeft: (json['skillUsesLeft'] as num?)?.toInt() ?? 0,
    nextBattleMultiplier:
        (json['nextBattleMultiplier'] as num?)?.toDouble() ?? 1.0,
    multiplierEnemySupplyBelow: (json['multiplierEnemySupplyBelow'] as num?)
        ?.toDouble(),
    withdrawn: json['withdrawn'] as bool? ?? false,
  );
}

Map<String, dynamic> _$OfficerStateToJson(_OfficerState instance) =>
    <String, dynamic>{
      'nodeId': instance.nodeId,
      'troops': instance.troops,
      'morale': instance.morale,
      'loyalty': instance.loyalty,
      'status': _$OfficerStatusEnumMap[instance.status]!,
      'order': instance.order?.toJson(),
      'skillUsesLeft': instance.skillUsesLeft,
      'nextBattleMultiplier': instance.nextBattleMultiplier,
      'multiplierEnemySupplyBelow': instance.multiplierEnemySupplyBelow,
      'withdrawn': instance.withdrawn,
    };

const _$OfficerStatusEnumMap = {
  OfficerStatus.active: 'active',
  OfficerStatus.defected: 'defected',
  OfficerStatus.captured: 'captured',
};

_Intent _$IntentFromJson(Map<String, dynamic> json) {
  $checkKeys(json, allowedKeys: const ['kind', 'moveTo', 'targetNodeId']);
  return _Intent(
    kind: $enumDecode(_$IntentKindEnumMap, json['kind']),
    moveTo: json['moveTo'] as String?,
    targetNodeId: json['targetNodeId'] as String?,
  );
}

Map<String, dynamic> _$IntentToJson(_Intent instance) => <String, dynamic>{
  'kind': _$IntentKindEnumMap[instance.kind]!,
  'moveTo': instance.moveTo,
  'targetNodeId': instance.targetNodeId,
};

const _$IntentKindEnumMap = {
  IntentKind.hold: 'hold',
  IntentKind.advance: 'advance',
  IntentKind.assault: 'assault',
  IntentKind.forage: 'forage',
  IntentKind.retreat: 'retreat',
};

_ArmyState _$ArmyStateFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    allowedKeys: const [
      'commanderId',
      'nodeId',
      'troops',
      'supply',
      'maxSupply',
      'morale',
      'retreatNodeId',
      'intent',
      'predictedIntent',
      'status',
    ],
  );
  return _ArmyState(
    commanderId: json['commanderId'] as String,
    nodeId: json['nodeId'] as String,
    troops: (json['troops'] as num).toInt(),
    supply: (json['supply'] as num).toInt(),
    maxSupply: (json['maxSupply'] as num).toInt(),
    morale: (json['morale'] as num).toInt(),
    retreatNodeId: json['retreatNodeId'] as String,
    intent: json['intent'] == null
        ? null
        : Intent.fromJson(json['intent'] as Map<String, dynamic>),
    predictedIntent: json['predictedIntent'] == null
        ? null
        : Intent.fromJson(json['predictedIntent'] as Map<String, dynamic>),
    status:
        $enumDecodeNullable(_$ArmyStatusEnumMap, json['status']) ??
        ArmyStatus.active,
  );
}

Map<String, dynamic> _$ArmyStateToJson(_ArmyState instance) =>
    <String, dynamic>{
      'commanderId': instance.commanderId,
      'nodeId': instance.nodeId,
      'troops': instance.troops,
      'supply': instance.supply,
      'maxSupply': instance.maxSupply,
      'morale': instance.morale,
      'retreatNodeId': instance.retreatNodeId,
      'intent': instance.intent?.toJson(),
      'predictedIntent': instance.predictedIntent?.toJson(),
      'status': _$ArmyStatusEnumMap[instance.status]!,
    };

const _$ArmyStatusEnumMap = {
  ArmyStatus.active: 'active',
  ArmyStatus.routed: 'routed',
};

_Ambush _$AmbushFromJson(Map<String, dynamic> json) {
  $checkKeys(json, allowedKeys: const ['edge', 'officerId']);
  return _Ambush(
    edge: json['edge'] as String,
    officerId: json['officerId'] as String,
  );
}

Map<String, dynamic> _$AmbushToJson(_Ambush instance) => <String, dynamic>{
  'edge': instance.edge,
  'officerId': instance.officerId,
};

_PendingChoice _$PendingChoiceFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    allowedKeys: const [
      'source',
      'sourceId',
      'path',
      'optionCount',
      'bindings',
    ],
  );
  return _PendingChoice(
    source: $enumDecode(_$ChoiceSourceEnumMap, json['source']),
    sourceId: json['sourceId'] as String,
    path: (json['path'] as List<dynamic>)
        .map((e) => (e as num).toInt())
        .toList(),
    optionCount: (json['optionCount'] as num).toInt(),
    bindings:
        (json['bindings'] as Map<String, dynamic>?)?.map(
          (k, e) => MapEntry(k, e as String),
        ) ??
        const <String, String>{},
  );
}

Map<String, dynamic> _$PendingChoiceToJson(_PendingChoice instance) =>
    <String, dynamic>{
      'source': _$ChoiceSourceEnumMap[instance.source]!,
      'sourceId': instance.sourceId,
      'path': instance.path,
      'optionCount': instance.optionCount,
      'bindings': instance.bindings,
    };

const _$ChoiceSourceEnumMap = {
  ChoiceSource.card: 'card',
  ChoiceSource.skill: 'skill',
};

_MissionStats _$MissionStatsFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    allowedKeys: const [
      'troopsLost',
      'defections',
      'captures',
      'battlesWon',
      'battlesLost',
      'evacuations',
      'raids',
      'ambushesTriggered',
      'cardsPlayed',
      'skillsUsed',
      'counterattackNodes',
      'wonOnTurn',
    ],
  );
  return _MissionStats(
    troopsLost: (json['troopsLost'] as num?)?.toInt() ?? 0,
    defections: (json['defections'] as num?)?.toInt() ?? 0,
    captures: (json['captures'] as num?)?.toInt() ?? 0,
    battlesWon: (json['battlesWon'] as num?)?.toInt() ?? 0,
    battlesLost: (json['battlesLost'] as num?)?.toInt() ?? 0,
    evacuations: (json['evacuations'] as num?)?.toInt() ?? 0,
    raids: (json['raids'] as num?)?.toInt() ?? 0,
    ambushesTriggered: (json['ambushesTriggered'] as num?)?.toInt() ?? 0,
    cardsPlayed:
        (json['cardsPlayed'] as Map<String, dynamic>?)?.map(
          (k, e) => MapEntry(k, (e as num).toInt()),
        ) ??
        const <String, int>{},
    skillsUsed:
        (json['skillsUsed'] as Map<String, dynamic>?)?.map(
          (k, e) => MapEntry(k, (e as num).toInt()),
        ) ??
        const <String, int>{},
    counterattackNodes:
        (json['counterattackNodes'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList() ??
        const <String>[],
    wonOnTurn: (json['wonOnTurn'] as num?)?.toInt(),
  );
}

Map<String, dynamic> _$MissionStatsToJson(_MissionStats instance) =>
    <String, dynamic>{
      'troopsLost': instance.troopsLost,
      'defections': instance.defections,
      'captures': instance.captures,
      'battlesWon': instance.battlesWon,
      'battlesLost': instance.battlesLost,
      'evacuations': instance.evacuations,
      'raids': instance.raids,
      'ambushesTriggered': instance.ambushesTriggered,
      'cardsPlayed': instance.cardsPlayed,
      'skillsUsed': instance.skillsUsed,
      'counterattackNodes': instance.counterattackNodes,
      'wonOnTurn': instance.wonOnTurn,
    };

_GameState _$GameStateFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    allowedKeys: const [
      'missionId',
      'seed',
      'rng',
      'turn',
      'phase',
      'outcome',
      'lossReason',
      'rice',
      'support',
      'unity',
      'nodes',
      'officers',
      'armies',
      'ambushes',
      'deck',
      'hand',
      'discard',
      'pendingChoice',
      'scriptedQueue',
      'revealDepth',
      'flags',
      'evacuationsThisTurn',
      'missionStats',
      'stars',
      'log',
    ],
  );
  return _GameState(
    missionId: json['missionId'] as String,
    seed: (json['seed'] as num).toInt(),
    rng: (json['rng'] as num).toInt(),
    turn: (json['turn'] as num).toInt(),
    phase: $enumDecode(_$PhaseEnumMap, json['phase']),
    outcome: $enumDecodeNullable(_$OutcomeEnumMap, json['outcome']),
    lossReason: json['lossReason'] as String?,
    rice: (json['rice'] as num).toInt(),
    support: (json['support'] as num).toInt(),
    unity: Unity.fromJson(json['unity'] as Map<String, dynamic>),
    nodes: (json['nodes'] as Map<String, dynamic>).map(
      (k, e) => MapEntry(k, NodeState.fromJson(e as Map<String, dynamic>)),
    ),
    officers: (json['officers'] as Map<String, dynamic>).map(
      (k, e) => MapEntry(k, OfficerState.fromJson(e as Map<String, dynamic>)),
    ),
    armies: (json['armies'] as Map<String, dynamic>).map(
      (k, e) => MapEntry(k, ArmyState.fromJson(e as Map<String, dynamic>)),
    ),
    ambushes:
        (json['ambushes'] as List<dynamic>?)
            ?.map((e) => Ambush.fromJson(e as Map<String, dynamic>))
            .toList() ??
        const <Ambush>[],
    deck:
        (json['deck'] as List<dynamic>?)?.map((e) => e as String).toList() ??
        const <String>[],
    hand:
        (json['hand'] as List<dynamic>?)?.map((e) => e as String).toList() ??
        const <String>[],
    discard:
        (json['discard'] as List<dynamic>?)?.map((e) => e as String).toList() ??
        const <String>[],
    pendingChoice: json['pendingChoice'] == null
        ? null
        : PendingChoice.fromJson(json['pendingChoice'] as Map<String, dynamic>),
    scriptedQueue:
        (json['scriptedQueue'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList() ??
        const <String>[],
    revealDepth: (json['revealDepth'] as num?)?.toInt() ?? 1,
    flags:
        (json['flags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
        const <String>[],
    evacuationsThisTurn: (json['evacuationsThisTurn'] as num?)?.toInt() ?? 0,
    missionStats: json['missionStats'] == null
        ? const MissionStats()
        : MissionStats.fromJson(json['missionStats'] as Map<String, dynamic>),
    stars:
        (json['stars'] as List<dynamic>?)?.map((e) => e as bool).toList() ??
        const <bool>[],
    log:
        (json['log'] as List<dynamic>?)
            ?.map((e) => GameAction.fromJson(e as Map<String, dynamic>))
            .toList() ??
        const <GameAction>[],
  );
}

Map<String, dynamic> _$GameStateToJson(_GameState instance) =>
    <String, dynamic>{
      'missionId': instance.missionId,
      'seed': instance.seed,
      'rng': instance.rng,
      'turn': instance.turn,
      'phase': _$PhaseEnumMap[instance.phase]!,
      'outcome': _$OutcomeEnumMap[instance.outcome],
      'lossReason': instance.lossReason,
      'rice': instance.rice,
      'support': instance.support,
      'unity': instance.unity.toJson(),
      'nodes': instance.nodes.map((k, e) => MapEntry(k, e.toJson())),
      'officers': instance.officers.map((k, e) => MapEntry(k, e.toJson())),
      'armies': instance.armies.map((k, e) => MapEntry(k, e.toJson())),
      'ambushes': instance.ambushes.map((e) => e.toJson()).toList(),
      'deck': instance.deck,
      'hand': instance.hand,
      'discard': instance.discard,
      'pendingChoice': instance.pendingChoice?.toJson(),
      'scriptedQueue': instance.scriptedQueue,
      'revealDepth': instance.revealDepth,
      'flags': instance.flags,
      'evacuationsThisTurn': instance.evacuationsThisTurn,
      'missionStats': instance.missionStats.toJson(),
      'stars': instance.stars,
      'log': instance.log.map((e) => e.toJson()).toList(),
    };

const _$PhaseEnumMap = {
  Phase.intel: 'intel',
  Phase.council: 'council',
  Phase.orders: 'orders',
  Phase.resolution: 'resolution',
  Phase.upkeep: 'upkeep',
  Phase.ended: 'ended',
};

const _$OutcomeEnumMap = {Outcome.won: 'won', Outcome.lost: 'lost'};
