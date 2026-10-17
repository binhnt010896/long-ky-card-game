import 'package:freezed_annotation/freezed_annotation.dart';

import '../model/game_state.dart';

part 'game_action.freezed.dart';
part 'game_action.g.dart';

/// Everything the player can do (build-spec section 4). Serialized into the
/// save file's action log.
@Freezed(unionKey: 'type')
sealed class GameAction with _$GameAction {
  /// Council: pay the cost, check conditions, apply effects, discard.
  /// [target] is a node id, edge key, officer id or army id.
  const factory GameAction.playCard({required String cardId, String? target}) = PlayCard;

  /// Council: an activated skill.
  const factory GameAction.useSkill({required String officerId, String? target}) = UseSkill;

  /// Whenever a choice is pending; nothing else is legal until then.
  const factory GameAction.resolveChoice({required int index}) = ResolveChoice;

  /// Orders: one order per active officer.
  const factory GameAction.setOrder({required String officerId, required Order order}) = SetOrder;

  const factory GameAction.clearOrder({required String officerId}) = ClearOrder;

  /// Council → Orders. Orders → Resolution, Upkeep, next Intel, Council.
  const factory GameAction.endPhase() = EndPhase;

  /// After the mission has ended (won or lost): keep playing until either
  /// side has no troops left. The mission's result and stars stand.
  const factory GameAction.continueFreePlay() = ContinueFreePlay;

  factory GameAction.fromJson(Map<String, Object?> json) => _$GameActionFromJson(json);
}
