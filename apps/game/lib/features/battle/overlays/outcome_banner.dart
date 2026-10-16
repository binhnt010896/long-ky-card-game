import 'package:flutter/material.dart';
import 'package:lk_rules/lk_rules.dart';

import '../../../app/l10n/app_localizations.dart';
import '../../../app/theme.dart';
import '../labels.dart';
import 'panel.dart';

/// A plain "won / lost" banner so a mission can be played to its end. The
/// Result screen with stars, debrief and unlocks replaces it in T-18.
class OutcomeBanner extends StatelessWidget {
  const OutcomeBanner({super.key, required this.state, required this.onBack});

  final GameState state;
  final VoidCallback? onBack;

  String _reason(AppLocalizations l) {
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
    final won = state.outcome == Outcome.won;
    return Material(
      key: const Key('outcome-banner'),
      color: LongKyColors.lacquerRaised,
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: won ? LongKyColors.goldLeaf : LongKyColors.cinnabar, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              won ? l.outcomeWon : l.outcomeLost,
              style: const TextStyle(color: LongKyColors.goldLeaf, fontSize: 22, fontWeight: FontWeight.w700),
            ),
            if (won)
              Text(
                l.outcomeStars(state.stars.where((s) => s).length, state.stars.length),
                style: const TextStyle(color: LongKyColors.ivory, fontSize: 14),
              )
            else
              Text(_reason(l), style: const TextStyle(color: LongKyColors.ivory, fontSize: 14)),
            if (onBack != null) ...[
              const SizedBox(height: 10),
              FilledButton(
                key: const Key('outcome-back'),
                onPressed: onBack,
                style: FilledButton.styleFrom(minimumSize: const Size(0, minTouch)),
                child: Text(l.outcomeBack),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
