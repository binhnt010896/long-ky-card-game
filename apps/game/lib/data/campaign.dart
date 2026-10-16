import 'package:lk_rules/lk_rules.dart';

import 'progress.dart';

/// The order of the missions and what is open (build-spec section 6): the
/// missions of all chapters in one line, by chapter and then by their order
/// in it; mission N opens when N−1 is won, and the first one is always open.
final class Campaign {
  Campaign(Iterable<MissionDef> missions)
    : sequence = (missions.toList()
        ..sort((a, b) => a.chapter != b.chapter ? a.chapter.compareTo(b.chapter) : a.order.compareTo(b.order)));

  /// Every mission, in play order.
  final List<MissionDef> sequence;

  List<int> get chapters => {for (final m in sequence) m.chapter}.toList();

  List<MissionDef> missionsOf(int chapter) => [
    for (final m in sequence)
      if (m.chapter == chapter) m,
  ];

  MissionDef? mission(String id) {
    for (final m in sequence) {
      if (m.id == id) return m;
    }
    return null;
  }

  /// The mission after [id], or null for the last one.
  MissionDef? next(String id) {
    final i = sequence.indexWhere((m) => m.id == id);
    return i < 0 || i + 1 >= sequence.length ? null : sequence[i + 1];
  }

  /// A mission is won once its first star (the "won" star) is earned.
  static bool isWon(Progress p, String id) => (p.stars[id] ?? const []).firstOrNull == true;

  /// Whether [id] can be played now.
  bool isUnlocked(Progress p, String id) {
    final i = sequence.indexWhere((m) => m.id == id);
    if (i < 0) return false;
    return i == 0 || isWon(p, sequence[i - 1].id);
  }

  /// A chapter is open once its first mission is.
  bool chapterUnlocked(Progress p, int chapter) {
    final first = missionsOf(chapter).firstOrNull;
    return first != null && isUnlocked(p, first.id);
  }

  /// Stars earned in [id], out of its star objectives.
  static int starsEarned(Progress p, String id) => (p.stars[id] ?? const []).where((s) => s).length;

  int starsInChapter(Progress p, int chapter) => missionsOf(chapter).fold(0, (n, m) => n + starsEarned(p, m.id));

  int starsPossible(int chapter) => missionsOf(chapter).fold(0, (n, m) => n + m.stars.length);

  int wonInChapter(Progress p, int chapter) => missionsOf(chapter).where((m) => isWon(p, m.id)).length;
}
