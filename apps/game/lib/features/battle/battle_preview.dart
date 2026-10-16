import 'package:lk_rules/lk_rules.dart';

/// A battle the player is about to cause with an order (build-spec section 6,
/// "Battle preview"): who fights where, and the engine's forecast.
final class BattlePreview {
  const BattlePreview({
    required this.kind,
    required this.nodeId,
    required this.officerIds,
    required this.armyIds,
    required this.forecast,
    this.edge,
  });

  final BattleKind kind;
  final String nodeId;
  final List<String> officerIds;
  final List<String> armyIds;
  final BattleForecast forecast;

  /// The river edge of an ambush.
  final String? edge;

  /// An ambush's result depends on the roll.
  bool get isRange => kind == BattleKind.ambush;

  /// The result is the same at both ends of the roll.
  bool get certain => forecast.winner == forecast.winnerAtMaxRoll;
}

/// The battles that giving [officerId] [order] would cause, judged from the
/// armies' revealed intents: an army fights where it stands unless its intent
/// moves it, and where it is going if it does.
///
/// Returns nothing when no battle follows (the order is then given at once).
List<BattlePreview> battlePreviewsFor(GameEngine engine, GameState state, String officerId, Order order) {
  final orders = <String, Order?>{for (final e in state.activeOfficers) e.key: e.value.order, officerId: order};
  String destination(String id) {
    final o = orders[id];
    final from = state.officers[id]!.nodeId;
    return o != null && o.kind == OrderKind.move ? o.target ?? from : from;
  }

  String armyDestination(ArmyState a) => a.intent?.moveTo ?? a.nodeId;

  final out = <BattlePreview>[];

  // An ambush on the edge a Yuan army is about to cross.
  if (order.kind == OrderKind.ambush) {
    final here = state.officers[officerId]!.nodeId;
    for (final e in state.activeArmies) {
      final a = e.value;
      final to = a.intent?.moveTo;
      if (to == null) continue;
      final edge = engine.graph.edge(a.nodeId, to);
      if (edge == null || edge.key != order.target) continue;
      out.add(
        BattlePreview(
          kind: BattleKind.ambush,
          nodeId: here,
          edge: edge.key,
          officerIds: [officerId],
          armyIds: [e.key],
          forecast: engine.forecastAmbush(state, officerId, e.key),
        ),
      );
    }
  }

  // A field battle where this officer ends the turn, with everyone else
  // who ends it there too.
  final node = destination(officerId);
  final armies = [
    for (final e in state.activeArmies)
      if (armyDestination(e.value) == node) e.key,
  ];
  if (armies.isNotEmpty) {
    final officers = [
      for (final e in state.activeOfficers)
        if (destination(e.key) == node && !e.value.withdrawn) e.key,
    ];
    final moving = {
      for (final id in officers)
        if (orders[id]?.kind == OrderKind.move) id,
    };
    out.add(
      BattlePreview(
        kind: BattleKind.field,
        nodeId: node,
        officerIds: officers,
        armyIds: armies,
        forecast: engine.forecastBattle(
          state,
          node,
          officerIds: officers,
          armyIds: armies,
          moving: moving,
          orders: orders,
        ),
      ),
    );
  }
  return out;
}
