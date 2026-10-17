import 'dart:math' as math;
import 'dart:ui';

import 'package:lk_rules/lk_rules.dart';

/// Geometry of the battle board for one viewport size. Pure: no Flame, no
/// state, so it is unit-tested directly.
///
/// Node positions are the 0–1 `x, y` of the map file placed on a map
/// rectangle with the painted map's aspect ratio (16:9 until the painted
/// map exists), centred in the viewport.
final class BoardLayout {
  BoardLayout(this.map, this.size, {this.zoom = 1.0, this.pan = Offset.zero})
      : mapRect = _zoomed(size, zoom, pan),
        _nodes = {for (final n in map.nodes) n.id: n} {
    unit = mapRect.height;
    // Medallions never overlap: no larger than 45% of the closest pair.
    var closest = double.infinity;
    for (var i = 0; i < map.nodes.length; i++) {
      for (var j = i + 1; j < map.nodes.length; j++) {
        closest = math.min(closest, (nodeCenter(map.nodes[i].id) - nodeCenter(map.nodes[j].id)).distance);
      }
    }
    nodeRadius = math.min((unit * 0.055).clamp(minNodeRadius, maxNodeRadius), closest * 0.45).toDouble();
    tokenRadius = math.max(nodeRadius * 0.72, minTokenRadius);
  }

  /// Placeholder until the painted Chapter 1 map is supplied.
  static const double mapAspect = 16 / 9;
  static const double padding = 12;
  static const double minNodeRadius = 12;
  static const double maxNodeRadius = 40;
  static const double minTokenRadius = 11;

  /// Zoom limits: 1 shows the whole map; 4 is close enough to tell apart
  /// every officer standing at one node.
  static const double minZoom = 1;
  static const double maxZoom = 4;

  /// How far past the map edge the view may be panned.
  static const double panMargin = 24;

  /// Touch targets are at least 48 logical pixels (build-spec section 6).
  static const double minTouchRadius = 24;

  /// Tokens per ring around a node.
  static const int tokensPerRing = 4;

  final MapDef map;
  final Size size;

  /// 1 shows the whole map; larger values magnify it about the viewport
  /// centre, then [pan] moves it.
  final double zoom;
  final Offset pan;
  final Rect mapRect;
  final Map<String, NodeDef> _nodes;
  late final double unit;
  late final double nodeRadius;
  late final double tokenRadius;

  /// Width of the viewport counts as compact below 900 logical pixels.
  bool get isCompact => size.width < 900;

  static Rect _zoomed(Size size, double zoom, Offset pan) {
    final base = _fit(size, mapAspect);
    return Rect.fromCenter(
      center: size.center(Offset.zero) + pan,
      width: base.width * zoom,
      height: base.height * zoom,
    );
  }

  /// The largest pan that keeps the map in view at [zoom]: none while the
  /// map fits, otherwise up to its edge plus [panMargin].
  static Offset clampPan(Size size, double zoom, Offset pan) {
    if (zoom <= minZoom) return Offset.zero;
    final base = _fit(size, mapAspect);
    double limit(double scaled, double view) => math.max(0.0, (scaled - view) / 2 + panMargin);
    final maxX = limit(base.width * zoom, size.width);
    final maxY = limit(base.height * zoom, size.height);
    return Offset(pan.dx.clamp(-maxX, maxX).toDouble(), pan.dy.clamp(-maxY, maxY).toDouble());
  }

  /// The pan that keeps the map point under [focal] still when the zoom
  /// goes from [zoom] to [newZoom].
  static Offset panForZoom(Size size, double zoom, Offset pan, double newZoom, Offset focal) {
    final c = size.center(Offset.zero);
    final d = focal - c;
    return d - (d - pan) * (newZoom / zoom);
  }

  static Rect _fit(Size size, double aspect) {
    final w = math.max(size.width - 2 * padding, 1);
    final h = math.max(size.height - 2 * padding, 1);
    var mw = w;
    var mh = mw / aspect;
    if (mh > h) {
      mh = h.toDouble();
      mw = mh * aspect;
    }
    return Rect.fromCenter(center: Offset(size.width / 2, size.height / 2), width: mw.toDouble(), height: mh.toDouble());
  }

  Offset nodeCenter(String nodeId) {
    final n = _nodes[nodeId]!;
    return Offset(mapRect.left + n.x * mapRect.width, mapRect.top + n.y * mapRect.height);
  }

  /// Angles (radians, screen coordinates: 0 = right, π/2 = down) from
  /// [nodeId] to each node it is joined to.
  List<double> edgeAngles(String nodeId) {
    final c = nodeCenter(nodeId);
    return [
      for (final e in map.edges)
        if (e.touches(nodeId))
          () {
            final d = nodeCenter(e.other(nodeId)) - c;
            return math.atan2(d.dy, d.dx);
          }(),
    ];
  }

  static double angleDistance(double a, double b) {
    var d = (a - b) % (2 * math.pi);
    if (d > math.pi) d = 2 * math.pi - d;
    return d.abs();
  }

  /// Angle between neighbouring tokens in the first ring around a node.
  double ringStep() {
    final gap = tokenRadius * 0.15;
    final radius = nodeRadius + tokenRadius + gap;
    return 2 * math.asin(math.min(1.0, (tokenRadius + gap / 2) / radius));
  }

  /// The direction in which to fan [count] tokens out from [nodeId]: the
  /// one whose whole arc stays furthest from the node's edges and from
  /// [avoid], leaning toward [prefer] (up for officers, down for armies)
  /// when several are equal.
  double fanDirection(String nodeId, {required double prefer, required int count, List<double> avoid = const []}) {
    final blocked = [...edgeAngles(nodeId), ...avoid];
    final halfSpan = math.min(count, tokensPerRing) * ringStep() / 2;
    var best = prefer;
    var bestScore = -double.infinity;
    for (var deg = 0; deg < 360; deg += 10) {
      final a = deg * math.pi / 180;
      var gap = math.pi;
      for (final b in blocked) {
        gap = math.min(gap, angleDistance(a, b) - halfSpan);
      }
      final score = math.min(gap, math.pi * 0.3) - 0.02 * angleDistance(a, prefer);
      if (score > bestScore) {
        bestScore = score;
        best = a;
      }
    }
    return best;
  }

  /// Centres of [count] tokens at [nodeId], fanned out around
  /// [centerAngle] in rings of [tokensPerRing].
  List<Offset> tokenCenters(String nodeId, {required int count, required double centerAngle}) {
    final c = nodeCenter(nodeId);
    final gap = tokenRadius * 0.15;
    final out = <Offset>[];
    for (var i = 0; i < count; i++) {
      final ring = i ~/ tokensPerRing;
      final inRing = math.min(tokensPerRing, count - ring * tokensPerRing);
      final radius = nodeRadius + tokenRadius + gap + ring * (2 * tokenRadius + gap);
      // Angle between neighbouring tokens so that they just do not overlap.
      final step = 2 * math.asin(math.min(1.0, (tokenRadius + gap / 2) / radius));
      final angle = centerAngle + (i % tokensPerRing - (inRing - 1) / 2) * step;
      out.add(c + Offset(math.cos(angle), math.sin(angle)) * radius);
    }
    return out;
  }

  /// Distance from the node centre to the outer edge of its token rings.
  double tokenExtent(int count) {
    if (count == 0) return 0;
    final rings = (count + tokensPerRing - 1) ~/ tokensPerRing;
    final gap = tokenRadius * 0.15;
    return nodeRadius + rings * (2 * tokenRadius + gap) + gap;
  }

  /// The arrow of an army moving from [from] to [to]: its start and end on
  /// the edges of the two medallions, shifted sideways by [lane] so that
  /// it does not hide the edge line.
  ({Offset start, Offset end}) arrowBetween(String from, String to, {double lane = 0}) {
    final a = nodeCenter(from);
    final b = nodeCenter(to);
    final d = b - a;
    final len = d.distance;
    if (len < 1e-6) return (start: a, end: b);
    final dir = d / len;
    final normal = Offset(-dir.dy, dir.dx) * lane;
    final margin = nodeRadius + 4;
    return (start: a + dir * margin + normal, end: b - dir * margin + normal);
  }

  /// Font size of node name labels.
  double get labelFontSize => (unit * 0.026).clamp(10.0, 14.0).toDouble();

  /// Rough size of a label before it is painted (Be Vietnam Pro averages
  /// about 0.56 em per letter in semibold).
  Size labelSize(String text) => Size(text.length * labelFontSize * 0.6 + 4, labelFontSize * 1.3);

  /// Hit radius of a node (never below the touch minimum).
  double nodeHitRadius() => math.max(nodeRadius, minTouchRadius);

  double tokenHitRadius() => math.max(tokenRadius, minTouchRadius);
}
