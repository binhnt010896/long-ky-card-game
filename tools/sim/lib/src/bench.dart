import 'package:lk_rules/lk_rules.dart';

import 'strategy.dart';

/// How long engine steps took, in microseconds.
final class StepTimings {
  StepTimings(this.micros, this.resolutionMicros);

  /// Every `GameEngine.apply` call.
  final List<int> micros;

  /// Only the `EndPhase` that runs Resolution and Upkeep: the heaviest step.
  final List<int> resolutionMicros;

  static int _percentile(List<int> sorted, double p) =>
      sorted.isEmpty ? 0 : sorted[((sorted.length - 1) * p).round()];

  static List<int> _sorted(List<int> xs) => [...xs]..sort();

  int get count => micros.length;
  int percentile(double p) => _percentile(_sorted(micros), p);
  int get max => micros.isEmpty ? 0 : _sorted(micros).last;
  double get mean => micros.isEmpty ? 0 : micros.reduce((a, b) => a + b) / micros.length;

  int resolutionPercentile(double p) => _percentile(_sorted(resolutionMicros), p);
  int get resolutionMax => resolutionMicros.isEmpty ? 0 : _sorted(resolutionMicros).last;

  Map<String, Object?> toJson() => {
        'steps': count,
        'meanMicros': mean.round(),
        'p50Micros': percentile(0.5),
        'p95Micros': percentile(0.95),
        'p99Micros': percentile(0.99),
        'maxMicros': max,
        'resolutionSteps': resolutionMicros.length,
        'resolutionP99Micros': resolutionPercentile(0.99),
        'resolutionMaxMicros': resolutionMax,
      };
}

/// Times every engine step of [games] games (build-spec section 7, performance:
/// "a full engine step under 5 ms on a mid-range phone"). The strategy's own
/// thinking is not timed, only `engine.apply`. A short warm-up game is played
/// first so the JIT is not counted.
StepTimings benchSteps(GameEngine engine, Strategy strategy, {required int games, required int seed}) {
  final micros = <int>[];
  final resolution = <int>[];
  void play(int s, {required bool record}) {
    strategy.reset(s);
    var state = engine.newGame(s).state;
    var steps = 0;
    while (!state.isOver && steps++ < 5000) {
      final action = strategy.next(engine, state);
      final inOrders = state.phase == Phase.orders;
      final watch = Stopwatch()..start();
      state = engine.apply(state, action).state;
      watch.stop();
      if (record) {
        micros.add(watch.elapsedMicroseconds);
        if (inOrders && action is EndPhase) resolution.add(watch.elapsedMicroseconds);
      }
    }
  }

  play(seed - 1, record: false);
  for (var i = 0; i < games; i++) {
    play(seed + i, record: true);
  }
  return StepTimings(micros, resolution);
}
