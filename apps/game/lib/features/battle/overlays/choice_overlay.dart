import 'package:flutter/material.dart';
import 'package:lk_rules/lk_rules.dart';

import '../../../app/l10n/app_localizations.dart';
import '../../../app/theme.dart';
import '../labels.dart';
import 'panel.dart';

/// Shown while `pendingChoice` is set: it covers the screen, so no other
/// input reaches the game (build-spec section 6, "Choice dialog").
class ChoiceOverlay extends StatelessWidget {
  const ChoiceOverlay({super.key, required this.choice, required this.ruleset, required this.onChoose});

  final PendingChoice choice;
  final Ruleset ruleset;
  final ValueChanged<int> onChoose;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final effect = choiceEffectOf(ruleset, choice);
    final (name, text) = switch (choice.source) {
      ChoiceSource.card => (
        l.content(ruleset.cards[choice.sourceId]!.name),
        l.content(ruleset.cards[choice.sourceId]!.text),
      ),
      ChoiceSource.skill => (
        l.content(ruleset.officers[choice.sourceId]!.skill!.name),
        l.content(ruleset.officers[choice.sourceId]!.skill!.text),
      ),
    };
    return Stack(
      key: const Key('choice-overlay'),
      children: [
        // Absorbs every tap behind the dialog.
        const Positioned.fill(child: ModalBarrier(color: Color(0xB3000000), dismissible: false)),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Material(
              color: LongKyColors.lacquerRaised,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: const BorderSide(color: LongKyColors.goldLeaf, width: 2),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        l.choiceTitle,
                        style: TextStyle(color: LongKyColors.ivory.withValues(alpha: 0.85), fontSize: 13),
                      ),
                      Text(
                        name,
                        style: const TextStyle(color: LongKyColors.goldLeaf, fontSize: 20, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 6),
                      Text(text, style: const TextStyle(color: LongKyColors.ivory, fontSize: 15, height: 1.35)),
                      const SizedBox(height: 14),
                      for (var i = 0; i < effect.options.length; i++) ...[
                        FilledButton(
                          key: Key('choice-$i'),
                          onPressed: () => onChoose(i),
                          style: FilledButton.styleFrom(minimumSize: const Size(0, minTouch)),
                          child: Text(l.content(effect.options[i].label), textAlign: TextAlign.center),
                        ),
                        if (i < effect.options.length - 1) const SizedBox(height: 8),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
