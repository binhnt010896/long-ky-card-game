import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:lk_rules/lk_rules.dart';

import '../../../app/theme.dart';
import 'board_animator.dart';
import 'board_painter.dart';
import 'board_scene.dart';

/// The Flame battle board (build-spec section 6). Flame draws only the map
/// board; every other part of the battle screen is Flutter widgets on top.
class BoardGame extends FlameGame {
  BoardGame({required this.ruleset, required this._state, required this._languageCode});

  final Ruleset ruleset;
  GameState _state;
  String _languageCode;
  BoardScene? _scene;

  /// The selected node, officer or army; null when nothing is selected.
  final ValueNotifier<Selection?> selection = ValueNotifier(null);

  final BoardPainter painter = BoardPainter();

  /// Plays the events of each step (moves, battles, forage, defections).
  final BoardAnimator animator = BoardAnimator();

  /// True while [animator] has something left to play.
  final ValueNotifier<bool> busy = ValueNotifier(false);

  /// What the board shows now; null until the game has a size.
  BoardScene? get scene => _scene;

  GameState get state => _state;

  @override
  Color backgroundColor() => LongKyColors.lacquer;

  @override
  Future<void> onLoad() async {
    await add(_BoardComponent());
    selection.addListener(_rebuild);
  }

  @override
  void onRemove() {
    selection.removeListener(_rebuild);
    super.onRemove();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _rebuild();
  }

  /// Plays [events], which led to the state now shown. With [reduceMotion]
  /// nothing plays and the board shows the new state at once.
  void play(Iterable<GameEvent> events, {required bool reduceMotion}) {
    if (reduceMotion) {
      animator.clear();
    } else {
      animator.enqueue(events, nodeOfOfficer: (id) => _state.officers[id]?.nodeId);
    }
    busy.value = animator.isBusy;
  }

  /// Shows everything at once, dropping what is still playing.
  void skipAnimation() {
    animator.clear();
    busy.value = false;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (animator.isBusy) {
      animator.update(dt);
      busy.value = animator.isBusy;
    }
  }

  /// Shows [state] (and [languageCode] for node names).
  void showState({required GameState state, required String languageCode}) {
    _state = state;
    _languageCode = languageCode;
    _rebuild();
  }

  void _rebuild() {
    if (!hasLayout || size.x <= 0 || size.y <= 0) return;
    _scene = BoardScene.build(
      ruleset: ruleset,
      state: _state,
      size: Size(size.x, size.y),
      languageCode: _languageCode,
      selection: selection.value,
    );
  }

  /// Selects whatever is at [point] (game coordinates); empty ground clears.
  void selectAt(Offset point) => selection.value = _scene?.hitTest(point);

  void clearSelection() => selection.value = null;
}

class _BoardComponent extends PositionComponent with TapCallbacks, HasGameReference<BoardGame> {
  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size;
  }

  @override
  bool containsLocalPoint(Vector2 point) => true;

  @override
  void render(Canvas canvas) {
    final scene = game.scene;
    if (scene != null) game.painter.paint(canvas, scene, animator: game.animator);
  }

  @override
  void onTapUp(TapUpEvent event) => game.selectAt(Offset(event.localPosition.x, event.localPosition.y));
}
