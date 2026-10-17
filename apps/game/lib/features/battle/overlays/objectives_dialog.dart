import 'package:flutter/material.dart';
import 'package:lk_rules/lk_rules.dart';

import '../../../app/l10n/app_localizations.dart';
import '../../../app/theme.dart';
import '../labels.dart';
import 'panel.dart';

/// The mission's objectives, always one tap away during the battle: how to
/// win, how to lose and the bonus stars (build-spec section 6).
Future<void> showObjectives(BuildContext context, {required Ruleset ruleset, required GameState state}) =>
    showDialog<void>(context: context, builder: (_) => ObjectivesDialog(ruleset: ruleset, state: state));

class ObjectivesDialog extends StatelessWidget {
  const ObjectivesDialog({super.key, required this.ruleset, required this.state});

  final Ruleset ruleset;
  final GameState state;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final namer = Namer(l, ruleset);
    final mission = ruleset.mission;
    final wins = [for (final o in mission.win) namer.objective(state, o)];
    final losses = [
      l.lossKingCaptured,
      l.objectivesLossUnity,
      l.objectivesLossSeason(mission.seasonTurns),
      ...namer.extraLossRules(mission),
    ];
    final stars = [for (final o in mission.stars) namer.objective(state, o)];
    return Dialog(
      key: const Key('objectives-dialog'),
      backgroundColor: LongKyColors.lacquerRaised,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: LongKyColors.goldLeaf),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l.content(mission.title),
                style: const TextStyle(color: LongKyColors.goldLeaf, fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    _Section(
                      key: const Key('objectives-win'),
                      heading: l.objectivesWin,
                      color: LongKyColors.goldLeaf,
                      icon: Icons.emoji_events_outlined,
                      lines: wins,
                    ),
                    _Section(
                      key: const Key('objectives-loss'),
                      heading: l.briefingLoss,
                      color: const Color(0xFFE88A80),
                      icon: Icons.warning_amber_rounded,
                      lines: losses,
                    ),
                    if (stars.isNotEmpty)
                      _Section(
                        key: const Key('objectives-stars'),
                        heading: l.objectivesStars,
                        color: LongKyColors.ivory,
                        icon: Icons.star_outline,
                        lines: stars,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              FilledButton(
                key: const Key('objectives-close'),
                autofocus: true,
                onPressed: () => Navigator.of(context).pop(),
                style: FilledButton.styleFrom(minimumSize: const Size(0, minTouch)),
                child: Text(l.battleMenuResume),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({super.key, required this.heading, required this.color, required this.icon, required this.lines});

  final String heading;
  final Color color;
  final IconData icon;
  final List<String> lines;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 8, bottom: 4),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(heading, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w700)),
        for (final line in lines)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(padding: const EdgeInsets.only(top: 2), child: Icon(icon, size: 16, color: color)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(line, style: const TextStyle(color: LongKyColors.ivory, fontSize: 15, height: 1.3)),
                ),
              ],
            ),
          ),
      ],
    ),
  );
}

/// The top-bar button that opens the objectives.
class ObjectivesButton extends StatelessWidget {
  const ObjectivesButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => IconButton(
    key: const Key('objectives-button'),
    tooltip: AppLocalizations.of(context).objectivesShow,
    constraints: const BoxConstraints(minWidth: minTouch, minHeight: minTouch),
    onPressed: onPressed,
    icon: const Icon(Icons.flag_outlined, color: LongKyColors.goldLeaf),
  );
}
