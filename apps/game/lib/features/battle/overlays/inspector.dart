import 'package:flutter/material.dart';
import 'package:lk_rules/lk_rules.dart';

import '../../../app/l10n/app_localizations.dart';
import '../../../app/theme.dart';
import '../board/board_scene.dart';
import '../labels.dart';
import 'panel.dart';

/// Details of the selected node, officer or army.
///
/// Compact layout shows it as a bottom sheet, regular as a floating panel
/// next to the selection; both use this body. [BattleScreen] places it.
class InspectorPanel extends StatelessWidget {
  const InspectorPanel({
    super.key,
    required this.selection,
    required this.state,
    required this.ruleset,
    required this.mode,
    required this.onClose,
    this.actions,
  });

  final Selection selection;
  final GameState state;
  final Ruleset ruleset;
  final BattleLayoutMode mode;
  final VoidCallback onClose;

  /// Right under an officer's name and troops: what the player can do with
  /// them now.
  final Widget? actions;

  static const double floatingWidth = 300;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final namer = Namer(l, ruleset);
    final body = switch (selection.kind) {
      SelectionKind.node => _nodeBody(l, namer),
      SelectionKind.officer => _officerBody(l, namer),
      SelectionKind.army => _armyBody(l, namer),
    };
    return Material(
      key: Key('inspector-${selection.kind.name}'),
      color: LongKyColors.lacquerRaised,
      shape: RoundedRectangleBorder(
        borderRadius: mode.isCompact ? const BorderRadius.vertical(top: Radius.circular(12)) : BorderRadius.circular(8),
        side: BorderSide(color: LongKyColors.goldLeaf.withValues(alpha: 0.7)),
      ),
      elevation: 4,
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(12, mode.isCompact ? 12 : 10, 12 + minTouch, 10),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [body],
              ),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              key: const Key('inspector-close'),
              tooltip: l.inspectorClose,
              constraints: const BoxConstraints(minWidth: minTouch, minHeight: minTouch),
              onPressed: onClose,
              icon: const Icon(Icons.close, color: LongKyColors.ivory),
            ),
          ),
        ],
      ),
    );
  }

  // ---- node

  Widget _nodeBody(AppLocalizations l, Namer namer) {
    final def = ruleset.map.nodes.firstWhere((n) => n.id == selection.id);
    final node = state.nodes[def.id]!;
    final officers = [
      for (final e in state.activeOfficers)
        if (e.value.nodeId == def.id) namer.officer(e.key),
    ];
    final armies = [
      for (final e in state.activeArmies)
        if (e.value.nodeId == def.id) namer.army(state, e.key),
    ];
    final here = [...officers, ...armies];
    return _Section(
      title: l.content(def.name),
      subtitle: [
        l.terrainName(def.terrain),
        if (def.isCapital) l.nodeCapital,
        if (def.isBorder) l.nodeBorder,
        if (node.evacuated) l.nodeEvacuated,
      ].join(' · '),
      children: [
        _Line(l.nodeControlledBy(l.sideName(node.controller))),
        _Line(l.nodeRiceStock(node.riceStock)),
        const SizedBox(height: 6),
        _Heading(l.nodeUnits),
        if (here.isEmpty) _Line(l.nodeNoUnits) else for (final h in here) _Line(h),
      ],
    );
  }

  // ---- officer

  Widget _officerBody(AppLocalizations l, Namer namer) {
    final def = ruleset.officers[selection.id]!;
    final o = state.officers[selection.id]!;
    final skill = def.skill;
    final flaw = def.flaw;
    return _Section(
      title: l.content(def.name),
      subtitle: [if (def.title != null) l.content(def.title!), if (def.isKing) l.officerIsKing].join(' · '),
      children: [
        _Line('${l.troopsFull(o.troops)} · ${l.moraleShort(o.morale)}'),
        _Line(namer.node(o.nodeId)),
        // What the player can do now comes first: on a phone the sheet is short.
        ?actions,
        _Stats(
          entries: [
            (l.statLeadership, def.stats.leadership),
            (l.statWar, def.stats.war),
            (l.statIntelligence, def.stats.intelligence),
            (l.statPolitics, def.stats.politics),
            (l.statLoyalty, o.loyalty),
          ],
        ),
        const SizedBox(height: 6),
        _Heading(l.inspectorOrder),
        _Line(o.order == null ? l.orderNone : namer.order(state, o.order!)),
        if (skill != null) ...[
          const SizedBox(height: 6),
          _Heading(
            '${l.inspectorSkill}: ${l.content(skill.name)}'
            ' (${skill.kind == SkillKind.passive ? l.skillPassive : l.skillUsesLeft(o.skillUsesLeft)})',
          ),
          _Line(l.content(skill.text)),
        ],
        if (flaw != null) ...[
          const SizedBox(height: 6),
          _Heading('${l.inspectorFlaw}: ${l.content(flaw.name)}'),
          _Line(l.content(flaw.text)),
        ],
      ],
    );
  }

  // ---- army

  Widget _armyBody(AppLocalizations l, Namer namer) {
    final a = state.armies[selection.id]!;
    final commander = ruleset.commanders[a.commanderId];
    final intent = a.intent;
    final predicted = a.predictedIntent;
    return _Section(
      title: namer.army(state, selection.id),
      subtitle: a.status == ArmyStatus.routed ? l.armyRouted : namer.node(a.nodeId),
      children: [
        if (commander != null) _Line('${l.inspectorCommander}: ${l.content(commander.name)}'),
        _Line('${l.troopsFull(a.troops)} · ${l.moraleShort(a.morale)}'),
        _Line(l.inspectorSupply(a.supply, a.maxSupply)),
        const SizedBox(height: 6),
        _Heading(l.inspectorIntent),
        _Line(intent == null ? l.intentUnknown : namer.intent(intent)),
        if (predicted != null) _Line(l.intentPredicted(namer.intent(predicted))),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.subtitle, required this.children});

  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: const TextStyle(color: LongKyColors.goldLeaf, fontSize: 17, fontWeight: FontWeight.w700, height: 1.2),
        ),
        if (subtitle.isNotEmpty)
          Text(subtitle, style: TextStyle(color: LongKyColors.ivory.withValues(alpha: 0.8), fontSize: 12, height: 1.3)),
        const SizedBox(height: 6),
        ...children,
      ],
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(color: LongKyColors.goldLeaf, fontSize: 12, fontWeight: FontWeight.w700, height: 1.4),
  );
}

class _Line extends StatelessWidget {
  const _Line(this.text);

  final String text;

  @override
  Widget build(BuildContext context) =>
      Text(text, style: const TextStyle(color: LongKyColors.ivory, fontSize: 13, height: 1.35));
}

class _Stats extends StatelessWidget {
  const _Stats({required this.entries});

  final List<(String, int)> entries;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Wrap(
        spacing: 12,
        runSpacing: 2,
        children: [
          for (final (label, value) in entries)
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '$label ',
                    style: TextStyle(color: LongKyColors.ivory.withValues(alpha: 0.8)),
                  ),
                  TextSpan(
                    text: '$value',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              style: const TextStyle(color: LongKyColors.ivory, fontSize: 12),
            ),
        ],
      ),
    );
  }
}
