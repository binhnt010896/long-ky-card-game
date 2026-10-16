/// Pure Dart rules engine for Long Ký - The Game.
///
/// No Flutter, no `dart:io`, no clock, no global state. All randomness goes
/// through [SeededRng]; the same seed and actions always give the same game.
library;

export 'src/actions/game_action.dart';
export 'src/balance.dart';
export 'src/engine/state_hash.dart';
export 'src/model/defs.dart';
export 'src/model/enums.dart';
export 'src/model/game_state.dart';
export 'src/model/save_game.dart';
export 'src/rng/seeded_rng.dart';
