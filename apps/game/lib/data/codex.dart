import 'package:lk_content/lk_content.dart';
import 'package:lk_rules/lk_rules.dart';

enum CodexKind { officer, enemy, card }

/// One page of the Codex: an officer, an enemy commander or a card. Everything
/// shown comes from the content files; nothing is written here.
final class CodexEntry {
  const CodexEntry._({
    required this.kind,
    required this.id,
    required this.name,
    required this.title,
    required this.longKyId,
    required this.isPerson,
    required this.art,
    required this.sourceRefs,
    this.officer,
    this.commander,
    this.card,
  });

  factory CodexEntry.officer(OfficerDef o) => CodexEntry._(
    kind: CodexKind.officer,
    id: o.id,
    name: o.name,
    title: o.title,
    longKyId: o.longKyPersonId,
    isPerson: true,
    art: o.portraitArt,
    sourceRefs: o.sourceRefs,
    officer: o,
  );

  factory CodexEntry.commander(CommanderDef c) => CodexEntry._(
    kind: CodexKind.enemy,
    id: c.id,
    name: c.name,
    title: c.title,
    longKyId: c.longKyPersonId,
    isPerson: true,
    art: c.portraitArt,
    sourceRefs: c.sourceRefs,
    commander: c,
  );

  factory CodexEntry.card(CardDef c) => CodexEntry._(
    kind: CodexKind.card,
    id: c.id,
    name: c.name,
    title: null,
    longKyId: c.longKyEventId,
    isPerson: false,
    art: c.art,
    sourceRefs: c.sourceRefs,
    card: c,
  );

  final CodexKind kind;
  final String id;
  final LocalizedText name;
  final LocalizedText? title;

  /// The id in Long Ký (`longKyPersonId` or `longKyEventId`); null when the
  /// content names none. Unlock codes and "Read more" go by it.
  final String? longKyId;

  /// A person (otherwise an event) in Long Ký.
  final bool isPerson;
  final String? art;
  final List<String> sourceRefs;
  final OfficerDef? officer;
  final CommanderDef? commander;
  final CardDef? card;
}

/// The pages of the Codex, in the order of the content files.
final class Codex {
  Codex(ContentBundle content)
    : entries = [
        for (final o in content.officers.values) CodexEntry.officer(o),
        for (final c in content.commanders.values) CodexEntry.commander(c),
        for (final c in content.cards.values) CodexEntry.card(c),
      ];

  final List<CodexEntry> entries;

  List<CodexEntry> ofKind(CodexKind kind) => [
    for (final e in entries)
      if (e.kind == kind) e,
  ];

  /// The pages that unlock with the Long Ký id [id]: one person, or every
  /// card that belongs to one event.
  List<CodexEntry> entriesOf(String id) => [
    for (final e in entries)
      if (e.longKyId == id) e,
  ];

  /// Every Long Ký id a code can unlock here.
  List<String> get unlockableIds => {
    for (final e in entries)
      if (e.longKyId != null) e.longKyId!,
  }.toList();
}
