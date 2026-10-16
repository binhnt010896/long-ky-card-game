import 'package:lk_content/io.dart';
import 'package:lk_content/lk_content.dart';
import 'package:lk_rules/lk_rules.dart';
import 'package:sim/sim.dart';
import 'package:test/test.dart';

/// The Chapter 1 balance targets of build-spec section 7 (T-25), kept as a
/// test so that a content or rules change which breaks them is caught.
///
/// `min` is a lowest win rate, `max` a highest one, as fractions.
void main() {
  final content = loadContent(readContentDir(findContentDir()!));

  const games = 300;
  const seed = 1;

  const targets =
      <String, ({double expertMin, double? naiveMin, double? naiveMax, double? randomMin, double? randomMax})>{
        'ch1_m1': (expertMin: 0.95, naiveMin: 0.80, naiveMax: null, randomMin: 0.50, randomMax: null),
        'ch1_m2': (expertMin: 0.90, naiveMin: null, naiveMax: 0.20, randomMin: null, randomMax: 0.15),
        'ch1_m3': (expertMin: 0.90, naiveMin: null, naiveMax: 0.20, randomMin: null, randomMax: 0.10),
        'ch1_m4': (expertMin: 0.85, naiveMin: null, naiveMax: 0.30, randomMin: null, randomMax: 0.10),
        'ch1_m5': (expertMin: 0.85, naiveMin: null, naiveMax: 0.25, randomMin: null, randomMax: 0.10),
      };

  double winRate(String missionId, String strategy) {
    final engine = GameEngine(content.ruleset(missionId));
    final report = runGames(engine, strategyByName(strategy), games: games, seed: seed);
    expect(report.violationCount, 0, reason: report.violations.join('\n'));
    return report.winRate;
  }

  for (final entry in targets.entries) {
    final id = entry.key;
    final t = entry.value;
    group('balance $id', () {
      test('expert wins at least ${t.expertMin}', () {
        expect(winRate(id, 'expert'), greaterThanOrEqualTo(t.expertMin));
      });
      test('naive stays within its band', () {
        final w = winRate(id, 'naive');
        if (t.naiveMin != null) expect(w, greaterThanOrEqualTo(t.naiveMin!));
        if (t.naiveMax != null) expect(w, lessThanOrEqualTo(t.naiveMax!));
      });
      test('random stays within its band', () {
        final w = winRate(id, 'random');
        if (t.randomMin != null) expect(w, greaterThanOrEqualTo(t.randomMin!));
        if (t.randomMax != null) expect(w, lessThanOrEqualTo(t.randomMax!));
      });
    });
  }

  test('doing nothing never wins a Chapter 1 mission after the first (the tutorial)', () {
    for (final id in targets.keys.skip(1)) {
      expect(winRate(id, 'passive'), lessThanOrEqualTo(0.05), reason: id);
    }
  });

  test('every star is reachable by the expert in every mission (the stars can all be earned)', () {
    for (final id in targets.keys) {
      final engine = GameEngine(content.ruleset(id));
      final report = runGames(engine, strategyByName('expert'), games: 50, seed: seed);
      for (var i = 0; i < report.stars.length; i++) {
        expect(report.stars[i], greaterThan(0), reason: '$id star ${i + 1}');
      }
    }
  });
}
