import 'package:lk_rules/lk_rules.dart';

import 'view.dart';

/// A player for the simulator. [next] is asked for one action at a time.
abstract class Strategy {
  String get name;

  /// The next action in [s]. Must be legal; the runner checks it.
  GameAction next(GameEngine engine, GameState s);

  /// Called once before each game.
  void reset(int seed) {}

  /// Actions the strategy planned that turned out illegal and were skipped.
  int get skipped => 0;
}

/// A strategy that plans each Council and each Orders phase as a list of
/// actions, and plays the legal ones in order before ending the phase.
abstract class PlannedStrategy extends Strategy {
  final List<GameAction> _queue = [];
  String? _plannedFor;
  int _skipped = 0;

  @override
  int get skipped => _skipped;

  @override
  void reset(int seed) {
    _queue.clear();
    _plannedFor = null;
    _skipped = 0;
  }

  /// Index of the option to take for the pending choice.
  int choose(GameView v) => 0;

  /// Card plays and skill uses for this Council, in order.
  List<GameAction> planCouncil(GameView v);

  /// One order per officer for this Orders phase (missing = hold).
  Map<String, Order> planOrders(GameView v);

  @override
  GameAction next(GameEngine engine, GameState s) {
    final v = GameView(engine, s);
    if (s.pendingChoice != null) return GameAction.resolveChoice(index: choose(v));
    final key = '${s.turn}/${s.phase.name}';
    if (_plannedFor != key) {
      _plannedFor = key;
      _queue
        ..clear()
        ..addAll(s.phase == Phase.council
            ? planCouncil(v)
            : [
                for (final e in planOrders(v).entries)
                  GameAction.setOrder(officerId: e.key, order: e.value),
              ]);
    }
    while (_queue.isNotEmpty) {
      final a = _queue.removeAt(0);
      if (engine.isLegal(s, a)) return a;
      _skipped++;
    }
    return const GameAction.endPhase();
  }
}
