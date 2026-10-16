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
  });

  final Ruleset ruleset;
  final GameState state;
  final String languageCode;
  final ValueChanged<Selection?>? onSelectionChanged;

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
  }

  /// Selects [selection] from outside the board (the officer strip, the
  /// inspector's close button); null clears it.
  void select(Selection? selection) => game.selection.value = selection;

  void _selectionChanged() => widget.onSelectionChanged?.call(game.selection.value);

  @override
  void didUpdateWidget(BattleBoard oldWidget) {
    super.didUpdateWidget(oldWidget);
    game.showState(state: widget.state, languageCode: widget.languageCode);
  }

  @override
  void dispose() {
    game.selection.removeListener(_selectionChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GameWidget<BoardGame>(game: game);
}
