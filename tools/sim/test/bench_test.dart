import 'package:lk_content/io.dart';
import 'package:lk_content/lk_content.dart';
import 'package:lk_rules/lk_rules.dart';
import 'package:sim/sim.dart';
import 'package:test/test.dart';

/// Build-spec section 7, performance: "a full engine step under 5 ms on a
/// mid-range phone". Measured here on the machine running the tests (a
/// desktop-class CPU, JIT), so the limits are a fraction of 5 ms: p99 of every
/// step under 1 ms, and of the heaviest step (Resolution and Upkeep) under 2 ms.
/// A single slowest step is not asserted: garbage collection makes it noisy.
void main() {
  final content = loadContent(readContentDir(findContentDir()!));

  for (final missionId in content.missions.keys) {
    test('$missionId: engine steps are fast', () {
      final engine = GameEngine(content.ruleset(missionId));
      for (final name in ['expert', 'random']) {
        final t = benchSteps(engine, strategyByName(name), games: 60, seed: 1);
        expect(t.count, greaterThan(100), reason: name);
        expect(t.percentile(0.99), lessThan(1000), reason: '$name p99 (µs) of every step');
        expect(t.resolutionPercentile(0.99), lessThan(2000), reason: '$name p99 (µs) of Resolution');
      }
    });
  }
}
