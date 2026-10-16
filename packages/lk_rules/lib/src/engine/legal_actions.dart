import '../actions/game_action.dart';
import '../model/enums.dart';
import '../model/game_state.dart';
import 'engine.dart';

/// Every legal action in [s], in a deterministic order.
List<GameAction> enumerateLegalActions(GameEngine engine, GameState s) {
  if (s.isOver) return const [];
  final choice = s.pendingChoice;
  if (choice != null) {
    return [for (var i = 0; i < choice.optionCount; i++) GameAction.resolveChoice(index: i)];
  }
  return switch (s.phase) {
    Phase.council || Phase.orders => const [GameAction.endPhase()],
    _ => const [],
  };
}
