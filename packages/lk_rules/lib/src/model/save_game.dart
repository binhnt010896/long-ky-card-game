import 'package:freezed_annotation/freezed_annotation.dart';

import '../actions/game_action.dart';

part 'save_game.freezed.dart';
part 'save_game.g.dart';

/// The battle save file (build-spec section 4). Loading replays [actions]
/// from the mission start; if [contentHash] differs from the installed
/// content, the app offers a restart instead of replaying.
@freezed
abstract class SaveGame with _$SaveGame {
  const factory SaveGame({
    @Default(SaveGame.currentVersion) int saveVersion,
    required String missionId,
    required String contentHash,
    required int seed,
    required List<GameAction> actions,
  }) = _SaveGame;

  factory SaveGame.fromJson(Map<String, Object?> json) => _$SaveGameFromJson(json);

  static const int currentVersion = 1;
}
