import '../actions/game_action.dart';
import '../balance.dart';
import '../model/defs.dart';
import '../model/enums.dart';
import '../model/game_state.dart';
import '../rng/seeded_rng.dart';
import 'council.dart';
import 'events.dart';
import 'forecast.dart';
import 'graph.dart';
import 'intel.dart';
import 'legal_actions.dart';
import 'objectives.dart';
import 'orders.dart';
import 'turn.dart';
import 'tx.dart';
import 'upkeep.dart';

/// The rules engine for one mission. [apply] is a pure function of its
/// inputs: the same state and action always give the same result.
final class GameEngine {
  GameEngine(this.def) : graph = MapGraph(def.map);

  final Ruleset def;
  final MapGraph graph;

  /// The start of the mission: setup, the opening hand, then Intel of turn 1.
  /// Stops at Council (with a pending choice if a scripted event asks one).
  StepResult newGame(int seed) {
    final m = def.mission;
    final rng = SeededRng(seed);

    final armyNodes = {for (final a in m.yuanArmies) a.nodeId};
    final nodes = <String, NodeState>{
      for (final id in graph.nodeIds)
        id: NodeState(
          controller: armyNodes.contains(id) ? Side.yuan : Side.daiViet,
          riceStock: graph.node(id).riceYield * Balance.riceStockPerYield,
        ),
    };

    final officerSetups = [...m.playerOfficers]..sort((a, b) => a.officerId.compareTo(b.officerId));
    final officers = <String, OfficerState>{
      for (final p in officerSetups) p.officerId: _startingOfficer(p),
    };

    final armySetups = [...m.yuanArmies]..sort((a, b) => a.id.compareTo(b.id));
    final armies = <String, ArmyState>{
      for (final a in armySetups)
        a.id: ArmyState(
          commanderId: a.commanderId,
          nodeId: a.nodeId,
          troops: a.troops,
          supply: a.supply,
          maxSupply: a.maxSupply,
          morale: a.morale,
          retreatNodeId: a.retreatNodeId,
        ),
    };

    final deck = rng.shuffled([
      for (final e in m.deck)
        for (var i = 0; i < e.count; i++) e.cardId,
    ]);

    final capital = graph.capitalId;
    final state = GameState(
      missionId: m.id,
      seed: seed,
      rng: rng.state,
      turn: 1,
      phase: Phase.intel,
      rice: m.start.rice,
      support: m.start.support,
      unity: Unity(court: m.start.unity.court, clan: m.start.unity.clan, people: m.start.unity.people),
      nodes: nodes,
      officers: officers,
      armies: armies,
      deck: deck,
      flags: [
        if (capital != null && nodes[capital]!.controller == Side.yuan) GameFlags.capitalLost,
      ],
    );

    final tx = Tx(def, graph, state);
    tx.emit(const TurnStarted(1));
    drawToHandSize(tx);
    runIntel(tx);
    checkEnd(tx, endOfTurn: false);
    return StepResult(tx.s, tx.events);
  }

  OfficerState _startingOfficer(PlayerOfficerSetup p) {
    final d = def.officers[p.officerId]!;
    final cap = d.troopCap;
    final skill = d.skill;
    return OfficerState(
      nodeId: p.nodeId,
      troops: cap != null && p.troops > cap ? cap : p.troops,
      morale: Balance.officerStartMorale,
      loyalty: d.stats.loyalty,
      skillUsesLeft: skill != null && skill.kind == SkillKind.activated ? skill.usesPerMission : 0,
    );
  }

  /// Applies [action] to [state]. Throws [IllegalAction] if it is not legal;
  /// the input state is never modified.
  StepResult apply(GameState state, GameAction action) {
    if (state.isOver && !(action is ContinueFreePlay && state.outcome != null && !state.freePlay)) {
      throw const IllegalAction(IllegalCodes.gameOver);
    }
    if (state.pendingChoice != null && action is! ResolveChoice) {
      throw const IllegalAction(IllegalCodes.choicePending);
    }
    final tx = Tx(def, graph, state);
    switch (action) {
      case PlayCard():
        _requirePhase(state, Phase.council);
        playCard(tx, action);
      case UseSkill():
        _requirePhase(state, Phase.council);
        useSkill(tx, action);
      case ResolveChoice():
        resolveChoice(tx, action);
      case SetOrder():
        _requirePhase(state, Phase.orders);
        setOrder(tx, action);
      case ClearOrder():
        _requirePhase(state, Phase.orders);
        clearOrder(tx, action);
      case ContinueFreePlay():
        if (!state.isOver) throw IllegalAction(IllegalCodes.wrongPhase, 'free play starts after the mission ends');
        continueFreePlay(tx);
      case EndPhase():
        if (state.phase == Phase.council) {
          if (state.hasFlag(GameFlags.skipOrders)) {
            tx.emit(const OrdersSkipped());
            endTurn(tx);
          } else {
            tx.s = tx.s.copyWith(phase: Phase.orders);
            tx.emit(const PhaseChanged(Phase.orders));
          }
        } else if (state.phase == Phase.orders) {
          endTurn(tx);
        } else {
          throw IllegalAction(IllegalCodes.wrongPhase, 'EndPhase in ${state.phase.name}');
        }
    }
    checkEnd(tx, endOfTurn: false);
    tx.s = tx.s.copyWith(log: [...tx.s.log, action]);
    return StepResult(tx.s, tx.events);
  }

  /// Whether [action] is legal in [state].
  bool isLegal(GameState state, GameAction action) {
    try {
      apply(state, action);
      return true;
    } on IllegalAction {
      return false;
    }
  }

  /// Every legal action in [state], in a deterministic order.
  List<GameAction> legalActions(GameState state) => enumerateLegalActions(this, state);

  /// Preview of a field battle at [nodeId] in [state] (see [forecastFieldBattleIn]).
  BattleForecast forecastBattle(
    GameState state,
    String nodeId, {
    required List<String> officerIds,
    List<String>? armyIds,
    Set<String> moving = const {},
    Map<String, Order?> orders = const {},
  }) =>
      forecastFieldBattleIn(Tx(def, graph, state), nodeId,
          officerIds: officerIds, armyIds: armyIds, moving: moving, orders: orders);

  /// Preview of an ambush by [officerId] on [armyId], over the roll range.
  BattleForecast forecastAmbush(GameState state, String officerId, String armyId) =>
      forecastAmbushIn(Tx(def, graph, state), officerId, armyId);

  /// Replays [actions] from the mission start with [seed].
  GameState replay(int seed, Iterable<GameAction> actions) {
    var s = newGame(seed).state;
    for (final a in actions) {
      s = apply(s, a).state;
    }
    return s;
  }

  void _requirePhase(GameState s, Phase phase) {
    if (s.phase != phase) {
      throw IllegalAction(IllegalCodes.wrongPhase, 'needs ${phase.name}, is ${s.phase.name}');
    }
  }
}
