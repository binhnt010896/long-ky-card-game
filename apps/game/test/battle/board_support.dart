import 'dart:ui';

import 'package:lk_content/io.dart';
import 'package:lk_content/lk_content.dart';
import 'package:lk_rules/lk_rules.dart';
import 'package:long_ky_game/features/battle/board/board_scene.dart';

/// The real Chapter 1 content, loaded once.
final ContentBundle content = loadContent(readContentDir(findContentDir()!));

/// Phone in landscape (compact, < 900 wide) and a desktop window (regular).
const Size compact = Size(790, 390);
const Size regular = Size(1600, 900);

Ruleset ruleset(String missionId) => content.ruleset(missionId);

GameState startState(String missionId, {int seed = 1}) => GameEngine(ruleset(missionId)).newGame(seed).state;

BoardScene sceneFor(String missionId, Size size, {String lang = 'vi', GameState? state, Selection? selection}) =>
    BoardScene.build(
      ruleset: ruleset(missionId),
      state: state ?? startState(missionId),
      size: size,
      languageCode: lang,
      selection: selection,
    );

/// Ends the current turn from Council or Orders.
StepResult endTurn(GameEngine e, GameState s) {
  final r = e.apply(s, const GameAction.endPhase());
  if (r.state.phase == Phase.orders) return e.apply(r.state, const GameAction.endPhase());
  return r;
}
