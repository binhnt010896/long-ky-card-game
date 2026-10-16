import '../balance.dart';
import '../model/enums.dart';
import 'events.dart';
import 'tx.dart';

/// Evacuates [nodeId]: it gives no forage or income for the rest of the
/// mission, and the player gains its `riceStock` as Rice. Every evacuation
/// after the first in a turn costs 1 People.
void evacuateNode(Tx tx, String nodeId) {
  final n = tx.node(nodeId);
  if (n.evacuated) throw IllegalAction(IllegalCodes.alreadyEvacuated, nodeId);
  final rice = n.riceStock;
  tx.updateNode(nodeId, (n) => n.copyWith(evacuated: true, riceStock: 0));
  tx.modResource(Resource.rice, rice);
  tx.s = tx.s.copyWith(evacuationsThisTurn: tx.s.evacuationsThisTurn + 1);
  tx.updateStats((m) => m.copyWith(evacuations: m.evacuations + 1));
  tx.emit(NodeEvacuated(nodeId, rice));
  if (tx.s.evacuationsThisTurn > 1) tx.modUnity(Pillar.people, -Balance.extraEvacuationPeopleLoss);
}
