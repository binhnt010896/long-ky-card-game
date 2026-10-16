import 'package:flutter/material.dart';
import 'package:lk_rules/lk_rules.dart';

import '../../../app/l10n/app_localizations.dart';
import '../../../app/theme.dart';
import '../labels.dart';
import 'panel.dart';

/// The Result screen (build-spec section 6): won or lost, the star
/// objectives, the debrief, and what to do next. It covers the battle once
/// the mission is over.
///
/// TODO(T-24): "Read more in Long Ký" (needs the deep-link format, an open
/// input) and unlocks from codes. TODO(T-23): "next mission" once the
/// campaign unlocks them.
class ResultScreen extends StatelessWidget {
  const ResultScreen({
    super.key,
    required this.state,
    required this.ruleset,
    required this.onBack,
    required this.onRetry,
  });

  final GameState state;
  final Ruleset ruleset;
  final VoidCallback? onBack;
  final VoidCallback? onRetry;

  String _lossReason(AppLocalizations l) {
    final r = state.lossReason;
    if (r == null) return l.lossObjective;
    if (r == LossReasons.kingCaptured) return l.lossKingCaptured;
    if (r == LossReasons.seasonEnded) return l.lossSeasonEnded;
    if (r.startsWith(LossReasons.unityPrefix)) {
      final name = r.substring(LossReasons.unityPrefix.length);
      for (final p in Pillar.values) {
        if (p.name == name) return l.lossUnity(l.pillarName(p));
      }
    }
    return l.lossObjective;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final namer = Namer(l, ruleset);
    final won = state.outcome == Outcome.won;
    final accent = won ? LongKyColors.goldLeaf : LongKyColors.cinnabar;
    final objectives = ruleset.mission.stars;
    return Material(
      key: const Key('result-screen'),
      color: LongKyColors.lacquer.withValues(alpha: 0.96),
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l.content(ruleset.mission.title),
                          style: TextStyle(color: LongKyColors.ivory.withValues(alpha: 0.85), fontSize: 14),
                        ),
                        Text(
                          won ? l.outcomeWon : l.outcomeLost,
                          key: const Key('result-title'),
                          style: TextStyle(color: accent, fontSize: 30, fontWeight: FontWeight.w700),
                        ),
                        if (!won) ...[
                          const SizedBox(height: 4),
                          Text(
                            _lossReason(l),
                            key: const Key('result-reason'),
                            style: const TextStyle(color: LongKyColors.ivory, fontSize: 16),
                          ),
                        ],
                        if (won) ...[
                          const SizedBox(height: 4),
                          Text(
                            l.outcomeStars(state.stars.where((s) => s).length, objectives.length),
                            key: const Key('result-stars'),
                            style: const TextStyle(color: LongKyColors.ivory, fontSize: 16),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            l.resultObjectives,
                            style: const TextStyle(
                              color: LongKyColors.goldLeaf,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          for (var i = 0; i < objectives.length; i++)
                            _ObjectiveRow(
                              key: Key('objective-$i'),
                              text: namer.objective(state, objectives[i]),
                              met: i < state.stars.length && state.stars[i],
                            ),
                          const SizedBox(height: 12),
                          Text(
                            l.resultDebrief,
                            style: const TextStyle(
                              color: LongKyColors.goldLeaf,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l.content(ruleset.mission.debrief),
                            key: const Key('result-debrief'),
                            style: const TextStyle(color: LongKyColors.ivory, fontSize: 15, height: 1.4),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      if (onRetry != null)
                        OutlinedButton(
                          key: const Key('result-retry'),
                          onPressed: onRetry,
                          style: OutlinedButton.styleFrom(minimumSize: const Size(0, minTouch)),
                          child: Text(l.resultRetry),
                        ),
                      if (onBack != null)
                        FilledButton(
                          key: const Key('result-back'),
                          onPressed: onBack,
                          style: FilledButton.styleFrom(minimumSize: const Size(0, minTouch)),
                          child: Text(l.outcomeBack),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ObjectiveRow extends StatelessWidget {
  const _ObjectiveRow({super.key, required this.text, required this.met});

  final String text;
  final bool met;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Semantics(
      label: '$text, ${met ? l.resultMet : l.resultNotMet}',
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filled or outlined, so the result is not told by colour alone.
            Icon(met ? Icons.star : Icons.star_border, size: 20, color: LongKyColors.goldLeaf),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: LongKyColors.ivory.withValues(alpha: met ? 1 : 0.75),
                  fontSize: 15,
                  height: 1.3,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              met ? l.resultMet : l.resultNotMet,
              style: TextStyle(color: LongKyColors.ivory.withValues(alpha: 0.75), fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
