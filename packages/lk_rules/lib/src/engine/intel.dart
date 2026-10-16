import '../ai/yuan_ai.dart';
import '../model/enums.dart';
import 'council.dart';
import 'events.dart';
import 'tx.dart';

/// Intel: armies pick intents, then this turn's scripted Event cards are
/// played. A `choice` stops the queue until it is resolved.
void runIntel(Tx tx) {
  tx.s = tx.s.copyWith(phase: Phase.intel);
  tx.emit(const PhaseChanged(Phase.intel));
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
