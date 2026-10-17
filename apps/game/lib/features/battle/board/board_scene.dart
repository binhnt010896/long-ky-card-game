import 'dart:math' as math;
import 'dart:ui';

import 'package:lk_rules/lk_rules.dart';

import 'board_layout.dart';

enum SelectionKind { node, officer, army }

/// What the player has selected on the board.
final class Selection {
  const Selection(this.kind, this.id);

  final SelectionKind kind;
  final String id;

  @override
  bool operator ==(Object other) => other is Selection && other.kind == kind && other.id == id;

  @override
  int get hashCode => Object.hash(kind, id);

  @override
  String toString() => 'Selection(${kind.name} $id)';
}

final class NodeView {
  const NodeView({
    required this.id,
    required this.center,
    required this.radius,
    required this.name,
    required this.terrain,
    required this.controller,
    required this.evacuated,
    required this.isCapital,
    required this.isBorder,
    required this.labelCenter,
  });

  final String id;
  final Offset center;
  final double radius;
  final String name;
  final Terrain terrain;
  final Side controller;
  final bool evacuated;
  final bool isCapital;
  final bool isBorder;

  /// Where the name label is centred.
  final Offset labelCenter;
}

final class EdgeView {
  const EdgeView({required this.key, required this.a, required this.b, required this.kind, required this.ambushed});

  final String key;
  final Offset a;
  final Offset b;
  final EdgeKind kind;

  /// An ambush is set on this edge (shown to the player only).
  final bool ambushed;
}

enum TokenKind { officer, army }

final class TokenView {
  const TokenView({
    required this.id,
    required this.kind,
    required this.nodeId,
    required this.center,
    required this.radius,
    required this.initials,
    required this.troops,
    required this.isKing,
    this.artPath,
  });

  final String id;
  final TokenKind kind;
  final String nodeId;
  final Offset center;
  final double radius;

  /// Two letters of the person's name, never translated.
  final String initials;

  /// In units of 1,000 men.
  final int troops;
  final bool isKing;

  /// The portrait under `assets/images/`, when the content names one.
  final String? artPath;

  Selection get selection => Selection(kind == TokenKind.officer ? SelectionKind.officer : SelectionKind.army, id);
}

/// An arrow showing where a Yuan army will go.
final class ArrowView {
  const ArrowView({
    required this.armyId,
    required this.start,
    required this.end,
    required this.intent,
    required this.predicted,
  });

  final String armyId;
  final Offset start;
  final Offset end;
  final IntentKind intent;

  /// Next turn's intent, shown dashed.
  final bool predicted;
}

/// An intent that does not move the army (hold, or forage in place),
/// shown as a badge on its token.
final class BadgeView {
  const BadgeView({required this.armyId, required this.center, required this.intent, required this.predicted});

  final String armyId;
  final Offset center;
  final IntentKind intent;
  final bool predicted;
}

/// Everything the board draws for one game state at one viewport size.
final class BoardScene {
  const BoardScene({
    required this.layout,
    required this.nodes,
    required this.edges,
    required this.tokens,
    required this.arrows,
    required this.badges,
    required this.selection,
    this.mapImagePath,
  });

  final BoardLayout layout;
  final List<NodeView> nodes;
  final List<EdgeView> edges;
  final List<TokenView> tokens;
  final List<ArrowView> arrows;
  final List<BadgeView> badges;
  final Selection? selection;

  /// The painted map under `assets/images/`, when the content names one.
  final String? mapImagePath;

  NodeView node(String id) => nodes.firstWhere((n) => n.id == id);

  Iterable<TokenView> tokensOf(TokenKind kind) => tokens.where((t) => t.kind == kind);

  /// Centre of the selected item, or null.
  Offset? get selectedCenter {
    final s = selection;
    if (s == null) return null;
    return switch (s.kind) {
      SelectionKind.node => nodes.where((n) => n.id == s.id).firstOrNull?.center,
      _ => tokens.where((t) => t.selection == s).firstOrNull?.center,
    };
  }

  /// The item at [point]: tokens first (they sit on top), then nodes.
  /// Hit areas are at least 48 logical pixels wide.
  Selection? hitTest(Offset point) {
    TokenView? bestToken;
    var bestTokenD = double.infinity;
    for (final t in tokens) {
      final d = (t.center - point).distance;
      if (d <= layout.tokenHitRadius() && d < bestTokenD) {
        bestToken = t;
        bestTokenD = d;
      }
    }
    // A token's whole disc wins over the node it fans out from.
    if (bestToken != null) return bestToken.selection;
    NodeView? bestNode;
    var bestNodeD = double.infinity;
    for (final n in nodes) {
      final d = (n.center - point).distance;
      if (d <= layout.nodeHitRadius() && d < bestNodeD) {
        bestNode = n;
        bestNodeD = d;
      }
    }
    return bestNode == null ? null : Selection(SelectionKind.node, bestNode.id);
  }

  /// Builds the scene for [state].
  factory BoardScene.build({
    required Ruleset ruleset,
    required GameState state,
    required Size size,
    required String languageCode,
    Selection? selection,
    double zoom = 1.0,
    Offset pan = Offset.zero,
  }) {
    final layout = BoardLayout(ruleset.map, size, zoom: zoom, pan: pan);
    final vi = languageCode == 'vi';
    String text(LocalizedText t) => vi ? t.vi : t.en;

    // Units standing at each node, in a stable order.
    final officersAt = <String, List<String>>{};
    for (final id in (state.officers.keys.toList()..sort())) {
      final o = state.officers[id]!;
      if (o.status == OfficerStatus.active) officersAt.putIfAbsent(o.nodeId, () => []).add(id);
    }
    final armiesAt = <String, List<String>>{};
    for (final id in (state.armies.keys.toList()..sort())) {
      final a = state.armies[id]!;
      if (a.status == ArmyStatus.active) armiesAt.putIfAbsent(a.nodeId, () => []).add(id);
    }

    final tokens = <TokenView>[];
    final tokenCenters = <String, Offset>{};
    // Where each node's fans point, so labels can keep clear of them.
    final fans = <String, List<({double angle, int count})>>{};
    for (final nodeId in {...officersAt.keys, ...armiesAt.keys}) {
      final officers = officersAt[nodeId] ?? const [];
      final armies = armiesAt[nodeId] ?? const [];
      final officerAngle =
          officers.isEmpty ? null : layout.fanDirection(nodeId, prefer: -math.pi / 2, count: officers.length);
      final armyAngle = armies.isEmpty
          ? null
          : layout.fanDirection(nodeId, prefer: math.pi / 2, count: armies.length, avoid: [?officerAngle]);
      final above = layout.tokenCenters(nodeId, count: officers.length, centerAngle: officerAngle ?? 0);
      final below = layout.tokenCenters(nodeId, count: armies.length, centerAngle: armyAngle ?? 0);
      fans[nodeId] = [
        if (officerAngle != null) (angle: officerAngle, count: officers.length),
        if (armyAngle != null) (angle: armyAngle, count: armies.length),
      ];
      for (var i = 0; i < officers.length; i++) {
        final def = ruleset.officers[officers[i]]!;
        tokens.add(TokenView(
          id: officers[i],
          kind: TokenKind.officer,
          nodeId: nodeId,
          center: above[i],
          radius: layout.tokenRadius,
          initials: initialsOf(def.name.vi),
          troops: state.officers[officers[i]]!.troops,
          isKing: def.isKing,
          artPath: def.portraitArt,
        ));
        tokenCenters[officers[i]] = above[i];
      }
      for (var i = 0; i < armies.length; i++) {
        final a = state.armies[armies[i]]!;
        final commander = ruleset.commanders[a.commanderId];
        tokens.add(TokenView(
          id: armies[i],
          kind: TokenKind.army,
          nodeId: nodeId,
          center: below[i],
          radius: layout.tokenRadius,
          initials: initialsOf(commander?.name.vi ?? armies[i]),
          troops: a.troops,
          isKing: false,
          artPath: commander?.portraitArt,
        ));
        tokenCenters[armies[i]] = below[i];
      }
    }

    final nodes = [
      for (final def in ruleset.map.nodes)
        NodeView(
          id: def.id,
          center: layout.nodeCenter(def.id),
          radius: layout.nodeRadius,
          name: text(def.name),
          terrain: def.terrain,
          controller: state.nodes[def.id]!.controller,
          evacuated: state.nodes[def.id]!.evacuated,
          isCapital: def.isCapital,
          isBorder: def.isBorder,
          labelCenter: layout.nodeCenter(def.id),
        ),
    ];

    final ambushed = {for (final a in state.ambushes) a.edge};
    final edges = [
      for (final e in ruleset.map.edges)
        EdgeView(
          key: e.key,
          a: layout.nodeCenter(e.from),
          b: layout.nodeCenter(e.to),
          kind: e.kind,
          ambushed: ambushed.contains(e.key),
        ),
    ];

    final arrows = <ArrowView>[];
    final badges = <BadgeView>[];
    for (final id in state.armies.keys.toList()..sort()) {
      final a = state.armies[id]!;
      if (a.status != ArmyStatus.active) continue;
      final intent = a.intent;
      if (intent != null) {
        if (intent.moveTo != null) {
          final r = layout.arrowBetween(a.nodeId, intent.moveTo!, lane: layout.nodeRadius * 0.35);
          arrows.add(ArrowView(armyId: id, start: r.start, end: r.end, intent: intent.kind, predicted: false));
        } else {
          badges.add(BadgeView(armyId: id, center: _badgeCenter(tokenCenters[id], layout), intent: intent.kind, predicted: false));
        }
      }
      // Predicted intents (borderWatch) start where the army will stand.
      final predicted = a.predictedIntent;
      if (predicted != null && predicted.moveTo != null) {
        final from = intent?.moveTo ?? a.nodeId;
        final r = layout.arrowBetween(from, predicted.moveTo!, lane: -layout.nodeRadius * 0.35);
        arrows.add(ArrowView(armyId: id, start: r.start, end: r.end, intent: predicted.kind, predicted: true));
      }
    }

    final labelled = _placeLabels(layout, nodes, tokens, fans);

    return BoardScene(
      layout: layout,
      nodes: labelled,
      edges: edges,
      tokens: tokens,
      arrows: arrows,
      badges: badges,
      selection: selection,
      mapImagePath: ruleset.map.imagePath,
    );
  }

  /// Puts each name label on the first free side of its node (below,
  /// above, right, left), clear of other medallions, tokens and labels.
  static List<NodeView> _placeLabels(
    BoardLayout layout,
    List<NodeView> nodes,
    List<TokenView> tokens,
    Map<String, List<({double angle, int count})>> fans,
  ) {
    final placed = <Rect>[];
    final out = <NodeView>[];
    final r = layout.nodeRadius;
    for (final n in nodes) {
      final size = layout.labelSize(n.name);
      final myFans = fans[n.id] ?? const [];
      // How far the token fans reach in a direction (0 if none points there).
      double reach(double angle) {
        var extent = r;
        for (final f in myFans) {
          if (BoardLayout.angleDistance(f.angle, angle) < math.pi * 0.45) {
            extent = math.max(extent, layout.tokenExtent(f.count));
          }
        }
        return extent;
      }

      final c = n.center;
      // Below first, then above, right, left, then the diagonals; each at
      // six distances, nearest first.
      final candidates = <Rect>[];
      for (final extra in [0.0, 0.7, 1.4, 2.1, 2.8, 3.5]) {
        for (final angle in [math.pi / 2, -math.pi / 2, 0.0, math.pi, math.pi / 4, 3 * math.pi / 4, -math.pi / 4, -3 * math.pi / 4]) {
          final dir = Offset(math.cos(angle), math.sin(angle));
          final dist = reach(angle) + 3 + extra * size.height;
          candidates.add(Rect.fromCenter(
            center: c + dir * dist + Offset(dir.dx * size.width / 2, dir.dy * size.height / 2),
            width: size.width,
            height: size.height,
          ));
        }
      }
      int collisions(Rect label) {
        var count = 0;
        for (final o in nodes) {
          if (o.id != n.id && _hitsCircle(label, o.center, o.radius + 2)) count++;
        }
        for (final t in tokens) {
          if (_hitsCircle(label, t.center, t.radius)) count++;
        }
        for (final p in placed) {
          if (p.overlaps(label)) count++;
        }
        if (label.left < 0 || label.right > layout.size.width || label.top < 0 || label.bottom > layout.size.height) count++;
        return count;
      }

      var best = candidates.first;
      var bestCount = collisions(best);
      for (final cand in candidates.skip(1)) {
        if (bestCount == 0) break;
        final k = collisions(cand);
        if (k < bestCount) {
          best = cand;
          bestCount = k;
        }
      }
      placed.add(best);
      out.add(NodeView(
        id: n.id,
        center: n.center,
        radius: n.radius,
        name: n.name,
        terrain: n.terrain,
        controller: n.controller,
        evacuated: n.evacuated,
        isCapital: n.isCapital,
        isBorder: n.isBorder,
        labelCenter: best.center,
      ));
    }
    return out;
  }

  static bool _hitsCircle(Rect rect, Offset center, double radius) {
    final nearest = Offset(center.dx.clamp(rect.left, rect.right), center.dy.clamp(rect.top, rect.bottom));
    return (nearest - center).distance < radius;
  }

  static Offset _badgeCenter(Offset? token, BoardLayout layout) =>
      (token ?? Offset.zero) + Offset(layout.tokenRadius * 0.8, -layout.tokenRadius * 0.8);
}

/// First letters of the last two words of [name]: "Trần Thái Tông" → "TT".
String initialsOf(String name) {
  final words = name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
  if (words.isEmpty) return '?';
  final take = words.length >= 2 ? words.sublist(words.length - 2) : words;
  return take.map((w) => String.fromCharCode(w.runes.first).toUpperCase()).join();
}
