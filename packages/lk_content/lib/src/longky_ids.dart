import 'dart:convert';

/// Builds the `longky_ids.json` snapshot from Long Ký's `people.json` and
/// `events.json`.
///
/// The exact shape of Long Ký's files is not in this repo, so both shapes
/// are accepted: a top-level list of objects with an `id`, or an object
/// whose first list value holds them (e.g. `{ "people": [ ... ] }`).
String buildLongKyIdsJson({
  required Object? people,
  required Object? events,
  String generatedFrom = 'Long Ký people.json and events.json',
}) {
  final out = {
    'generatedFrom': generatedFrom,
    'people': extractIds(people, 'people.json'),
    'events': extractIds(events, 'events.json'),
  };
  return '${const JsonEncoder.withIndent('  ').convert(out)}\n';
}

/// Sorted unique `id` values of the records in [json].
List<String> extractIds(Object? json, String what) {
  List<Object?>? records;
  if (json is List<Object?>) {
    records = json;
  } else if (json is Map<String, Object?>) {
    records = json.values.whereType<List<Object?>>().firstOrNull;
  }
  if (records == null) throw FormatException('$what: expected a list of records or an object holding one');
  final ids = <String>{};
  for (final r in records) {
    final id = r is Map<String, Object?> ? r['id'] : null;
    if (id is! String || id.isEmpty) throw FormatException('$what: every record needs a string "id"');
    ids.add(id);
  }
  return ids.toList()..sort();
}
