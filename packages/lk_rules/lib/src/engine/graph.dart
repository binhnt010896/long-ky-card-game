import 'dart:collection';

import '../model/defs.dart';
import '../model/enums.dart';

/// Graph queries on a [MapDef]. Edges are undirected. Every tie is broken by
/// node id so that all paths are deterministic.
final class MapGraph {
  MapGraph(this.map)
      : nodes = {for (final n in map.nodes) n.id: n},
        edges = {for (final e in map.edges) e.key: e} {
    final ids = nodes.keys.toList()..sort();
    _ids = ids;
    for (final id in ids) {
      final nbrs = <String>[
        for (final e in map.edges)
          if (e.touches(id)) e.other(id),
      ]..sort();
      _neighbors[id] = List.unmodifiable(nbrs);
    }
    for (final id in ids) {
      _dist[id] = _bfs(id, (_) => true);
    }
  }

  final MapDef map;
  final Map<String, NodeDef> nodes;
  final Map<String, EdgeDef> edges;
  late final List<String> _ids;
  final Map<String, List<String>> _neighbors = {};
  final Map<String, Map<String, int>> _dist = {};

  /// Node ids in sorted order.
  List<String> get nodeIds => _ids;

  NodeDef node(String id) => nodes[id]!;

  bool hasNode(String id) => nodes.containsKey(id);

  /// Neighbours of [id], sorted by id.
  List<String> neighbors(String id) => _neighbors[id] ?? const [];

  bool adjacent(String a, String b) => edges.containsKey(edgeKey(a, b));

  EdgeDef? edge(String a, String b) => edges[edgeKey(a, b)];

  String? get capitalId {
    for (final n in map.nodes) {
      if (n.isCapital) return n.id;
    }
    return null;
  }

  /// Shortest number of edges from [a] to [b], or null if unreachable.
  int? distance(String a, String b) => _dist[a]?[b];

  /// The neighbour of [from] on a shortest path to [to] (ties by id), or
  /// null if [from] == [to] or [to] is unreachable.
  String? nextHop(String from, String to) {
    if (from == to) return null;
    final toDist = _dist[to];
    if (toDist == null || !toDist.containsKey(from)) return null;
    final want = toDist[from]! - 1;
    for (final n in neighbors(from)) {
      if (toDist[n] == want) return n;
    }
    return null;
  }

  /// Nodes an officer at [from] can move to with one order: one land edge,
  /// or a path of 1 to [maxRiverEdges] river edges (boats).
  Set<String> moveTargets(String from, {required int maxRiverEdges}) {
    final out = <String>{};
    for (final n in neighbors(from)) {
      if (edge(from, n)!.kind == EdgeKind.land) out.add(n);
    }
    final riverDist = _bfs(from, (e) => e.kind == EdgeKind.river);
    riverDist.forEach((node, d) {
      if (d >= 1 && d <= maxRiverEdges) out.add(node);
    });
    out.remove(from);
    return out;
  }

  /// Whether the graph is connected (validator rule 7).
  bool get isConnected => _ids.isEmpty || _dist[_ids.first]!.length == _ids.length;

  /// Nearest node from [from] (BFS distance, ties by id) satisfying [test],
  /// including [from] itself.
  String? nearest(String from, bool Function(String nodeId) test) {
    final d = _dist[from];
    if (d == null) return null;
    String? best;
    int? bestD;
    for (final id in _ids) {
      final dd = d[id];
      if (dd == null || !test(id)) continue;
      if (bestD == null || dd < bestD) {
        best = id;
        bestD = dd;
      }
    }
    return best;
  }

  Map<String, int> _bfs(String start, bool Function(EdgeDef) usable) {
    final dist = <String, int>{start: 0};
    final queue = Queue<String>()..add(start);
    while (queue.isNotEmpty) {
      final cur = queue.removeFirst();
      for (final n in neighbors(cur)) {
        if (dist.containsKey(n) || !usable(edge(cur, n)!)) continue;
        dist[n] = dist[cur]! + 1;
        queue.add(n);
      }
    }
    return dist;
  }
}
