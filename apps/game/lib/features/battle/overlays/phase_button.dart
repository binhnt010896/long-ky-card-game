import 'package:flutter/material.dart';
import 'package:lk_rules/lk_rules.dart';

import '../../../app/l10n/app_localizations.dart';
import '../../../app/theme.dart';
import '../labels.dart';
import 'panel.dart';

/// The one button that moves the turn on: Council → Orders → next turn.
/// Disabled while a choice is pending and once the mission has ended.
class PhaseButton extends StatelessWidget {
  const PhaseButton({super.key, required this.state, required this.mode, required this.onPressed, this.busy = false});

  final GameState state;
  final BattleLayoutMode mode;
  final VoidCallback onPressed;

  /// The board is still playing the last step; wait for it.
  final bool busy;

  /// The player can end the phase now.
  static bool canEnd(GameState s) =>
      !s.isOver && s.pendingChoice == null && (s.phase == Phase.council || s.phase == Phase.orders);

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final label = busy
        ? l.phaseButtonWait
        : state.isOver
        ? l.phaseButtonEnded
        : state.pendingChoice != null
        ? l.phaseButtonChoice
        : switch (state.phase) {
            Phase.council => l.phaseButtonCouncil,
            Phase.orders => l.phaseButtonOrders,
            _ => l.phaseButtonWait,
          };
    final compact = mode.isCompact;
    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: compact ? 132 : 200, minHeight: minTouch),
      child: Tooltip(
        message: l.shortcutHint(label, 'Space / Enter'),
        child: FilledButton(
          key: const Key('phase-button'),
          onPressed: canEnd(state) && !busy ? onPressed : null,
          style: FilledButton.styleFrom(
            minimumSize: Size(compact ? 132 : 200, minTouch),
            padding: EdgeInsets.symmetric(horizontal: compact ? 12 : 20),
            disabledBackgroundColor: LongKyColors.lacquerRaised,
            disabledForegroundColor: LongKyColors.ivory.withValues(alpha: 0.7),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l.phaseName(state.phase),
                style: TextStyle(fontSize: compact ? 10 : 12, fontWeight: FontWeight.w500, height: 1.1),
              ),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: compact ? 14 : 17, fontWeight: FontWeight.w700, height: 1.15),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
