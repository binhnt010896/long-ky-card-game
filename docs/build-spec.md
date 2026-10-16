# Long Ký - The Game — Build spec

> Exported from the Claude Doc "Long Ký - The Game — Plan" (build spec). The doc is the living version; re-export this file after changing it.

This document is the instruction set for the coding agent. Read it with docs/plan.md; where they differ, this document wins on implementation and docs/plan.md wins on design intent. Work through the ticket backlog in order.

## 1. Agent setup

Run the coding agent on Fable at `high` effort, raising to `xhigh` for the rules engine, Yuan AI and balance tickets. If Fable is not on your plan, use Opus 5.5 with the same effort levels.

| Setting | Value | Why ([Claude Code model config](https://code.claude.com/docs/en/model-config.md)) |
| --- | --- | --- |
| Model | `/model fable`; fallback `/model opus` | Fable is documented for the hardest and longest-running tasks; Opus is documented for complex reasoning. Some plans bill Fable to usage credits |
| Effort (default) | `high` | Documented for work where verification matters or edge cases are likely |
| Effort (tickets marked xhigh in section 9) | `xhigh` | Deeper reasoning for the reducer, combat, AI and simulator |
| Effort to avoid | `max` | Documented as prone to overthinking with diminishing returns |

**How to run it**

1. One ticket (section 9) per session. Start each session in plan mode, approve the plan, then let it build.
2. Give it the outcome and acceptance criteria of the ticket, not step-by-step instructions.
3. One branch and one pull request per ticket; you review and merge.
4. Commit this whole spec into the repo first (T-00), so every session can read it.

**CLAUDE.md (put at the repo root in T-00)**

```markdown
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
```

## 2. Bootstrap and repo layout

The repo is a Dart pub workspace managed with Melos 8, which uses pub workspaces and keeps its config in the root `pubspec.yaml` ([Melos docs](https://pub.dev/documentation/melos/8.9.0/)). Melos 8 needs Dart SDK 3.9 or newer.

**Layout**

```
long-ky-card-game/
  pubspec.yaml                 workspace root + melos scripts
  CLAUDE.md
  docs/plan.md                 the design plan
  docs/build-spec.md           this document, exported
  packages/
    lk_rules/                  pure Dart: model, reducer, AI, RNG
      lib/src/model/           GameState, OfficerState, ArmyState, NodeState...
      lib/src/actions/         GameAction sealed classes
      lib/src/engine/          reducer, phases, combat, forage, unity, loyalty
      lib/src/ai/              Yuan intent selection
      lib/src/effects/         card effect ops
      test/
    lk_content/                pure Dart: content models, parser, validator
      lib/                     parse JSON maps into lk_rules definitions
      bin/validate.dart        CLI: validates apps/game/assets/content
      test/
  apps/
    game/                      Flutter app (android, ios, macos, windows)
      assets/content/          ALL content JSON (single source of truth)
      assets/images/           art, by id
      assets/audio/            voice, music, sfx, by id
      lib/
        main.dart
        app/                   routing, theme, l10n setup
        features/menu/
        features/campaign/     chapter and mission select
        features/battle/       Flame board + Flutter overlays
        features/codex/        officer and event lore
        features/settings/
        data/                  save repository, unlock codes
      l10n/app_vi.arb, app_en.arb
  tools/
    sim/bin/sim.dart           headless balance simulator
```

**Create commands (T-01)**

```bash
flutter create --platforms=android,ios,macos,windows --org <bundle prefix> --project-name long_ky_game apps/game
dart create -t package packages/lk_rules
dart create -t package packages/lk_content
dart create -t console tools/sim
```

The `--platforms` flag limits which platform folders are generated ([Flutter desktop docs](https://docs.flutter.dev/platform-integration/desktop)). Replace `<bundle prefix>` with the same reverse-domain prefix the Long Ký app uses (open question for you).

**Packages**

At T-01, check each on pub.dev, take the latest stable version, and pin it. Flame was at v1.37.0 in April 2026 ([depscope](https://depscope.dev/pkg/pub/flame)) and supports Flutter 3.47 ([Flame PR #3995](https://github.com/flame-engine/flame/pull/3995)).

| Package | Where | Purpose |
| --- | --- | --- |
| `freezed`, `freezed_annotation` | lk\_rules, lk\_content | Immutable state with `copyWith` and equality |
| `json_annotation`, `json_serializable`, `build_runner` | lk\_rules, lk\_content | JSON for content and save files |
| `test` | lk\_rules, lk\_content, sim | Unit tests |
| `flame` | game | Map board, tokens, animations |
| `flame_audio` | game | Music and voice playback |
| `flutter_bloc` | game | One `BattleCubit` wrapping the engine |
| `path_provider` | game | Save file location |
| `flutter_localizations`, `intl` | game | vi and en (gen-l10n) |
| `app_links` | game | Incoming unlock deep links on mobile |
| `url_launcher` | game | Opening Long Ký or its store page |
| `qr_flutter` | game | QR codes for Long Ký links on desktop |
| `window_manager` | game | Desktop minimum window size (1280×720) and title |
| `melos` | root | Workspace scripts |

No package that does networking, analytics, ads or crash reporting.

## 3. Content data

All content is JSON under `apps/game/assets/content/`. Player-facing text is always a `{ "vi": ..., "en": ... }` object, the same shape Long Ký's own data uses. Code may only reference content by ID.

| File | Holds |
| --- | --- |
| `officers.json` | Player officers (Đại Việt) |
| `enemies.json` | Yuan commanders |
| `cards.json` | Stratagem, Event and Intent cards |
| `maps/ch1.json` | Chapter 1 nodes and edges |
| `missions/ch1_m1.json` … `ch1_m5.json` | One file per mission |
| `sources.json` | Citation registry referenced by `sourceRefs` |
| `longky_ids.json` | Snapshot of valid Long Ký person and event IDs, for validation |

**Officer**

```json
{
  "id": "tran-thu-do",
  "longKyPersonId": "tran-thu-do",
  "name": { "vi": "Trần Thủ Độ", "en": "Trần Thủ Độ" },
  "title": { "vi": "Thái sư", "en": "Grand Chancellor" },
  "stats": { "leadership": 8, "war": 5, "intelligence": 8, "politics": 9, "loyalty": 10 },
  "loyaltyLocked": true,
  "isKing": false,
  "skill": {
    "id": "dau-than-chua-roi",
    "kind": "activated",
    "usesPerMission": 1,
    "name": { "vi": "Đầu thần chưa rơi", "en": "My Head Has Not Fallen" },
    "text": { "vi": "Khôi phục Triều đình về tối đa.", "en": "Restore Court to full." },
    "effects": [ { "op": "setUnity", "pillar": "court", "value": 10 } ]
  },
  "flaw": null,
  "art": { "portrait": "officers/tran-thu-do/portrait.png", "card": "officers/tran-thu-do/card.png" },
  "sourceRefs": ["vietjack-sbt7-p48"]
}
```

`skill.kind` is `activated` (player triggers it in Council) or `passive` (always on). Passive skills have no `effects`; the engine implements each passive by its `id` from a closed list (section 4).

**Card**

```json
{
  "id": "vuon-khong-nha-trong",
  "type": "stratagem",
  "name": { "vi": "Vườn không nhà trống", "en": "Empty Gardens, Empty Houses" },
  "text": { "vi": "...", "en": "Evacuate a node you hold. Foraging there yields nothing." },
  "cost": { "rice": 0, "support": 2 },
  "target": "ownNode",
  "conditions": [],
  "effects": [ { "op": "evacuateNode", "target": "$node" } ],
  "longKyEventId": "khang-chien-mong-co-lan-mot",
  "art": "cards/vuon-khong-nha-trong.png",
  "sourceRefs": ["vietjack-sbt7-p48"]
}
```

`target` is one of `none`, `ownNode`, `anyNode`, `riverEdge`, `ownOfficer`, `yuanArmy`. The play action supplies the target; effects refer to it as `$node`, `$edge`, `$officer` or `$army`.

**Effect ops (closed set; validator rejects anything else)**

| Op | Params | Effect |
| --- | --- | --- |
| `modUnity` | `pillar`, `delta` | Change a Unity pillar, clamped 0–10 |
| `setUnity` | `pillar`, `value` | Set a pillar |
| `modResource` | `resource` (`rice`/`support`), `delta` | Change a resource, floor 0 |
| `evacuateNode` | `target` | Mark node evacuated for the rest of the mission |
| `withdrawOfficer` | `target` | Move officer one edge toward the king with no troop loss; cancels any battle there this turn |
| `placeAmbush` | `target` (edge) | Ambush on that edge for this turn (section 4) |
| `powerMultiplier` | `target`, `value`, `duration` (`nextBattle`), optional enemySupplyBelow (0–1) | Multiply the officer's Power in their next battle |
| `modArmy` | `target` (`$army` or `allArmies`), `field` (`troops`/`supply`/`morale`), `delta` | Change Yuan army values |
| `revealIntent` | `turnsAhead` | Show enemy intents further ahead this turn |
| `skipTurn` | none | Player skips Orders this turn |
| `choice` | `options`: list of `{ label, effects }` | Player picks one option (used by Events) |

**Condition ops:** `armySupplyBelowFraction` (`target`, `value` 0–1), `unityAtLeast` (`pillar`, `value`), `nodeTerrain` (`target`, `terrain`).

**Map**

```json
{
  "id": "ch1",
  "nodes": [
    { "id": "thang-long", "name": { "vi": "Thăng Long", "en": "Thăng Long" },
      "terrain": "city", "x": 0.62, "y": 0.55, "riceYield": 3, "isCapital": true }
  ],
  "edges": [ { "from": "binh-le-nguyen", "to": "thang-long", "kind": "land" } ]
}
```

`terrain` is one of `city`, `plain`, `river`, `marsh`, `hill`. `x` and `y` are 0–1 positions on the map image. Edges are undirected; `kind` is `land` or `river`.

Node flags: `isCapital` (exactly one per map) and `isBorder` (used by the `borderWatch` passive).

**Mission (fields)**

| Field | Type | Notes |
| --- | --- | --- |
| `id`, `chapter`, `order` | string, int, int | `ch1_m2`, 1, 2 |
| `title`, `briefing`, `debrief` | localized text | Narration scripts for ElevenLabs reuse these |
| `map` | map id | `ch1` |
| `seasonTurns`, `heatStartTurn` | int | Turn limit and when heat attrition starts |
| `start.rice`, `start.support`, `start.unity` | ints | Unity as `{ court, clan, people }` |
| `playerOfficers` | list of `{ officerId, nodeId, troops }` |  |
| `yuanArmies` | list of `{ id, commanderId, nodeId, troops, supply, morale, retreatNodeId }` |  |
| `deck` | list of `{ cardId, count }` | Shuffled with the mission seed |
| `handSize` | int | Draw up to this in Upkeep |
| `scriptedEvents` | list of `{ turn, cardId }` | Event card forced into play at the start of that turn |
| `win`, `loss` | list of objective objects | Section 5 per mission |
| `stars` | list of 3 objective objects | Star 1 is always "win" |
| `tutorial` | list of `{ id, text, highlight }` | Optional coach marks |
| `longKyEventId`, `sourceRefs` |  |  |

Three more mission fields: `inducements` (list of `{ turn, threshold }`, section 4), `yuanScript` (list of `{ turn, armyId, intent, targetNodeId? }`, overriding the AI), and `yuanObjectiveNodeId` (defaults to the capital).

**Objective types (closed list):** `allArmiesBroken`, `armyBroken` (`armyId`), `counterattackAt` (`nodeId`: win a battle there that you started, against an army below half Supply), `surviveTurns` (`turns`), `kingAt` (`nodeId`, by end of `turn`), `armySupplyAtMost` (`armyId`, `fraction`), `kingNotCaptured`, `capitalHeld`, `unityAllAbove` (`value`), `unityAtLeastAtEnd` (`pillar`, `value`), `noDefections`, `noCaptures`, `troopsLostAtMost` (`value`), `winByTurn` (`turn`). A list of objectives is satisfied when all of them are; use `anyOf: [...]` for "or".

**Source**

```json
{ "id": "vietjack-sbt7-p48", "work": "SBT Lịch sử 7, trang 48", "publisher": "VietJack",
  "url": "https://vietjack.com/sbt-lich-su-7-kn/giai-sbt-lich-su-7-trang-48-ket-noi.jsp", "note": "" }
```

The history reviewer will add Đại Việt sử ký toàn thư entries in the same shape Long Ký uses (`work`, `section`, `author`).

**Validator rules (`lk_content/bin/validate.dart`, run in CI)**

1. Every file parses and matches its schema; unknown fields are errors.
2. All IDs are unique; every reference resolves (officer, card, node, edge, army, source, art and audio path).
3. Every officer, card and mission has at least one `sourceRef`.
4. Every non-null `longKyPersonId` and `longKyEventId` exists in `longky_ids.json`.
5. Every localized text has non-empty `vi` and `en`.
6. Only effect, condition, objective, passive and flaw IDs from the closed lists are used.
7. The map graph is connected, has exactly one `isCapital` node, and every army's `retreatNodeId` is reachable.
8. Missing art or audio is a warning; with `--release` it is an error.

## 4. Rules engine (`lk_rules`)

The engine is one pure function: `StepResult apply(GameState state, GameAction action)`, returning the new state plus a list of `GameEvent`s for the UI to animate. Illegal actions throw `IllegalAction(code)`; the UI must prevent them, and tests must cover them. All numbers below are first-pass values for tuning in T-25.

**Units.** Troops are counted in units of 1,000 men; the UI shows both ("30 đơn vị · 30.000 quân").

**Starting values.** Officers start each mission at morale 7; armies start at the morale given in the mission. Rice and Support have no cap.

**State**

| Type | Fields |
| --- | --- |
| `GameState` | `missionId`, `seed`, `rng` (state), `turn` (from 1), `phase`, `outcome` (`null`/`won`/`lost`), `lossReason`, `rice`, `support`, `unity` (`court`, `clan`, `people`, each 0–10), `nodes`, `officers`, `armies`, `ambushes`, `deck`, `hand`, `discard`, `pendingChoice`, `revealDepth`, `flags`, `missionStats`, `log` |
| `NodeState` | `controller` (`daiViet`/`yuan`/`none`), `evacuated`, `riceStock` |
| `OfficerState` | `nodeId`, `troops`, `morale` (0–10), `loyalty`, `status` (`active`/`defected`/`captured`), `order`, `skillUsesLeft`, `nextBattleMultiplier` |
| `ArmyState` | `commanderId`, `nodeId`, `troops`, `supply`, `maxSupply`, `morale` (0–10), `intent`, `status` (`active`/`routed`) |

**Actions (sealed class `GameAction`)**

| Action | Allowed in | Effect |
| --- | --- | --- |
| `PlayCard(cardId, target?)` | Council | Pay cost, check conditions, apply effects, move card to discard |
| `UseSkill(officerId, target?)` | Council | Activated skills only; decrements `skillUsesLeft` |
| `ResolveChoice(index)` | Whenever `pendingChoice` is set | Applies that option's effects; no other action is legal until resolved |
| `SetOrder(officerId, order)` / `ClearOrder(officerId)` | Orders | One order per active officer |
| `EndPhase()` | Council, Orders | Council → Orders. Orders → runs Resolution and Upkeep, then Intel of the next turn, and stops at Council |

**Orders**

| Order | Target | Rule |
| --- | --- | --- |
| `hold` | none | +20% Power when defending at this node |
| `move` | node | One land edge, or up to two river edges (boats) |
| `evacuate` | own node | Costs 1 Support (2 if People < 4). Node becomes evacuated; player gains Rice equal to its `riceStock`, which drops to 0 |
| `raid` | army on an adjacent node | No battle. Army loses `2 + floor(war / 3)` Supply (doubled by passive `raider`). Raider loses `floor(army troops / 20)` troops |
| `ambush` | adjacent river edge | Triggers if a Yuan army crosses that edge this turn |
| `rally` | none | +1 morale to Đại Việt officers at this node; +1 troop if the node is held and not evacuated (none if People < 4) |

An officer with no order holds.

**Turn sequence**

1. **Intel.** Each army picks an intent (Yuan AI below). Scripted Event cards for this turn are played; a `choice` sets `pendingChoice`.
2. **Council.** Player plays cards and activated skills. If Court < 4, every card costs +1 Support.
3. **Orders.** Player sets orders, then `EndPhase`.
4. **Resolution**, in this order:
   1. Đại Việt moves resolve together.
   2. Yuan moves resolve in army-id order. Crossing an ambushed edge triggers the ambush first.
   3. A battle happens at every node holding both an active officer and an active army.
   4. Raids resolve.
   5. Forage: an army whose intent was `forage`, standing on a non-evacuated node with `riceStock` > 0, gains `min(2 × riceStock, maxSupply − supply)` Supply; the node's `riceStock` becomes 0. Evacuated nodes give nothing.
   6. Node control updates: a node with only one side present goes to that side.
5. **Upkeep**, in this order:
   1. Each army uses `ceil(troops / 10)` Supply.
   2. Starvation: an army at 0 Supply loses 2 morale and `ceil(troops × 0.1)` troops.
   3. Heat: from `heatStartTurn`, each army loses `turn − heatStartTurn + 1` troops.
   4. An army with morale ≤ 0 or troops ≤ 0 is routed and removed.
   5. Player income: Rice += `riceYield` of each held, non-evacuated node. Then Rice −= `ceil(total player troops / 10)`; if that goes below 0, Rice is 0 and every officer loses 1 morale.
   6. Inducement checks (below).
   7. Draw up to `handSize`; if the deck is empty, shuffle the discard with the RNG.
   8. Check win and loss, then `turn + 1` and Intel.

**Combat**

```latex
\text{Power} = \text{effective troops} \times \left(1 + \frac{\text{War}}{10}\right) \times \text{terrain} \times \left(0.5 + \frac{\text{morale}}{20}\right) \times \text{modifiers}
```

- Effective troops: an officer commands up to `leadership × 3` units at full value; troops above that count half. Several officers at one node add their Power.
- Modifiers multiply: `hold` 1.2, `nextBattleMultiplier` (then reset to 1), ambusher 1.5, passive `kingPresence` adds +1 morale before the calculation.
- Higher Power wins. A tie goes to the higher leadership, then to the side that held the node at turn start.
- With `r = loser Power / winner Power`: loser loses `ceil(troops × (0.5 − 0.3r))`, winner loses `ceil(troops × 0.25r)`. Loser −2 morale, winner +1 morale.
- Losing officers withdraw one edge toward the king's node. With no free node to go to, they are captured.
- Losing armies retreat one edge toward their `retreatNodeId`.
- Ambush: the only random step. Ambusher Power is also multiplied by a uniform roll in \[0.9, 1.1\] from the RNG. If the ambusher wins, the army stops at its starting node and loses an extra 2 morale.

| Terrain | Đại Việt | Yuan |
| --- | --- | --- |
| city | 1.2 when defending, else 1.0 | 1.0 |
| plain | 1.0 | 1.2 |
| river | 1.2 | 0.9 |
| marsh | 1.2 | 0.8 |
| hill | 1.1 | 1.0 |

**Unity**

| Pillar | Below 4 | Changes |
| --- | --- | --- |
| Court | Cards cost +1 Support | −1 the first time the capital is lost; card and skill effects |
| Clan | Defection threshold +2 | −1 per defection |
| People | Evacuate costs 2; Rally gives no troops | +1 per battle won; −1 per evacuation after the first in the same turn |

Any pillar at 0 loses the mission.

**Inducements.** A mission lists `inducements: [{ turn, threshold }]`. In that turn's Upkeep, the active, non-locked officer with the lowest loyalty (ties by id) defects if `loyalty + floor(clan / 2) < threshold` (+2 if Clan < 4). A defector's troops are removed and Clan drops by 1.

**Yuan AI.** Deterministic. For each active army in id order, take the first rule that applies:

1. Mission script names an intent for this army this turn → use it.
2. Morale ≤ 2, or Supply is 0 from `heatStartTurn` on → `retreat` toward `retreatNodeId`.
3. Supply < 40% of `maxSupply` → `forage`: move toward the nearest non-evacuated node with `riceStock` > 0 (BFS, ties by node id); if standing on one, stay.
4. The king's node is adjacent and the army's Power there would beat the defenders → `assault` it.
5. Otherwise `advance` one edge along the shortest path to the mission's `yuanObjectiveNodeId` (the capital by default; once it is taken, the king's node).

Armies move one edge per turn. Intent is shown for this turn (`revealDepth` 1); passive `borderWatch` sets it to 2 by simulating the AI one turn ahead on the current state, shown as "predicted".

**Passive skills and flaws (closed list)**

| ID | Officer | Rule |
| --- | --- | --- |
| `kingPresence` | Trần Thái Tông | +1 morale to all Đại Việt units at his node in battle |
| `shieldKing` | Lê Phụ Trần | While at the king's node, the king withdraws instead of being captured; if there is no free node, Lê Phụ Trần is captured instead |
| `borderWatch` | Trần Quốc Tuấn | At a node with `isBorder`, `revealDepth` is 2 |
| `raider` | Trần Khánh Dư | Raid Supply damage ×2 |
| flaw `isKing` | Trần Thái Tông | Captured → mission lost |
| flaw `troopCap` | Trần Quốc Tuấn | Max 6 troops in Chapter 1 |

**Randomness.** Implement a small specified PRNG yourself (for example SplitMix64) in `SeededRng`, and never use `dart:math` `Random`, so replays stay identical across Dart versions. Uses: deck shuffles and ambush rolls only.

**Save format.** `{ "saveVersion": 1, "missionId", "contentHash", "seed", "actions": [...] }`. Loading replays the actions from the mission start. If `contentHash` differs, offer to restart the mission instead of replaying.

## 5. Chapter 1 data (1258)

This is the starting content for T-12. Place names come from the sources in docs/plan.md; the graph, terrain, positions and all numbers are game design, to be tuned in T-25. Map positions are placeholders until the painted map exists.

**Map `ch1`**

| Node id | Name | Terrain | riceYield | Flags | x, y |
| --- | --- | --- | --- | --- | --- |
| `bien-gioi` | Biên giới (hướng Vân Nam) | hill | 0 | `isBorder`, Yuan retreat | 0.08, 0.12 |
| `song-thao` | Sông Thao | river | 1 | `isBorder` | 0.20, 0.25 |
| `bach-hac` | Bạch Hạc | river | 2 |  | 0.35, 0.38 |
| `song-lo` | Sông Lô | river | 1 |  | 0.42, 0.20 |
| `binh-le-nguyen` | Bình Lệ Nguyên | plain | 2 |  | 0.45, 0.35 |
| `phu-lo` | Phù Lỗ | river | 2 |  | 0.58, 0.32 |
| `thang-long` | Thăng Long | city | 3 | `isCapital` | 0.62, 0.50 |
| `dong-bo-dau` | Đông Bộ Đầu | river | 1 |  | 0.66, 0.44 |
| `thien-mac` | Thiên Mạc | river | 2 |  | 0.75, 0.68 |

Node `riceStock` starts equal to `riceYield × 3`.

**Edges:** `bien-gioi`–`song-thao` (river), `song-thao`–`bach-hac` (river), `bach-hac`–`song-lo` (river), `bach-hac`–`binh-le-nguyen` (land), `song-lo`–`binh-le-nguyen` (land), `binh-le-nguyen`–`phu-lo` (land), `binh-le-nguyen`–`thang-long` (land), `phu-lo`–`thang-long` (land), `phu-lo`–`dong-bo-dau` (river), `thang-long`–`dong-bo-dau` (river), `thang-long`–`thien-mac` (river), `dong-bo-dau`–`thien-mac` (river).

**Officers**

| id | longKyPersonId | Thống/Võ/Trí/Chính | Loyalty | Skill | Flaw |
| --- | --- | --- | --- | --- | --- |
| `tran-thai-tong` | `tran-thai-tong` | 7/6/6/8 | 10, locked | passive `kingPresence` | `isKing` |
| `tran-thu-do` | `tran-thu-do` | 8/5/8/9 | 10, locked | activated `dau-than-chua-roi`: setUnity court 10, once | none |
| `le-phu-tran` | none yet | 6/7/6/6 | 9, locked | passive `shieldKing` | none |
| `tran-quoc-tuan` | `tran-hung-dao` | 9/8/10/7 | 10, locked | passive `borderWatch` | `troopCap` 6 |
| `tran-khanh-du` | `tran-khanh-du` | 7/9/7/4 | 8 | passive `raider` | none in Chapter 1 |
| `tran-nhat-hieu` | none yet | 4/3/6/6 | 5 | activated `nhap-tong`: evacuate own node at no Support cost, then Court −1; twice per mission | none |

Lê Phụ Trần, Trần Nhật Hiệu and Ngột Lương Hợp Thai are not in Long Ký's `people.json` yet; `longKyPersonId` is `null` until they are added there.

**Enemy commander:** `ngot-luong-hop-thai` (Uriyangkhadai): Thống 9, Võ 9, Trí 7. Army `mong-co-1258`: 30 troops (30,000 men, per the sources), `maxSupply` 20, morale 8, `retreatNodeId` `bien-gioi`.

**Cards**

| id | Type | Cost (rice/support) | Target | Effects |
| --- | --- | --- | --- | --- |
| `vuon-khong-nha-trong` | stratagem | 0/2 | ownNode | `evacuateNode $node` |
| `lui-binh-bao-toan` | stratagem | 1/0 | ownOfficer | `withdrawOfficer $officer` |
| `phuc-kich-ben-song` | stratagem | 2/0 | riverEdge | `placeAmbush $edge`, manned by your highest-War officer on a node at either end; illegal if none |
| `phan-cong` | stratagem | 2/1 | ownOfficer | `powerMultiplier 2.0 nextBattle`, applied only if the opposing army is below 50% Supply |
| `su-gia-phuong-bac` | event | 0/0 | none | `choice`: refuse → People +1; accept → `skipTurn`, Court −2 |
| `nang-nong` | event | 0/0 | none | `modArmy allArmies troops −1` |

**Missions**

| Mission | Turns / heat from | Start (rice, support, court/clan/people) | Player forces | Yuan | Script and inducements | Win | Lose | Stars 2 and 3 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `ch1_m1` Sứ giả phương Bắc | 3 / none | 4, 4, 6/6/6 | Thái Tông 12 and Thủ Độ 6 at `thang-long`; Quốc Tuấn 6 at `song-thao`; Nhật Hiệu 4 at `thang-long` | at `bien-gioi`, holds turns 1–3 | `su-gia-phuong-bac` turns 1, 2, 3; inducement turn 3, threshold 6 | `surviveTurns 3` | standard | `noDefections`; `unityAllAbove 5` |
| `ch1_m2` Bình Lệ Nguyên | 4 / none | 4, 3, 6/6/6 | Thái Tông 12, Lê Phụ Trần 6, Thủ Độ 6 at `binh-le-nguyen` | at `bach-hac`; assaults `binh-le-nguyen` turn 1 | none | `kingAt song-lo` or `kingAt thang-long` by end of turn 4 | standard | no officer captured; total troops lost ≤ 10 |
| `ch1_m3` Bỏ ngỏ Thăng Long | 6 / 5 | 3, 6, 5/6/6 | Thái Tông, Thủ Độ, Lê Phụ Trần, Nhật Hiệu at `thang-long`; Khánh Dư 8 at `phu-lo` | at `binh-le-nguyen`, Supply 14 | none | `surviveTurns 6` and `armySupplyAtMost mong-co-1258 0.25` | standard | `unityAllAbove 4`; no officer captured |
| `ch1_m4` Đầu thần chưa rơi | 5 / 3 | 2, 4, 3/5/5 | all six officers, spread over `thien-mac`, `dong-bo-dau`, `phu-lo` | at `thang-long`, Supply 10 | `su-gia-phuong-bac` turn 2; inducements turns 2 and 4, threshold 8 | `surviveTurns 5` | standard | `noDefections`; Court ≥ 7 at end |
| `ch1_m5` Đông Bộ Đầu | 6 / 1 | 5, 5, 6/6/6 | all six officers at `thien-mac` and `dong-bo-dau` | at `thang-long`: 24 troops, Supply 6, morale 5 | `nang-nong` turn 2; script moves the army to dong-bo-dau on turn 1 | `counterattackAt dong-bo-dau` or `allArmiesBroken` | standard | win by turn 4; no officer captured |

"Standard" loss = `isKing` officer captured or any Unity pillar at 0. Where a mission does not list troops, use: Thái Tông 12, Thủ Độ 6, Lê Phụ Trần 6, Quốc Tuấn 6, Khánh Dư 8, Nhật Hiệu 4. Star objectives map to the closed objective list ("no officer captured" = `noCaptures`, "win by turn 4" = `winByTurn`, and so on). Missions 1–2 have tutorial steps for each phase; missions 3–5 have one tip each.

**Decks:** every mission deck starts as 3× `vuon-khong-nha-trong`, 2× `lui-binh-bao-toan`, 2× `phuc-kich-ben-song`; `ch1_m5` adds 3× `phan-cong`. Hand size 4.

## 6. App (`apps/game`)

One Flutter app, landscape everywhere, with one responsive layout that switches at 900 logical pixels of width. Flame draws only the map board; everything else is Flutter widgets on top.

**Screens**

| Screen | Contents |
| --- | --- |
| Title | "Long Ký - The Game", Continue, Campaign, Codex, Settings |
| Campaign | Chapter list, then mission list with stars and locks; mission N unlocks when N−1 is won |
| Briefing | Narration with subtitles, objectives, starting officers, Start |
| Battle | Flame board plus overlays: top bar (turn / season clock, Rice, Support, three Unity gauges), officer strip, hand of cards, phase button, event log, inspector for the selected node, officer or army |
| Battle preview | Opens whenever an order or card would cause a battle: both Powers and expected losses. Ambush shows a range because of the roll |
| Choice dialog | Shown while `pendingChoice` is set; blocks other input |
| Result | Won or lost, stars, debrief narration, unlocks, "Read more in Long Ký" |
| Codex | Officers, events and cards: lore, sources, "Read more in Long Ký", unlock-code entry |
| Settings | Language (vi/en), music, voice and effects volume, text size 100–150%, reduce motion, reset progress, credits and sources |

**Battle board (Flame)**

- Painted map background; nodes as lacquer medallions; edges drawn as river (blue-gold) or road (dashed).
- Tokens: one per officer and army, showing troops; stacked tokens fan out.
- Yuan intent: an arrow along the edge it will take, with an icon for advance, forage, assault or retreat; predicted intents drawn dashed.
- Evacuated nodes greyed with a smoke mark; ambushed edges marked for the player only.
- Animations play from `GameEvent`s in order: moves, battles, forage, defections. Reduce motion skips them.

**Layout and input**

|  | Compact (< 900 wide: phones) | Regular (≥ 900: tablets, desktop) |
| --- | --- | --- |
| Hand | Bottom drawer, cards fan out on tap | Right column, always visible |
| Inspector | Bottom sheet | Floating panel next to the selection |
| Log | Hidden behind a button | Collapsible left panel |

- Mobile: lock to landscape in the Android manifest and iOS Info.plist; respect safe areas; touch targets at least 48 logical pixels.
- Desktop: `window_manager` sets minimum 1280×720, default 1600×900, resizable. Hover shows tooltips. Keyboard: Space or Enter ends the phase, Esc closes a panel or opens the menu, 1–9 selects a card, Tab cycles officers, right-click cancels the current selection.
- Orders can be changed freely until `EndPhase`; played cards are final.

**State management.** A `BattleCubit` holds the `GameState`, sends actions to the engine, queues the returned `GameEvent`s for the board, and autosaves. Other screens use small Cubits or plain widgets.

**Saving**

- Files under `getApplicationSupportDirectory()` (`path_provider`): `progress.json` (stars, unlocks, settings) and `battle.json` (the current mission's save, format in section 4).
- Autosave after every action; write to a temp file and rename, so a crash cannot corrupt the save.
- `progress.json` carries a `version` and migrations from the first release on.

**Localization**

- UI strings: gen-l10n with `app_vi.arb` and `app_en.arb`; Vietnamese is the template and default.
- Content strings come from the JSON `{ vi, en }` objects for the current locale.
- Bundle fonts that cover Vietnamese diacritics in the app (for example Be Vietnam Pro for body text). Never download fonts at runtime.
- Voice is Vietnamese in both languages, with subtitles in the chosen language, as in the shorts.

**Audio.** `flame_audio` with three channels: music (looping, subtle), voice (narration and character lines), effects. Files are named by content id, for example `audio/voice/ch1_m2_briefing.mp3`. Missing audio is skipped silently in debug and fails the content validator in release.

**Art.** Images are loaded by id from `assets/images/`. If a file is missing, draw a placeholder: lacquer background, gold border, the item's name. This lets code ship before art. Card art is 3:4 portrait; frames look like lacquer tablets, never playing cards.

**Theme tokens (starting values).** Lacquer black `#0E0B0A`, gold leaf `#C9A24A`, cinnabar `#B3261E`, ivory text `#F2E8D5`, river blue `#2E5E6E`. Check text contrast against the background.

**Long Ký links**

- `LongKyLinks` builds a URL for a person or event id from one config constant, `longKyLinkBase`, which you supply (the Long Ký deep-link format is an open question).
- Mobile: open the link with `url_launcher`; if it cannot open, open the store page URL from the same config.
- Desktop: show the same link as a QR code (`qr_flutter`) with the text "Scan with your phone to open Long Ký".
- Unlock codes: format `LK-XXXX-XXXX`, derived from the person or event id and a shared secret (same derivation implemented in Long Ký). The game checks codes offline. On mobile, also accept them through a custom-scheme deep link via `app_links`.
- Build the code derivation as a small pure-Dart file you can copy into the Long Ký codebase.

## 7. Testing and balance

Most bugs in this game will be rules bugs, so most tests live in `lk_rules` and run in milliseconds; the simulator turns balance into numbers.

**Required tests**

| Layer | Tests |
| --- | --- |
| `lk_rules` unit | Every action in every phase, legal and illegal; every order; every effect op; every passive; combat with hand-computed numbers for each terrain; upkeep steps in order; win, loss and star checks |
| `lk_rules` invariants | Run 1,000 seeded random-legal games and assert after every step: Unity 0–10, troops and Supply ≥ 0, each unit on exactly one node, at most one `pendingChoice`, the game ends by `seasonTurns` |
| Determinism | Same seed and actions give an identical state hash; save, reload and replay give an identical state |
| `lk_content` | Validator passes on real content; one failing fixture per validator rule |
| App widget tests | Card frame, top bar, choice dialog, battle preview, compact and regular layouts |
| Golden tests | Card frame and top bar, run on one fixed CI OS only |
| Integration | Play `ch1_m1` to a win with scripted taps, on each of the four platforms (Flutter's `integration_test`) |
| Offline guard | A test that fails if the app or packages import an HTTP client or socket API |

**Simulator (`tools/sim`)**

```bash
dart run tools/sim/bin/sim.dart --mission ch1_m3 --strategy expert --games 1000 --seed 1
```

It prints win rate, average turns, average Supply left per army, defections, and card play counts, as text and as JSON for CI. It also has `--play`, a text-mode game in the terminal for checking rules before the UI exists.

**Strategies**

- `expert`: a scripted plan per mission that follows the historical approach (retreat, evacuate ahead of the army, raid Supply, counterattack late).
- `naive`: fights head-on, never evacuates or raids.
- `passive`: every officer holds.
- `random`: random legal actions from the seeded RNG.

**Balance targets (T-25)**

| Mission | `expert` win | `naive` win | `random` win |
| --- | --- | --- | --- |
| `ch1_m1` | ≥ 95% | ≥ 80% (tutorial) | ≥ 50% |
| `ch1_m2` | ≥ 90% | ≤ 20% | ≤ 15% |
| `ch1_m3` | ≥ 90% | ≤ 20% | ≤ 10% |
| `ch1_m4` | ≥ 85% | ≤ 30% | ≤ 10% |
| `ch1_m5` | ≥ 85% | ≤ 25% | ≤ 10% |

Balance by changing numbers in content JSON first, then rule constants in one `balance.dart` file. Every balance PR attaches the simulator report before and after.

**Performance:** a full engine step under 5 ms on a mid-range phone; the board at 60 fps.

## 8. CI and platform builds

Two GitHub Actions workflows: a fast check on every pull request, and a four-platform build on every merge to `main`. Pin the same Flutter version in CI as locally, and record it in the README.

**`ci.yml` (pull requests, Linux runner)**

1. Install the pinned Flutter, then `melos bootstrap`.
2. `melos run analyze` with zero warnings allowed.
3. `melos run test` for `lk_rules`, `lk_content`, `tools/sim` and the app's widget and golden tests.
4. `dart run packages/lk_content/bin/validate.dart`.
5. Simulator smoke run: 200 games per mission with `expert`; fail if any win rate is below the T-25 target minus 10 points (only after T-25 is merged).

**`build.yml` (merges to `main` and tags)**

| Target | Runner | Command | Artifact |
| --- | --- | --- | --- |
| Android | Linux | `flutter build appbundle` | `.aab` |
| iOS | macOS | `flutter build ios --no-codesign` until signing is set up | build folder |
| macOS | macOS | `flutter build macos` | `.app` |
| Windows | Windows | `flutter build windows` | build folder |

The Flutter desktop docs show Windows and macOS builds run on their own OS ([Flutter desktop docs](https://docs.flutter.dev/platform-integration/desktop)), hence one runner per OS.

**Signing and release (T-27 only)**

- Signing keys, certificates and the unlock-code secret live in GitHub Actions secrets and your machine, never in the repo.
- Android: Play internal testing. iOS and macOS: TestFlight. Windows: the channel you choose (open decision in docs/plan.md).
- App name on every platform: "Long Ký - The Game". The bundle id uses your Long Ký prefix.
- macOS: App Sandbox on, with no network entitlement.

## 9. Ticket backlog

Thirty tickets, in build order; each is one session, one branch and one pull request. The rules engine (M1) is finished and tested before any UI work starts, and art never blocks code thanks to placeholders.

| ID | Milestone | Ticket | Effort | Needs | Done when |
| --- | --- | --- | --- | --- | --- |
| T-00 | M0 | Put `docs/plan.md`, `docs/build-spec.md` and `CLAUDE.md` in the repo | high | none | Files on `main`, exported from this doc |
| T-01 | M0 | Scaffold the workspace (section 2): packages, app with 4 platforms, Melos scripts, lints, pinned versions | high | T-00 | App opens a blank title screen on Android, iOS, macOS and Windows; `ci.yml` green |
| T-02 | M0 | `build.yml` four-platform build matrix | high | T-01 | All four artifacts build on a merge to `main` |
| T-03 | M1 | `lk_rules` models, `SeededRng`, state hash, `balance.dart` constants | high | T-01 | Models serialize to and from JSON; RNG gives a fixed sequence for a fixed seed (test) |
| T-04 | M1 | Reducer skeleton: phases, `EndPhase` flow, `IllegalAction`, `GameEvent`s, action log | xhigh | T-03 | A mission with no units runs from turn 1 to `seasonTurns` and ends |
| T-05 | M1 | Orders: move (land and river), hold, evacuate, rally, raid | high | T-04 | Every order rule in section 4 has a passing test |
| T-06 | M1 | Combat, ambush, withdrawal, capture | xhigh | T-05 | Hand-computed combat cases for every terrain pass; ambush is the only random step |
| T-07 | M1 | Forage and Upkeep: Supply, starvation, heat, income, routing | high | T-06 | Upkeep steps run in the documented order (test) |
| T-08 | M1 | Unity effects, inducements, win, loss and star objectives | high | T-07 | Every objective type and Unity threshold has a test |
| T-09 | M1 | Card effects interpreter, conditions, `choice`, activated and passive skills | xhigh | T-08 | Every effect op, condition and passive in the closed lists has a test |
| T-10 | M1 | Yuan AI and `borderWatch` prediction | xhigh | T-09 | AI rules 1–5 each have a test; same state always gives the same intents |
| T-11 | M1 | `lk_content`: models, parser, validator CLI, script that builds `longky_ids.json` from Long Ký's `people.json` and `events.json` | high | T-03 | Validator rules 1–8 each have a failing fixture and pass on valid data |
| T-12 | M1 | Chapter 1 content JSON from section 5 | high | T-11 | Validator passes; anything not in section 5 is a `TODO` listed in the PR, never invented |
| T-13 | M1 | Simulator with the four strategies, JSON report and `--play` text mode | xhigh | T-10, T-12 | `ch1_m2` playable to the end in the terminal; 1,000-game run finishes and passes the invariant checks |
| T-14 | M2 | App shell: routing, theme tokens, bundled fonts, gen-l10n vi/en, Settings, `progress.json` | high | T-01 | Language switch works live; settings persist across restarts |
| T-15 | M2 | Flame board: map, nodes, edges, tokens, intent arrows, selection | high | T-13, T-14 | `ch1_m2` start state is drawn correctly at compact and regular sizes |
| T-16 | M2 | Battle overlays: top bar, officer strip, hand, inspector, phase button, log; both layouts | high | T-15 | Widget tests for each overlay at both layouts |
| T-17 | M2 | Orders and card UX, battle preview, choice dialog, event animations, reduce motion | high | T-16 | `ch1_m2` playable start to finish with touch and with mouse |
| T-18 | M2 | Battle autosave and resume, Result screen, stars | high | T-17 | Killing the app mid-turn and reopening restores the same state |
| T-19 | M2 | Desktop: window size, keyboard shortcuts, hover tooltips. Mobile: landscape lock, safe areas | high | T-17 | Shortcuts in section 6 work on macOS and Windows; no clipped UI on a notched phone |
| T-20 | M2 | Audio: narration, character lines, music, effects, volumes, subtitles | high | T-17 | Briefing plays voice with subtitles in both languages |
| T-21 | M2 | Art loading by id, placeholder renderer, lacquer card frame, golden tests | high | T-16 | Missing art shows placeholders; card goldens pass |
| T-22 | M2 | Tutorial coach marks for missions 1 and 2 | high | T-17 | A new player is guided through every phase of turn 1 |
| T-23 | M3 | Campaign and Briefing screens, unlock flow over 5 missions | high | T-18 | Winning mission N unlocks N+1; stars saved |
| T-24 | M3 | Codex, Long Ký links (mobile link, desktop QR), unlock codes, incoming deep link on mobile | high | T-23 | A valid code unlocks lore and the bonus card on all four platforms; an invalid code is rejected |
| T-25 | M3 | Balance pass with the simulator | xhigh | T-13, T-12 | Every mission meets the section 7 targets; report attached |
| T-26 | M3 | Content freeze export: CSV of every text and its sources for the history reviewer | high | T-25 | CSV lists every vi and en string with its content id and `sourceRefs` |
| T-27 | M4 | Release builds and signing, app icons, store names, age-rating notice | high | T-26 | Builds uploaded to Play internal testing and TestFlight (iOS, macOS); Windows package built |
| T-28 | M4 | Platform QA pass and performance check | high | T-27 | QA checklist done on all four platforms; performance targets met |
| T-29 | M4 | Offline and privacy check, store privacy answers ("no data collected") | high | T-27 | Offline guard test passes; app makes no network calls on all four platforms |

**Open inputs from you (agent: stop and ask if a ticket needs one)**

- [ ] Bundle id prefix (T-01).
- [ ] Long Ký deep-link format and store URLs (T-24).
- [ ] Unlock-code secret, kept out of the repo (T-24).
- [ ] Painted Chapter 1 map and node positions (T-15 uses placeholders until then).
- [ ] Font choice confirmed, with its licence (T-14).
- [ ] Windows distribution channel (T-27).

## 10. Definition of done and guardrails

A ticket is done only when its "Done when" holds and every item below is true; the guardrails apply to every ticket.

**Definition of done**

- [ ] `melos run analyze` has zero warnings; `melos run test` passes; the content validator passes.
- [ ] New rules logic has unit tests; new UI has at least one widget test.
- [ ] Runs on the platforms the ticket touches; the PR says which were checked by hand.
- [ ] No new dependency outside section 2 without asking first.
- [ ] Every new player-facing string exists in vi and en.
- [ ] The PR lists anything left as `TODO` and any question for you.

**Guardrails**

1. **Offline only.** No networking, accounts, analytics, ads, crash reporting or remote config, ever. This keeps the game in the G4 category.
2. **No invented history.** Facts come from content JSON with `sourceRefs`. If a ticket needs a fact that is missing, add a `TODO` and flag it; do not fill it in.
3. **Vietnamese is the source language.** Never machine-translate English into Vietnamese. Draft English from Vietnamese and mark it for review.
4. **Design numbers live in data.** Balance values go in content JSON or `balance.dart`, changed only with a simulator report.
5. **Pure rules.** `lk_rules` never imports Flutter, `dart:io` or the clock, and uses only `SeededRng` for randomness.
6. **No playing-card look.** No suits, ranks, corner indices or casino imagery anywhere.
7. **No secrets in git.** Signing keys, certificates and the unlock secret come from local config or CI secrets.
8. **Stay in scope.** One ticket per PR; no drive-by refactors of other packages.
9. **When the spec is ambiguous**, choose the simplest reading, write it down in the PR, and keep going; stop only for the open inputs listed in section 9.
