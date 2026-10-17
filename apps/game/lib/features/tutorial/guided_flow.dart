import 'package:lk_rules/lk_rules.dart';

/// The interactive tutorial of the training mission: a list of steps, one
/// shown at a time. A step with an `until` condition ends by itself when the
/// player does what it asks; any other step ends when the player taps Next.
/// A step can always be skipped, so nobody gets stuck.
///
/// Pure: [update] is given what the game and the screen look like and
/// moves on as far as they allow.
final class GuidedFlow {
  GuidedFlow(this.steps);

  final List<TutorialStep> steps;

  int _index = 0;

  /// The place of the current step (0-based); [steps].length when done.
  int get index => _index;

  bool get finished => _index >= steps.length;

  TutorialStep? get current => finished ? null : steps[_index];

  /// 1-based place of the current step, for "3/27".
  int get position => _index + 1;

  /// The current step waits for the player to do something.
  bool get waitingForAction {
    final c = current?.until;
    return c != null && c is! AcknowledgeCondition;
  }

  /// Starts from the right step for a game that is already under way (a
  /// resumed battle): just after the last step whose state-based condition
  /// already holds.
  void resumeAt(TutorialContext ctx) {
    var last = -1;
    for (var i = 0; i < steps.length; i++) {
      final c = steps[i].until;
      if (c != null && !c.needsScreen && c.holds(ctx)) last = i;
    }
    _index = last + 1;
  }

  /// Moves past every step whose condition already holds. Returns whether
  /// the current step changed.
  bool update(TutorialContext ctx) {
    final before = _index;
    while (!finished) {
      final c = steps[_index].until;
      if (c == null || c is AcknowledgeCondition || !c.holds(ctx)) break;
      _index++;
    }
    return _index != before;
  }

  /// The player tapped Next (or skipped the step).
  void advance() {
    if (!finished) _index++;
  }

  /// Ends the tutorial.
  void finish() => _index = steps.length;
}
