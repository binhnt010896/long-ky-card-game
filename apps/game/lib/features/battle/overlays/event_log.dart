import 'package:flutter/material.dart';
import 'package:lk_rules/lk_rules.dart';

import '../../../app/l10n/app_localizations.dart';
import '../../../app/theme.dart';
import '../labels.dart';
import 'panel.dart';

/// The log line for [event], or null for events the board shows by itself
/// (revealed intents, draws, shuffles, raw stat changes of effects).
String? describeEvent(AppLocalizations l, Ruleset ruleset, GameState state, GameEvent event) {
  final n = Namer(l, ruleset);
  return switch (event) {
    TurnStarted() => l.logTurnStarted(event.turn),
    PhaseChanged() => l.logPhaseChanged(l.phaseName(event.phase)),
    CardPlayed() =>
      ruleset.cards[event.cardId] == null
          ? null
          : event.target == null
          ? l.logCardPlayed(l.content(ruleset.cards[event.cardId]!.name))
          : l.logCardPlayedOn(l.content(ruleset.cards[event.cardId]!.name), n.target(state, event.target!)),
    SkillUsed() => l.logSkillUsed(
      n.officer(event.officerId),
      ruleset.officers[event.officerId]?.skill == null
          ? event.skillId
          : l.content(ruleset.officers[event.officerId]!.skill!.name),
    ),
    OrdersSkipped() => l.logOrdersSkipped,
    OrderSet() =>
      event.order == null
          ? l.logOrderCleared(n.officer(event.officerId))
          : l.logOrderSet(n.officer(event.officerId), n.order(state, event.order!)),
    OfficerMoved() => l.logUnitMoved(n.officer(event.officerId), n.node(event.from), n.node(event.to)),
    ArmyMoved() => l.logUnitMoved(n.army(state, event.armyId), n.node(event.from), n.node(event.to)),
    NodeEvacuated() => l.logNodeEvacuated(n.node(event.nodeId), event.riceGained),
    Rallied() => l.logRallied(n.officer(event.officerId), n.node(event.nodeId), event.troopsGained),
    AmbushPlaced() => l.logAmbushPlaced(n.officer(event.officerId), n.edge(event.edge)),
    BattleResolved() => switch (event.report.winner) {
      Side.daiViet => l.logBattleWon(n.node(event.report.nodeId)),
      Side.yuan => l.logBattleLost(n.node(event.report.nodeId)),
      Side.none => l.logBattleDraw(n.node(event.report.nodeId)),
    },
    OfficerCaptured() => l.logOfficerCaptured(n.officer(event.officerId), n.node(event.nodeId)),
    KingShielded() => l.logKingShielded(n.officer(event.kingId), n.officer(event.shieldId)),
    Raided() => l.logRaided(
      n.officer(event.officerId),
      n.army(state, event.armyId),
      event.supplyLost,
      event.troopsLost,
    ),
    Foraged() => l.logForaged(n.army(state, event.armyId), n.node(event.nodeId), event.supplyGained),
    NodeControlChanged() => l.logNodeControl(n.node(event.nodeId), l.sideName(event.to)),
    ArmyRouted() => l.logArmyRouted(n.army(state, event.armyId)),
    Starvation() => l.logStarvation(n.army(state, event.armyId), event.moraleLost, event.troopsLost),
    HeatAttrition() => l.logAttrition(n.army(state, event.armyId), event.troopsLost),
    IncomeCollected() =>
      '${l.logIncome(event.riceGained, event.riceUpkeep)}${event.shortfall ? ' ${l.logIncomeShortfall}' : ''}',
    OfficerDefected() => l.logDefected(n.officer(event.officerId)),
    InducementResisted() => l.logInducementResisted(n.officer(event.officerId)),
    ChoiceRequested() => l.logChoiceRequested,
    UnityChanged() => l.logUnityChanged(l.pillarName(event.pillar), event.from, event.to),
    ResourceChanged() => l.logResourceChanged(l.resourceName(event.resource), event.from, event.to),
    MissionEnded() => event.outcome == Outcome.won ? l.logMissionWon : l.logMissionLost,
    FreePlayStarted() => l.logFreePlayStarted,
    FreePlayEnded() => event.playerWon ? l.freePlayWon : l.freePlayLost,
    _ => null,
  };
}

/// Log lines, newest at the bottom.
List<String> logLines(AppLocalizations l, Ruleset ruleset, GameState state, List<GameEvent> events) => [
  for (final e in events) ?describeEvent(l, ruleset, state, e),
];

/// The scrolling list of log lines. The panel chrome around it differs per
/// layout (collapsible left panel, or a popover behind a button).
class EventLogList extends StatelessWidget {
  const EventLogList({super.key, required this.lines});

  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    if (lines.isEmpty) {
      return Text(l.logEmpty, style: TextStyle(color: LongKyColors.ivory.withValues(alpha: 0.8), fontSize: 12));
    }
    // Top-aligned while short; reversed, so a long log starts at the newest line.
    return Align(
      alignment: Alignment.topLeft,
      child: ListView.builder(
        key: const Key('log-list'),
        reverse: true,
        shrinkWrap: true,
        itemCount: lines.length,
        itemBuilder: (context, i) {
          final line = lines[lines.length - 1 - i];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text(line, style: const TextStyle(color: LongKyColors.ivory, fontSize: 12, height: 1.3)),
          );
        },
      ),
    );
  }
}

/// Regular layout: a collapsible panel on the left.
class LogSidePanel extends StatelessWidget {
  const LogSidePanel({super.key, required this.lines, required this.expanded, required this.onToggle});

  final List<String> lines;
  final bool expanded;
  final VoidCallback onToggle;

  static const double expandedWidth = 280;
  static const double collapsedWidth = minTouch;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final toggle = IconButton(
      key: const Key('log-toggle'),
      tooltip: expanded ? l.logCollapse : l.logExpand,
      constraints: const BoxConstraints(minWidth: minTouch, minHeight: minTouch),
      onPressed: onToggle,
      icon: Icon(expanded ? Icons.chevron_left : Icons.history, color: LongKyColors.goldLeaf),
    );
    return Container(
      key: const Key('log-panel'),
      width: expanded ? expandedWidth : collapsedWidth,
      decoration: const BoxDecoration(
        color: LongKyColors.lacquer,
        border: Border(right: BorderSide(color: LongKyColors.lacquerRaised)),
      ),
      child: expanded
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: Text(
                        l.logTitle,
                        style: const TextStyle(color: LongKyColors.goldLeaf, fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                    ),
                    const Spacer(),
                    toggle,
                  ],
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                    child: EventLogList(lines: lines),
                  ),
                ),
              ],
            )
          : Align(alignment: Alignment.topCenter, child: toggle),
    );
  }
}

/// Compact layout: the log opens from a button, over the board.
class LogPopover extends StatelessWidget {
  const LogPopover({super.key, required this.lines, required this.onClose});

  final List<String> lines;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Container(
      key: const Key('log-popover'),
      decoration: lacquerPanel(selected: false),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Text(
                  l.logTitle,
                  style: const TextStyle(color: LongKyColors.goldLeaf, fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ),
              const Spacer(),
              IconButton(
                key: const Key('log-close'),
                tooltip: l.logHide,
                constraints: const BoxConstraints(minWidth: minTouch, minHeight: minTouch),
                onPressed: onClose,
                icon: const Icon(Icons.close, color: LongKyColors.ivory),
              ),
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: EventLogList(lines: lines),
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact layout: the button that opens [LogPopover].
class LogButton extends StatelessWidget {
  const LogButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return IconButton(
      key: const Key('log-button'),
      tooltip: l.logShow,
      constraints: const BoxConstraints(minWidth: minTouch, minHeight: minTouch),
      onPressed: onPressed,
      icon: const Icon(Icons.history, color: LongKyColors.goldLeaf),
    );
  }
}
