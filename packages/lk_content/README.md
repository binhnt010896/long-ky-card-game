# lk_content

Parses the game content JSON (`apps/game/assets/content/`) into `lk_rules`
definitions and validates it.

```bash
dart run packages/lk_content/bin/validate.dart            # warnings for missing art/audio
dart run packages/lk_content/bin/validate.dart --release  # missing art/audio is an error
```
