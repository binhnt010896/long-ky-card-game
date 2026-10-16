import 'package:lk_rules/lk_rules.dart';

/// A citation (sources.json), in the same shape Long Ký uses.
final class SourceDef {
  const SourceDef({
    required this.id,
    required this.work,
    this.publisher,
    this.url,
    this.section,
    this.author,
    this.note,
  });

  final String id;
  final String work;
  final String? publisher;
  final String? url;
  final String? section;
  final String? author;
  final String? note;
}

/// Snapshot of the person and event ids that exist in Long Ký.
final class LongKyIds {
  const LongKyIds({required this.people, required this.events});

  final Set<String> people;
  final Set<String> events;
}

/// All game content, parsed and validated.
final class ContentBundle {
  ContentBundle({
    required this.officers,
    required this.commanders,
    required this.cards,
    required this.maps,
    required this.missions,
    required this.sources,
    required this.longKyIds,
    required this.contentHash,
  });

  final Map<String, OfficerDef> officers;
  final Map<String, CommanderDef> commanders;
  final Map<String, CardDef> cards;
  final Map<String, MapDef> maps;

  /// Missions sorted by chapter, then order.
  final Map<String, MissionDef> missions;
  final Map<String, SourceDef> sources;
  final LongKyIds longKyIds;

  /// Hash of every content file; goes into save files.
  final String contentHash;

  /// What the engine needs to play [missionId].
  Ruleset ruleset(String missionId) {
    final m = missions[missionId];
    if (m == null) throw ArgumentError.value(missionId, 'missionId', 'no such mission');
    return Ruleset(
      mission: m,
      map: maps[m.mapId]!,
      officers: officers.values.toList(),
      commanders: commanders.values.toList(),
      cards: cards.values.toList(),
    );
  }
}
