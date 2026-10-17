import 'enums.dart';
import 'game_state.dart';
import 'defs.dart';

/// What a guided tutorial step waits for (the `until` field of a mission's
/// tutorial step). A closed list: the validator rejects anything else.
///
/// | `until`                      | The step ends when                       |
/// | ---------------------------- | ---------------------------------------- |
/// | `next` (or no `until`)       | the player taps Next                     |
/// | `select:any`                 | anything is selected on the board        |
/// | `select:node:<id>`           | that node is selected                    |
/// | `select:officer:<id>`        | that officer is selected                 |
/// | `select:army:<id>`           | that army is selected                    |
/// | `card:<cardId>`              | that card has been played                |
/// | `skill:<officerId>`          | that officer's activated skill was used  |
/// | `order:<officerId>:<kind>`   | the officer holds an order of that kind  |
/// | `phase:council` / `phase:orders` | the game is in that phase            |
/// | `turn:<n>`                   | the turn is at least n                   |
/// | `hand`                       | the hand of cards is open (phones)       |
/// | `zoom`                       | the map is zoomed in                     |
sealed class TutorialCondition {
  const TutorialCondition();

  /// The `until` text this was read from.
  String get source;

  /// True for conditions only the screen can judge (what is selected, whether
  /// the hand is open, the zoom) and for "tap Next".
  bool get needsScreen => true;

  /// Reads [text], or returns null if it is not in the closed list.
  static TutorialCondition? parse(String text) {
    final p = text.split(':');
    switch (p[0]) {
      case 'next' when p.length == 1:
        return const AcknowledgeCondition();
      case 'hand' when p.length == 1:
        return const HandOpenCondition();
      case 'zoom' when p.length == 1:
        return const ZoomedCondition();
      case 'select':
        if (p.length == 2 && p[1] == 'any') return const SelectedCondition(null, null);
        if (p.length == 3 && p[2].isNotEmpty) {
          for (final k in SelectionTarget.values) {
            if (k.name == p[1]) return SelectedCondition(k, p[2]);
          }
        }
        return null;
      case 'card' when p.length == 2 && p[1].isNotEmpty:
        return CardPlayedCondition(p[1]);
      case 'skill' when p.length == 2 && p[1].isNotEmpty:
        return SkillUsedCondition(p[1]);
      case 'order' when p.length == 3 && p[1].isNotEmpty:
        for (final k in OrderKind.values) {
          if (k.name == p[2]) return OrderGivenCondition(p[1], k);
        }
        return null;
      case 'phase' when p.length == 2:
        for (final ph in [Phase.council, Phase.orders]) {
          if (ph.name == p[1]) return PhaseCondition(ph);
        }
        return null;
      case 'turn' when p.length == 2:
        final n = int.tryParse(p[1]);
        return n == null || n < 1 ? null : TurnAtLeastCondition(n);
    }
    return null;
  }

  /// Whether the condition holds in [ctx].
  bool holds(TutorialContext ctx);
}

enum SelectionTarget { node, officer, army }

/// What the screen and the game currently look like, for [TutorialCondition.holds].
final class TutorialContext {
  const TutorialContext({
    required this.state,
    required this.ruleset,
    this.selectedKind,
    this.selectedId,
    this.handOpen = false,
    this.zoomed = false,
  });

  final GameState state;
  final Ruleset ruleset;
  final SelectionTarget? selectedKind;
  final String? selectedId;
  final bool handOpen;
  final bool zoomed;
}

/// "Tap Next": never holds by itself.
final class AcknowledgeCondition extends TutorialCondition {
  const AcknowledgeCondition();
  @override
  String get source => 'next';
  @override
  bool holds(TutorialContext ctx) => false;
}

final class SelectedCondition extends TutorialCondition {
  /// Null kind and id mean "anything".
  const SelectedCondition(this.kind, this.id);
  final SelectionTarget? kind;
  final String? id;
  @override
  String get source => kind == null ? 'select:any' : 'select:${kind!.name}:$id';
  @override
  bool holds(TutorialContext ctx) =>
      ctx.selectedKind != null && (kind == null || (ctx.selectedKind == kind && ctx.selectedId == id));
}

final class CardPlayedCondition extends TutorialCondition {
  const CardPlayedCondition(this.cardId);
  final String cardId;
  @override
  String get source => 'card:$cardId';
  @override
  bool get needsScreen => false;
  @override
  bool holds(TutorialContext ctx) => (ctx.state.missionStats.cardsPlayed[cardId] ?? 0) > 0;
}

final class SkillUsedCondition extends TutorialCondition {
  const SkillUsedCondition(this.officerId);
  final String officerId;
  @override
  String get source => 'skill:$officerId';
  @override
  bool get needsScreen => false;
  @override
  bool holds(TutorialContext ctx) {
    final skill = ctx.ruleset.officers[officerId]?.skill;
    return skill != null && (ctx.state.missionStats.skillsUsed[skill.id] ?? 0) > 0;
  }
}

final class OrderGivenCondition extends TutorialCondition {
  const OrderGivenCondition(this.officerId, this.kind);
  final String officerId;
  final OrderKind kind;
  @override
  String get source => 'order:$officerId:${kind.name}';
  @override
  bool get needsScreen => false;
  @override
  bool holds(TutorialContext ctx) => ctx.state.officers[officerId]?.order?.kind == kind;
}

final class PhaseCondition extends TutorialCondition {
  const PhaseCondition(this.phase);
  final Phase phase;
  @override
  String get source => 'phase:${phase.name}';
  @override
  bool get needsScreen => false;
  @override
  bool holds(TutorialContext ctx) => ctx.state.phase == phase;
}

final class TurnAtLeastCondition extends TutorialCondition {
  const TurnAtLeastCondition(this.turn);
  final int turn;
  @override
  String get source => 'turn:$turn';
  @override
  bool get needsScreen => false;
  @override
  bool holds(TutorialContext ctx) => ctx.state.turn >= turn;
}

final class HandOpenCondition extends TutorialCondition {
  const HandOpenCondition();
  @override
  String get source => 'hand';
  @override
  bool holds(TutorialContext ctx) => ctx.handOpen;
}

final class ZoomedCondition extends TutorialCondition {
  const ZoomedCondition();
  @override
  String get source => 'zoom';
  @override
  bool holds(TutorialContext ctx) => ctx.zoomed;
}
