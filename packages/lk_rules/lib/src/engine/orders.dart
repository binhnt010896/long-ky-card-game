import '../actions/game_action.dart';
import '../balance.dart';
import '../model/enums.dart';
import '../model/game_state.dart';
import 'events.dart';
import 'tx.dart';

/// SetOrder: one order per active officer; orders can change until EndPhase.
void setOrder(Tx tx, SetOrder action) {
  validateOrder(tx, action.officerId, action.order);
  tx.updateOfficer(action.officerId, (o) => o.copyWith(order: action.order));
  tx.emit(OrderSet(action.officerId, action.order));
}

void clearOrder(Tx tx, ClearOrder action) {
  final o = _orderableOfficer(tx, action.officerId);
  if (o.order == null) throw const IllegalAction(IllegalCodes.noOrder);
  tx.updateOfficer(action.officerId, (o) => o.copyWith(order: null));
  tx.emit(OrderSet(action.officerId, null));
}

OfficerState _orderableOfficer(Tx tx, String id) {
  final o = tx.s.officers[id];
  if (o == null) throw IllegalAction(IllegalCodes.unknownOfficer, id);
  if (o.status != OfficerStatus.active) throw IllegalAction(IllegalCodes.officerInactive, id);
  if (o.withdrawn) throw IllegalAction(IllegalCodes.officerWithdrawn, id);
  return o;
}

/// Support cost of one evacuation by order (more when People is low).
int evacuateOrderCost(Tx tx) => tx.s.unity.people < Balance.unityLowThreshold
    ? Balance.evacuateSupportCostLowPeople
    : Balance.evacuateSupportCost;

/// Throws [IllegalAction] unless [officerId] may take [order] now.
void validateOrder(Tx tx, String officerId, Order order) {
  final o = _orderableOfficer(tx, officerId);
  final here = o.nodeId;
  void fail(String why) => throw IllegalAction(IllegalCodes.illegalOrder, '${order.kind.name}: $why');

  switch (order.kind) {
    case OrderKind.hold:
    case OrderKind.rally:
      if (order.target != null) fail('takes no target');
    case OrderKind.move:
      final to = order.target;
      if (to == null || !tx.graph.moveTargets(here, maxRiverEdges: Balance.maxRiverEdgesPerMove).contains(to)) {
        fail('$to is not one land edge or up to two river edges from $here');
      }
    case OrderKind.evacuate:
      if (order.target != null && order.target != here) fail('only the officer\'s own node');
      final node = tx.node(here);
      if (node.evacuated) throw IllegalAction(IllegalCodes.alreadyEvacuated, here);
      if (node.controller != Side.daiViet) fail('$here is not held');
      var others = 0;
      for (final id in tx.activeOfficerIds()) {
        if (id == officerId) continue;
        final other = tx.officer(id);
        if (other.order?.kind != OrderKind.evacuate) continue;
        if (other.nodeId == here) fail('$id already evacuates $here');
        others++;
      }
      if ((others + 1) * evacuateOrderCost(tx) > tx.s.support) {
        throw const IllegalAction(IllegalCodes.cannotAfford, 'not enough Support to evacuate');
      }
    case OrderKind.raid:
      final armyId = order.target;
      if (armyId == null || !tx.isActiveArmy(armyId)) fail('no active army $armyId');
      if (!tx.graph.adjacent(here, tx.army(armyId!).nodeId)) fail('$armyId is not on an adjacent node');
    case OrderKind.ambush:
      final edge = tx.graph.edges[order.target];
      if (edge == null || edge.kind != EdgeKind.river) fail('${order.target} is not a river edge');
      if (!edge!.touches(here)) fail('${order.target} does not touch $here');
  }
}

/// Every order [officerId] could take now (legal or not); callers filter.
List<Order> candidateOrders(Tx tx, String officerId) {
  final here = tx.officer(officerId).nodeId;
  final moves = tx.graph.moveTargets(here, maxRiverEdges: Balance.maxRiverEdgesPerMove).toList()..sort();
  return [
    Order.hold,
    for (final to in moves) Order.move(to),
    Order.evacuate,
    for (final armyId in tx.activeArmyIds()) Order.raid(armyId),
    for (final n in tx.graph.neighbors(here))
      if (tx.graph.edge(here, n)!.kind == EdgeKind.river) Order.ambush(tx.graph.edge(here, n)!.key),
    Order.rally,
  ];
}
