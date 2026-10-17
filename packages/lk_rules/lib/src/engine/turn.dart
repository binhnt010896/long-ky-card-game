import '../model/enums.dart';
import '../model/game_state.dart';
import 'events.dart';
import 'intel.dart';
import 'objectives.dart';
import 'resolution.dart';
import 'tx.dart';
import 'upkeep.dart';

/// Orders → Resolution → Upkeep → (next turn) Intel → Council.
void endTurn(Tx tx) {
  tx.s = tx.s.copyWith(phase: Phase.resolution);
  tx.emit(const PhaseChanged(Phase.resolution));
  runResolution(tx);
  checkEnd(tx, endOfTurn: false);
  if (tx.s.isOver) return;
  _afterResolution(tx);
}

void _afterResolution(Tx tx) {
  tx.s = tx.s.copyWith(phase: Phase.upkeep);
  tx.emit(const PhaseChanged(Phase.upkeep));
  runUpkeep(tx);
  checkEnd(tx, endOfTurn: true);
  if (tx.s.isOver) return;
  _afterUpkeep(tx);
}

void _afterUpkeep(Tx tx) {
  _cleanupTurn(tx);
  tx.s = tx.s.copyWith(turn: tx.s.turn + 1);
  tx.emit(TurnStarted(tx.s.turn));
  runIntel(tx);
}

/// After the mission ended: keep playing. The rest of the turn that was cut
/// short is finished, then play goes on from where it stood.
void continueFreePlay(Tx tx) {
  final from = tx.s.endedIn ?? Phase.council;
  tx.s = tx.s.copyWith(freePlay: true, endedIn: null);
  tx.emit(const FreePlayStarted());
  switch (from) {
    case Phase.resolution:
      _afterResolution(tx);
    case Phase.upkeep:
      _afterUpkeep(tx);
    case Phase.orders:
      tx.s = tx.s.copyWith(phase: Phase.orders);
      tx.emit(const PhaseChanged(Phase.orders));
    default:
      tx.s = tx.s.copyWith(phase: Phase.council);
      tx.emit(const PhaseChanged(Phase.council));
  }
}

/// Clears everything that lasts only one turn.
void _cleanupTurn(Tx tx) {
  final officers = <String, OfficerState>{
    for (final e in tx.s.officers.entries) e.key: e.value.copyWith(order: null, withdrawn: false),
  };
  tx.s = tx.s.copyWith(
    officers: officers,
    ambushes: const [],
    evacuationsThisTurn: 0,
  );
  tx.removeFlag(GameFlags.skipOrders);
}
