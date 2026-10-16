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

  tx.s = tx.s.copyWith(phase: Phase.upkeep);
  tx.emit(const PhaseChanged(Phase.upkeep));
  runUpkeep(tx);
  checkEnd(tx, endOfTurn: true);
  if (tx.s.isOver) return;

  _cleanupTurn(tx);
  tx.s = tx.s.copyWith(turn: tx.s.turn + 1);
  tx.emit(TurnStarted(tx.s.turn));
  runIntel(tx);
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
