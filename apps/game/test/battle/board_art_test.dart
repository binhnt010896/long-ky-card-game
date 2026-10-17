import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:long_ky_game/art/art_library.dart';
import 'package:long_ky_game/features/battle/board/battle_board.dart';
import 'package:long_ky_game/features/battle/board/board_art.dart';
import 'package:long_ky_game/features/battle/board/board_game.dart';
import 'package:long_ky_game/features/battle/board/board_painter.dart';
import 'package:long_ky_game/features/battle/board/board_scene.dart';

import '../art_support.dart';
import 'board_support.dart';

const _lacquerRaised = 0xFF1E1916;

/// Real time for the image decoder, which the test clock does not drive.
Future<void> decode(WidgetTester tester) => tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 300)));

Future<ByteData> render(WidgetTester tester, BoardScene scene, BoardArtCache? art) async {
  late ByteData data;
  await tester.runAsync(() async {
    final rec = ui.PictureRecorder();
    BoardPainter().paint(ui.Canvas(rec), scene, art: art);
    final img = await rec.endRecording().toImage(scene.layout.size.width.toInt(), scene.layout.size.height.toInt());
    data = (await img.toByteData())!;
  });
  return data;
}

int pixel(ByteData d, int width, Offset p) {
  final i = ((p.dy.round() * width) + p.dx.round()) * 4;
  return (d.getUint8(i + 3) << 24) | (d.getUint8(i) << 16) | (d.getUint8(i + 1) << 8) | d.getUint8(i + 2);
}

void main() {
  final scene = sceneFor('ch1_m2', regular);

  group('the content names the art', () {
    test('the map and every portrait path come from the content', () {
      expect(scene.mapImagePath, 'maps/ch1.png');
      final king = scene.tokens.firstWhere((t) => t.id == 'tran-thai-tong');
      expect(king.artPath, 'officers/tran-thai-tong/portrait.png');
      final army = scene.tokens.firstWhere((t) => t.id == 'mong-co-1258');
      expect(army.artPath, 'enemies/ngot-luong-hop-thai/portrait.png');
    });
  });

  group('BoardArtCache', () {
    testWidgets('decodes shipped files once and ignores files that are not shipped', (tester) async {
      final png = (await tester.runAsync(makePng))!;
      final bundle = MemoryArtBundle({
        'assets/images/maps/ch1.png': png,
        'assets/images/officers/tran-thai-tong/portrait.png': png,
      });
      final cache = BoardArtCache(bundle.library);
      expect(cache.image('maps/ch1.png'), isNull, reason: 'decoding has only just started');
      expect(cache.image('officers/le-phu-tran/portrait.png'), isNull, reason: 'not shipped');
      expect(cache.image(null), isNull);
      cache.image('officers/tran-thai-tong/portrait.png');
      await decode(tester);
      expect(cache.image('maps/ch1.png'), isNotNull);
      expect(cache.image('officers/tran-thai-tong/portrait.png')!.width, 240);
      expect(cache.image('officers/le-phu-tran/portrait.png'), isNull);
      expect(cache.loaded, 2);
      cache.dispose();
      expect(cache.loaded, 0);
    });

    testWidgets('a file that cannot be decoded is just absent', (tester) async {
      final bundle = MemoryArtBundle({'assets/images/maps/ch1.png': Uint8List.fromList([1, 2, 3])});
      final cache = BoardArtCache(bundle.library)..image('maps/ch1.png');
      await decode(tester);
      expect(cache.image('maps/ch1.png'), isNull);
    });
  });

  group('the board draws the art that is shipped', () {
    testWidgets('the painted map fills the map area; without it the lacquer placeholder shows', (tester) async {
      final png = (await tester.runAsync(makePng))!;
      final cache = BoardArtCache(MemoryArtBundle({'assets/images/maps/ch1.png': png}).library);
      cache.image('maps/ch1.png');
      await decode(tester);
      final spot = Offset(scene.layout.mapRect.left + 20, scene.layout.mapRect.bottom - 20);
      final plain = await render(tester, scene, null);
      final painted = await render(tester, scene, cache);
      expect(pixel(plain, 1600, spot), _lacquerRaised);
      expect(pixel(painted, 1600, spot), isNot(_lacquerRaised));
      // The same, with nothing shipped: identical to no art cache at all.
      final none = await render(tester, scene, BoardArtCache.empty());
      expect(pixel(none, 1600, spot), _lacquerRaised);
    });

    testWidgets('a portrait replaces the initials in the officer token', (tester) async {
      final png = (await tester.runAsync(makePng))!;
      final cache = BoardArtCache(
        MemoryArtBundle({'assets/images/officers/tran-thai-tong/portrait.png': png}).library,
      );
      cache.image('officers/tran-thai-tong/portrait.png');
      await decode(tester);
      final king = scene.tokens.firstWhere((t) => t.id == 'tran-thai-tong');
      final other = scene.tokens.firstWhere((t) => t.id == 'tran-thu-do');
      final withArt = await render(tester, scene, cache);
      final without = await render(tester, scene, null);
      // Inside the token, above the initials and clear of the troop badge.
      final inKing = king.center - Offset(0, king.radius * 0.75);
      expect(pixel(without, 1600, inKing), _lacquerRaised);
      expect(pixel(withArt, 1600, inKing), isNot(_lacquerRaised));
      // An officer with no portrait file is unchanged.
      final inOther = other.center - Offset(0, other.radius * 0.75);
      expect(pixel(withArt, 1600, inOther), pixel(without, 1600, inOther));
    });
  });

  testWidgets('the Flame board loads the art from the app\'s ArtLibrary', (tester) async {
    tester.view.physicalSize = regular;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final png = (await tester.runAsync(makePng))!;
    final library = MemoryArtBundle({'assets/images/maps/ch1.png': png}).library;
    await tester.pumpWidget(
      RepositoryProvider<ArtLibrary>.value(
        value: library,
        child: MaterialApp(
          home: BattleBoard(ruleset: ruleset('ch1_m2'), state: startState('ch1_m2'), languageCode: 'vi'),
        ),
      ),
    );
    for (var i = 0; i < 3; i++) {
      await tester.pump(const Duration(milliseconds: 50));
      await decode(tester);
    }
    final game = tester.widget<GameWidget<BoardGame>>(find.byType(GameWidget<BoardGame>)).game!;
    expect(game.art.loaded, 1);
    expect(tester.takeException(), isNull);
  });
}
