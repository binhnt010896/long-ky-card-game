# Long Ký - The Game

The first game in the Long Ký universe: a single-player, offline, turn-based card strategy game about the Trần dynasty's defence of Đại Việt against the Mongol–Yuan invasions. Real people and events; our own art.

Platforms: Android, iOS, macOS, Windows. No web.

- Design plan: [docs/plan.md](docs/plan.md)
- Build spec and ticket backlog for the coding agent: [docs/build-spec.md](docs/build-spec.md)
- Rules for the coding agent: [CLAUDE.md](CLAUDE.md)

## Toolchain (pinned)

| Tool | Version |
| --- | --- |
| Flutter | 3.47.7 (stable) |
| Dart | 3.13.5 (bundled with Flutter) |
| Melos | 8.9.0 |

CI (`.github/workflows/ci.yml`, `build.yml`) uses the same Flutter version.

## Layout

```
packages/lk_rules     pure Dart rules engine (state, reducer, Yuan AI, seeded RNG)
packages/lk_content   content parser, validator (bin/validate.dart) and text export (bin/export_text.dart)
apps/game             Flutter app; all content JSON in apps/game/assets/content
tools/sim             headless balance simulator and text-mode player
```

## Commands

```bash
dart pub global activate melos 8.9.0   # once; puts `melos` in ~/.pub-cache/bin
melos bootstrap
melos run analyze
melos run test
melos run generate                     # regenerate freezed / json_serializable code
dart run packages/lk_content/bin/validate.dart
dart run packages/lk_content/bin/export_text.dart   # every vi/en text + sourceRefs as CSV, for the history reviewer
dart run tools/sim/bin/sim.dart --mission ch1_m2 --games 1000
dart run tools/sim/bin/sim.dart --play --mission ch1_m2
```

Status: T-01 to T-26 are on `main`. T-27 is prepared (names, signing hooks, icons, release workflow, store notes) but needs the owner's signing keys and store accounts: see `docs/release/RELEASE.md`.
