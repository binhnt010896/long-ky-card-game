/// Headless balance simulator and text-mode player for Long Ký - The Game.
library;

export 'src/bench.dart';
export 'src/describe.dart';
export 'src/invariants.dart';
export 'src/play.dart';
export 'src/runner.dart';
export 'src/strategies/expert.dart';
export 'src/strategies/naive.dart';
export 'src/strategies/passive.dart';
export 'src/strategies/random.dart';
export 'src/strategy.dart';
export 'src/view.dart';

import 'src/strategies/expert.dart';
import 'src/strategies/naive.dart';
import 'src/strategies/passive.dart';
import 'src/strategies/random.dart';
import 'src/strategy.dart';

/// The four strategies of build-spec section 7, by name.
const List<String> strategyNames = ['expert', 'naive', 'passive', 'random'];

Strategy strategyByName(String name) => switch (name) {
      'expert' => ExpertStrategy(),
      'naive' => NaiveStrategy(),
      'passive' => PassiveStrategy(),
      'random' => RandomStrategy(),
      _ => throw ArgumentError.value(name, 'strategy', 'one of ${strategyNames.join(', ')}'),
    };
