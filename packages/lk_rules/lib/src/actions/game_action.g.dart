// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_action.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlayCard _$PlayCardFromJson(Map<String, dynamic> json) {
  $checkKeys(json, allowedKeys: const ['cardId', 'target', 'type']);
  return PlayCard(
    cardId: json['cardId'] as String,
    target: json['target'] as String?,
    $type: json['type'] as String?,
  );
}

Map<String, dynamic> _$PlayCardToJson(PlayCard instance) => <String, dynamic>{
  'cardId': instance.cardId,
  'target': instance.target,
  'type': instance.$type,
};

UseSkill _$UseSkillFromJson(Map<String, dynamic> json) {
  $checkKeys(json, allowedKeys: const ['officerId', 'target', 'type']);
  return UseSkill(
    officerId: json['officerId'] as String,
    target: json['target'] as String?,
    $type: json['type'] as String?,
  );
}

Map<String, dynamic> _$UseSkillToJson(UseSkill instance) => <String, dynamic>{
  'officerId': instance.officerId,
  'target': instance.target,
  'type': instance.$type,
};

ResolveChoice _$ResolveChoiceFromJson(Map<String, dynamic> json) {
  $checkKeys(json, allowedKeys: const ['index', 'type']);
  return ResolveChoice(
    index: (json['index'] as num).toInt(),
    $type: json['type'] as String?,
  );
}

Map<String, dynamic> _$ResolveChoiceToJson(ResolveChoice instance) =>
    <String, dynamic>{'index': instance.index, 'type': instance.$type};

SetOrder _$SetOrderFromJson(Map<String, dynamic> json) {
  $checkKeys(json, allowedKeys: const ['officerId', 'order', 'type']);
  return SetOrder(
    officerId: json['officerId'] as String,
    order: Order.fromJson(json['order'] as Map<String, dynamic>),
    $type: json['type'] as String?,
  );
}

Map<String, dynamic> _$SetOrderToJson(SetOrder instance) => <String, dynamic>{
  'officerId': instance.officerId,
  'order': instance.order.toJson(),
  'type': instance.$type,
};

ClearOrder _$ClearOrderFromJson(Map<String, dynamic> json) {
  $checkKeys(json, allowedKeys: const ['officerId', 'type']);
  return ClearOrder(
    officerId: json['officerId'] as String,
    $type: json['type'] as String?,
  );
}

Map<String, dynamic> _$ClearOrderToJson(ClearOrder instance) =>
    <String, dynamic>{'officerId': instance.officerId, 'type': instance.$type};

EndPhase _$EndPhaseFromJson(Map<String, dynamic> json) {
  $checkKeys(json, allowedKeys: const ['type']);
  return EndPhase($type: json['type'] as String?);
}

Map<String, dynamic> _$EndPhaseToJson(EndPhase instance) => <String, dynamic>{
  'type': instance.$type,
};
