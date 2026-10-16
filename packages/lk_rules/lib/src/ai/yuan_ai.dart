import '../engine/events.dart';
import '../engine/tx.dart';
import '../model/enums.dart';
import '../model/game_state.dart';

/// Picks this turn's intent for every active army (T-10 adds rules 2–5).
void assignIntents(Tx tx) {
  for (final id in tx.activeArmyIds()) {
    final intent = chooseIntent(tx, id);
    tx.updateArmy(id, (a) => a.copyWith(intent: intent, predictedIntent: null));
    tx.emit(IntentRevealed(id, intent));
  }
}

Intent chooseIntent(Tx tx, String armyId) {
  for (final e in tx.mission.yuanScript) {
    if (e.turn == tx.s.turn && e.armyId == armyId) {
      return Intent(kind: e.intent, targetNodeId: e.targetNodeId);
    }
  }
  return const Intent(kind: IntentKind.hold);
}
