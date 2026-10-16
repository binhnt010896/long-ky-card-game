import 'package:lk_rules/lk_rules.dart';

import '../../app/l10n/app_localizations.dart';
import 'board/board_layout.dart';

/// The battle screen switches layout at 900 logical pixels of width
/// (build-spec section 6). Same breakpoint as [BoardLayout.isCompact].
enum BattleLayoutMode {
  compact,
  regular;

  static BattleLayoutMode forWidth(double width) => width < 900 ? compact : regular;

  bool get isCompact => this == compact;
}

/// Text lookups shared by the battle overlays: UI strings from the ARB files,
/// content strings from the `{ vi, en }` objects for the current language.
extension BattleText on AppLocalizations {
  String content(LocalizedText t) => localeName == 'vi' ? t.vi : t.en;

  String phaseName(Phase p) => switch (p) {
    Phase.intel => phaseIntel,
    Phase.council => phaseCouncil,
    Phase.orders => phaseOrders,
    Phase.resolution => phaseResolution,
    Phase.upkeep => phaseUpkeep,
    Phase.ended => phaseEnded,
  };

  String pillarName(Pillar p) => switch (p) {
    Pillar.court => unityCourt,
    Pillar.clan => unityClan,
    Pillar.people => unityPeople,
  };

  String resourceName(Resource r) => switch (r) {
    Resource.rice => resourceRice,
    Resource.support => resourceSupport,
  };

  String terrainName(Terrain t) => switch (t) {
    Terrain.city => terrainCity,
    Terrain.plain => terrainPlain,
    Terrain.river => terrainRiver,
    Terrain.marsh => terrainMarsh,
    Terrain.hill => terrainHill,
  };

  String sideName(Side s) => switch (s) {
    Side.daiViet => sideDaiViet,
    Side.yuan => sideYuan,
    Side.none => sideNone,
  };

  String cardTypeName(CardType t) => switch (t) {
    CardType.stratagem => cardTypeStratagem,
    CardType.event => cardTypeEvent,
    CardType.intent => cardTypeIntent,
  };

  String intentName(IntentKind k) => switch (k) {
    IntentKind.hold => intentHold,
    IntentKind.advance => intentAdvance,
    IntentKind.assault => intentAssault,
    IntentKind.forage => intentForage,
    IntentKind.retreat => intentRetreat,
  };

  String orderKindName(OrderKind k) => switch (k) {
    OrderKind.hold => orderHold,
    OrderKind.move => orderMove,
    OrderKind.evacuate => orderEvacuate,
    OrderKind.raid => orderRaid,
    OrderKind.ambush => orderAmbush,
    OrderKind.rally => orderRally,
  };
}

/// Names of things in a [GameState], in the current language. One place so
/// the officer strip, inspector and log agree.
final class Namer {
  const Namer(this.l, this.ruleset);

  final AppLocalizations l;
  final Ruleset ruleset;

  String node(String id) {
    for (final n in ruleset.map.nodes) {
      if (n.id == id) return l.content(n.name);
    }
    return id;
  }

  String officer(String id) {
    final d = ruleset.officers[id];
    return d == null ? id : l.content(d.name);
  }

  /// "Quân của (commander)": armies have no names of their own.
  String army(GameState state, String id) {
    final commander = ruleset.commanders[state.armies[id]?.commanderId];
    return l.armyOf(commander == null ? id : l.content(commander.name));
  }

  String edge(String key) {
    for (final e in ruleset.map.edges) {
      if (e.key == key) return '${node(e.from)} – ${node(e.to)}';
    }
    return key;
  }

  /// A card or skill target: a node, officer, army or edge id.
  String target(GameState state, String id) {
    if (state.nodes.containsKey(id)) return node(id);
    if (state.officers.containsKey(id)) return officer(id);
    if (state.armies.containsKey(id)) return army(state, id);
    return edge(id);
  }

  String order(GameState state, Order order) {
    final kind = l.orderKindName(order.kind);
    final t = order.target;
    if (t == null) return kind;
    final targetName = order.kind == OrderKind.raid ? army(state, t) : target(state, t);
    return l.orderWithTarget(kind, targetName);
  }

  String intent(Intent intent) {
    final name = l.intentName(intent.kind);
    final to = intent.moveTo ?? intent.targetNodeId;
    return to == null ? name : l.intentToward(name, node(to));
  }
}
