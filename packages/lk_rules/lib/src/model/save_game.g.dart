// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'save_game.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SaveGame _$SaveGameFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    allowedKeys: const [
      'saveVersion',
      'missionId',
      'contentHash',
      'seed',
      'actions',
    ],
  );
  return _SaveGame(
    saveVersion:
        (json['saveVersion'] as num?)?.toInt() ?? SaveGame.currentVersion,
    missionId: json['missionId'] as String,
    contentHash: json['contentHash'] as String,
    seed: (json['seed'] as num).toInt(),
    actions: (json['actions'] as List<dynamic>)
        .map((e) => GameAction.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

Map<String, dynamic> _$SaveGameToJson(_SaveGame instance) => <String, dynamic>{
  'saveVersion': instance.saveVersion,
  'missionId': instance.missionId,
  'contentHash': instance.contentHash,
  'seed': instance.seed,
  'actions': instance.actions.map((e) => e.toJson()).toList(),
};
