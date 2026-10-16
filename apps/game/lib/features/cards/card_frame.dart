import 'package:flutter/material.dart';
import 'package:lk_rules/lk_rules.dart';

import '../../app/l10n/app_localizations.dart';
import '../../app/theme.dart';
import '../../art/art_image.dart';
import '../battle/labels.dart';

/// The four kinds of card share one frame (plan, "Cards"): an officer, a
/// stratagem, an event and an enemy intent.
enum CardFrameKind {
  officer(Icons.person_outline),
  stratagem(Icons.auto_stories_outlined),
  event(Icons.campaign_outlined),
  intent(Icons.flag_outlined);

  const CardFrameKind(this.icon);

  /// The glyph of the art placeholder.
  final IconData icon;

  static CardFrameKind of(CardType t) => switch (t) {
    CardType.stratagem => stratagem,
    CardType.event => event,
    CardType.intent => intent,
  };
}

/// What a card costs, as the frame shows it. Both zero is free.
typedef FrameCost = ({int rice, int support, bool surcharge});

/// A lacquer tablet in 3:4 portrait (build-spec section 6): a black lacquer
/// body, a gold border and hairline, the name on a banner, the art in a
/// window, the cost in a row under it and the text below. It is a tablet, not
/// a playing card: no suits, no ranks and no corner indices; the cost sits in
/// a row, never in a corner.
///
/// Painted art loads by id and is replaced by a placeholder until it exists.
class CardFrame extends StatelessWidget {
  const CardFrame({
    super.key,
    required this.kind,
    required this.name,
    required this.typeLabel,
    required this.width,
    this.artPath,
    this.text,
    this.cost,
    this.stats = const [],
    this.footer,
    this.selected = false,
    this.dimmed = false,
  });

  /// Width over height of every frame.
  static const double aspect = 3 / 4;

  /// From this width on the frame has room for the card text.
  static const double textMinWidth = 190;

  final CardFrameKind kind;
  final String name;

  /// "Mưu kế", "Stratagem", ...: small, above the name.
  final String typeLabel;
  final double width;
  final String? artPath;

  /// The effect text; shown when the frame is wide enough.
  final String? text;

  /// Null on an officer or an enemy intent, which are not paid for.
  final FrameCost? cost;

  /// Officer stats under the art: label and value.
  final List<(String, int)> stats;

  /// One line at the bottom, e.g. an officer's skill.
  final String? footer;
  final bool selected;

  /// Cannot be paid for now.
  final bool dimmed;

  double get height => width / aspect;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final big = width >= textMinWidth;
    final nameSize = (width * 0.075).clamp(11.0, 18.0);
    final small = (width * 0.055).clamp(9.0, 12.5);
    final pad = (width * 0.04).clamp(4.0, 10.0);
    final body = LongKyColors.lacquerRaised;

    return Opacity(
      opacity: dimmed ? 0.6 : 1,
      child: Container(
        key: const Key('card-frame'),
        width: width,
        height: height,
        padding: EdgeInsets.all(pad),
        decoration: BoxDecoration(
          color: body,
          borderRadius: BorderRadius.circular(width * 0.05),
          border: Border.all(color: LongKyColors.goldLeaf, width: selected ? 3 : 1.5),
          boxShadow: selected
              ? [BoxShadow(color: LongKyColors.goldLeaf.withValues(alpha: 0.45), blurRadius: 10)]
              : const [],
        ),
        child: Container(
          // The gold hairline inside the border: the tablet's inlay.
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(width * 0.03),
            border: Border.all(color: LongKyColors.goldLeaf.withValues(alpha: 0.4), width: 0.8),
          ),
          padding: EdgeInsets.all(pad * 0.7),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                typeLabel,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: LongKyColors.ivory.withValues(alpha: 0.7),
                  fontSize: small,
                  letterSpacing: 0.5,
                  height: 1.1,
                ),
              ),
              Text(
                name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: LongKyColors.goldLeaf,
                  fontSize: nameSize,
                  fontWeight: FontWeight.w700,
                  height: 1.15,
                ),
              ),
              // A cinnabar rule under the name, as on a lacquer plaque.
              Container(
                margin: EdgeInsets.symmetric(vertical: pad * 0.5, horizontal: width * 0.12),
                height: 2,
                color: LongKyColors.cinnabar,
              ),
              Expanded(
                flex: big ? 5 : 4,
                child: ArtImage(path: artPath, name: name, showName: false, icon: kind.icon),
              ),
              if (stats.isNotEmpty) ...[SizedBox(height: pad * 0.6), _StatsRow(stats: stats, fontSize: small)],
              if (cost != null) ...[
                SizedBox(height: pad * 0.6),
                _CostRow(cost: cost!, fontSize: small + 1, free: l.cardFree),
              ],
              if (big && text != null) ...[
                SizedBox(height: pad * 0.6),
                Expanded(
                  flex: 4,
                  child: Text(
                    text!,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 7,
                    style: TextStyle(color: LongKyColors.ivory.withValues(alpha: 0.92), fontSize: small, height: 1.25),
                  ),
                ),
              ],
              if (footer != null) ...[
                SizedBox(height: pad * 0.4),
                Text(
                  footer!,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: LongKyColors.ivory.withValues(alpha: 0.85), fontSize: small, height: 1.2),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// The cost as a centred row under the art: Rice and Support, each a glyph and
/// a number; "free" for none. A `+` marks Support raised by a low Court.
class _CostRow extends StatelessWidget {
  const _CostRow({required this.cost, required this.fontSize, required this.free});

  final FrameCost cost;
  final double fontSize;
  final String free;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(color: LongKyColors.ivory, fontSize: fontSize, fontWeight: FontWeight.w700, height: 1.1);
    if (cost.rice == 0 && cost.support == 0) {
      return Text(free, textAlign: TextAlign.center, style: style);
    }
    Widget item(IconData icon, String value) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: fontSize + 2, color: LongKyColors.goldLeaf),
        const SizedBox(width: 2),
        Text(value, style: style),
      ],
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (cost.rice > 0) item(Icons.grass, '${cost.rice}'),
        if (cost.rice > 0 && cost.support > 0) SizedBox(width: fontSize),
        if (cost.support > 0) item(Icons.favorite, '${cost.support}${cost.surcharge ? '+' : ''}'),
      ],
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.stats, required this.fontSize});

  final List<(String, int)> stats;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final (label, value) in stats)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '$label ',
                      style: TextStyle(color: LongKyColors.ivory.withValues(alpha: 0.75)),
                    ),
                    TextSpan(
                      text: '$value',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                style: TextStyle(color: LongKyColors.ivory, fontSize: fontSize),
              ),
            ),
        ],
      ),
    );
  }
}

/// The frame of a stratagem, event or enemy-intent card.
CardFrame frameForCard(
  AppLocalizations l,
  CardDef card, {
  required double width,
  required FrameCost cost,
  bool selected = false,
  bool dimmed = false,
}) => CardFrame(
  kind: CardFrameKind.of(card.type),
  name: l.content(card.name),
  typeLabel: l.cardTypeName(card.type),
  width: width,
  artPath: card.art,
  text: l.content(card.text),
  cost: cost,
  selected: selected,
  dimmed: dimmed,
);

/// The frame of an officer card: portrait, the five stats and the signature
/// skill. [loyalty] is the officer's loyalty now (it changes in play).
CardFrame frameForOfficer(
  AppLocalizations l,
  OfficerDef officer, {
  required double width,
  int? loyalty,
  bool selected = false,
}) => CardFrame(
  kind: CardFrameKind.officer,
  name: l.content(officer.name),
  typeLabel: officer.title == null ? l.officerStripLabel : l.content(officer.title!),
  width: width,
  artPath: officer.cardArt ?? officer.portraitArt,
  stats: [
    (l.statLeadership, officer.stats.leadership),
    (l.statWar, officer.stats.war),
    (l.statIntelligence, officer.stats.intelligence),
    (l.statPolitics, officer.stats.politics),
    (l.statLoyalty, loyalty ?? officer.stats.loyalty),
  ],
  footer: officer.skill == null ? null : l.content(officer.skill!.name),
  selected: selected,
);
