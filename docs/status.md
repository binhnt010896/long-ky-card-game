# Status and next steps (handoff)

Last updated 2026-10-17. Source of truth stays `docs/build-spec.md` (implementation) and `docs/plan.md` (design intent); rules in `CLAUDE.md`.

## Done: T-01 to T-29, all on `main`

| Tickets | What | Where to look |
| --- | --- | --- |
| T-01 to T-14 | Workspace, rules engine, content validator, Chapter 1 content, simulator, app shell | `packages/`, `tools/sim`, `apps/game` |
| T-15 to T-17 | Flame board, battle overlays at both layouts, orders/cards/preview/choice/animations | `apps/game/lib/features/battle` |
| T-18 | Autosave and resume, Result screen, stars | `lib/data/battle_save_*`, `battle_page.dart` |
| T-19 | Desktop window, shortcuts, hover tooltips, landscape lock, safe areas | `lib/platform`, `battle_keys.dart` |
| T-20 | Audio behind `AudioBackend`, Briefing with subtitles | `lib/audio`, `features/briefing` |
| T-21 | Art by id with placeholders, lacquer card frame, goldens | `lib/art`, `features/cards` |
| T-22 | Coach marks for missions 1–2, tips for 3–5 | `features/tutorial` |
| T-23 | Campaign and chapter screens, unlock flow, Next mission | `features/campaign`, `data/campaign.dart` |
| T-24 | Codex, Long Ký links (phone link / desktop QR), unlock codes, incoming unlock link | `features/codex`, `data/unlock_code.dart`, `config/long_ky_config.dart` |
| T-25 | Balance pass; every Chapter 1 target met | `docs/balance/t25-report.md` |
| T-26 | CSV of all 75 vi/en texts for the history reviewer | `docs/review/` |
| T-27 | Prepared only (see "Needs the owner") | `docs/release/RELEASE.md`, `docs/store/`, `.github/workflows/release.yml` |
| T-28 | Performance measured here; device checklist written, not run | `docs/qa/checklist.md` |
| T-29 | Offline guard test and privacy answers | `apps/game/test/offline_guard_test.dart`, `docs/store/privacy.md` |

State at last push: analyze clean; tests app 528, `lk_rules` 156, `lk_content` 37, sim 46, all passing; content validates (0 errors, 30 art/audio warnings, expected until assets ship). The `build` workflow succeeded for Android, iOS, macOS and Windows on the T-28 commit.

Commands: see `README.md`. Flutter 3.47.7 (needs `/opt/fl/flutter/bin` on PATH in the cloud container). Commit messages end with the attribution lines; no force-push.

## Update 2026-10-17: feedback from phone testing

- **Board zoom and pan** (`features/battle/board`): pinch, drag (once zoomed), mouse wheel, double tap, and +, − and "whole map" buttons. Medallions and tokens grow with the zoom (capped) so officers standing together can be tapped one by one. `BoardLayout` takes `zoom` and `pan`; the scene and the inspector use the zoomed layout.
- **Thinner borders** on the board (nodes, tokens, edges, arrows, selection).
- **Text size:** the setting now runs 80–150% (it was 100–150%). On a phone the battle HUD caps its text at 120% (`compactMaxTextScale`), because the officer strip and buttons are cut off beyond that. Default buttons are 16 px.
- **Art on the board:** the map (`maps/ch1.png`, named by the new optional `image` field in `maps/ch1.json`, `MapDef.imagePath`) and the officer and commander portraits (`portraitArt` in the content) are drawn when shipped, with the old vector placeholders otherwise. **The repo still holds no art or audio files** (only `.gitkeep`), so nothing painted can show yet. Paths: `docs/review/` and `dart run packages/lk_content/bin/validate.dart --release` list every file expected.
- Test phone: an earlier test left the app's text size at 150% on the owner's phone; set it back to 100% (Settings, Text size).

## Update 2026-10-17 (later): painted art and a new look

The game had no graphics at all; it now has painted art everywhere.

- **Art sources and prompts:** `docs/art/README.md`. Seven portraits, the title cover, the dragon splash, the logo and the mission 2 and 4 paintings come from the owner's **viet-su** project (`tools/art/import_viet_su.sh`). The **painted Chapter 1 map**, the **six card illustrations** and the mission 1, 3 and 5 backdrops were **generated with Higgsfield** (`nano_banana_pro`, viet-su style lock; mission 1 and 5 were redone to remove writing on a plaque and a banner). **All AI-made pictures are drafts: they need a human paint-over and a history review before release** (plan.md, "Art pipeline").
- **Content:** missions now have an `art` field (`MissionDef.art`); `maps/ch1.json` points at `maps/ch1.jpg` and its nine node positions were fitted by eye to the painted map; officer and card art are `.jpg`. Saved battles from before this change restart (content hash changed).
- **Look:** painted title screen with logo, painted backdrops on campaign, briefing, result, settings and codex, mission tiles with thumbnails, gold-edged lacquer buttons and panels (`lib/app/lacquer.dart`), officer portraits in the strip, on tokens and in the briefing, painted map (with a dimmed copy behind it) on the board, card art in the frames.
- Still missing: narration, music and effects (10 audio files; the validator warns), a human paint-over, and per-person art for any new officer.

## Update 2026-10-17 (latest): training mission and vivid links

- Map links (rivers, roads) are drawn bold with a dark halo so they stay visible over the painted map.
- New chapter 0 mission `ch0_training` (27 steps): a guided lesson that walks through the goal, top bar, map and zoom, selecting armies and officers, skills, hand and cards, Council/Orders phases, holding, the log, winning and losing conditions, and counter-cards. Steps wait for the player to do the action (`until` conditions, a closed list parsed in `lk_rules/model/tutorial.dart`, evaluated by `GuidedFlow` in the app).
- Chapter 0 is always open, not part of the unlock chain, and is offered once to new players (`tutorialDone` marker).
- Verified in tests only (analyze clean; full workspace tests pass). Not yet checked on the phone, which was locked.

## Update 2026-10-17 (latest 2): battle polish

- **Objectives:** a flag button in the battle top bar and a "View objectives" entry in the pause menu open how to win, how to lose (king captured, a Unity pillar at 0, season ends, mission rules) and the bonus stars.
- **Review before the result:** when the mission ends the board stays; a banner (won/lost) has "See the result", and the Result screen has "Review the battlefield" to go back.
- **Wider map:** `maps/ch1-wide.jpg` is the Chapter 1 painting outpainted to 21:9 (Higgsfield `outpaint`); the painter draws it centred on the node map and fades its wings into the darkened copy, so the map reaches the screen edges. Nodes did not move. A map without a `-wide` file falls back to the framed rectangle.
- **Buttons:** filled buttons are gold leaf, outlined are lacquer, both with painted textures (`ui/btn-gold.jpg`, `ui/btn-lacquer.jpg`, Higgsfield) under a bevel and inlay line (`longKyButtonFace` in `app/theme.dart`).
- **Strategy cutscene:** playing a strategy shows its painting, name and effect under a brush streak and embers for 2.4 s (`strategy_cutscene.dart`); it takes no taps and is skipped with Reduce motion. No sound effects were made: the ElevenLabs connector here cannot save audio files into the repo.
- Checked on the phone: wide map, buttons, hand button, cutscene. Not on the phone: objectives dialog and the review banner (covered by widget tests).

## Needs the owner (the agent cannot do these)

1. **T-24 inputs:** Long Ký deep-link template (`LONG_KY_LINK_TEMPLATE`, with `{id}` and optional `{kind}`), Long Ký store URL (`LONG_KY_STORE_URL`), the unlock secret (`LK_UNLOCK_SECRET`, same one Long Ký uses). Without them "Read more" is hidden and every code is refused. Long Ký must open `longkygame://unlock?code=LK-XXXX-XXXX` (the scheme is the game's own choice; confirm it).
2. **T-27:** Android upload keystore and Play service account, Apple signing for iOS/macOS and TestFlight, Windows distribution channel, the painted icon (`tools/icons/master.png`, then `python3 tools/icons/make_icons.py --master …`). Add the secrets listed in `docs/release/RELEASE.md`, then run `release.yml` once with `android_track: none`. It has never been run.
3. **T-28:** the device passes in `docs/qa/checklist.md` (Android phone, iPhone/iPad, Mac, Windows PC) including real 60 fps on the busiest missions, the T-16 phone check, and the T-29 per-platform "no network call" checks.
4. **Art and audio:** painted Chapter 1 map and node positions, card and officer art, narration, character lines, music, effects. Until then placeholders and silence ship. Validator warnings go to errors under `--release`.
5. **History reviewer:** read `docs/review/content-text.csv`; briefings and debriefs are placeholders; map-place rows have no `sourceRefs`; several `todo` notes (en text drafted from vi). Lore text and a bonus card per unlock do not exist in the content yet.
6. **Store:** screenshots, privacy-policy URL, support contact, price, final age-rating answers (`docs/store/`).

## Decisions to make

- `ch1_m4` is lost on troops (more than 14,000 lost) because a survive-only mission cannot be lost otherwise (one army never captures the king). Alternative: a rules change (e.g. an officer at 0 troops is captured). Details in `docs/balance/t25-report.md`.
- T-25 changed spec numbers (m2 win adds `surviveTurns 4` and troops ≤ 16,000; m3 troops 60%; m4 troops 80%, Yuan morale 10, star 2 `noCaptures`; m5 Yuan 30 troops, morale 9, heat from turn 6). Confirm or ask for different levers.
- The expert wins 100% because it is a scripted deterministic player; a human playtest is needed for real difficulty and stars.
- `http` is in the shipped tree through `audioplayers` (not called). To close it on iOS too, replace the audio backend behind `AudioBackend`.

## Known gaps in the app (candidates for the next session)

- Settings is not reachable from the battle menu (Resume/Leave only).
- Orders are picked from a list; no tap-a-node mode and no orders drawn on the map.
- At zoom 1 on a phone the Bình Lệ Nguyên cluster is still tight (four neighbours, three officers, an arrow); node positions are placeholders until the painted map. Preview only covers where the ordered officer fights.
- Chapter names are not in the content (UI says "Chương n" / "Chapter n").
- Windows has no incoming unlock link or installer; desktop uses typed codes and the QR.
- Briefing text for `ch1_m2` and others should mention the new win/loss rules once the narration is rewritten.
- Strategy "expert" is brittle: results flip between 0% and 100% for small parameter changes. Rerun `dart run tools/sim/bin/sim.dart --mission all --strategy all --games 1000 --seed 1` (and `melos run test`, which has `balance_test.dart`) after any content or rules change.

## Suggested order for the next session

1. Supply the T-24 inputs, then verify codes and links end to end with Long Ký.
2. Do the device QA pass and fix what it finds (start with phone landscape and safe areas).
3. Decide the `ch1_m4` loss approach and the Windows channel.
4. Drop in art and audio as it arrives; run the validator with `--release`.
5. Run `release.yml` for Android, do TestFlight by hand, build the Windows package.
6. Chapter 2 content once the above is stable (not in the current spec).
