import 'package:flame/game.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:long_ky_game/features/battle/board/board_game.dart';
import 'package:long_ky_game/features/battle/board/board_layout.dart';
import 'package:long_ky_game/features/battle/board/board_scene.dart';

import 'overlay_support.dart';

void main() {
  final map = ruleset('ch1_m2').map;

  group('BoardLayout zoom and pan', () {
    test('zoom 1 is the whole map; zoom scales the map about the viewport centre', () {
      final a = BoardLayout(map, regular);
      final b = BoardLayout(map, regular, zoom: 2);
      expect(b.mapRect.width, closeTo(a.mapRect.width * 2, 1e-9));
      expect(b.mapRect.center, a.mapRect.center);
      final shifted = BoardLayout(map, regular, zoom: 2, pan: const Offset(30, -10));
      expect(shifted.mapRect.center, a.mapRect.center + const Offset(30, -10));
    });

    test('zooming about a point keeps the map point under it still', () {
      const size = regular;
      const focal = Offset(500, 300);
      final before = BoardLayout(map, size);
      final pointBefore = before.nodeCenter('binh-le-nguyen');
      final pan = BoardLayout.panForZoom(size, 1, Offset.zero, 2.5, focal);
      final after = BoardLayout(map, size, zoom: 2.5, pan: pan);
      // The node's offset from the focal point grows by exactly the zoom ratio.
      final got = after.nodeCenter('binh-le-nguyen') - focal;
      final want = (pointBefore - focal) * 2.5;
      expect((got - want).distance, lessThan(1e-6));
    });

    test('pan is clamped: none while the map fits, then up to its edge plus a margin', () {
      expect(BoardLayout.clampPan(regular, 1, const Offset(500, 500)), Offset.zero);
      final base = BoardLayout(map, regular).mapRect;
      final far = BoardLayout.clampPan(regular, 3, const Offset(5000, -5000));
      expect(far.dx, closeTo((base.width * 3 - regular.width) / 2 + BoardLayout.panMargin, 1e-9));
      expect(far.dy, closeTo(-((base.height * 3 - regular.height) / 2 + BoardLayout.panMargin), 1e-9));
    });

    test('medallions and tokens get bigger as the map is zoomed, up to the caps', () {
      var last = 0.0;
      for (final z in [1.0, 2.0, 3.0, 4.0]) {
        final l = BoardLayout(map, compact, zoom: z);
        expect(l.nodeRadius, greaterThanOrEqualTo(last), reason: 'zoom $z');
        expect(l.nodeRadius, lessThanOrEqualTo(BoardLayout.maxNodeRadius));
        last = l.nodeRadius;
      }
      expect(BoardLayout(map, compact, zoom: 4).nodeRadius, greaterThan(BoardLayout(map, compact).nodeRadius * 1.5));
    });

    test('generals in one place are far enough apart to tap one by one when zoomed in', () {
      // Three officers fan out at Bình Lệ Nguyên: at 1× their centres can be
      // under 48 px apart; at 3× every pair is at least 48 px apart.
      double minGap(double zoom) {
        final scene = sceneZoomed(zoom);
        final officers = scene.tokens.where((t) => t.nodeId == 'binh-le-nguyen').toList();
        var gap = double.infinity;
        for (var i = 0; i < officers.length; i++) {
          for (var j = i + 1; j < officers.length; j++) {
            gap = gap < (officers[i].center - officers[j].center).distance ? gap : (officers[i].center - officers[j].center).distance;
          }
        }
        return gap;
      }

      expect(minGap(1), lessThan(48));
      expect(minGap(3), greaterThanOrEqualTo(48));
    });
  });

  group('zooming the board', () {
    testWidgets('the buttons zoom in, out and back to the whole map', (tester) async {
      await pumpBattle(tester, compact);
      final game = boardGame(tester);
      expect(game.view.value.zoom, 1);
      expect(find.byKey(const Key('zoom-reset')).evaluate().isNotEmpty, isTrue);
      final reset = tester.widget<IconButton>(find.byKey(const Key('zoom-reset')));
      expect(reset.onPressed, isNull, reason: 'nothing to reset at 1×');
      expect(tester.widget<IconButton>(find.byKey(const Key('zoom-out'))).onPressed, isNull);

      await tester.tap(find.byKey(const Key('zoom-in')));
      await settle(tester);
      expect(game.view.value.zoom, closeTo(1.6, 1e-9));
      await tester.tap(find.byKey(const Key('zoom-in')));
      await settle(tester);
      expect(game.view.value.zoom, closeTo(2.56, 1e-9));
      await tester.tap(find.byKey(const Key('zoom-out')));
      await settle(tester);
      expect(game.view.value.zoom, closeTo(1.6, 1e-9));
      await tester.tap(find.byKey(const Key('zoom-reset')));
      await settle(tester);
      expect(game.view.value, const BoardView());
      for (final k in ['zoom-in', 'zoom-out', 'zoom-reset']) {
        expect(tester.getSize(find.byKey(Key(k))).shortestSide, greaterThanOrEqualTo(48), reason: '$k is a 48 px touch target');
      }
    });

    testWidgets('zoom is limited to 4×', (tester) async {
      await pumpBattle(tester, regular);
      final game = boardGame(tester);
      for (var i = 0; i < 12; i++) {
        game.zoomBy(2, const Offset(400, 300));
      }
      expect(game.view.value.zoom, BoardLayout.maxZoom);
      game.zoomBy(0.0001, const Offset(400, 300));
      expect(game.view.value.zoom, BoardLayout.minZoom);
    });

    testWidgets('a mouse wheel zooms about the pointer', (tester) async {
      await pumpBattle(tester, regular);
      final game = boardGame(tester);
      final board = tester.getTopLeft(find.byKey(const Key('zoom-in'))) - const Offset(400, -150);
      final mouse = TestPointer(1, PointerDeviceKind.mouse);
      await tester.sendEventToBinding(mouse.hover(board));
      await tester.sendEventToBinding(mouse.scroll(const Offset(0, -300)));
      await settle(tester);
      expect(game.view.value.zoom, greaterThan(1.5));
      await tester.sendEventToBinding(mouse.scroll(const Offset(0, 900)));
      await settle(tester);
      expect(game.view.value.zoom, 1);
    });

    testWidgets('two fingers pinch to zoom, one finger drags the map once zoomed', (tester) async {
      await pumpBattle(tester, regular);
      final game = boardGame(tester);
      final c = tester.getCenter(find.byKey(const Key('top-bar'))).translate(0, 350);
      final f1 = await tester.startGesture(c - const Offset(40, 0), pointer: 1);
      final f2 = await tester.startGesture(c + const Offset(40, 0), pointer: 2);
      await f1.moveBy(const Offset(-160, 0));
      await f2.moveBy(const Offset(160, 0));
      await settle(tester);
      expect(game.view.value.zoom, greaterThan(1.5), reason: 'fingers moved apart');
      await f1.up();
      await f2.up();
      await settle(tester);

      final before = game.view.value.pan;
      final drag = await tester.startGesture(c, pointer: 3);
      await drag.moveBy(const Offset(-80, -30));
      await settle(tester);
      await drag.up();
      await settle(tester);
      expect(game.view.value.pan, isNot(before));
      expect(game.view.value.zoom, greaterThan(1.5), reason: 'dragging does not change the zoom');
    });

    testWidgets('one finger does not move the map while it shows everything', (tester) async {
      await pumpBattle(tester, regular);
      final game = boardGame(tester);
      final c = tester.getCenter(find.byKey(const Key('top-bar'))).translate(0, 350);
      final drag = await tester.startGesture(c, pointer: 1);
      await drag.moveBy(const Offset(-120, 40));
      await drag.up();
      await settle(tester);
      expect(game.view.value, const BoardView());
    });

    testWidgets('a quick second tap zooms in on that spot, and again zooms back out', (tester) async {
      await pumpBattle(tester, regular);
      final game = boardGame(tester);
      final at = game.scene!.node('thang-long').center;
      await tester.tapAt(boardOrigin(tester) + at);
      await tester.pump(const Duration(milliseconds: 80));
      await tester.tapAt(boardOrigin(tester) + at);
      await settle(tester);
      expect(game.view.value.zoom, greaterThan(2));
      await tester.tapAt(boardOrigin(tester) + game.scene!.node('thang-long').center);
      await tester.pump(const Duration(milliseconds: 80));
      await tester.tapAt(boardOrigin(tester) + game.scene!.node('thang-long').center);
      await settle(tester);
      expect(game.view.value, const BoardView());
    });

    testWidgets('taps still select the right general after zooming', (tester) async {
      await pumpBattle(tester, compact);
      final game = boardGame(tester);
      game.zoomBy(2.6, game.scene!.node('binh-le-nguyen').center);
      await settle(tester);
      for (final id in ['tran-thai-tong', 'le-phu-tran', 'tran-thu-do']) {
        // The inspector opens beside a selection and the board re-lays out.
        game.clearSelection();
        await settle(tester);
        await tester.pump(const Duration(milliseconds: 600));
        final token = game.scene!.tokens.firstWhere((t) => t.id == id);
        await tester.tapAt(boardOrigin(tester) + token.center);
        await settle(tester);
        expect(game.selection.value, Selection(SelectionKind.officer, id), reason: id);
        await tester.pump(const Duration(milliseconds: 600));
      }
    });

    testWidgets('the inspector follows the node it is for when the map moves', (tester) async {
      await pumpBattle(tester, regular);
      final game = boardGame(tester);
      final node = game.scene!.node('thang-long');
      await tester.tapAt(boardOrigin(tester) + node.center);
      await settle(tester);
      expect(find.byKey(const Key('inspector-node')), findsOneWidget);
      final before = tester.getTopLeft(find.byKey(const Key('inspector-node')));
      game.zoomBy(2, const Offset(100, 100));
      await settle(tester);
      expect(find.byKey(const Key('inspector-node')), findsOneWidget);
      expect(tester.takeException(), isNull);
      expect(tester.getTopLeft(find.byKey(const Key('inspector-node'))), isNot(before),
          reason: 'the node moved, so the panel beside it moved too');
    });

    testWidgets('the zoomed map is clipped to the board area', (tester) async {
      await pumpBattle(tester, compact);
      expect(find.ancestor(of: find.byType(GameWidget<BoardGame>), matching: find.byType(ClipRect)), findsWidgets);
      final board = tester.getRect(find.byType(GameWidget<BoardGame>));
      final clip = tester.getRect(find.ancestor(of: find.byType(GameWidget<BoardGame>), matching: find.byType(ClipRect)).first);
      expect(clip.contains(board.topLeft) && clip.contains(board.bottomRight - const Offset(1, 1)), isTrue);
      expect(clip.top, greaterThanOrEqualTo(tester.getRect(find.byKey(const Key('top-bar'))).bottom - 0.01),
          reason: 'the clip starts below the top bar');
    });

    testWidgets('resizing keeps the pan in range', (tester) async {
      await pumpBattle(tester, regular);
      final game = boardGame(tester);
      game.zoomBy(4, const Offset(900, 400));
      game.panBy(const Offset(-4000, 0));
      tester.view.physicalSize = compact;
      await settle(tester);
      final v = game.view.value;
      expect(v.pan, BoardLayout.clampPan(Size(game.size.x, game.size.y), v.zoom, v.pan));
    });
  });
}

BoardScene sceneZoomed(double zoom) => BoardScene.build(
  ruleset: ruleset('ch1_m2'),
  state: startState('ch1_m2'),
  size: compact,
  languageCode: 'vi',
  zoom: zoom,
  pan: BoardLayout.clampPan(compact, zoom, Offset.zero),
);

/// Where the board's top-left corner is on screen.
Offset boardOrigin(WidgetTester tester) => tester.getTopLeft(find.byType(GameWidget<BoardGame>));
