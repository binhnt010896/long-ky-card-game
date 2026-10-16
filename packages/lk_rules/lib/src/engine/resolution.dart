import '../model/enums.dart';
import 'events.dart';
import 'tx.dart';

/// Resolution, in the order of build-spec section 4.
void runResolution(Tx tx) {
  updateNodeControl(tx);
}

/// Step 6: a node with only one side present goes to that side.
void updateNodeControl(Tx tx) {
  for (final id in tx.graph.nodeIds) {
    final dv = tx.activeOfficersAt(id).isNotEmpty;
    final yuan = tx.activeArmiesAt(id).isNotEmpty;
    final to = dv && !yuan
        ? Side.daiViet
        : yuan && !dv
            ? Side.yuan
            : null;
    final from = tx.node(id).controller;
    if (to == null || to == from) continue;
    tx.updateNode(id, (n) => n.copyWith(controller: to));
    tx.emit(NodeControlChanged(id, from, to));
  }
}
