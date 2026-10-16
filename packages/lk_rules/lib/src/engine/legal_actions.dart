import '../actions/game_action.dart';
import '../model/enums.dart';
import '../model/game_state.dart';
import 'engine.dart';
import 'orders.dart';
import 'tx.dart';

/// Every legal action in [s], in a deterministic order.
List<GameAction> enumerateLegalActions(GameEngine engine, GameState s) {
  if (s.isOver) return const [];
  final choice = s.pendingChoice;
  if (choice != null) {
    return [for (var i = 0; i < choice.optionCount; i++) GameAction.resolveChoice(index: i)];
  }
  final tx = Tx(engine.def, engine.graph, s);
  switch (s.phase) {
    case Phase.council:
      return const [GameAction.endPhase()];
    case Phase.orders:
      return [...legalOrders(tx), const GameAction.endPhase()];
    default:
      return const [];
  }
}

/// SetOrder / ClearOrder actions that are legal now.
List<GameAction> legalOrders(Tx tx) {
  final out = <GameAction>[];
  for (final id in tx.activeOfficerIds()) {
    final o = tx.officer(id);
    if (o.withdrawn) continue;
    for (final order in candidateOrders(tx, id)) {
      try {
        validateOrder(tx, id, order);
        out.add(GameAction.setOrder(officerId: id, order: order));
      } on IllegalAction {
        // Not legal now.
      }
    }
    if (o.order != null) out.add(GameAction.clearOrder(officerId: id));
  }
  return out;
}
