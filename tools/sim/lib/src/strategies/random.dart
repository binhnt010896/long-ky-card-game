import 'package:lk_rules/lk_rules.dart';

import '../strategy.dart';

/// Random legal actions from the seeded RNG. EndPhase is taken with
/// probability [endPhaseChance] when legal, so phases do not drag on.
final class RandomStrategy extends Strategy {
  RandomStrategy({this.endPhaseChance = 0.3});

  final double endPhaseChance;
  SeededRng _rng = SeededRng(0);

  @override
  String get name => 'random';

  @override
  void reset(int seed) => _rng = SeededRng(seed ^ 0x5DEECE66D);

  @override
  GameAction next(GameEngine engine, GameState s) {
    final legal = engine.legalActions(s);
    if (legal.contains(const GameAction.endPhase()) && _rng.nextDouble() < endPhaseChance) {
      return const GameAction.endPhase();
    }
    return legal[_rng.nextInt(legal.length)];
  }
}
