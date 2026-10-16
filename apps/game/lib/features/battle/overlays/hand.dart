import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lk_rules/lk_rules.dart';

import '../../../app/l10n/app_localizations.dart';
import '../../../app/theme.dart';
import '../labels.dart';
import 'panel.dart';

/// What a card costs now. Mirrors the engine: Support is +1 while Court is
/// below 4 (`cardSupportCost` in lk_rules). Tests keep the two in step.
({int rice, int support}) cardCostNow(GameState state, CardDef card) => (
  rice: card.cost.rice,
  support:
      card.cost.support + (state.unity.court < Balance.unityLowThreshold ? Balance.lowCourtCardSupportSurcharge : 0),
);

bool canAffordCard(GameState state, CardDef card) {
  final c = cardCostNow(state, card);
  return state.rice >= c.rice && state.support >= c.support;
}

/// The cards in hand, in hand order, as definitions. Unknown ids are skipped.
List<CardDef> handCards(GameState state, Ruleset ruleset) => [
  for (final id in state.hand)
    if (ruleset.cards[id] != null) ruleset.cards[id]!,
];

/// A lacquer tablet with a card's name, type, cost and text. Not a playing
/// card: no suit, rank or corner index. Painted frames come in T-21.
class CardTile extends StatelessWidget {
  const CardTile({
    super.key,
    required this.card,
    required this.state,
    required this.width,
    required this.selected,
    required this.onTap,
    this.showText = true,
    this.maxTextLines = 3,
    this.shortcut,
  });

  final CardDef card;
  final GameState state;
  final double width;
  final bool selected;
  final VoidCallback onTap;
  final bool showText;
  final int maxTextLines;

  /// The key that opens this card (1–9), named in its tooltip.
  final String? shortcut;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final cost = cardCostNow(state, card);
    final affordable = canAffordCard(state, card);
    final free = cost.rice == 0 && cost.support == 0;
    final costText = free
        ? l.cardFree
        : [
            if (cost.rice > 0) '${l.resourceRice} ${cost.rice}',
            if (cost.support > 0) '${l.resourceSupport} ${cost.support}',
          ].join(' · ');
    final name = l.content(card.name);
    return Semantics(
      button: true,
      selected: selected,
      label: l.cardSemantics(
        name,
        l.cardTypeName(card.type),
        affordable ? costText : '$costText, ${l.cardCannotAfford}',
      ),
      excludeSemantics: true,
      child: Tooltip(
        message: shortcut == null ? name : l.shortcutHint(name, shortcut!),
        child: Opacity(
          opacity: affordable ? 1 : 0.6,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(6),
              child: Container(
                width: width,
                constraints: const BoxConstraints(minHeight: minTouch),
                padding: const EdgeInsets.all(8),
                decoration: lacquerPanel(selected: selected, radius: 6, fill: LongKyColors.lacquerRaised),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: LongKyColors.goldLeaf,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l.cardTypeName(card.type),
                      style: TextStyle(color: LongKyColors.ivory.withValues(alpha: 0.75), fontSize: 11, height: 1.2),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      affordable ? costText : '$costText · ${l.cardCannotAfford}',
                      maxLines: 2,
                      style: const TextStyle(
                        color: LongKyColors.ivory,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                    ),
                    if (showText) ...[
                      const SizedBox(height: 4),
                      Text(
                        l.content(card.text),
                        maxLines: selected ? 8 : maxTextLines,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: LongKyColors.ivory.withValues(alpha: 0.9), fontSize: 11, height: 1.25),
                      ),
                    ],
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

/// Header line: hand size, piles and the low-Court surcharge note.
class _HandNotes extends StatelessWidget {
  const _HandNotes({required this.state});

  final GameState state;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final surcharge = state.unity.court < Balance.unityLowThreshold;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          l.handPiles(state.deck.length, state.discard.length),
          style: TextStyle(color: LongKyColors.ivory.withValues(alpha: 0.8), fontSize: 11),
        ),
        if (surcharge)
          Text(
            l.handCourtSurcharge(Balance.lowCourtCardSupportSurcharge),
            style: const TextStyle(color: LongKyColors.ivory, fontSize: 11, fontWeight: FontWeight.w600),
          ),
      ],
    );
  }
}

/// Regular layout: the hand is a column on the right, always visible.
class HandColumn extends StatefulWidget {
  const HandColumn({super.key, required this.state, required this.ruleset, this.onCardTap});

  final GameState state;
  final Ruleset ruleset;

  /// Opens the card (to play it). Without it, tapping only selects.
  final ValueChanged<CardDef>? onCardTap;

  static const double width = 280;

  @override
  State<HandColumn> createState() => _HandColumnState();
}

class _HandColumnState extends State<HandColumn> {
  String? _selected;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final cards = handCards(widget.state, widget.ruleset);
    return Container(
      key: const Key('hand-column'),
      width: HandColumn.width,
      padding: const EdgeInsets.all(8),
      decoration: const BoxDecoration(
        color: LongKyColors.lacquer,
        border: Border(left: BorderSide(color: LongKyColors.lacquerRaised)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l.handTitle(cards.length),
            style: const TextStyle(color: LongKyColors.goldLeaf, fontSize: 16, fontWeight: FontWeight.w700),
          ),
          _HandNotes(state: widget.state),
          const SizedBox(height: 8),
          Expanded(
            child: cards.isEmpty
                ? Text(l.handEmpty, style: const TextStyle(color: LongKyColors.ivory))
                : ListView.separated(
                    itemCount: cards.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      final card = cards[i];
                      // The same card can be in hand twice; select by position.
                      final key = '$i:${card.id}';
                      return CardTile(
                        key: Key('card-$i-${card.id}'),
                        card: card,
                        state: widget.state,
                        shortcut: i < 9 ? '${i + 1}' : null,
                        width: double.infinity,
                        selected: _selected == key,
                        onTap: () {
                          if (widget.onCardTap != null) {
                            widget.onCardTap!(card);
                          } else {
                            setState(() => _selected = _selected == key ? null : key);
                          }
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

/// Compact layout: the handle at the bottom bar; tapping it opens the fan.
class HandDrawer extends StatelessWidget {
  const HandDrawer({super.key, required this.state, required this.ruleset, required this.open, required this.onToggle});

  final GameState state;
  final Ruleset ruleset;
  final bool open;
  final VoidCallback onToggle;

  /// Width of the handle button.
  static const double handleWidth = 148;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return FilledButton.tonal(
      key: const Key('hand-handle'),
      onPressed: onToggle,
      style: FilledButton.styleFrom(
        minimumSize: const Size(handleWidth, minTouch),
        maximumSize: const Size(handleWidth, minTouch),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        backgroundColor: LongKyColors.lacquerRaised,
        foregroundColor: LongKyColors.goldLeaf,
        side: const BorderSide(color: LongKyColors.goldLeaf),
      ),
      child: Tooltip(
        message: open ? l.handHide : l.handShow,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(open ? Icons.expand_more : Icons.expand_less, size: 18),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                l.handTitle(state.hand.length),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact layout: the cards of the hand fanned out above the bottom bar.
/// Tapping a card lifts it and shows its full text; playing comes in T-17.
class HandFan extends StatefulWidget {
  const HandFan({super.key, required this.state, required this.ruleset, required this.availableWidth, this.onCardTap});

  final GameState state;
  final Ruleset ruleset;
  final double availableWidth;

  /// Opens the card (to play it). Without it, tapping only lifts the card.
  final ValueChanged<CardDef>? onCardTap;

  static const double cardWidth = 118;
  static const double height = 168;

  @override
  State<HandFan> createState() => _HandFanState();
}

class _HandFanState extends State<HandFan> {
  int? _selected;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final cards = handCards(widget.state, widget.ruleset);
    if (cards.isEmpty) {
      return Container(
        key: const Key('hand-fan'),
        padding: const EdgeInsets.all(12),
        decoration: lacquerPanel(),
        child: Text(l.handEmpty, style: const TextStyle(color: LongKyColors.ivory)),
      );
    }
    // Cards overlap just enough to fit; the selected one lifts and straightens.
    const w = HandFan.cardWidth;
    final n = cards.length;
    final step = n <= 1 ? 0.0 : math.min(w * 0.9, (widget.availableWidth - w) / (n - 1));
    final total = w + step * (n - 1);
    final duration = MediaQuery.of(context).disableAnimations ? Duration.zero : const Duration(milliseconds: 150);
    // The selected card is drawn last, so it is on top.
    final order = [for (var i = 0; i < n; i++) i]..sort((a, b) => (a == _selected ? 1 : 0) - (b == _selected ? 1 : 0));
    return SizedBox(
      key: const Key('hand-fan'),
      width: total,
      height: HandFan.height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (final i in order)
            AnimatedPositioned(
              key: ValueKey('fan-$i-${cards[i].id}'),
              duration: duration,
              left: step * i,
              bottom: i == _selected ? 4 : 0,
              child: Transform.rotate(
                angle: i == _selected || n == 1 ? 0 : (i - (n - 1) / 2) * 0.05,
                alignment: Alignment.bottomCenter,
                child: CardTile(
                  key: Key('card-$i-${cards[i].id}'),
                  card: cards[i],
                  state: widget.state,
                  shortcut: i < 9 ? '${i + 1}' : null,
                  width: w,
                  selected: i == _selected,
                  maxTextLines: 2,
                  onTap: () {
                    if (widget.onCardTap != null) {
                      widget.onCardTap!(cards[i]);
                    } else {
                      setState(() => _selected = _selected == i ? null : i);
                    }
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}
