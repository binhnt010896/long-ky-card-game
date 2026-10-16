# Long Ký - The Game

Single-player, offline, turn-based card strategy game about the Trần dynasty vs the Mongol–Yuan invasions.
Targets: Android, iOS, macOS, Windows. No web. No Linux.

## Source of truth
- docs/build-spec.md (implementation) and docs/plan.md (design intent). Build spec wins on implementation.
- Work tickets in order from build-spec section 9. One ticket per branch and PR.

## Hard rules
- packages/lk_rules is pure Dart: no Flutter, no dart:io, no DateTime.now(), no global state.
- All randomness goes through SeededRng in lk_rules. Same seed + same actions = same game.
- Never add networking, accounts, analytics or ads. The game must stay fully offline (Vietnam G4 status).
- All game content is JSON in apps/game/assets/content, parsed by packages/lk_content. Never hard-code officers, cards, missions or text in code.
- Every content item must have a sourceRef. Do not invent historical facts; leave a TODO and flag it in the PR.
- Card frames must never look like playing cards (no suits, ranks, or corner indices).
- All player-facing text goes through localization (vi and en). Vietnamese is the primary language.

## Commands
- melos bootstrap
- melos run analyze
- melos run test
- dart run tools/sim/bin/sim.dart --mission ch1_m2 --games 1000
- dart run packages/lk_content/bin/validate.dart

## Done means
- analyze has zero warnings, all tests pass, content validates.
- New rules logic has unit tests; new UI has at least one widget test.
- The PR description lists what was verified and on which platforms.
