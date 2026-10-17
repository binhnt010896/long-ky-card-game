import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:long_ky_game/app/long_ky_app.dart';
import 'package:long_ky_game/art/art_library.dart';
import 'package:long_ky_game/data/progress.dart';
import 'package:long_ky_game/data/progress_repository.dart';
import 'package:long_ky_game/data/progress_store.dart';
import 'package:long_ky_game/features/battle/overlays/panel.dart';

import 'art_support.dart';
import 'battle/overlay_support.dart';

/// The painted look: backdrops, portraits and mission pictures appear when the
/// art is shipped and give way to plain lacquer when it is not.
void main() {
  // A 1×1 PNG: enough for the image decoder.
  final png = base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR4nGNgYGD4DwABBAEAHnOcQAAAAABJRU5ErkJggg==',
  );

  Future<void> pumpApp(WidgetTester tester, ArtLibrary library, {Progress progress = const Progress()}) async {
    setViewSize(tester, compact);
    final repository = ProgressRepository(MemoryProgressStore());
    await tester.pumpWidget(
      DefaultAssetBundle(
        bundle: DiskAssetBundle(),
        child: LongKyApp(repository: repository, initial: progress, art: library),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  ArtLibrary shipped(Iterable<String> paths) =>
      MemoryArtBundle({for (final p in paths) 'assets/images/$p': Uint8List.fromList(png)}).library;

  group('title screen', () {
    testWidgets('shows the painted cover, the logo and the title when the art is shipped', (tester) async {
      await pumpApp(tester, shipped(['ui/title-cover.jpg', 'ui/logo.png']));
      expect(find.byKey(const Key('backdrop-art')), findsOneWidget);
      expect(find.text(LongKyApp.productName), findsOneWidget);
      for (final label in ['Tiếp tục', 'Chiến dịch', 'Sử liệu', 'Cài đặt']) {
        expect(find.text(label), findsOneWidget, reason: label);
      }
      expect(tester.takeException(), isNull);
    });

    testWidgets('without the art it is plain lacquer, with every button still there', (tester) async {
      await pumpApp(tester, ArtLibrary.empty());
      expect(find.byKey(const Key('backdrop-art')), findsNothing);
      expect(find.text('Chiến dịch'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('the menu fits a phone held sideways, inside the safe area', (tester) async {
      await pumpApp(tester, shipped(['ui/title-cover.jpg', 'ui/logo.png']));
      final bottom = tester.getBottomLeft(find.text('Cài đặt')).dy;
      expect(bottom, lessThan(compact.height), reason: 'the last button is on screen without scrolling');
    });
  });

  group('campaign', () {
    testWidgets('mission tiles show their painted pictures; locked ones are dimmed with a lock', (tester) async {
      await pumpApp(tester, shipped(['ui/dragon-splash.jpg', 'missions/ch1_m1.jpg', 'missions/ch1_m2.jpg']));
      await tester.tap(find.text('Chiến dịch'));
      await tester.pump();
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 400)));
      await tester.pump();
      await tester.tap(find.text('Chương 1'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byKey(const Key('mission-ch1_m1')), findsOneWidget);
      // m1 and m2 have pictures; the backdrop is the dragon.
      expect(find.byType(Image), findsAtLeastNWidgets(3));
      expect(find.byKey(const Key('lock')), findsNWidgets(4));
      expect(tester.takeException(), isNull);
    });
  });

  group('officer portraits', () {
    testWidgets('a portrait replaces the initials when shipped', (tester) async {
      await pumpOverlay(
        tester,
        compact,
        RepositoryProvider<ArtLibrary>.value(
          value: shipped(['officers/tran-thai-tong/portrait.jpg']),
          child: const PortraitBadge(path: 'officers/tran-thai-tong/portrait.jpg', initials: 'TT', size: 34),
        ),
      );
      expect(find.byKey(const Key('portrait-badge')), findsOneWidget);
      expect(find.text('TT'), findsNothing);
    });

    testWidgets('the initials are drawn when the file is not shipped', (tester) async {
      await pumpOverlay(
        tester,
        compact,
        RepositoryProvider<ArtLibrary>.value(
          value: ArtLibrary.empty(),
          child: const PortraitBadge(path: 'officers/tran-thai-tong/portrait.jpg', initials: 'TT', size: 34),
        ),
      );
      expect(find.byKey(const Key('portrait-badge')), findsNothing);
      expect(find.text('TT'), findsOneWidget);
    });
  });

  group('the art that ships', () {
    test('every picture the content names is a real file, and every UI picture exists', () {
      final missing = <String>[];
      final named = <String>{
        ...content.cards.values.map((c) => c.art).whereType<String>(),
        ...content.officers.values.expand((o) => [o.portraitArt, o.cardArt]).whereType<String>(),
        ...content.commanders.values.expand((c) => [c.portraitArt, c.cardArt]).whereType<String>(),
        ...content.maps.values.map((m) => m.imagePath).whereType<String>(),
        ...content.missions.values.map((m) => m.art).whereType<String>(),
        'ui/title-cover.jpg',
        'ui/dragon-splash.jpg',
        'ui/logo.png',
      };
      for (final path in named) {
        if (!File('assets/images/$path').existsSync()) missing.add(path);
      }
      expect(missing, isEmpty, reason: 'missing art files: $missing');
      expect(named.length, greaterThanOrEqualTo(27));
    });

    test('no shipped picture is too heavy for a phone (under 1.5 MB each)', () {
      final big = [
        for (final e in Directory('assets/images').listSync(recursive: true))
          if (e is File && !e.path.endsWith('.gitkeep') && e.lengthSync() > 1500 * 1024) e.path,
      ];
      expect(big, isEmpty);
    });
  });
}
