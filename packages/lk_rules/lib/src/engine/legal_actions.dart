import '../actions/game_action.dart';
import '../model/enums.dart';
import '../model/game_state.dart';
import 'engine.dart';
import 'council.dart';
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
      return [...legalCouncilActions(engine, tx), const GameAction.endPhase()];
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

/// PlayCard / UseSkill actions that are legal now.
List<GameAction> legalCouncilActions(GameEngine engine, Tx tx) {
  final out = <GameAction>[];
  final seen = <String>{};
  for (final cardId in tx.s.hand) {
    if (!seen.add(cardId)) continue;
    final card = tx.def.cards[cardId]!;
    for (final target in candidateTargets(tx, card.target)) {
      final a = GameAction.playCard(cardId: cardId, target: target);
      if (engine.isLegal(tx.s, a)) out.add(a);
    }
  }
  for (final id in tx.activeOfficerIds()) {
    final skill = tx.officerDef(id).skill;
    if (skill == null || skill.kind != SkillKind.activated || tx.officer(id).skillUsesLeft <= 0) continue;
    for (final target in candidateTargets(tx, skill.target)) {
      final a = GameAction.useSkill(officerId: id, target: target);
      if (engine.isLegal(tx.s, a)) out.add(a);
    }
  }
  return out;
}
