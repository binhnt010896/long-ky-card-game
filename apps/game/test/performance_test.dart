import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:lk_rules/lk_rules.dart';
import 'package:long_ky_game/features/battle/board/board_animator.dart';
import 'package:long_ky_game/features/battle/board/board_painter.dart';

import 'battle/board_support.dart';

/// Performance of what the screen does every frame (build-spec section 7:
/// "the board at 60 fps", so 16.7 ms a frame, of which the app's own Dart
/// work should take a small part).
///
/// What this measures: the CPU time to record the board's drawing commands and
/// to rebuild its scene, on the machine that runs the tests (a desktop-class
/// CPU). It does not measure GPU raster time or a phone: that is checked on the
/// devices (docs/qa/checklist.md). The limits leave a wide margin for a slower
/// phone.
void main() {
  /// Milliseconds per call of [f], after a warm-up.
  double msPer(void Function() f, {int runs = 200}) {
    for (var i = 0; i < 20; i++) {
      f();
    }
    final watch = Stopwatch()..start();
    for (var i = 0; i < runs; i++) {
      f();
    }
    watch.stop();
    return watch.elapsedMicroseconds / 1000 / runs;
  }

  /// The start of Orders on turn 1: every officer and army token on the map,
  /// the Yuan intents drawn. (Animations are not included: they only add a few marks.)
  GameState busyState(String missionId) {
    final engine = GameEngine(ruleset(missionId));
    return engine.apply(engine.newGame(1).state, const GameAction.endPhase()).state;
  }

  for (final (name, size) in [('compact', compact), ('regular', regular)]) {
    group('board ($name)', () {
      for (final id in ['ch1_m2', 'ch1_m3', 'ch1_m5']) {
        test('$id: recording a frame takes well under a frame (60 fps = 16.7 ms)', () {
          final scene = sceneFor(id, size, state: busyState(id));
          final painter = BoardPainter();
          final animator = BoardAnimator();
          final ms = msPer(() {
            final recorder = ui.PictureRecorder();
            painter.paint(ui.Canvas(recorder), scene, animator: animator);
            recorder.endRecording().dispose();
          });
          // ignore: avoid_print
          print('$id $name: paint $ms ms');
          expect(ms, lessThan(4), reason: 'a quarter of a frame on a desktop-class CPU');
        });

        test('$id: rebuilding the scene after a step is far under a frame', () {
          final state = busyState(id);
          final ms = msPer(() => sceneFor(id, size, state: state), runs: 100);
          // ignore: avoid_print
          print('$id $name: scene $ms ms');
          expect(ms, lessThan(4));
        });
      }
    });
  }
}
