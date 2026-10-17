import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lk_content/lk_content.dart';
import 'package:long_ky_game/app/theme.dart';
import 'package:long_ky_game/art/art_image.dart';
import 'package:long_ky_game/art/art_library.dart';

import 'art_support.dart';
import 'battle/board_support.dart' show content;

Widget around(Widget child, {ArtLibrary? library}) {
  Widget w = MaterialApp(
    theme: buildLongKyTheme(),
    home: Scaffold(
      body: Center(child: SizedBox(width: 160, height: 120, child: child)),
    ),
  );
  if (library != null) w = RepositoryProvider.value(value: library, child: w);
  return w;
}

void main() {
  group('ArtLibrary', () {
    test('finds art by its id under assets/images/', () {
      final lib = ArtLibrary(bundle: MemoryArtBundle({}), assets: {'assets/images/cards/a.png'});
      expect(lib.has('cards/a.png'), isTrue);
      expect(lib.has('cards/b.png'), isFalse);
      expect(lib.has(null), isFalse);
      expect(lib.provider('cards/a.png'), isA<AssetImage>());
      expect(lib.provider('cards/b.png'), isNull);
    });

    test('an empty library has nothing', () {
      expect(ArtLibrary.empty().has('cards/a.png'), isFalse);
    });

    test('reads the shipped list from a bundle', () async {
      final bundle = MemoryArtBundle({'assets/images/cards/a.png': Uint8List(1)});
      final lib = await ArtLibrary.fromBundle(bundle);
      expect(lib.has('cards/a.png'), isTrue);
      expect(lib.has('cards/z.png'), isFalse);
    });
  });

  group('ArtImage', () {
    testWidgets('missing art is a placeholder: lacquer, gold border and the name', (tester) async {
      await tester.pumpWidget(around(const ArtImage(path: 'cards/missing.png', name: 'Phục kích bên sông')));
      expect(find.byKey(const Key('art-placeholder')), findsOneWidget);
      expect(find.text('Phục kích bên sông'), findsOneWidget);
      final box = tester.widget<DecoratedBox>(find.byKey(const Key('art-placeholder')));
      final d = box.decoration as BoxDecoration;
      expect(d.color, LongKyColors.lacquer);
      expect((d.border as Border).top.color, LongKyColors.goldLeaf);
      expect(find.byType(Image), findsNothing);
    });

    testWidgets('no path at all (the content names none) is a placeholder too', (tester) async {
      await tester.pumpWidget(around(const ArtImage(path: null, name: 'X')));
      expect(find.byKey(const Key('art-placeholder')), findsOneWidget);
    });

    testWidgets('with no art library in the app, everything is a placeholder', (tester) async {
      await tester.pumpWidget(around(const ArtImage(path: 'cards/a.png', name: 'X')));
      expect(find.byKey(const Key('art-placeholder')), findsOneWidget);
    });

    testWidgets('the name can be left out where it is already written beside the art', (tester) async {
      await tester.pumpWidget(
        around(const ArtImage(path: null, name: 'Tên', showName: false, icon: Icons.flag_outlined)),
      );
      expect(find.text('Tên'), findsNothing);
      expect(find.byIcon(Icons.flag_outlined), findsOneWidget);
    });

    testWidgets('a shipped file is drawn, loaded by its id, and there is no placeholder', (tester) async {
      final png = await tester.runAsync(makePng);
      final bundle = MemoryArtBundle({'assets/images/cards/a.png': png!});
      await tester.pumpWidget(
        around(
          const ArtImage(path: 'cards/a.png', name: 'Thẻ A'),
          library: bundle.library,
        ),
      );
      await tester.runAsync(() async {
        final element = tester.element(find.byType(ArtImage));
        await precacheImage(bundle.library.provider('cards/a.png')!, element);
      });
      await tester.pump();
      expect(find.byType(Image), findsOneWidget);
      expect(find.byKey(const Key('art-placeholder')), findsNothing);
      expect(find.bySemanticsLabel('Thẻ A'), findsOneWidget, reason: 'the picture is named for screen readers');
    });

    testWidgets('a file that is there but cannot be read falls back to the placeholder', (tester) async {
      final bundle = MemoryArtBundle({'assets/images/cards/bad.png': Uint8List.fromList(utf8.encode('not a png'))});
      await tester.pumpWidget(
        around(
          const ArtImage(path: 'cards/bad.png', name: 'Hỏng'),
          library: bundle.library,
        ),
      );
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
      await tester.pump();
      await tester.pump();
      expect(find.byKey(const Key('art-placeholder')), findsOneWidget);
    });

    testWidgets('a placeholder in a tiny box shows only its glyph, without overflow', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Center(
            child: SizedBox(
              width: 30,
              height: 30,
              child: ArtImage(path: null, name: 'Tên dài dài dài', icon: Icons.person),
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(find.text('Tên dài dài dài'), findsNothing);
    });
  });

  group('art ids in the content', () {
    final art = <String>{
      for (final c in content.cards.values)
        if (c.art != null) c.art!,
      for (final o in content.officers.values) ...[?o.portraitArt, ?o.cardArt],
      for (final c in content.commanders.values) ...[?c.portraitArt, ?c.cardArt],
      for (final m in content.maps.values) ?m.imagePath,
    };

    test('there is art named for every card, officer and Yuan commander', () {
      expect(art, isNotEmpty);
      expect(art.where((p) => p.startsWith('cards/')), hasLength(content.cards.length));
    });

    test('each art folder is declared in pubspec.yaml and exists, so delivered art is bundled', () {
      final pubspec = File('pubspec.yaml').readAsStringSync();
      for (final path in art) {
        final dir = path.substring(0, path.lastIndexOf('/') + 1);
        expect(pubspec, contains('- assets/images/$dir'), reason: '$path needs its folder declared');
        expect(Directory('assets/images/$dir').existsSync(), isTrue, reason: dir);
      }
    });

    test('the content validator wants exactly these files, none shipped yet', () {
      // `files` read straight from the content folder, as the app ships it.
      final r = validateContentForArt(art);
      expect(r, art, reason: 'every art id is a file the validator looks for');
    });
  });
}

/// The art files the validator reports missing when none are shipped.
Set<String> validateContentForArt(Set<String> expected) {
  final files = readContentFiles();
  final r = validateContent(files, assetPaths: <String>{});
  return {
    for (final i in r.issues)
      if (i.message.contains('art file')) i.message.split('assets/images/').last,
  };
}

Map<String, String> readContentFiles() {
  final root = Directory('assets/content');
  return {
    for (final f in root.listSync(recursive: true))
      if (f is File && f.path.endsWith('.json')) f.path.substring(root.path.length + 1): f.readAsStringSync(),
  };
}
