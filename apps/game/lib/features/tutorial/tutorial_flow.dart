import 'package:lk_rules/lk_rules.dart';

/// When a coach mark is due, judged from the mission's own step ids
/// (`m1-intel`, `m1-council`, `m1-orders`, `m1-resolution`, `m1-upkeep`, or
/// `m3-tip`): the part after the last `-` names the phase it talks about.
enum TutorialMoment {
  /// Turn 1, Council: the first thing the player sees (Intel is already on the map).
  council,

  /// Turn 1, Orders (the resolution tip is read here too: it explains what
  /// ending the phase will do).
  orders,

  /// The next turn, after the first one has resolved.
  upkeep,
}

/// The moment a step with [id] belongs to. Unknown endings are shown at the
/// start, like a tip.
TutorialMoment momentOf(String id) => switch (id.substring(id.lastIndexOf('-') + 1)) {
  'orders' || 'resolution' => TutorialMoment.orders,
  'upkeep' => TutorialMoment.upkeep,
  _ => TutorialMoment.council,
};

/// Which coach mark to show now (T-22: a new player is guided through every
/// phase of turn 1). Pure: the same steps, state and seen set give the same
/// answer.
///
/// A step is shown once, in order, while its moment is the current one; a step
/// whose moment has passed (the player went on without reading it) is dropped,
/// not shown late.
final class TutorialFlow {
  const TutorialFlow(this.steps);

  /// Step ids in the order the mission lists them.
  final List<String> steps;

  /// The id of the step to show in [state], or null for none.
  String? current(GameState state, Set<String> seen) {
    if (state.isOver) return null;
    for (final id in steps) {
      if (seen.contains(id)) continue;
      switch (_standing(momentOf(id), state)) {
        case _Standing.now:
          return id;
        case _Standing.later:
        case _Standing.past:
          // Later steps wait their turn; passed ones are skipped over.
          continue;
      }
    }
    return null;
  }

  /// Nothing is left to show now or later: every step was read, or has passed
  /// (the player went on without reading it), or the mission is over.
  bool finished(GameState state, Set<String> seen) {
    if (state.isOver) return true;
    return steps.every((id) => seen.contains(id) || _standing(momentOf(id), state) == _Standing.past);
  }

  /// The 1-based place of step [id] in the list (the "2" of "2/5").
  int position(String id) => steps.indexOf(id) + 1;

  static _Standing _standing(TutorialMoment m, GameState s) {
    switch (m) {
      case TutorialMoment.council:
        if (s.turn == 1 && s.phase == Phase.council) return _Standing.now;
        return s.turn == 1 && s.phase.index < Phase.council.index ? _Standing.later : _Standing.past;
      case TutorialMoment.orders:
        if (s.turn == 1 && s.phase == Phase.orders) return _Standing.now;
        return s.turn == 1 && s.phase.index < Phase.orders.index ? _Standing.later : _Standing.past;
      case TutorialMoment.upkeep:
        return s.turn >= 2 ? _Standing.now : _Standing.later;
    }
  }
}

enum _Standing { now, later, past }
