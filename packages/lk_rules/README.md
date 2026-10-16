# lk_rules

Pure Dart rules engine for Long Ký - The Game: game state, actions, the reducer
(`GameEngine.apply`), the Yuan AI and the seeded RNG.

Rules for this package (build-spec section 10):

- No Flutter, no `dart:io`, no clock, no global state.
- All randomness goes through `SeededRng`. Same seed + same actions = same game.
- Balance numbers live in `lib/src/balance.dart` or in content JSON.

Regenerate freezed / json_serializable code with `melos run generate`.
