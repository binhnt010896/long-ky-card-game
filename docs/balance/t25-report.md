# T-25 balance report

Simulator: `dart run tools/sim/bin/sim.dart --mission all --strategy all --games 1000 --seed 1`.
Before: `sim-baseline-t13.json` (content hash `93e18e4316a21ea7`). After: `sim-t25.json`
(content hash `63ff31bdbb7c2155`). 20,000 games, 0 invariant violations in both.

## Result (win rate, %, 1000 games, seed 1)

Targets are from build-spec section 7. "Passive" (every officer holds) has no
target; it is shown because a game that can be won by doing nothing is not a game.

| Mission | Expert target | Expert before → after | Naive target | Naive before → after | Random target | Random before → after | Passive before → after |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `ch1_m1` | ≥ 95 | 100.0 → **100.0** | ≥ 80 | 100.0 → **100.0** | ≥ 50 | 73.8 → **73.8** | 100.0 → 100.0 |
| `ch1_m2` | ≥ 90 | 100.0 → **100.0** | ≤ 20 | 100.0 → **0.0** | ≤ 15 | 99.4 → **9.6** | 100.0 → 0.0 |
| `ch1_m3` | ≥ 90 | 100.0 → **100.0** | ≤ 20 | 100.0 → **0.0** | ≤ 10 | 27.8 → **2.6** | 100.0 → 0.0 |
| `ch1_m4` | ≥ 85 | 100.0 → **100.0** | ≤ 30 | 100.0 → **0.0** | ≤ 10 | 71.6 → **6.1** | 100.0 → 0.0 |
| `ch1_m5` | ≥ 85 | 100.0 → **100.0** | ≤ 25 | 100.0 → **0.0** | ≤ 10 | 100.0 → **1.3** | 100.0 → 0.0 |

Every target is met. `tools/sim/test/balance_test.dart` keeps them as a test
(300 games, seed 1) and CI gates the expert at target minus 10 points
(`ci.yml`, simulator smoke run).

## Why the first-pass numbers did not work

With build-spec section 5 as written, doing nothing won every mission:

1. **`ch1_m2`**: `kingAt` is true at any end of turn up to 4, and a king who
   loses the battle at Bình Lệ Nguyên *withdraws to Thăng Long* on turn 1 and
   so wins at once.
2. **`ch1_m3`, `ch1_m4`**: a stack of all officers on a river or city node,
   holding, beats one 30-troop army, and the army starves anyway.
3. **`ch1_m4`**: the win is only to survive 5 turns, and with one Yuan army the
   king is never captured (an officer is captured only when *no* neighbouring
   node is free of an army, section 4), so the mission could not be lost except
   through Unity.
4. **`ch1_m5`**: the army (24 troops, morale 5, Supply 6, heat from turn 1)
   melts away in four turns whatever the player does.

## Changes (content JSON only; no rule constant was touched)

| Mission | Change | Why |
| --- | --- | --- |
| `ch1_m2` | win also needs `surviveTurns 4` and `troopsLostAtMost 16` | the withdraw-to-Thăng-Long shortcut; random play wandered to a haven |
| `ch1_m3` | Đại Việt troops at 60% (7/4/4/2/5) | a full stack held the city against the army |
| `ch1_m4` | Đại Việt troops at 80%; Yuan morale 10; **loss** when more than 14,000 troops are lost; star 2 `noCaptures` | see 3 above; star 2 `noDefections` could not be earned by any play (Trần Nhật Hiệu defects at turn 2 and no card or skill in Chapter 1 raises loyalty or Clan) |
| `ch1_m5` | Yuan 30 troops (not 24), morale 9 (not 5), heat from turn 6 (not 1) | see 4 above; the Supply 6 start stays, so Phản công (x2 when the army is below half Supply) is what wins |

Not changed: the Yuan army size where a source gives it (30,000 men, `vietjack-ls11-p50`);
no historical fact was touched, and every changed item keeps its `sourceRefs`.
The `todo` of each changed mission says what moved.

## Changes to the simulator

`expert` no longer counterattacks an army it can leave to starve: it attacks only when
the mission's win asks for a battle (`counterattackAt`, `allArmiesBroken`, `armyBroken`).
That was needed for `ch1_m4`, where every troop lost counts against the loss rule.

## Changes to the app

The new loss rule and win condition have to be told to the player: the Briefing has a
"Thua nếu / You lose if" section for loss rules beyond the standard ones, and the Result
screen names the rule that ended the mission.

## Things the owner should decide

1. **`ch1_m4` is lost on troops, not on capture.** It is the smallest content-only way to
   make a survival mission losable. The alternative is a rule: an officer left with 0 troops
   is captured, or Court −1 when the king withdraws. Either changes section 4, so it was not done here.
2. **Win rates for the expert are 100% everywhere.** The expert is a deterministic script, so
   this says "the intended solution works", not "a good human wins 100%". A human playtest is still needed.
3. **Cliffs.** Deterministic strategies flip between 0% and 100% across small parameter
   changes (for example `ch1_m3` with Đại Việt troops at 70% instead of 60% scored 0% for the expert in the scan). The chosen values
   sit on a plateau where they were tested, but any later change of a number should rerun the simulator
   (`melos run test` does, through `balance_test.dart`).
4. **Stars.** `ch1_m1` to `ch1_m3` and `ch1_m5` give the expert three stars in every game; `ch1_m4`'s court star
   needs Trần Thủ Độ's Court skill. Whether the stars are hard enough is a playtest question.
5. **The Result and Briefing texts** of the missions are still the placeholders flagged in their `todo`
   (historian-approved narration is needed).
