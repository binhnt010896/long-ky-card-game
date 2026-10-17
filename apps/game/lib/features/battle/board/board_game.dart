import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:lk_rules/lk_rules.dart';

import '../../../app/theme.dart';
import 'board_animator.dart';
import 'board_art.dart';
import 'board_layout.dart';
import 'board_painter.dart';
import 'board_scene.dart';

/// The Flame battle board (build-spec section 6). Flame draws only the map
/// board; every other part of the battle screen is Flutter widgets on top.
class BoardGame extends FlameGame {
  BoardGame({required this.ruleset, required this._state, required this._languageCode, BoardArtCache? art})
      : art = art ?? BoardArtCache.empty();

  final Ruleset ruleset;
  GameState _state;
  String _languageCode;
  BoardScene? _scene;

  /// How the map is zoomed and panned (`1` shows the whole map).
  final ValueNotifier<BoardView> view = ValueNotifier(const BoardView());

  /// The selected node, officer or army; null when nothing is selected.
  final ValueNotifier<Selection?> selection = ValueNotifier(null);

  final BoardPainter painter = BoardPainter();

  /// The painted art that is shipped (map and portraits).
  final BoardArtCache art;

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
    view.addListener(_rebuild);
  }

  @override
  void onRemove() {
    selection.removeListener(_rebuild);
    view.removeListener(_rebuild);
    art.dispose();
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
    final s = Size(size.x, size.y);
    final v = view.value;
    // A new window size can leave the old pan out of range.
    final pan = BoardLayout.clampPan(s, v.zoom, v.pan);
    if (pan != v.pan) {
      view.value = BoardView(zoom: v.zoom, pan: pan);
      return; // the listener rebuilds
    }
    _scene = BoardScene.build(
      ruleset: ruleset,
      state: _state,
      size: s,
      languageCode: _languageCode,
      selection: selection.value,
      zoom: v.zoom,
      pan: v.pan,
    );
  }

  /// Zooms by [factor] about [focal] (game coordinates), keeping the map
  /// point under it still.
  void zoomBy(double factor, Offset focal) {
    if (!hasLayout) return;
    final s = Size(size.x, size.y);
    final v = view.value;
    final zoom = (v.zoom * factor).clamp(BoardLayout.minZoom, BoardLayout.maxZoom).toDouble();
    if (zoom == v.zoom) return;
    final pan = BoardLayout.panForZoom(s, v.zoom, v.pan, zoom, focal);
    view.value = BoardView(zoom: zoom, pan: BoardLayout.clampPan(s, zoom, pan));
  }

  /// Moves the map by [delta] screen pixels.
  void panBy(Offset delta) {
    if (!hasLayout) return;
    final v = view.value;
    final pan = BoardLayout.clampPan(Size(size.x, size.y), v.zoom, v.pan + delta);
    if (pan != v.pan) view.value = BoardView(zoom: v.zoom, pan: pan);
  }

  /// Shows the whole map again.
  void resetView() => view.value = const BoardView();

  /// Zooms in on [focal], or back out if already zoomed (double tap).
  void toggleZoomAt(Offset focal) {
    if (view.value.zoom > 1.5) {
      resetView();
    } else {
      zoomBy(2.5, focal);
    }
  }

  final Stopwatch _clock = Stopwatch()..start();
  Duration? _lastTapAt;
  Offset? _lastTapPoint;

  /// A second tap this soon, and this close, is a double tap.
  static const Duration doubleTapWindow = Duration(milliseconds: 300);
  static const double doubleTapSlop = 32;

  /// Selects whatever is at [point] (game coordinates); empty ground clears.
  /// A quick second tap in the same place zooms in there, or back out.
  void selectAt(Offset point) {
    final now = _clock.elapsed;
    final last = _lastTapAt;
    final lastPoint = _lastTapPoint;
    final isDouble = last != null &&
        lastPoint != null &&
        now - last <= doubleTapWindow &&
        (point - lastPoint).distance <= doubleTapSlop;
    _lastTapAt = isDouble ? null : now;
    _lastTapPoint = isDouble ? null : point;
    if (isDouble) {
      toggleZoomAt(point);
      return;
    }
    selection.value = _scene?.hitTest(point);
  }

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
    if (scene != null) game.painter.paint(canvas, scene, animator: game.animator, art: game.art);
  }

  @override
  void onTapUp(TapUpEvent event) => game.selectAt(Offset(event.localPosition.x, event.localPosition.y));
}

/// The zoom and pan of the board.
final class BoardView {
  const BoardView({this.zoom = 1.0, this.pan = Offset.zero});

  final double zoom;
  final Offset pan;

  bool get isZoomed => zoom > 1.0 + 1e-9;

  @override
  bool operator ==(Object other) => other is BoardView && other.zoom == zoom && other.pan == pan;

  @override
  int get hashCode => Object.hash(zoom, pan);
}
