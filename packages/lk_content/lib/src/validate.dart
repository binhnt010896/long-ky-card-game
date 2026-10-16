import 'dart:convert';

import 'package:lk_rules/lk_rules.dart';

import 'issues.dart';
import 'model.dart';
import 'parse.dart';
import 'reader.dart';

/// Content files every content root must have (besides maps/ and missions/).
const List<String> requiredFiles = [
  'officers.json',
  'enemies.json',
  'cards.json',
  'sources.json',
  'longky_ids.json',
];

const Set<String> _imageExtensions = {'.png', '.jpg', '.jpeg', '.webp'};
const Set<String> _audioExtensions = {'.mp3', '.ogg', '.wav', '.m4a'};

final class ValidationResult {
  const ValidationResult(this.issues, this.bundle);

  final List<Issue> issues;

  /// The parsed content, or null if there were errors.
  final ContentBundle? bundle;

  Iterable<Issue> get errors => issues.where((i) => i.isError);
  Iterable<Issue> get warnings => issues.where((i) => !i.isError);
  bool get ok => errors.isEmpty;
}

final class ContentException implements Exception {
  ContentException(this.issues);
  final List<Issue> issues;

  @override
  String toString() => 'Invalid content:\n${issues.where((i) => i.isError).join('\n')}';
}

/// Parses and validates content. [files] maps paths relative to the content
/// root (e.g. `missions/ch1_m2.json`) to file text. [assetPaths] lists the
/// files under `assets/` (e.g. `images/cards/x.png`, `audio/voice/y.mp3`);
/// when given, missing art and audio are warnings, or errors with [release].
ValidationResult validateContent(
  Map<String, String> files, {
  Set<String>? assetPaths,
  bool release = false,
}) {
  final issues = Issues();
  final parser = ContentParser(issues);

  for (final f in requiredFiles) {
    if (!files.containsKey(f)) issues.error(Rule.schema, 'missingFile', f, r'$', 'required content file is missing');
  }
  final mapFiles = files.keys.where((f) => f.startsWith('maps/')).toList()..sort();
  final missionFiles = files.keys.where((f) => f.startsWith('missions/')).toList()..sort();
  if (mapFiles.isEmpty) issues.error(Rule.schema, 'missingFile', 'maps/', r'$', 'no map files');
  if (missionFiles.isEmpty) issues.error(Rule.schema, 'missingFile', 'missions/', r'$', 'no mission files');
  for (final f in files.keys) {
    if (!f.endsWith('.json')) continue;
    if (requiredFiles.contains(f) || mapFiles.contains(f) || missionFiles.contains(f)) continue;
    issues.error(Rule.schema, 'unknownFile', f, r'$', 'unexpected content file');
  }

  final decoded = <String, Object?>{};
  for (final f in files.keys) {
    if (!f.endsWith('.json')) continue;
    try {
      decoded[f] = jsonDecode(files[f]!);
    } on FormatException catch (e) {
      issues.error(Rule.schema, 'parse', f, r'$', 'invalid JSON: ${e.message}');
    }
  }

  List<T> listFile<T>(String file, String what, T? Function(Obj o) parse) =>
      decoded.containsKey(file) ? parser.parseList(file, decoded[file], what, parse) : <T>[];

  final officers = listFile('officers.json', 'officers', parser.officer);
  final commanders = listFile('enemies.json', 'enemy commanders', parser.commander);
  final cards = listFile('cards.json', 'cards', parser.card);
  final sources = listFile('sources.json', 'sources', parser.source);
  final longKy = (decoded.containsKey('longky_ids.json')
          ? parser.parseObject('longky_ids.json', decoded['longky_ids.json'], parser.longKyIds)
          : null) ??
      const LongKyIds(people: {}, events: {});
  final maps = <(String, MapDef)>[
    for (final f in mapFiles)
      if (decoded.containsKey(f))
        if (parser.parseObject(f, decoded[f], parser.map) case final MapDef m) (f, m),
  ];
  final missions = <(String, MissionDef)>[
    for (final f in missionFiles)
      if (decoded.containsKey(f))
        if (parser.parseObject(f, decoded[f], parser.mission) case final MissionDef m) (f, m),
  ];

  // Rule 2: unique ids.
  void unique(Iterable<(String, String)> idsWithFile, String what) {
    final seen = <String>{};
    for (final (id, file) in idsWithFile) {
      if (!seen.add(id)) issues.error(Rule.references, 'duplicateId', file, r'$', 'duplicate $what id "$id"');
    }
  }

  unique(officers.map((o) => (o.id, 'officers.json')), 'officer');
  unique(commanders.map((c) => (c.id, 'enemies.json')), 'enemy');
  unique([
    ...officers.map((o) => (o.id, 'officers.json')),
    ...commanders.map((c) => (c.id, 'enemies.json')),
  ], 'person');
  unique(cards.map((c) => (c.id, 'cards.json')), 'card');
  unique(sources.map((s) => (s.id, 'sources.json')), 'source');
  unique(maps.map((m) => (m.$2.id, m.$1)), 'map');
  unique(missions.map((m) => (m.$2.id, m.$1)), 'mission');
  for (final (file, m) in maps) {
    if (file != 'maps/${m.id}.json') {
      issues.error(Rule.references, 'fileName', file, r'$.id', 'map "${m.id}" must be in maps/${m.id}.json');
    }
    unique(m.nodes.map((n) => (n.id, file)), 'node');
    unique(m.edges.map((e) => (e.key, file)), 'edge');
  }
  for (final (file, m) in missions) {
    if (file != 'missions/${m.id}.json') {
      issues.error(Rule.references, 'fileName', file, r'$.id', 'mission "${m.id}" must be in missions/${m.id}.json');
    }
    unique(m.yuanArmies.map((a) => (a.id, file)), 'army');
    unique(m.playerOfficers.map((p) => (p.officerId, file)), 'mission officer');
    unique(m.tutorial.map((t) => (t.id, file)), 'tutorial step');
  }

  // Rules 2, 4 and 8: references.
  final officerIds = {for (final o in officers) o.id};
  final commanderIds = {for (final c in commanders) c.id};
  final cardIds = {for (final c in cards) c.id};
  final sourceIds = {for (final s in sources) s.id};
  final mapById = {for (final (_, m) in maps) m.id: m};
  final missionById = {for (final (_, m) in missions) m.id: m};
  for (final r in parser.refs) {
    bool resolves() => switch (r.kind) {
          RefKind.officer => officerIds.contains(r.id),
          RefKind.commander => commanderIds.contains(r.id),
          RefKind.card => cardIds.contains(r.id),
          RefKind.map => mapById.containsKey(r.id),
          RefKind.node => mapById[r.scope]?.nodes.any((n) => n.id == r.id) ?? mapById[r.scope] == null,
          RefKind.army => missionById[r.scope]?.yuanArmies.any((a) => a.id == r.id) ?? false,
          RefKind.source => sourceIds.contains(r.id),
          RefKind.longKyPerson => longKy.people.contains(r.id),
          RefKind.longKyEvent => longKy.events.contains(r.id),
          RefKind.image || RefKind.audio => true,
        };
    switch (r.kind) {
      case RefKind.longKyPerson || RefKind.longKyEvent:
        if (!resolves()) {
          issues.error(Rule.longKyIds, 'unknownLongKyId', r.file, r.path, '"${r.id}" is not in longky_ids.json');
        }
      case RefKind.image || RefKind.audio:
        _checkAsset(issues, r, assetPaths, release);
      default:
        if (!resolves()) {
          issues.error(Rule.references, 'unresolved', r.file, r.path, 'no ${r.kind.name} "${r.id}"');
        }
    }
  }

  // Rule 3: sourceRefs.
  void needsSource(String file, String what, String id, List<String> refs) {
    if (refs.isEmpty) issues.error(Rule.sourceRefs, 'noSourceRef', file, r'$', '$what "$id" has no sourceRef');
  }

  for (final o in officers) {
    needsSource('officers.json', 'officer', o.id, o.sourceRefs);
  }
  for (final c in commanders) {
    needsSource('enemies.json', 'enemy', c.id, c.sourceRefs);
  }
  for (final c in cards) {
    needsSource('cards.json', 'card', c.id, c.sourceRefs);
  }
  for (final (file, m) in missions) {
    needsSource(file, 'mission', m.id, m.sourceRefs);
  }

  // Rule 7: map graph.
  for (final (file, m) in maps) {
    final graph = MapGraph(m);
    final capitals = m.nodes.where((n) => n.isCapital).length;
    if (capitals != 1) {
      issues.error(Rule.mapGraph, 'capitalCount', file, r'$.nodes', 'a map needs exactly one isCapital node, has $capitals');
    }
    if (!graph.isConnected) issues.error(Rule.mapGraph, 'disconnected', file, r'$.edges', 'the map graph is not connected');
  }
  for (final (file, m) in missions) {
    final map = mapById[m.mapId];
    if (map == null) continue;
    final graph = MapGraph(map);
    for (var i = 0; i < m.yuanArmies.length; i++) {
      final a = m.yuanArmies[i];
      if (!graph.hasNode(a.nodeId) || !graph.hasNode(a.retreatNodeId)) continue;
      if (graph.distance(a.nodeId, a.retreatNodeId) == null) {
        issues.error(Rule.mapGraph, 'unreachableRetreat', file, '\$.yuanArmies[$i].retreatNodeId',
            '"${a.retreatNodeId}" cannot be reached from "${a.nodeId}"');
      }
    }
  }

  // Mission rules that the engine relies on (rule 1, semantic).
  final officerById = {for (final o in officers) o.id: o};
  for (final (file, m) in missions) {
    final kings = m.playerOfficers.where((p) => officerById[p.officerId]?.isKing ?? false).length;
    if (kings > 1) issues.error(Rule.schema, 'kingCount', file, r'$.playerOfficers', 'at most one king per mission');
    for (var i = 0; i < m.playerOfficers.length; i++) {
      final p = m.playerOfficers[i];
      final cap = officerById[p.officerId]?.troopCap;
      if (cap != null && p.troops > cap) {
        issues.error(Rule.schema, 'troopCap', file, '\$.playerOfficers[$i].troops', '${p.officerId} has troopCap $cap');
      }
    }
    for (var i = 0; i < m.deck.length; i++) {
      if (cards.where((c) => c.id == m.deck[i].cardId).firstOrNull?.type == CardType.intent) {
        issues.error(Rule.schema, 'intentInDeck', file, '\$.deck[$i]', 'enemy intent cards cannot be in the player deck');
      }
    }
    for (final (key, turns) in [
      ('scriptedEvents', m.scriptedEvents.map((e) => e.turn)),
      ('inducements', m.inducements.map((e) => e.turn)),
      ('yuanScript', m.yuanScript.map((e) => e.turn)),
    ]) {
      if (turns.any((t) => t > m.seasonTurns)) {
        issues.error(Rule.schema, 'range', file, '\$.$key', 'a turn is after seasonTurns ${m.seasonTurns}');
      }
    }
  }

  final all = issues.all;
  if (issues.hasErrors) return ValidationResult(all, null);

  final sortedMissions = [for (final (_, m) in missions) m]..sort((a, b) {
      final c = a.chapter.compareTo(b.chapter);
      return c != 0 ? c : a.order.compareTo(b.order);
    });
  return ValidationResult(
    all,
    ContentBundle(
      officers: {for (final o in officers) o.id: o},
      commanders: {for (final c in commanders) c.id: c},
      cards: {for (final c in cards) c.id: c},
      maps: mapById,
      missions: {for (final m in sortedMissions) m.id: m},
      sources: {for (final s in sources) s.id: s},
      longKyIds: longKy,
      contentHash: contentHash(files),
    ),
  );
}

/// Parses content, throwing [ContentException] if it is invalid.
ContentBundle loadContent(Map<String, String> files) {
  final result = validateContent(files);
  if (!result.ok) throw ContentException(result.issues);
  return result.bundle!;
}

/// Hash of all content files (sorted by path) for save compatibility.
String contentHash(Map<String, String> files) {
  final paths = files.keys.where((p) => p.endsWith('.json')).toList()..sort();
  final buffer = StringBuffer();
  for (final p in paths) {
    buffer
      ..write(p)
      ..write('\n')
      ..write(files[p])
      ..write('\n');
  }
  return fnv1a64Hex(buffer.toString());
}

void _checkAsset(Issues issues, Ref r, Set<String>? assetPaths, bool release) {
  final isImage = r.kind == RefKind.image;
  final exts = isImage ? _imageExtensions : _audioExtensions;
  final p = r.id;
  final dot = p.lastIndexOf('.');
  final ext = dot < 0 ? '' : p.substring(dot).toLowerCase();
  if (p.isEmpty || p.startsWith('/') || p.contains('\\') || p.split('/').contains('..') || !exts.contains(ext)) {
    issues.error(Rule.references, 'badPath', r.file, r.path,
        '"$p" must be a relative ${isImage ? 'image' : 'audio'} path ending in ${exts.join('/')}');
    return;
  }
  if (assetPaths == null) return;
  final full = '${isImage ? 'images' : 'audio'}/$p';
  if (assetPaths.contains(full)) return;
  final message = 'missing ${isImage ? 'art' : 'audio'} file assets/$full';
  if (release) {
    issues.error(Rule.assets, 'missingAsset', r.file, r.path, message);
  } else {
    issues.warning(Rule.assets, 'missingAsset', r.file, r.path, message);
  }
}
