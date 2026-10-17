import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lk_content/lk_content.dart';
import 'package:lk_rules/lk_rules.dart';

import '../../app/l10n/app_localizations.dart';
import '../../app/lacquer.dart';
import '../../app/theme.dart';
import '../../art/art_image.dart';
import '../../data/codex.dart';
import '../../data/progress.dart';
import '../battle/labels.dart';
import '../settings/progress_cubit.dart';
import 'read_more.dart';

/// One page of the Codex: portrait, what the content says about it, its
/// sources and "Read more in Long Ký".
///
/// TODO(T-24): lore text and the bonus card behind an unlock code. The
/// content has neither yet (lore needs the history reviewer; no bonus card is
/// defined), so an unlocked page shows the "Unlocked" mark and nothing more.
class CodexEntryScreen extends StatelessWidget {
  const CodexEntryScreen({super.key, required this.entry, required this.sources});

  final CodexEntry entry;
  final Map<String, SourceDef> sources;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final title = entry.title == null ? null : l.content(entry.title!);
    return LacquerPage(
      title: l.content(entry.name),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: SingleChildScrollView(
              key: const Key('codex-entry'),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 120,
                        height: 160,
                        child: ArtImage(path: entry.art, name: l.content(entry.name), icon: _icon),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l.content(entry.name),
                              style: const TextStyle(
                                color: LongKyColors.goldLeaf,
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (title != null)
                              Text(title, style: const TextStyle(color: LongKyColors.ivory, fontSize: 14)),
                            const SizedBox(height: 8),
                            ..._facts(l),
                          ],
                        ),
                      ),
                    ],
                  ),
                  BlocBuilder<ProgressCubit, Progress>(
                    builder: (context, progress) => entry.longKyId != null && progress.unlocks.contains(entry.longKyId)
                        ? Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Row(
                              key: const Key('entry-unlocked'),
                              children: [
                                const Icon(Icons.lock_open, size: 20, color: LongKyColors.goldLeaf),
                                const SizedBox(width: 8),
                                Text(
                                  l.codexUnlocked,
                                  style: const TextStyle(color: LongKyColors.goldLeaf, fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                  ..._text(l),
                  const SizedBox(height: 16),
                  Text(
                    l.codexSources,
                    style: const TextStyle(color: LongKyColors.goldLeaf, fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  for (final ref in entry.sourceRefs)
                    Padding(
                      key: Key('source-$ref'),
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text(
                        _sourceLine(sources[ref], ref),
                        style: TextStyle(color: LongKyColors.ivory.withValues(alpha: 0.85), fontSize: 13),
                      ),
                    ),
                  if (entry.longKyId != null) ...[
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: ReadMoreButton(longKyId: entry.longKyId!, isPerson: entry.isPerson),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData get _icon => switch (entry.kind) {
    CodexKind.officer => Icons.person_outline,
    CodexKind.enemy => Icons.shield_outlined,
    CodexKind.card => Icons.style_outlined,
  };

  static String _sourceLine(SourceDef? s, String ref) {
    if (s == null) return ref;
    return [s.work, ?s.publisher, ?s.section].where((x) => x.isNotEmpty).join(' · ');
  }

  /// Stats of a person, the cost and type of a card.
  List<Widget> _facts(AppLocalizations l) {
    const style = TextStyle(color: LongKyColors.ivory, fontSize: 14);
    Widget line(String s) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Text(s, style: style),
    );
    final o = entry.officer;
    if (o != null) {
      return [
        line('${l.statLeadership}: ${o.stats.leadership}'),
        line('${l.statWar}: ${o.stats.war}'),
        line('${l.statIntelligence}: ${o.stats.intelligence}'),
        line('${l.statPolitics}: ${o.stats.politics}'),
        line('${l.statLoyalty}: ${o.stats.loyalty}'),
      ];
    }
    final c = entry.commander;
    if (c != null) {
      return [
        line('${l.statLeadership}: ${c.stats.leadership}'),
        line('${l.statWar}: ${c.stats.war}'),
        line('${l.statIntelligence}: ${c.stats.intelligence}'),
      ];
    }
    final card = entry.card!;
    return [
      line(switch (card.type) {
        CardType.stratagem => l.cardTypeStratagem,
        CardType.event => l.cardTypeEvent,
        CardType.intent => l.cardTypeIntent,
      }),
      line(l.cardCostSemantics(card.cost.rice, card.cost.support)),
    ];
  }

  /// Skill, flaw or card text, as written in the content.
  List<Widget> _text(AppLocalizations l) {
    Widget block(String heading, LocalizedText name, LocalizedText text) => Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$heading: ${l.content(name)}',
            style: const TextStyle(color: LongKyColors.goldLeaf, fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 2),
          Text(l.content(text), style: const TextStyle(color: LongKyColors.ivory, fontSize: 15, height: 1.4)),
        ],
      ),
    );
    final o = entry.officer;
    if (o != null) {
      return [
        if (o.skill != null) block(l.inspectorSkill, o.skill!.name, o.skill!.text),
        if (o.flaw != null) block(l.inspectorFlaw, o.flaw!.name, o.flaw!.text),
      ];
    }
    final card = entry.card;
    if (card != null) {
      return [
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Text(
            l.content(card.text),
            style: const TextStyle(color: LongKyColors.ivory, fontSize: 15, height: 1.4),
          ),
        ),
      ];
    }
    return const [];
  }
}
