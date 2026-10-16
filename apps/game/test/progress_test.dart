import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:long_ky_game/data/progress.dart';
import 'package:long_ky_game/data/progress_repository.dart';
import 'package:long_ky_game/data/progress_store.dart';

void main() {
  group('Progress JSON', () {
    test('round-trips and carries the version', () {
      final p = Progress(
        stars: const {
          'ch1_m2': [true, false, true],
        },
        unlocks: const ['x'],
        settings: const GameSettings().copyWith(languageCode: 'en', textScale: 1.3, reduceMotion: true),
      );
      final json = jsonDecode(jsonEncode(p.toJson())) as Map<String, Object?>;
      expect(json['version'], Progress.currentVersion);
      final back = Progress.fromJson(json);
      expect(back.stars, p.stars);
      expect(back.unlocks, p.unlocks);
      expect(back.settings, p.settings);
    });

    test('a version 1 file (before coach marks) loads, with no tutorial done and everything else kept', () {
      final p = Progress.fromJson({
        'version': 1,
        'stars': {
          'ch1_m1': [true, false, true],
        },
        'unlocks': ['x'],
        'settings': {'languageCode': 'en', 'reduceMotion': true},
      });
      expect(p.tutorialDone, isEmpty);
      expect(p.stars['ch1_m1'], [true, false, true]);
      expect(p.unlocks, ['x']);
      expect(p.settings.languageCode, 'en');
      expect(p.settings.reduceMotion, isTrue);
      expect(p.toJson()['version'], Progress.currentVersion, reason: 'written back as the current version');
    });

    test('finished coach marks are remembered, round-trip, and a reset makes the player new again', () {
      final p = const Progress().copyWith(tutorialDone: ['ch1_m1', 'ch1_m2']);
      final back = Progress.fromJson(p.toJson());
      expect(back.tutorialDone, ['ch1_m1', 'ch1_m2']);
      expect(p.reset().tutorialDone, isEmpty);
    });

    test('a damaged tutorialDone list is ignored, not fatal', () {
      expect(Progress.fromJson({'version': 2, 'tutorialDone': 'nope'}).tutorialDone, isEmpty);
      expect(
        Progress.fromJson({
          'version': 2,
          'tutorialDone': ['a', 3, null],
        }).tutorialDone,
        ['a'],
      );
    });

    test('missing or invalid settings fall back to defaults; values are clamped', () {
      final p = Progress.fromJson({
        'version': 1,
        'settings': {'languageCode': 'fr', 'musicVolume': 7, 'textScale': 0.5, 'reduceMotion': 'yes'},
      });
      expect(p.settings.languageCode, 'vi');
      expect(p.settings.musicVolume, 1.0);
      expect(p.settings.textScale, 1.0);
      expect(p.settings.reduceMotion, isFalse);
      expect(p.stars, isEmpty);
    });

    test('a file without a version or from a newer app is rejected', () {
      expect(() => Progress.fromJson({'stars': {}}), throwsFormatException);
      expect(() => Progress.fromJson({'version': Progress.currentVersion + 1}), throwsFormatException);
    });
  });

  group('ProgressRepository', () {
    test('no file gives defaults (Vietnamese)', () async {
      final p = await ProgressRepository(MemoryProgressStore()).load();
      expect(p.settings.languageCode, 'vi');
    });

    test('an unreadable file is set aside and defaults are used', () async {
      final store = MemoryProgressStore('{ not json');
      final p = await ProgressRepository(store).load();
      expect(p.settings, const GameSettings());
      expect(store.quarantined, '{ not json');
    });
  });

  group('FileProgressStore', () {
    late Directory dir;
    setUp(() => dir = Directory.systemTemp.createTempSync('lk_progress_'));
    tearDown(() => dir.deleteSync(recursive: true));

    test('writes atomically through a temp file and reads back', () async {
      final repo = ProgressRepository(FileProgressStore(dir));
      await repo.save(const Progress(settings: GameSettings(languageCode: 'en')));
      expect(File('${dir.path}/progress.json').existsSync(), isTrue);
      expect(File('${dir.path}/progress.json.tmp').existsSync(), isFalse);
      expect((await ProgressRepository(FileProgressStore(dir)).load()).settings.languageCode, 'en');
    });

    test('a corrupt file is renamed to progress.json.bad', () async {
      File('${dir.path}/progress.json').writeAsStringSync('garbage');
      final p = await ProgressRepository(FileProgressStore(dir)).load();
      expect(p.settings, const GameSettings());
      expect(File('${dir.path}/progress.json.bad').existsSync(), isTrue);
      expect(File('${dir.path}/progress.json').existsSync(), isFalse);
    });
  });
}
