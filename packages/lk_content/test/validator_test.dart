// Tests edit raw JSON trees, so dynamic access is intended here.
// ignore_for_file: avoid_dynamic_calls

import 'dart:convert';
import 'dart:io';

import 'package:lk_content/io.dart';
import 'package:lk_content/lk_content.dart';
import 'package:lk_rules/lk_rules.dart';
import 'package:test/test.dart';

final _fixtures = Directory('test/fixtures');

Map<String, String> validFiles() => readContentDir(Directory('${_fixtures.path}/valid'));

/// Every art and audio path the valid fixture refers to.
Set<String> allAssets(Map<String, String> files) {
  final paths = <String>{};
  final re = RegExp(r'"((?:officers|enemies|cards)/[^"]+\.png)"');
  for (final text in files.values) {
    for (final m in re.allMatches(text)) {
      paths.add('images/${m.group(1)}');
    }
  }
  paths.addAll(['audio/voice/m1_briefing.mp3', 'audio/voice/m1_debrief.mp3']);
  return paths;
}

void main() {
  group('valid content', () {
    test('passes with no errors and builds a bundle', () {
      final files = validFiles();
      final result = validateContent(files, assetPaths: allAssets(files), release: true);
      expect(result.errors, isEmpty, reason: result.errors.join('\n'));
      expect(result.warnings, isEmpty, reason: result.warnings.join('\n'));
      final b = result.bundle!;
      expect(b.officers.keys, ['king', 'general']);
      expect(b.missions.keys, ['m1']);
      expect(b.contentHash, matches(RegExp(r'^[0-9a-f]{16}$')));
    });

    test('parses into lk_rules definitions the engine can play', () {
      final b = loadContent(validFiles());
      final general = b.officers['general']!;
      expect(general.troopCap, 8);
      expect(general.skill!.target, TargetKind.ownNode);
      expect(general.skill!.effects.first, isA<EvacuateNodeEffect>());
      final envoy = b.cards['envoy']!;
      expect((envoy.effects.single as ChoiceEffect).options, hasLength(2));
      final m = b.missions['m1']!;
      expect(m.heatStartTurn, isNull);
      expect(m.stars.first, isA<WonObjective>());
      expect(m.stars.last, isA<AnyOfObjective>());

      final engine = GameEngine(b.ruleset('m1'));
      final s = engine.newGame(1).state;
      expect(s.pendingChoice, isNotNull, reason: 'scripted envoy on turn 1');
      expect(s.officers.keys, containsAll(['king', 'general']));
    });

    test('the content hash changes when any file changes', () {
      final files = validFiles();
      final changed = {...files, 'cards.json': files['cards.json']!.replaceFirst('"support": 2', '"support": 3')};
      expect(contentHash(changed), isNot(contentHash(files)));
      expect(contentHash({...files}), contentHash(files));
    });

    test('missing art is a warning without --release', () {
      final result = validateContent(validFiles(), assetPaths: const {});
      expect(result.ok, isTrue);
      expect(result.warnings.map((w) => w.code).toSet(), {'missingAsset'});
      expect(result.warnings.every((w) => w.rule == 8), isTrue);
    });
  });

  group('one failing fixture per rule', () {
    final dirs = Directory('${_fixtures.path}/invalid').listSync().whereType<Directory>().toList()
      ..sort((a, b) => a.path.compareTo(b.path));
    final rules = <int>{};
    for (final dir in dirs) {
      final expectJson = jsonDecode(File('${dir.path}/expect.json').readAsStringSync()) as Map<String, Object?>;
      final rule = expectJson['rule']! as int;
      final code = expectJson['code']! as String;
      final release = expectJson['release'] == true;
      rules.add(rule);
      test('${dir.uri.pathSegments[dir.uri.pathSegments.length - 2]}: rule $rule ($code)', () {
        final files = {...validFiles(), ...readContentDir(dir)}..remove('expect.json');
        final assets = release ? <String>{} : allAssets(files);
        final result = validateContent(files, assetPaths: assets, release: release);
        expect(result.ok, isFalse);
        expect(result.bundle, isNull);
        expect(result.errors.map((e) => (e.rule, e.code)), contains((rule, code)), reason: result.issues.join('\n'));
      });
    }
    test('covers rules 1 to 8', () => expect(rules, {1, 2, 3, 4, 5, 6, 7, 8}));
  });

  group('more checks', () {
    Map<String, String> edit(String file, void Function(dynamic json) change) {
      final files = validFiles();
      final json = jsonDecode(files[file]!);
      change(json);
      return {...files, file: jsonEncode(json)};
    }

    List<String> codes(Map<String, String> files) =>
        validateContent(files).errors.map((e) => e.code).toList();

    test('a choice must be the last effect', () {
      expect(
        codes(edit('cards.json', (c) => (c[1]['effects'] as List).add({'op': 'skipTurn'}))),
        contains('choiceNotLast'),
      );
    });

    test('effect variables must match the target', () {
      expect(codes(edit('cards.json', (c) => c[0]['effects'][0]['target'] = r'$officer')), contains('badVariable'));
    });

    test('unknown condition and objective types are rejected', () {
      expect(codes(edit('cards.json', (c) => c[1]['conditions'][0]['op'] = 'moonPhase')), contains('unknownCondition'));
      expect(codes(edit('missions/m1.json', (m) => m['win'][0]['type'] = 'conquerWorld')), contains('unknownObjective'));
    });

    test('unknown flaws, enum values and missing fields are rejected', () {
      expect(codes(edit('officers.json', (o) => o[1]['flaw']['id'] = 'cowardice')), contains('unknownFlaw'));
      expect(codes(edit('maps/m.json', (m) => m['nodes'][0]['terrain'] = 'desert')), contains('unknownValue'));
      expect(codes(edit('cards.json', (c) => (c[0] as Map).remove('cost'))), contains('missingField'));
      expect(codes(edit('officers.json', (o) => o[0]['stats']['war'] = 11)), contains('range'));
    });

    test('troops above troopCap and a star 1 that is not "won" are rejected', () {
      expect(codes(edit('missions/m1.json', (m) => m['playerOfficers'][1]['troops'] = 9)), contains('troopCap'));
      expect(codes(edit('missions/m1.json', (m) => m['stars'][0] = {'type': 'noCaptures'})), contains('starOne'));
    });

    test('bad asset paths and file names are rejected', () {
      expect(codes(edit('cards.json', (c) => c[0]['art'] = '../secret.png')), contains('badPath'));
      final files = validFiles();
      expect(codes({...files, 'missions/other.json': files['missions/m1.json']!}), containsAll(['fileName', 'duplicateId']));
    });

    test('isKing and the isKing flaw go together', () {
      expect(codes(edit('officers.json', (o) => o[0]['isKing'] = false)), contains('kingFlaw'));
    });
  });

  group('longky_ids.json builder', () {
    test('accepts a list of records or an object holding one; sorts and dedupes', () {
      final text = buildLongKyIdsJson(
        people: [
          {'id': 'tran-thu-do', 'name': 'x'},
          {'id': 'tran-thai-tong'},
          {'id': 'tran-thu-do'},
        ],
        events: {
          'version': 2,
          'events': [
            {'id': 'bach-dang-1288'},
          ],
        },
        generatedFrom: 'test',
      );
      final json = jsonDecode(text) as Map<String, Object?>;
      expect(json['people'], ['tran-thai-tong', 'tran-thu-do']);
      expect(json['events'], ['bach-dang-1288']);
      expect(json['generatedFrom'], 'test');
    });

    test('rejects records without an id', () {
      expect(() => extractIds([{'name': 'x'}], 'people.json'), throwsFormatException);
      expect(() => extractIds('nope', 'people.json'), throwsFormatException);
    });
  });
}
