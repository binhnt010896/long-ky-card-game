import 'dart:convert';
import 'dart:io';

import 'package:lk_content/io.dart';
import 'package:lk_content/lk_content.dart';
import 'package:test/test.dart';

/// A small RFC 4180 reader, to check the CSV the other way round.
List<List<String>> parseCsv(String text) {
  final rows = <List<String>>[];
  var row = <String>[];
  final cell = StringBuffer();
  var quoted = false;
  for (var i = 0; i < text.length; i++) {
    final c = text[i];
    if (quoted) {
      if (c == '"') {
        if (i + 1 < text.length && text[i + 1] == '"') {
          cell.write('"');
          i++;
        } else {
          quoted = false;
        }
      } else {
        cell.write(c);
      }
    } else if (c == '"') {
      quoted = true;
    } else if (c == ',') {
      row.add(cell.toString());
      cell.clear();
    } else if (c == '\r') {
      // Part of CRLF.
    } else if (c == '\n') {
      row.add(cell.toString());
      cell.clear();
      rows.add(row);
      row = <String>[];
    } else {
      cell.write(c);
    }
  }
  return rows;
}

void main() {
  final dir = findContentDir();

  group('collectTextRows', () {
    final files = {
      'sources.json': jsonEncode([
        {'id': 's1', 'work': 'Work One', 'publisher': 'Pub'},
      ]),
      'things.json': jsonEncode([
        {
          'id': 'a',
          'name': {'vi': 'Một', 'en': 'One'},
          'sourceRefs': ['s1', 'unknown'],
          'todo': ['check me'],
          'skill': {
            'id': 'sk',
            'name': {'vi': 'Kỹ năng', 'en': 'Skill'},
            'text': {'vi': 'a, "b"\nc', 'en': 'x'},
          },
          'list': [
            {'vi': 'phần tử', 'en': 'item'},
          ],
        },
        {
          'id': 'b',
          'name': {'vi': 'Hai', 'en': 'Two'},
        },
      ]),
      'notes.txt': 'not json',
      'bad.json': '{',
    };
    final rows = collectTextRows(files);

    test('finds every vi/en pair, in file and document order, skipping sources, other files and broken JSON', () {
      expect(
        [for (final r in rows) '${r.contentId}:${r.path}'],
        ['a:name', 'a/sk:name', 'a/sk:text', 'a:list[0]', 'b:name'],
      );
    });

    test('an item without its own sourceRefs has none, nested items inherit those of their item', () {
      expect(rows[0].sourceRefs, ['s1', 'unknown']);
      expect(rows[1].sourceRefs, ['s1', 'unknown']);
      expect(rows[4].sourceRefs, isEmpty);
      expect(rows[0].sources, ['s1: Work One, Pub', 'unknown']);
      expect(rows[0].todo, ['check me']);
      expect(rows[4].todo, isEmpty);
    });

    test('the CSV reads back to the same cells, with commas, quotes and line breaks', () {
      final csv = textRowsToCsv(rows);
      expect(csv.startsWith('﻿'), isTrue);
      expect(textRowsToCsv(rows, bom: false).startsWith('file,'), isTrue);
      final back = parseCsv(csv.substring(1));
      expect(back.first, textRowColumns);
      expect(back, hasLength(rows.length + 1));
      expect(back[3][3], 'a, "b"\nc');
      expect(back[1][5], 's1 | unknown');
      expect(back[1][7], 'check me');
      for (var i = 0; i < rows.length; i++) {
        expect(back[i + 1], hasLength(textRowColumns.length), reason: 'row $i');
        expect(back[i + 1][3], rows[i].vi);
        expect(back[i + 1][4], rows[i].en);
      }
    });
  });

  group('the real content', () {
    test('every text is exported: the count matches a separate count of "vi" keys', () {
      final files = readContentDir(dir!);
      final rows = collectTextRows(files);
      var viKeys = 0;
      for (final e in files.entries) {
        if (!e.key.endsWith('.json') || e.key == 'sources.json') continue;
        viKeys += RegExp(r'"vi"\s*:').allMatches(e.value).length;
      }
      expect(rows, hasLength(viKeys));
      expect(rows, isNotEmpty);
      for (final r in rows) {
        expect(r.vi.trim(), isNotEmpty, reason: '${r.file} ${r.contentId} ${r.path}');
        expect(r.en.trim(), isNotEmpty, reason: '${r.file} ${r.contentId} ${r.path}');
        expect(r.contentId, isNotEmpty);
      }
    });

    test('officers, cards and missions carry their sourceRefs, which all resolve to a source', () {
      final files = readContentDir(dir!);
      final rows = collectTextRows(files);
      final known = {
        for (final s in (jsonDecode(files['sources.json']!) as List<Object?>).cast<Map<String, Object?>>())
          s['id'] as String,
      };
      for (final r in rows.where((r) => r.file != 'maps/ch1.json')) {
        expect(r.sourceRefs, isNotEmpty, reason: '${r.file} ${r.contentId}');
        expect(known.containsAll(r.sourceRefs), isTrue, reason: '${r.file} ${r.contentId}');
      }
    });

    test('the export command writes the file', () {
      final out = File('${Directory.systemTemp.createTempSync('lk_export_').path}/text.csv');
      final r = Process.runSync('dart', ['run', 'bin/export_text.dart', '--out', out.path, '--content', dir!.path]);
      expect(r.exitCode, 0, reason: '${r.stderr}');
      expect(out.readAsBytesSync().take(3), [0xEF, 0xBB, 0xBF], reason: 'UTF-8 byte-order mark for Excel');
      final back = parseCsv(out.readAsStringSync());
      expect(back.first, textRowColumns);
      expect(back.length - 1, collectTextRows(readContentDir(dir)).length);
      out.parent.deleteSync(recursive: true);
    });
  });
}
