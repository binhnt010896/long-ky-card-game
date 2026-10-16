# Platform QA checklist and performance (T-28)

Sources: build-spec section 6 (screens, layouts, shortcuts), section 7 ("Performance: a full engine step under 5 ms on a mid-range phone; the board at 60 fps"), section 9 (T-28).

**Status: the device passes have not been done.** This was prepared in a cloud container that has no phone, tablet, Mac, Windows PC, simulator or emulator. Everything marked *auto* is covered by a test that runs in `melos run test` (Linux only); everything marked *device* has to be done by a person on that platform, and each line has a box for the result. Do not read an empty box as a pass.

## Measured here (Linux container, desktop-class CPU, `nproc` = 4)

| Measure | Result | Limit (spec) | Where |
| --- | --- | --- | --- |
| Engine step, all 5 missions × 4 strategies, JIT | mean 5–16 µs, p99 ≤ 0.2 ms (Resolution step p99 ≤ 0.6 ms), slowest single step 3.6 ms (a GC outlier) | < 5 ms on a mid-range phone | `dart run tools/sim/bin/sim.dart --bench --mission all`; `tools/sim/test/bench_test.dart` asserts p99 < 1 ms (< 2 ms for Resolution) |
| Board: recording one frame of drawing commands, compact and regular | 0.13–0.26 ms | 16.7 ms a frame for 60 fps | `apps/game/test/performance_test.dart` asserts < 4 ms |
| Board: rebuilding the scene after a step | 0.10–0.32 ms | (part of the same frame budget) | same file |

A phone core is several times slower than this CPU and runs AOT code rather than the JIT, so the margin (about 25× on the p99 of an engine step) should hold, but **that is an inference, not a measurement**. GPU raster time is not measured at all.

## Device checklist (do once per platform: Android phone, iPhone/iPad, Mac, Windows)

Mark each line P (pass), F (fail, with a note) or N/A.

| # | Check | Android | iOS | macOS | Windows | Covered by |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | Installs and starts to the title screen, product name "Long Ký - The Game" | ☐ | ☐ | ☐ | ☐ | device |
| 2 | Landscape only; rotating the phone does not rotate the UI; auto-rotate setting left as found | ☐ | ☐ | n/a | n/a | manifest/plist: `desktop_mobile_test.dart` (auto); device |
| 3 | Window opens 1600×900, cannot be resized below 1280×720 | n/a | n/a | ☐ | ☐ | `desktop_mobile_test.dart` (settings only); device |
| 4 | Notch, rounded corners, home indicator: no clipped button or text (battle, Result, Settings, Codex) | ☐ | ☐ | n/a | n/a | `battle/safe_area_test.dart` (auto, simulated notch); device |
| 5 | Compact layout on a phone, regular layout on a tablet/desktop; resizing a desktop window across 900 px switches layout live | ☐ | ☐ | ☐ | ☐ | every overlay test at both sizes (auto); device |
| 6 | Touch targets: every button easy to hit with a thumb (≥ 48 px) | ☐ | ☐ | n/a | n/a | tests assert ≥ 48 px (auto); device |
| 7 | Text size 150% in Settings: nothing overflows on the title, Settings, Campaign, Briefing, battle, Result, Codex | ☐ | ☐ | ☐ | ☐ | `battle_screen_test.dart`, `result_screen_test.dart` at 150% (auto, partial); device |
| 8 | Vietnamese diacritics render correctly everywhere (no tofu boxes); English too | ☐ | ☐ | ☐ | ☐ | `font_coverage_test.dart` (auto); device |
| 9 | Language switch is live on every screen | ☐ | ☐ | ☐ | ☐ | `app_shell_test.dart` (auto) |
| 10 | Play `ch1_m1` to a win with taps/clicks; play `ch1_m2` with the winning line (fall back to Sông Lô, hold four turns) | ☐ | ☐ | ☐ | ☐ | `battle_play_test.dart` (auto, touch and mouse); device |
| 11 | Win a mission: Next opens the next briefing; the next mission is unlocked in Campaign; stars are kept after a restart | ☐ | ☐ | ☐ | ☐ | `campaign_test.dart`, `battle_page_test.dart` (auto) |
| 12 | Kill the app mid-turn, reopen, Continue: same state | ☐ | ☐ | ☐ | ☐ | `battle_save_test.dart`, `battle_page_test.dart` (auto); device (real kill) |
| 13 | Reduce motion: battle animations are skipped | ☐ | ☐ | ☐ | ☐ | `battle_play_test.dart` (auto) |
| 14 | Desktop only: Space/Enter end the phase, Esc menu, 1–9 open a card, Tab cycles officers, right click cancels, hover tooltips | n/a | n/a | ☐ | ☐ | `battle/shortcuts_test.dart` (auto); device |
| 15 | Coach marks on missions 1 and 2, once; Skip works; they do not come back after a restart | ☐ | ☐ | ☐ | ☐ | `battle/tutorial_test.dart` (auto) |
| 16 | Audio: no files ship yet, so the game is silent and does not fail; when files are added, narration, music and effects follow the volume sliders and the pause on backgrounding | ☐ | ☐ | ☐ | ☐ | `audio_test.dart` (backend faked); device once files exist |
| 17 | Codex: every page opens; a valid unlock code unlocks it; a wrong one is refused (needs a build with `LK_UNLOCK_SECRET`) | ☐ | ☐ | ☐ | ☐ | `codex_test.dart` (auto) |
| 18 | Read more in Long Ký: phone opens the link or the store page; desktop shows the QR code and a phone scans it to the same link (needs the link template) | ☐ | ☐ | ☐ | ☐ | `codex_test.dart` (auto, launcher faked); device |
| 19 | Unlock link `longkygame://unlock?code=…` opens the game and unlocks (phones only) | ☐ | ☐ | n/a | n/a | `codex_test.dart` (parsing, listener); device |
| 20 | No network: airplane mode / firewall block, the whole game still works; no request leaves the app (see `docs/store/privacy.md`) | ☐ | ☐ | ☐ | ☐ | `offline_guard_test.dart` (static); device |
| 21 | Performance: board feels smooth (60 fps) in the busiest mission (`ch1_m3`, `ch1_m4`) at both layouts; `flutter run --profile` + the performance overlay shows no red frames while ending a turn | ☐ | ☐ | ☐ | ☐ | device (the tests above only time the Dart side) |
| 22 | Accessibility: TalkBack / VoiceOver reads the title buttons, phase button, officers, stars, objectives | ☐ | ☐ | n/a | n/a | semantics labels exist; device |
| 23 | Battery/thermal: 15 minutes of play does not heat a phone noticeably | ☐ | ☐ | n/a | n/a | device |
| 24 | Reset progress in Settings: stars, unlocks and tutorials are cleared, settings kept | ☐ | ☐ | ☐ | ☐ | `app_shell_test.dart` (auto) |

## Known gaps found while preparing this (not device findings)

- Settings is not reachable from the battle menu (Resume and Leave only).
- Orders are chosen from a list of legal orders for the selected officer; there is no "tap a node on the map" mode, and orders are not drawn on the map.
- The painted Chapter 1 map, painted card art, the narration and music files, and the final icon are not delivered: placeholders and silence are what ships.
- The Result screen has "Retry" and "Back"; "Read more" shows only when the build has a link template.
