import 'package:flutter/material.dart';
import 'package:lk_rules/lk_rules.dart';

import '../../../app/l10n/app_localizations.dart';
import '../../../app/theme.dart';
import '../board/board_scene.dart';
import '../labels.dart';
import 'panel.dart';

/// One tile per officer: portrait, name, troops, morale, order.
/// Tapping an active officer selects them on the board.
class OfficerStrip extends StatelessWidget {
  const OfficerStrip({
    super.key,
    required this.state,
    required this.ruleset,
    required this.mode,
    required this.selection,
    required this.onSelect,
  });

  final GameState state;
  final Ruleset ruleset;
  final BattleLayoutMode mode;
  final Selection? selection;
  final ValueChanged<Selection> onSelect;

  static double heightFor(BattleLayoutMode mode) => mode.isCompact ? 52 : 80;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final ids = state.officers.keys.toList()..sort();
    return Semantics(
      container: true,
      label: l.officerStripLabel,
      child: SizedBox(
        key: const Key('officer-strip'),
        height: heightFor(mode),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: mode.isCompact ? 4 : 8, vertical: mode.isCompact ? 2 : 6),
          itemCount: ids.length,
          separatorBuilder: (_, _) => SizedBox(width: mode.isCompact ? 4 : 8),
          itemBuilder: (context, i) {
            final id = ids[i];
            final selected = selection?.kind == SelectionKind.officer && selection?.id == id;
            return OfficerTile(
              key: Key('officer-$id'),
              id: id,
              state: state,
              ruleset: ruleset,
              mode: mode,
              selected: selected,
              onTap: () => onSelect(Selection(SelectionKind.officer, id)),
            );
          },
        ),
      ),
    );
  }
}

class OfficerTile extends StatelessWidget {
  const OfficerTile({
    super.key,
    required this.id,
    required this.state,
    required this.ruleset,
    required this.mode,
    required this.selected,
    required this.onTap,
  });

  final String id;
  final GameState state;
  final Ruleset ruleset;
  final BattleLayoutMode mode;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final namer = Namer(l, ruleset);
    final o = state.officers[id]!;
    final def = ruleset.officers[id]!;
    final active = o.status == OfficerStatus.active;
    final compact = mode.isCompact;
    final name = l.content(def.name);
    final troops = l.troopsShort(o.troops);

    final String detail;
    if (!active) {
      detail = o.status == OfficerStatus.captured ? l.statusCaptured : l.statusDefected;
    } else if (o.order != null) {
      detail = namer.order(state, o.order!);
    } else if (state.phase == Phase.orders) {
      detail = l.orderNone;
    } else {
      detail = l.moraleShort(o.morale);
    }

    return Semantics(
      button: active,
      selected: selected,
      label: l.officerSemantics(name, troops, detail),
      excludeSemantics: true,
      child: Tooltip(
        message: l.shortcutHint('$name · ${l.troopsFull(o.troops)} · ${l.moraleShort(o.morale)}', 'Tab'),
        child: Opacity(
          opacity: active ? 1 : 0.5,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: active ? onTap : null,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                constraints: BoxConstraints(minWidth: compact ? 112 : 168, minHeight: minTouch),
                padding: EdgeInsets.symmetric(horizontal: compact ? 6 : 10),
                decoration: lacquerPanel(selected: selected),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    PortraitBadge(
                      path: def.portraitArt,
                      initials: initialsOf(def.name.vi),
                      size: compact ? 34 : 46,
                      heavy: def.isKing,
                    ),
                    SizedBox(width: compact ? 6 : 8),
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: compact ? 120 : 150),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: LongKyColors.ivory,
                              fontSize: compact ? 12 : 14,
                              fontWeight: FontWeight.w600,
                              height: 1.15,
                            ),
                          ),
                          Text(
                            active ? '$troops · $detail' : detail,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: LongKyColors.ivory.withValues(alpha: 0.85),
                              fontSize: compact ? 11 : 12,
                              height: 1.15,
                            ),
                          ),
                          if (!compact && active)
                            Text(
                              l.moraleShort(o.morale),
                              maxLines: 1,
                              style: TextStyle(
                                color: LongKyColors.ivory.withValues(alpha: 0.7),
                                fontSize: 11,
                                height: 1.15,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
