import 'dart:async';

import 'package:flame/game.dart';
import 'package:flutter/widgets.dart';
import 'package:lk_rules/lk_rules.dart';

import 'board_game.dart';
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

  @override
  State<BattleBoard> createState() => BattleBoardState();
}

class BattleBoardState extends State<BattleBoard> {
  late final BoardGame game = BoardGame(
    ruleset: widget.ruleset,
    state: widget.state,
    languageCode: widget.languageCode,
  );

  @override
  void initState() {
    super.initState();
    game.selection.addListener(_selectionChanged);
    game.busy.addListener(_busyChanged);
  }

  bool _busy = false;

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GameWidget<BoardGame>(game: game);
}
