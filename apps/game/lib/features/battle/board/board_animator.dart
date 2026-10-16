import 'package:lk_rules/lk_rules.dart';

import 'board_scene.dart';

/// One visual effect on the board, made from a [GameEvent].
sealed class BoardEffect {
  const BoardEffect();

  /// Seconds.
  double get duration;
}

/// A unit's token travels from one node to another.
final class MoveEffect extends BoardEffect {
  const MoveEffect({required this.unitId, required this.kind, required this.from, required this.to});

  final String unitId;
  final TokenKind kind;
  final String from;
  final String to;

  @override
  double get duration => 0.4;
}

/// Clash at a node; [winner] colours it.
final class BattleEffect extends BoardEffect {
  const BattleEffect({required this.nodeId, required this.winner});

  final String nodeId;
  final Side winner;

  @override
  double get duration => 0.6;
}

final class ForageEffect extends BoardEffect {
  const ForageEffect({required this.nodeId});

  final String nodeId;

  @override
  double get duration => 0.5;
}

final class DefectEffect extends BoardEffect {
  const DefectEffect({required this.nodeId});

  final String nodeId;

  @override
  double get duration => 0.7;
}

/// An effect that is playing, and how far along it is (0 to 1).
typedef ActiveEffect = ({BoardEffect effect, double progress});

/// Plays the effects of [GameEvent]s one step after another: moves, battles,
/// forage and defections (build-spec section 6). Moves that follow each other
/// play together, since Đại Việt's moves resolve together.
///
/// Pure: it knows nothing about Flame, so it is tested directly. The board
/// feeds it with [update] each frame and asks what to draw.
class BoardAnimator {
  /// Longest the whole queue may take, whatever it holds.
  static const double maxTotalSeconds = 6;

  final List<List<BoardEffect>> _steps = [];
  int _index = 0;
  double _t = 0;

  /// Something is still playing; input that changes the game should wait.
  bool get isBusy => _index < _steps.length;

  /// Steps still to play, including the current one.
  int get stepsLeft => _steps.length - _index;

  /// Queues the effects of [events]. [nodeOfOfficer] says where an officer
  /// stands now (for defections, whose event names no node).
  void enqueue(Iterable<GameEvent> events, {required String? Function(String officerId) nodeOfOfficer}) {
    final steps = <List<BoardEffect>>[];
    void add(BoardEffect e) {
      if (e is MoveEffect && steps.isNotEmpty && steps.last.every((x) => x is MoveEffect)) {
        steps.last.add(e);
      } else {
        steps.add([e]);
      }
    }

    for (final e in events) {
      switch (e) {
        case OfficerMoved():
          add(MoveEffect(unitId: e.officerId, kind: TokenKind.officer, from: e.from, to: e.to));
        case ArmyMoved():
          add(MoveEffect(unitId: e.armyId, kind: TokenKind.army, from: e.from, to: e.to));
        case BattleResolved():
          add(BattleEffect(nodeId: e.report.nodeId, winner: e.report.winner));
        case Foraged():
          add(ForageEffect(nodeId: e.nodeId));
        case OfficerDefected():
          final node = nodeOfOfficer(e.officerId);
          if (node != null) add(DefectEffect(nodeId: node));
        default:
          break;
      }
    }
    if (steps.isEmpty) return;
    if (!isBusy) {
      _steps.clear();
      _index = 0;
      _t = 0;
    }
    _steps.addAll(steps);
    // Fixed now, so the queue ends on time: faster than normal only when what
    // is queued would take longer than the cap.
    _speed = _remaining > maxTotalSeconds ? _remaining / maxTotalSeconds : 1;
  }

  double _speed = 1;

  /// Play time of what is left, at normal speed.
  double get _remaining {
    var total = 0.0;
    for (var i = _index; i < _steps.length; i++) {
      total += _stepDuration(_steps[i]);
    }
    return total - _t;
  }

  /// Advances by [dt] seconds.
  void update(double dt) {
    if (!isBusy) return;
    _t += dt * _speed;
    while (isBusy && _t >= _stepDuration(_steps[_index])) {
      _t -= _stepDuration(_steps[_index]);
      _index++;
    }
    if (!isBusy) {
      _steps.clear();
      _index = 0;
      _t = 0;
    }
  }

  /// Skips everything that is queued (reduce motion, or a tap to skip).
  void clear() {
    _steps.clear();
    _index = 0;
    _t = 0;
  }

  double _stepDuration(List<BoardEffect> step) => step.map((e) => e.duration).fold(0.0, (a, b) => a > b ? a : b);

  /// The effects of the current step, with their progress.
  List<ActiveEffect> get active {
    if (!isBusy) return const [];
    return [for (final e in _steps[_index]) (effect: e, progress: (_t / e.duration).clamp(0.0, 1.0).toDouble())];
  }

  /// Where [unitId]'s token is: null when it is not travelling, else the next
  /// move it makes (progress 0 while it waits for its turn).
  ({MoveEffect move, double progress})? moveOf(String unitId) {
    for (var i = _index; i < _steps.length; i++) {
      for (final e in _steps[i]) {
        if (e is MoveEffect && e.unitId == unitId) {
          final p = i == _index ? (_t / e.duration).clamp(0.0, 1.0).toDouble() : 0.0;
          return (move: e, progress: p);
        }
      }
    }
    return null;
  }
}
