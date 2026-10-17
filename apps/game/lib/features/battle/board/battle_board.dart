import 'dart:async';
import 'dart:math' as math;

import 'package:flame/game.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:lk_rules/lk_rules.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app/l10n/app_localizations.dart';
import '../../../art/art_library.dart';
import '../../../app/theme.dart';
import 'board_art.dart';
import 'board_game.dart';
import 'board_layout.dart';
import 'board_scene.dart';

/// The board as a widget. It follows [state] and [languageCode] live.
class BattleBoard extends StatefulWidget {
  const BattleBoard({
    super.key,
    required this.ruleset,
    required this.state,
    required this.languageCode,
    this.onSelectionChanged,
    this.events = const [],
    this.step = 0,
    this.onBusyChanged,
    this.onViewChanged,
  });

  final Ruleset ruleset;
  final GameState state;
  final String languageCode;
  final ValueChanged<Selection?>? onSelectionChanged;

  /// The events that led to [state]; played once each time [step] changes.
  /// Not played at all under reduce motion (`MediaQuery.disableAnimations`).
  final List<GameEvent> events;
  final int step;

  /// Called when the animations start or stop playing.
  final ValueChanged<bool>? onBusyChanged;

  /// Called when the map is zoomed or panned.
  final VoidCallback? onViewChanged;

  @override
  State<BattleBoard> createState() => BattleBoardState();
}

class BattleBoardState extends State<BattleBoard> {
  late final BoardGame game = BoardGame(
    ruleset: widget.ruleset,
    state: widget.state,
    languageCode: widget.languageCode,
    art: BoardArtCache(_library()),
  );

  /// The shipped art, or none when the app has not provided it.
  ArtLibrary _library() {
    try {
      return context.read<ArtLibrary>();
    } on Object {
      return ArtLibrary.empty();
    }
  }

  @override
  void initState() {
    super.initState();
    game.selection.addListener(_selectionChanged);
    game.busy.addListener(_busyChanged);
    game.view.addListener(_viewChanged);
  }

  bool _busy = false;
  double _lastScale = 1;

  void _viewChanged() {
    // The board re-clamps the pan while it is being laid out; tell the
    // widgets after the frame, never in the middle of a build.
    if (SchedulerBinding.instance.schedulerPhase == SchedulerPhase.persistentCallbacks) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _notifyViewChanged());
    } else {
      _notifyViewChanged();
    }
  }

  void _notifyViewChanged() {
    if (!mounted) return;
    widget.onViewChanged?.call();
    setState(() {});
  }

  /// Told after the frame, never in the middle of a build.
  void _busyChanged() {
    if (game.busy.value == _busy) return;
    _busy = game.busy.value;
    scheduleMicrotask(() {
      if (mounted) widget.onBusyChanged?.call(_busy);
    });
  }

  /// Selects [selection] from outside the board (the officer strip, the
  /// inspector's close button); null clears it.
  void select(Selection? selection) => game.selection.value = selection;

  void _selectionChanged() => widget.onSelectionChanged?.call(game.selection.value);

  @override
  void didUpdateWidget(BattleBoard oldWidget) {
    super.didUpdateWidget(oldWidget);
    game.showState(state: widget.state, languageCode: widget.languageCode);
    if (widget.step != oldWidget.step) {
      game.play(widget.events, reduceMotion: MediaQuery.disableAnimationsOf(context));
    }
  }

  @override
  void dispose() {
    game.selection.removeListener(_selectionChanged);
    game.busy.removeListener(_busyChanged);
    game.view.removeListener(_viewChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = Localizations.of<AppLocalizations>(context, AppLocalizations);
    final zoomed = game.view.value.isZoomed;
    return Stack(
      children: [
        Positioned.fill(
          child: Listener(
            // The mouse wheel zooms about the pointer.
            onPointerSignal: (e) {
              if (e is PointerScrollEvent) game.zoomBy(math.exp(-e.scrollDelta.dy / 400), e.localPosition);
            },
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              // Two fingers pinch and move the map; one finger drags it once
              // zoomed in. A tap still selects at once (the Flame component
              // handles it, and a second quick tap zooms).
              onScaleStart: (d) => _lastScale = 1,
              onScaleUpdate: (d) {
                if (d.pointerCount >= 2) {
                  final factor = d.scale / _lastScale;
                  _lastScale = d.scale;
                  game.zoomBy(factor, d.localFocalPoint);
                }
                game.panBy(d.focalPointDelta);
              },
              child: GameWidget<BoardGame>(game: game),
            ),
          ),
        ),
        Positioned(
          right: 4,
          top: 4,
          child: _ZoomControls(
            zoomIn: () => game.zoomBy(1.6, _center),
            zoomOut: () => game.zoomBy(1 / 1.6, _center),
            reset: zoomed ? game.resetView : null,
            zoomInLabel: l?.boardZoomIn ?? 'Zoom in',
            zoomOutLabel: l?.boardZoomOut ?? 'Zoom out',
            resetLabel: l?.boardZoomReset ?? 'Show the whole map',
            canZoomIn: game.view.value.zoom < BoardLayout.maxZoom,
            canZoomOut: zoomed,
          ),
        ),
      ],
    );
  }

  Offset get _center => game.hasLayout ? Offset(game.size.x / 2, game.size.y / 2) : Offset.zero;
}

/// Zoom in, zoom out and "whole map" buttons in a corner of the board.
class _ZoomControls extends StatelessWidget {
  const _ZoomControls({
    required this.zoomIn,
    required this.zoomOut,
    required this.reset,
    required this.zoomInLabel,
    required this.zoomOutLabel,
    required this.resetLabel,
    required this.canZoomIn,
    required this.canZoomOut,
  });

  final VoidCallback zoomIn;
  final VoidCallback zoomOut;
  final VoidCallback? reset;
  final String zoomInLabel;
  final String zoomOutLabel;
  final String resetLabel;
  final bool canZoomIn;
  final bool canZoomOut;

  @override
  Widget build(BuildContext context) {
    Widget button(Key key, IconData icon, String label, VoidCallback? onTap) => IconButton(
          key: key,
          tooltip: label,
          icon: Icon(icon, size: 20),
          color: LongKyColors.goldLeaf,
          disabledColor: LongKyColors.ivory.withValues(alpha: 0.25),
          style: IconButton.styleFrom(
            backgroundColor: LongKyColors.lacquer.withValues(alpha: 0.75),
            minimumSize: const Size(48, 48),
          ),
          onPressed: onTap,
        );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        button(const Key('zoom-in'), Icons.add, zoomInLabel, canZoomIn ? zoomIn : null),
        button(const Key('zoom-out'), Icons.remove, zoomOutLabel, canZoomOut ? zoomOut : null),
        button(const Key('zoom-reset'), Icons.fit_screen, resetLabel, reset),
      ],
    );
  }
}
