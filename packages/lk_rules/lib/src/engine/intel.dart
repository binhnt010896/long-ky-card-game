import '../ai/yuan_ai.dart';
import '../balance.dart';
import '../model/enums.dart';
import 'council.dart';
import 'events.dart';
import 'tx.dart';

/// Intel: armies pick intents, then this turn's scripted Event cards are
/// played. A `choice` stops the queue until it is resolved.
void runIntel(Tx tx) {
  tx.s = tx.s.copyWith(phase: Phase.intel);
  tx.emit(const PhaseChanged(Phase.intel));
  _updateRevealDepth(tx);
  assignIntents(tx);

  final turn = tx.s.turn;
  final scripted = [
    for (final e in tx.mission.scriptedEvents)
      if (e.turn == turn) e.cardId,
  ];
  tx.s = tx.s.copyWith(scriptedQueue: scripted);
  processScriptedQueue(tx);

  tx.s = tx.s.copyWith(phase: Phase.council);
  tx.emit(const PhaseChanged(Phase.council));
}

/// `revealDepth` is 1, or 2 while a `borderWatch` officer stands on a border node.
void _updateRevealDepth(Tx tx) {
  var depth = Balance.baseRevealDepth;
  for (final id in tx.activeOfficerIds()) {
    if (tx.officerDef(id).hasPassive(PassiveIds.borderWatch) && tx.graph.node(tx.officer(id).nodeId).isBorder) {
      depth = Balance.borderWatchRevealDepth;
    }
  }
  if (depth != tx.s.revealDepth) tx.emit(RevealDepthChanged(depth));
  tx.s = tx.s.copyWith(revealDepth: depth);
}
