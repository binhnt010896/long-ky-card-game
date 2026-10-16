import 'package:lk_rules/lk_rules.dart';

/// Read-only queries on a game state, shared by the strategies and the
/// text-mode player.
final class GameView {
  GameView(this.engine, this.s);

  final GameEngine engine;
  final GameState s;

  Ruleset get def => engine.def;
  MapGraph get graph => engine.graph;
  MissionDef get mission => def.mission;

  List<String> get officerIds => [
        for (final e in s.activeOfficers) e.key,
      ]..sort();

  List<String> get armyIds => [
        for (final e in s.activeArmies) e.key,
      ]..sort();

  OfficerState officer(String id) => s.officers[id]!;
  ArmyState army(String id) => s.armies[id]!;
  OfficerDef officerDef(String id) => def.officers[id]!;

  String? get kingId {
    for (final id in officerIds) {
      if (officerDef(id).isKing) return id;
    }
    return null;
  }

  String? get kingNode => kingId == null ? null : officer(kingId!).nodeId;

  List<String> officersAt(String node) => [for (final id in officerIds) if (officer(id).nodeId == node) id];

  List<String> armiesAt(String node) => [for (final id in armyIds) if (army(id).nodeId == node) id];

  /// Where the army will be after its move this turn.
  String projected(String armyId) => army(armyId).intent?.moveTo ?? army(armyId).nodeId;

  /// Nodes an army will occupy after the Yuan move (ignoring ambushes).
  Set<String> get dangerNodes => {for (final id in armyIds) projected(id)};

  /// Nodes where an army stands now or will stand.
  Set<String> get armyNodes => {for (final id in armyIds) ...[army(id).nodeId, projected(id)]};

  Set<String> moveTargets(String officerId) =>
      graph.moveTargets(officer(officerId).nodeId, maxRiverEdges: Balance.maxRiverEdgesPerMove);

  int distance(String a, String b) => graph.distance(a, b) ?? 99;

  /// Distance from [node] to the nearest army (now or projected).
  int armyDistance(String node) {
    var best = 99;
    for (final n in armyNodes) {
      final d = distance(node, n);
      if (d < best) best = d;
    }
    return best;
  }

  bool held(String node) => s.nodes[node]!.controller == Side.daiViet;

  bool hasRice(String node) => !s.nodes[node]!.evacuated && s.nodes[node]!.riceStock > 0;

  int cardSupportCost(CardDef card) =>
      card.cost.support + (s.unity.court < Balance.unityLowThreshold ? Balance.lowCourtCardSupportSurcharge : 0);

  bool canAfford(String cardId) {
    final c = def.cards[cardId]!;
    return s.rice >= c.cost.rice && s.support >= cardSupportCost(c);
  }

  bool inHand(String cardId) => s.hand.contains(cardId);
}
