import '../balance.dart';
import '../model/defs.dart';
import '../model/enums.dart';
import '../model/game_state.dart';
import '../rng/seeded_rng.dart';
import 'events.dart';
import 'graph.dart';

/// Thrown for an action that is not legal in the current state. The UI must
/// prevent these; [code] is stable and tested.
final class IllegalAction implements Exception {
  const IllegalAction(this.code, [this.message = '']);

  final String code;
  final String message;

  @override
  String toString() => message.isEmpty ? 'IllegalAction($code)' : 'IllegalAction($code): $message';
}

/// Stable [IllegalAction.code] values.
abstract final class IllegalCodes {
  static const String gameOver = 'gameOver';
  static const String choicePending = 'choicePending';
  static const String wrongPhase = 'wrongPhase';
  static const String noChoicePending = 'noChoicePending';
  static const String badChoiceIndex = 'badChoiceIndex';
  static const String cardNotInHand = 'cardNotInHand';
  static const String cannotAfford = 'cannotAfford';
  static const String conditionFailed = 'conditionFailed';
  static const String badTarget = 'badTarget';
  static const String unknownOfficer = 'unknownOfficer';
  static const String officerInactive = 'officerInactive';
  static const String officerWithdrawn = 'officerWithdrawn';
  static const String noActivatedSkill = 'noActivatedSkill';
  static const String noUsesLeft = 'noUsesLeft';
  static const String illegalOrder = 'illegalOrder';
  static const String noOrder = 'noOrder';
  static const String alreadyEvacuated = 'alreadyEvacuated';
  static const String noWithdrawal = 'noWithdrawal';
  static const String noAmbusher = 'noAmbusher';
}

/// The result of one engine step.
final class StepResult {
  const StepResult(this.state, this.events);

  final GameState state;
  final List<GameEvent> events;
}

/// Working context for one step: the evolving immutable state plus the events
/// emitted so far. Discarded if the step throws, so steps are atomic.
final class Tx {
  Tx(this.def, this.graph, this.s);

  final Ruleset def;
  final MapGraph graph;
  GameState s;
  final List<GameEvent> events = [];

  MissionDef get mission => def.mission;

  void emit(GameEvent e) => events.add(e);

  // -- Lookups ---------------------------------------------------------------

  OfficerState officer(String id) => s.officers[id]!;
  ArmyState army(String id) => s.armies[id]!;
  NodeState node(String id) => s.nodes[id]!;
  OfficerDef officerDef(String id) => def.officers[id]!;
  CommanderDef commanderDef(String armyId) => def.commanders[army(armyId).commanderId]!;

  bool isActiveOfficer(String id) => s.officers[id]?.status == OfficerStatus.active;
  bool isActiveArmy(String id) => s.armies[id]?.status == ArmyStatus.active;

  /// Active officer ids, sorted.
  List<String> activeOfficerIds() =>
      (s.activeOfficers.map((e) => e.key).toList()..sort());

  /// Active army ids, sorted.
  List<String> activeArmyIds() => (s.activeArmies.map((e) => e.key).toList()..sort());

  List<String> activeOfficersAt(String nodeId) =>
      [for (final id in activeOfficerIds()) if (officer(id).nodeId == nodeId) id];

  List<String> activeArmiesAt(String nodeId) =>
      [for (final id in activeArmyIds()) if (army(id).nodeId == nodeId) id];

  /// The mission's king officer id, if any.
  String? get kingId {
    for (final id in s.officers.keys.toList()..sort()) {
      if (def.officers[id]?.isKing ?? false) return id;
    }
    return null;
  }

  /// The king's node if the king is active.
  String? get kingNodeId {
    final k = kingId;
    if (k == null || !isActiveOfficer(k)) return null;
    return officer(k).nodeId;
  }

  // -- Updates ---------------------------------------------------------------

  void setOfficer(String id, OfficerState o) => s = s.copyWith(officers: {...s.officers, id: o});

  void updateOfficer(String id, OfficerState Function(OfficerState o) f) => setOfficer(id, f(officer(id)));

  void setArmy(String id, ArmyState a) => s = s.copyWith(armies: {...s.armies, id: a});

  void updateArmy(String id, ArmyState Function(ArmyState a) f) => setArmy(id, f(army(id)));

  void setNode(String id, NodeState n) => s = s.copyWith(nodes: {...s.nodes, id: n});

  void updateNode(String id, NodeState Function(NodeState n) f) => setNode(id, f(node(id)));

  void updateStats(MissionStats Function(MissionStats m) f) => s = s.copyWith(missionStats: f(s.missionStats));

  void setUnity(Pillar p, int value) {
    final from = s.unity[p];
    final to = value.clamp(Balance.unityMin, Balance.unityMax);
    if (from == to) return;
    s = s.copyWith(unity: s.unity.withPillar(p, to));
    emit(UnityChanged(p, from, to));
  }

  void modUnity(Pillar p, int delta) => setUnity(p, s.unity[p] + delta);

  void setResource(Resource r, int value) {
    final from = r == Resource.rice ? s.rice : s.support;
    final to = value < 0 ? 0 : value;
    if (from == to) return;
    s = r == Resource.rice ? s.copyWith(rice: to) : s.copyWith(support: to);
    emit(ResourceChanged(r, from, to));
  }

  void modResource(Resource r, int delta) =>
      setResource(r, (r == Resource.rice ? s.rice : s.support) + delta);

  void addFlag(String flag) {
    if (!s.flags.contains(flag)) s = s.copyWith(flags: [...s.flags, flag]);
  }

  void removeFlag(String flag) {
    if (s.flags.contains(flag)) s = s.copyWith(flags: [...s.flags]..remove(flag));
  }

  void setOfficerMorale(String id, int morale) => updateOfficer(
      id, (o) => o.copyWith(morale: morale.clamp(Balance.moraleMin, Balance.moraleMax)));

  void setArmyMorale(String id, int morale) =>
      updateArmy(id, (a) => a.copyWith(morale: morale.clamp(Balance.moraleMin, Balance.moraleMax)));

  /// Runs [f] with the game's RNG and stores the advanced RNG state.
  T withRng<T>(T Function(SeededRng rng) f) {
    final rng = SeededRng.fromState(s.rng);
    final out = f(rng);
    s = s.copyWith(rng: rng.state);
    return out;
  }
}

/// `ceil(x)` that ignores float noise just above an integer.
int ceilSafe(double x) => (x - Balance.roundingEpsilon).ceil();
