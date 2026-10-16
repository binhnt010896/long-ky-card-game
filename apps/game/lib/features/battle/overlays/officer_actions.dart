import 'package:flutter/material.dart';
import 'package:lk_rules/lk_rules.dart';

import '../../../app/l10n/app_localizations.dart';
import '../../../app/theme.dart';
import '../labels.dart';
import 'panel.dart';

/// What the player can do with the selected officer now: in Council their
/// activated skill, in Orders one of the legal orders. The choices come from
/// the engine's legal actions, so an illegal one is never offered.
class OfficerActions extends StatelessWidget {
  const OfficerActions({
    super.key,
    required this.officerId,
    required this.state,
    required this.ruleset,
    required this.legal,
    required this.enabled,
    required this.onSetOrder,
    required this.onClearOrder,
    required this.onUseSkill,
  });

  final String officerId;
  final GameState state;
  final Ruleset ruleset;
  final List<GameAction> legal;

  /// False while animations play or the mission is over.
  final bool enabled;
  final ValueChanged<Order> onSetOrder;
  final VoidCallback onClearOrder;
  final ValueChanged<String?> onUseSkill;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final namer = Namer(l, ruleset);
    final officer = state.officers[officerId]!;
    if (state.isOver || officer.status != OfficerStatus.active || state.pendingChoice != null) {
      return const SizedBox.shrink();
    }

    final skills = [
      for (final a in legal)
        if (a is UseSkill && a.officerId == officerId) a,
    ];
    final orders = [
      for (final a in legal)
        if (a is SetOrder && a.officerId == officerId) a.order,
    ];
    final canClear = legal.any((a) => a is ClearOrder && a.officerId == officerId);

    final children = <Widget>[];
    if (state.phase == Phase.council) {
      for (final s in skills) {
        children.add(
          _ActionButton(
            key: Key('skill-${s.target ?? 'none'}'),
            label: s.target == null ? l.skillUse : l.skillUseOn(namer.target(state, s.target!)),
            onPressed: enabled ? () => onUseSkill(s.target) : null,
          ),
        );
      }
      if (children.isEmpty) children.add(_Hint(l.ordersOnlyInOrders));
    } else if (state.phase == Phase.orders) {
      if (officer.withdrawn) {
        children.add(_Hint(l.orderNoOrders));
      } else if (orders.isEmpty) {
        children.add(_Hint(l.ordersNone));
      } else {
        for (final o in orders) {
          final selected = officer.order == o;
          var label = namer.order(state, o);
          if (o.kind == OrderKind.evacuate) {
            final cost = state.unity.people < Balance.unityLowThreshold
                ? Balance.evacuateSupportCostLowPeople
                : Balance.evacuateSupportCost;
            label = l.orderCostSupport(label, l.resourceSupport, cost);
          }
          children.add(
            _ActionButton(
              key: Key('order-${o.kind.name}-${o.target ?? 'none'}'),
              label: label,
              selected: selected,
              onPressed: enabled ? () => onSetOrder(o) : null,
            ),
          );
        }
        if (canClear) {
          children.add(
            _ActionButton(key: const Key('order-clear'), label: l.orderClear, onPressed: enabled ? onClearOrder : null),
          );
        }
      }
    }
    if (children.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (state.phase == Phase.orders)
            Text(
              l.ordersTitle,
              style: const TextStyle(color: LongKyColors.goldLeaf, fontSize: 12, fontWeight: FontWeight.w700),
            ),
          const SizedBox(height: 4),
          Wrap(spacing: 6, runSpacing: 6, children: children),
        ],
      ),
    );
  }
}

class _Hint extends StatelessWidget {
  const _Hint(this.text);

  final String text;

  @override
  Widget build(BuildContext context) =>
      Text(text, style: TextStyle(color: LongKyColors.ivory.withValues(alpha: 0.8), fontSize: 12));
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({super.key, required this.label, required this.onPressed, this.selected = false});

  final String label;
  final VoidCallback? onPressed;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: minTouch),
        child: selected
            ? FilledButton(
                onPressed: onPressed,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, minTouch),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                child: Text(label, style: const TextStyle(fontSize: 13)),
              )
            : OutlinedButton(
                onPressed: onPressed,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, minTouch),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                child: Text(label, style: const TextStyle(fontSize: 13)),
              ),
      ),
    );
  }
}
