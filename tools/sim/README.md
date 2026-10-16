# sim

Headless balance simulator and text-mode player (build-spec section 7).

```bash
# Balance runs: win rate, turns, Supply left per army, defections, stars,
# card plays; invariants checked after every step (exit code 1 on failure).
dart run tools/sim/bin/sim.dart --mission ch1_m3 --strategy expert --games 1000 --seed 1
dart run tools/sim/bin/sim.dart --mission all --strategy all --games 1000 --json report.json

# Play a mission in the terminal (numbers pick actions; e ends the phase).
dart run tools/sim/bin/sim.dart --play --mission ch1_m2

# Print one game of a strategy, step by step.
dart run tools/sim/bin/sim.dart --trace --mission ch1_m5 --strategy expert --seed 1
```

Strategies:

- `expert`: the historical approach. Reads its goals from the mission
  objectives (`kingAt` havens, `counterattackAt` node), evacuates where the
  army will forage or march, raids once the army cannot forage the Supply
  back, holds only where the engine's battle forecast wins, otherwise falls
  back toward the king, and counterattacks an army below half Supply.
- `naive`: every officer marches to meet the nearest army and attacks;
  never evacuates, raids, ambushes or withdraws.
- `passive`: every officer holds; no cards.
- `random`: random legal actions from the seeded RNG.

The T-13 baseline report is in `docs/balance/sim-baseline-t13.json`.
