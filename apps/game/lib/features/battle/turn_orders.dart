import 'package:lk_rules/lk_rules.dart';

/// Whether at least one of our officers goes forward or attacks when the turn
/// is resolved: a Move, a Raid or an Ambush order (a Hold, an Evacuate or a
/// Rally is not). [beforeResolution] is the state when the player ended the
/// Orders phase, with the orders still set. The king's shout and its callout
/// are for a turn like this; a quiet turn has neither.
bool turnAdvances(GameState beforeResolution) =>
    [
      for (final o in beforeResolution.officers.values)
        if (o.status == OfficerStatus.active) ?o.order?.kind,
    ].any(
      (k) =>
          k == OrderKind.move || k == OrderKind.raid || k == OrderKind.ambush,
    );
