import 'dart:convert';

/// One bilingual text of the content, for the history reviewer (T-26).
final class TextRow {
  const TextRow({
    required this.file,
    required this.contentId,
    required this.path,
    required this.vi,
    required this.en,
    required this.sourceRefs,
    required this.sources,
    required this.todo,
  });

  /// The content file, relative to the content root (`officers.json`).
  final String file;

  /// The ids of the item the text belongs to, outermost first, joined with
  /// `/` (`tran-thai-tong/kingPresence`, `ch1/bien-gioi`).
  final String contentId;

  /// Where the text is inside that item (`skill.name`).
  final String path;
  final String vi;
  final String en;

  /// The `sourceRefs` of the nearest item that has them; empty if none.
  final List<String> sourceRefs;

  /// The same references written out ("work, publisher").
  final List<String> sources;

  /// The open notes (`todo`) of the item and of the file's root.
  final List<String> todo;
}

const List<String> textRowColumns = ['file', 'contentId', 'path', 'vi', 'en', 'sourceRefs', 'sources', 'todo'];

/// Every `{ "vi": ..., "en": ... }` text of the content files, in file and
/// document order (build-spec section 9, T-26). Files that are not JSON, and
/// `sources.json` itself, are skipped.
List<TextRow> collectTextRows(Map<String, String> files) {
  final sources = _sourceTitles(files['sources.json']);
  final rows = <TextRow>[];
  for (final name in files.keys.toList()..sort()) {
    if (!name.endsWith('.json') || name == 'sources.json') continue;
    final Object? root;
    try {
      root = jsonDecode(files[name]!);
    } on FormatException {
      continue;
    }
    _walk(rows, name, sources, root, const _Context(), '');
  }
  return rows;
}

final class _Context {
  const _Context({this.ids = const [], this.sourceRefs = const [], this.todo = const []});

  final List<String> ids;
  final List<String> sourceRefs;
  final List<String> todo;
}

Map<String, String> _sourceTitles(String? text) {
  if (text == null) return const {};
  final out = <String, String>{};
  try {
    final list = jsonDecode(text);
    if (list is List<Object?>) {
      for (final s in list.whereType<Map<String, Object?>>()) {
        final id = s['id'];
        if (id is! String) continue;
        out[id] = [s['work'], s['publisher'], s['section']].whereType<String>().where((x) => x.isNotEmpty).join(', ');
      }
    }
  } on FormatException {
    // Left empty: the rows then show only the ids.
  }
  return out;
}

List<String> _strings(Object? v) => v is List<Object?> ? v.whereType<String>().toList() : const [];

void _walk(List<TextRow> rows, String file, Map<String, String> titles, Object? node, _Context ctx, String path) {
  if (node is Map<String, Object?>) {
    final vi = node['vi'];
    final en = node['en'];
    if (node.length == 2 && vi is String && en is String) {
      rows.add(
        TextRow(
          file: file,
          contentId: ctx.ids.join('/'),
          path: path,
          vi: vi,
          en: en,
          sourceRefs: ctx.sourceRefs,
          sources: [for (final r in ctx.sourceRefs) titles[r] == null ? r : '$r: ${titles[r]}'],
          todo: ctx.todo,
        ),
      );
      return;
    }
    final id = node['id'];
    final inner = _Context(
      ids: id is String ? [...ctx.ids, id] : ctx.ids,
      sourceRefs: node.containsKey('sourceRefs') ? _strings(node['sourceRefs']) : ctx.sourceRefs,
      todo: node.containsKey('todo') ? [...ctx.todo, ..._strings(node['todo'])] : ctx.todo,
    );
    // A new item starts its own path.
    final startsItem = id is String;
    node.forEach((key, value) {
      if (key == 'todo' || key == 'sourceRefs') return;
      final sub = startsItem ? key : (path.isEmpty ? key : '$path.$key');
      _walk(rows, file, titles, value, inner, sub);
    });
  } else if (node is List<Object?>) {
    for (var i = 0; i < node.length; i++) {
      _walk(rows, file, titles, node[i], ctx, '$path[$i]');
    }
  }
}

/// The rows as CSV (RFC 4180: CRLF line ends, quotes doubled), with a header.
/// Lists are joined with ` | `. A byte-order mark in front lets Excel read the
/// Vietnamese text as UTF-8; [bom] turns that off.
String textRowsToCsv(List<TextRow> rows, {bool bom = true}) {
  String cell(String s) =>
      (s.contains(',') || s.contains('"') || s.contains('\n') || s.contains('\r')) ? '"${s.replaceAll('"', '""')}"' : s;
  final b = StringBuffer(bom ? '﻿' : '');
  b.write('${textRowColumns.join(',')}\r\n');
  for (final r in rows) {
    b.write(
      [
        r.file,
        r.contentId,
        r.path,
        r.vi,
        r.en,
        r.sourceRefs.join(' | '),
        r.sources.join(' | '),
        r.todo.join(' | '),
      ].map(cell).join(','),
    );
    b.write('\r\n');
  }
  return b.toString();
}
