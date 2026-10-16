import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lk_rules/lk_rules.dart';

import '../../app/l10n/app_localizations.dart';
import '../../app/theme.dart';
import 'battle_cubit.dart';
import 'board/battle_board.dart';
import 'board/board_layout.dart';
import 'board/board_scene.dart';
import 'labels.dart';
import 'overlays/event_log.dart';
import 'overlays/hand.dart';
import 'overlays/inspector.dart';
import 'overlays/officer_strip.dart';
import 'overlays/panel.dart';
import 'overlays/phase_button.dart';
import 'overlays/top_bar.dart';

/// The battle screen: the Flame board with Flutter overlays around it
/// (build-spec section 6). Reads its [BattleCubit] from the context.
///
/// The board sits in the space the overlays leave free, so nothing covers
/// it except what is open on purpose: the inspector, the hand fan on
/// compact and the log popover on compact.
class BattleScreen extends StatefulWidget {
  const BattleScreen({super.key, required this.ruleset, this.onExit});

  final Ruleset ruleset;

  /// Shows a back button in the top bar when set.
  final VoidCallback? onExit;

  @override
  State<BattleScreen> createState() => _BattleScreenState();
}

class _BattleScreenState extends State<BattleScreen> {
  final GlobalKey<BattleBoardState> _boardKey = GlobalKey<BattleBoardState>();
  Selection? _selection;

  /// Regular: the left log panel is expanded.
  bool _logExpanded = true;

  /// Compact: the log popover and the hand fan are open.
  bool _logOpen = false;
  bool _handOpen = false;

  void _select(Selection? s) => _boardKey.currentState?.select(s);

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: LongKyColors.lacquer,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final mode = BattleLayoutMode.forWidth(constraints.maxWidth);
          return SafeArea(
            child: BlocBuilder<BattleCubit, BattleViewState>(
              builder: (context, view) => mode.isCompact ? _compact(context, l, view) : _regular(context, l, view),
            ),
          );
        },
      ),
    );
  }

  Widget _board(BattleViewState view, AppLocalizations l) => BattleBoard(
    key: _boardKey,
    ruleset: widget.ruleset,
    state: view.state,
    languageCode: l.localeName,
    onSelectionChanged: (s) => setState(() => _selection = s),
  );

  Widget _topBar(BattleViewState view, BattleLayoutMode mode, {Widget? trailing}) => BattleTopBar(
    state: view.state,
    seasonTurns: widget.ruleset.mission.seasonTurns,
    mode: mode,
    leading: widget.onExit == null
        ? null
        : IconButton(
            key: const Key('battle-exit'),
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            constraints: const BoxConstraints(minWidth: minTouch, minHeight: minTouch),
            onPressed: widget.onExit,
            icon: const Icon(Icons.arrow_back, color: LongKyColors.goldLeaf),
          ),
    trailing: trailing,
  );

  Widget _strip(BattleViewState view, BattleLayoutMode mode) =>
      OfficerStrip(state: view.state, ruleset: widget.ruleset, mode: mode, selection: _selection, onSelect: _select);

  Widget _inspector(BattleViewState view, BattleLayoutMode mode) => InspectorPanel(
    selection: _selection!,
    state: view.state,
    ruleset: widget.ruleset,
    mode: mode,
    onClose: () => _select(null),
  );

  // ---- compact (< 900 wide)

  Widget _compact(BuildContext context, AppLocalizations l, BattleViewState view) {
    const mode = BattleLayoutMode.compact;
    final top = BattleTopBar.heightFor(mode);
    final bottom = OfficerStrip.heightFor(mode);
    final cubit = context.read<BattleCubit>();
    final lines = logLines(l, widget.ruleset, view.state, view.events);
    return LayoutBuilder(
      builder: (context, c) {
        final free = c.maxHeight - top - bottom;
        return Stack(
          children: [
            Positioned.fill(top: top, bottom: bottom, child: _board(view, l)),
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              child: _topBar(view, mode, trailing: LogButton(onPressed: () => setState(() => _logOpen = !_logOpen))),
            ),
            // Bottom row: officers, hand handle, phase button.
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: bottom,
              child: ColoredBox(
                color: LongKyColors.lacquer,
                child: Row(
                  children: [
                    Expanded(child: _strip(view, mode)),
                    HandDrawer(
                      state: view.state,
                      ruleset: widget.ruleset,
                      open: _handOpen,
                      onToggle: () => setState(() => _handOpen = !_handOpen),
                    ),
                    const SizedBox(width: 4),
                    PhaseButton(state: view.state, mode: mode, onPressed: cubit.endPhase),
                    const SizedBox(width: 4),
                  ],
                ),
              ),
            ),
            if (_handOpen)
              Positioned(
                left: 8,
                right: 8,
                bottom: bottom + 4,
                child: Center(
                  child: HandFan(state: view.state, ruleset: widget.ruleset, availableWidth: c.maxWidth - 16),
                ),
              ),
            if (_selection != null)
              Positioned(
                left: 0,
                right: 0,
                bottom: bottom,
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 560, maxHeight: free * 0.65),
                    child: _inspector(view, mode),
                  ),
                ),
              ),
            if (_logOpen)
              Positioned(
                top: top,
                right: 4,
                width: 320,
                height: free,
                child: LogPopover(lines: lines, onClose: () => setState(() => _logOpen = false)),
              ),
          ],
        );
      },
    );
  }

  // ---- regular (>= 900 wide)

  Widget _regular(BuildContext context, AppLocalizations l, BattleViewState view) {
    const mode = BattleLayoutMode.regular;
    final top = BattleTopBar.heightFor(mode);
    final bottom = OfficerStrip.heightFor(mode);
    final left = _logExpanded ? LogSidePanel.expandedWidth : LogSidePanel.collapsedWidth;
    const right = HandColumn.width;
    final cubit = context.read<BattleCubit>();
    final lines = logLines(l, widget.ruleset, view.state, view.events);
    return LayoutBuilder(
      builder: (context, c) {
        final boardRect = Rect.fromLTRB(left, top, c.maxWidth - right, c.maxHeight - bottom);
        return Stack(
          children: [
            Positioned.fromRect(rect: boardRect, child: _board(view, l)),
            Positioned(left: 0, right: 0, top: 0, child: _topBar(view, mode)),
            Positioned(
              left: 0,
              top: top,
              bottom: 0,
              child: LogSidePanel(
                lines: lines,
                expanded: _logExpanded,
                onToggle: () => setState(() => _logExpanded = !_logExpanded),
              ),
            ),
            Positioned(
              left: left,
              right: right,
              bottom: 0,
              height: bottom,
              child: ColoredBox(color: LongKyColors.lacquer, child: _strip(view, mode)),
            ),
            Positioned(
              right: 0,
              top: top,
              bottom: 0,
              width: right,
              child: Column(
                children: [
                  Expanded(
                    child: HandColumn(state: view.state, ruleset: widget.ruleset),
                  ),
                  ColoredBox(
                    color: LongKyColors.lacquer,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: SizedBox(
                        width: double.infinity,
                        child: PhaseButton(state: view.state, mode: mode, onPressed: cubit.endPhase),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_selection != null)
              Positioned.fill(
                child: CustomSingleChildLayout(
                  delegate: _FloatingInspectorDelegate(
                    anchor: _anchorFor(view.state, boardRect),
                    gap: _inspectorGap(boardRect.size),
                    bounds: boardRect,
                  ),
                  child: _inspector(view, mode),
                ),
              ),
          ],
        );
      },
    );
  }

  /// Clear space between the selected node and the panel: the node, the token
  /// fan beside it and a margin.
  double _inspectorGap(Size boardSize) {
    final layout = BoardLayout(widget.ruleset.map, boardSize);
    return layout.nodeRadius + layout.tokenRadius * 2.5 + 16;
  }

  /// Where the selection is on screen: its node's centre (tokens fan out
  /// from there), in the screen's coordinates.
  Offset _anchorFor(GameState state, Rect boardRect) {
    final s = _selection!;
    final nodeId = switch (s.kind) {
      SelectionKind.node => s.id,
      SelectionKind.officer => state.officers[s.id]?.nodeId,
      SelectionKind.army => state.armies[s.id]?.nodeId,
    };
    final layout = BoardLayout(widget.ruleset.map, boardRect.size);
    final local = nodeId == null ? boardRect.size.center(Offset.zero) : layout.nodeCenter(nodeId);
    return boardRect.topLeft + local;
  }
}

/// Puts the regular-layout inspector beside the selection: to its right if
/// it fits inside the board area, otherwise to its left, and always inside
/// the board area.
class _FloatingInspectorDelegate extends SingleChildLayoutDelegate {
  _FloatingInspectorDelegate({required this.anchor, required this.gap, required this.bounds});

  final Offset anchor;
  final double gap;
  final Rect bounds;

  static const double margin = 8;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) =>
      BoxConstraints(maxWidth: InspectorPanel.floatingWidth, maxHeight: bounds.height - 2 * margin);

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    var x = anchor.dx + gap;
    if (x + childSize.width > bounds.right - margin) x = anchor.dx - gap - childSize.width;
    x = x.clamp(bounds.left + margin, bounds.right - margin - childSize.width);
    final y = (anchor.dy - childSize.height / 2).clamp(bounds.top + margin, bounds.bottom - margin - childSize.height);
    return Offset(x, y);
  }

  @override
  bool shouldRelayout(_FloatingInspectorDelegate old) => old.anchor != anchor || old.gap != gap || old.bounds != bounds;
}
