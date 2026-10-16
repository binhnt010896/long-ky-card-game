import 'package:flutter/material.dart';
import 'package:lk_rules/lk_rules.dart';

import '../../../app/l10n/app_localizations.dart';
import '../../../app/theme.dart';
import '../labels.dart';
import 'panel.dart';

/// Top bar: turn / season clock, Rice, Support and the three Unity gauges.
class BattleTopBar extends StatelessWidget {
  const BattleTopBar({
    super.key,
    required this.state,
    required this.seasonTurns,
    required this.mode,
    this.leading,
    this.trailing,
  });

  final GameState state;
  final int seasonTurns;
  final BattleLayoutMode mode;

  /// Placed before the clock, for example the back button.
  final Widget? leading;

  /// Placed after the gauges, for example the log button.
  final Widget? trailing;

  /// 48 in compact so the buttons in the bar are full-size touch targets.
  static double heightFor(BattleLayoutMode mode) => mode.isCompact ? minTouch : 56;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final compact = mode.isCompact;
    return Container(
      key: const Key('top-bar'),
      height: heightFor(mode),
      color: LongKyColors.lacquer,
      padding: EdgeInsets.symmetric(horizontal: compact ? 4 : 12),
      child: Row(
        children: [
          ?leading,
          Expanded(
            // Large text sizes shrink the bar's content rather than overflow.
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SeasonClock(turn: state.turn, total: seasonTurns, phase: state.phase, compact: compact),
                  SizedBox(width: compact ? 12 : 24),
                  ResourceChip(
                    key: const Key('rice'),
                    icon: Icons.grass,
                    label: l.resourceRice,
                    value: state.rice,
                    compact: compact,
                  ),
                  SizedBox(width: compact ? 8 : 12),
                  ResourceChip(
                    key: const Key('support'),
                    icon: Icons.favorite,
                    label: l.resourceSupport,
                    value: state.support,
                    compact: compact,
                  ),
                  SizedBox(width: compact ? 12 : 24),
                  for (final p in Pillar.values) ...[
                    UnityGauge(key: Key('unity-${p.name}'), pillar: p, value: state.unity[p], compact: compact),
                    SizedBox(width: compact ? 8 : 16),
                  ],
                ],
              ),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// "Lượt 2/4", a pip per turn of the season and the current phase.
class SeasonClock extends StatelessWidget {
  const SeasonClock({super.key, required this.turn, required this.total, required this.phase, required this.compact});

  final int turn;
  final int total;
  final Phase phase;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final shown = turn.clamp(1, total);
    return Semantics(
      label: l.battleSeasonClockSemantics(shown, total),
      excludeSemantics: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.battleTurnClock(shown, total),
            style: TextStyle(
              color: LongKyColors.goldLeaf,
              fontSize: compact ? 14 : 18,
              fontWeight: FontWeight.w700,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 1; i <= total; i++)
                Container(
                  key: Key('clock-pip-$i'),
                  width: compact ? 10 : 14,
                  height: 6,
                  margin: const EdgeInsets.only(right: 3),
                  decoration: BoxDecoration(
                    color: i <= shown ? LongKyColors.goldLeaf : Colors.transparent,
                    border: Border.all(color: LongKyColors.goldLeaf, width: 1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              const SizedBox(width: 4),
              Text(
                l.phaseName(phase),
                style: TextStyle(color: LongKyColors.ivory, fontSize: compact ? 11 : 13, height: 1.1),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ResourceChip extends StatelessWidget {
  const ResourceChip({super.key, required this.icon, required this.label, required this.value, required this.compact});

  final IconData icon;
  final String label;
  final int value;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Tooltip(
      message: label,
      child: Semantics(
        label: l.resourceSemantics(label, value),
        excludeSemantics: true,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: compact ? 16 : 20, color: LongKyColors.goldLeaf),
            const SizedBox(width: 4),
            Text(
              '$value',
              style: TextStyle(color: LongKyColors.ivory, fontSize: compact ? 15 : 18, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

/// One Unity pillar, 0–10. Below [Balance.unityLowThreshold] the gauge turns
/// cinnabar and shows a warning mark, so colour is never the only signal.
class UnityGauge extends StatelessWidget {
  const UnityGauge({super.key, required this.pillar, required this.value, required this.compact});

  final Pillar pillar;
  final int value;
  final bool compact;

  bool get low => value < Balance.unityLowThreshold;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final name = l.pillarName(pillar);
    final segment = compact ? 6.0 : 9.0;
    final fill = low ? LongKyColors.cinnabar : LongKyColors.goldLeaf;
    return Tooltip(
      message: name,
      child: Semantics(
        label: low ? l.unitySemanticsLow(name, value) : l.unitySemantics(name, value),
        excludeSemantics: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  style: TextStyle(color: LongKyColors.ivory, fontSize: compact ? 11 : 13, height: 1.1),
                ),
                const SizedBox(width: 4),
                Text(
                  '$value',
                  style: TextStyle(
                    color: LongKyColors.ivory,
                    fontSize: compact ? 11 : 13,
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                  ),
                ),
                if (low) Icon(Icons.warning_amber, size: compact ? 12 : 14, color: LongKyColors.ivory),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 1; i <= Balance.unityMax; i++)
                  Container(
                    width: segment,
                    height: 6,
                    margin: const EdgeInsets.only(right: 1),
                    decoration: BoxDecoration(
                      color: i <= value ? fill : Colors.transparent,
                      border: Border.all(color: fill.withValues(alpha: 0.7), width: 1),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
