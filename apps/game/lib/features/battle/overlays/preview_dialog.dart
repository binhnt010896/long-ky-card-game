import 'package:flutter/material.dart';
import 'package:lk_rules/lk_rules.dart';

import '../../../app/l10n/app_localizations.dart';
import '../../../app/theme.dart';
import '../battle_preview.dart';
import '../labels.dart';
import 'panel.dart';

/// Asks the player to confirm an order that would cause [previews]; true when
/// they give it anyway.
Future<bool> showBattlePreviewDialog(
  BuildContext context, {
  required List<BattlePreview> previews,
  required GameState state,
  required Ruleset ruleset,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (_) => BattlePreviewDialog(previews: previews, state: state, ruleset: ruleset),
  );
  return result ?? false;
}

/// The battle preview (build-spec section 6): both Powers and the expected
/// losses. An ambush shows a range, because of the roll.
class BattlePreviewDialog extends StatelessWidget {
  const BattlePreviewDialog({super.key, required this.previews, required this.state, required this.ruleset});

  final List<BattlePreview> previews;
  final GameState state;
  final Ruleset ruleset;

  static String _n(double x) => x.toStringAsFixed(1);

  static String _range(int lo, int hi) => lo == hi ? '$lo' : '$lo–$hi';

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final namer = Namer(l, ruleset);
    return Dialog(
      key: const Key('battle-preview'),
      backgroundColor: LongKyColors.lacquerRaised,
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: LongKyColors.cinnabar, width: 2),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l.previewTitle,
                style: const TextStyle(color: LongKyColors.goldLeaf, fontSize: 20, fontWeight: FontWeight.w700),
              ),
              for (final p in previews) ...[
                const SizedBox(height: 12),
                _PreviewBlock(preview: p, state: state, namer: namer, l: l),
              ],
              const SizedBox(height: 16),
              Wrap(
                alignment: WrapAlignment.end,
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton(
                    key: const Key('preview-cancel'),
                    onPressed: () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(minimumSize: const Size(0, minTouch)),
                    child: Text(l.actionCancel),
                  ),
                  FilledButton(
                    key: const Key('preview-confirm'),
                    onPressed: () => Navigator.of(context).pop(true),
                    style: FilledButton.styleFrom(minimumSize: const Size(0, minTouch)),
                    child: Text(l.previewConfirm),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PreviewBlock extends StatelessWidget {
  const _PreviewBlock({required this.preview, required this.state, required this.namer, required this.l});

  final BattlePreview preview;
  final GameState state;
  final Namer namer;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    final f = preview.forecast;
    final heading = preview.kind == BattleKind.ambush
        ? l.previewAmbush(namer.edge(preview.edge!))
        : l.previewField(namer.node(preview.nodeId));
    final dv = preview.isRange
        ? '${BattlePreviewDialog._n(f.daiVietPower)}–${BattlePreviewDialog._n(f.daiVietPowerMax)}'
        : BattlePreviewDialog._n(f.daiVietPower);
    final lossesDv = BattlePreviewDialog._range(
      f.daiVietLossesAtMaxRoll < f.daiVietLosses ? f.daiVietLossesAtMaxRoll : f.daiVietLosses,
      f.daiVietLossesAtMaxRoll < f.daiVietLosses ? f.daiVietLosses : f.daiVietLossesAtMaxRoll,
    );
    final lossesYuan = BattlePreviewDialog._range(
      f.yuanLosses < f.yuanLossesAtMaxRoll ? f.yuanLosses : f.yuanLossesAtMaxRoll,
      f.yuanLosses < f.yuanLossesAtMaxRoll ? f.yuanLossesAtMaxRoll : f.yuanLosses,
    );
    return Container(
      key: Key('preview-${preview.kind.name}-${preview.nodeId}'),
      padding: const EdgeInsets.all(10),
      decoration: lacquerPanel(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            heading,
            style: const TextStyle(color: LongKyColors.ivory, fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          _line(l.previewOfficers(preview.officerIds.map(namer.officer).join(', '))),
          _line(l.previewArmies(preview.armyIds.map((id) => namer.army(state, id)).join(', '))),
          _line(l.previewPowers(dv, BattlePreviewDialog._n(f.yuanPower))),
          preview.certain
              ? _line(l.previewWinner(l.sideName(f.winner)), bold: true)
              : _line(l.previewUncertain(l.sideName(f.winner), l.sideName(f.winnerAtMaxRoll)), bold: true),
          _line(l.previewLosses(lossesDv, lossesYuan)),
        ],
      ),
    );
  }

  Widget _line(String text, {bool bold = false}) => Padding(
    padding: const EdgeInsets.only(top: 2),
    child: Text(
      text,
      style: TextStyle(
        color: LongKyColors.ivory,
        fontSize: 13,
        height: 1.35,
        fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
      ),
    ),
  );
}
