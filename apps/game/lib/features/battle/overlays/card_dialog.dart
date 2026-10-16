import 'package:flutter/material.dart';
import 'package:lk_rules/lk_rules.dart';

import '../../../app/l10n/app_localizations.dart';
import '../../../app/theme.dart';
import '../labels.dart';
import 'hand.dart';
import 'panel.dart';

/// Opens the card dialog: the card in full, and in Council the ways to play
/// it. Played cards are final, so each target button plays at once.
/// [onPlay] gets the chosen target (null for a card without one).
Future<void> showCardDialog(
  BuildContext context, {
  required CardDef card,
  required GameState state,
  required Ruleset ruleset,
  required List<GameAction> legal,
  required bool enabled,
  required ValueChanged<String?> onPlay,
}) {
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => CardDialog(
      card: card,
      state: state,
      ruleset: ruleset,
      legal: legal,
      enabled: enabled,
      onPlay: (target) {
        Navigator.of(dialogContext).pop();
        onPlay(target);
      },
    ),
  );
}

class CardDialog extends StatelessWidget {
  const CardDialog({
    super.key,
    required this.card,
    required this.state,
    required this.ruleset,
    required this.legal,
    required this.enabled,
    required this.onPlay,
  });

  final CardDef card;
  final GameState state;
  final Ruleset ruleset;
  final List<GameAction> legal;
  final bool enabled;
  final ValueChanged<String?> onPlay;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final namer = Namer(l, ruleset);
    final targets = [
      for (final a in legal)
        if (a is PlayCard && a.cardId == card.id) a.target,
    ];
    // The same card twice in hand gives the same targets twice.
    final unique = <String?>[for (final t in targets.toSet()) t];
    final inCouncil = state.phase == Phase.council && state.pendingChoice == null && !state.isOver;
    final cost = cardCostNow(state, card);
    final costText = [
      if (cost.rice > 0) '${l.resourceRice} ${cost.rice}',
      if (cost.support > 0) '${l.resourceSupport} ${cost.support}',
    ].join(' · ');
    return Dialog(
      key: const Key('card-dialog'),
      backgroundColor: LongKyColors.lacquerRaised,
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: LongKyColors.goldLeaf),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l.content(card.name),
                style: const TextStyle(color: LongKyColors.goldLeaf, fontSize: 20, fontWeight: FontWeight.w700),
              ),
              Text(
                '${l.cardTypeName(card.type)} · ${costText.isEmpty ? l.cardFree : costText}',
                style: TextStyle(color: LongKyColors.ivory.withValues(alpha: 0.85), fontSize: 13),
              ),
              const SizedBox(height: 8),
              Text(l.content(card.text), style: const TextStyle(color: LongKyColors.ivory, fontSize: 15, height: 1.35)),
              const SizedBox(height: 12),
              if (!inCouncil)
                _Note(l.cardOnlyCouncil)
              else if (!canAffordCard(state, card))
                _Note(l.cardCannotAfford)
              else if (unique.isEmpty)
                _Note(l.cardNoTargets)
              else ...[
                if (card.target != TargetKind.none) _Note(l.cardPickTarget),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final t in unique)
                      FilledButton(
                        key: Key('play-${t ?? 'none'}'),
                        onPressed: enabled ? () => onPlay(t) : null,
                        style: FilledButton.styleFrom(minimumSize: const Size(0, minTouch)),
                        child: Text(t == null ? l.cardPlay : l.cardPlayOn(namer.target(state, t))),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                _Note(l.cardFinal),
              ],
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  key: const Key('card-dialog-close'),
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(minimumSize: const Size(minTouch, minTouch)),
                  child: Text(l.cardClose),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Note extends StatelessWidget {
  const _Note(this.text);

  final String text;

  @override
  Widget build(BuildContext context) =>
      Text(text, style: TextStyle(color: LongKyColors.ivory.withValues(alpha: 0.85), fontSize: 13));
}
