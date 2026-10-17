import 'package:lk_rules/lk_rules.dart';

import 'progress.dart';

/// The order of the missions and what is open (build-spec section 6): the
/// missions of all chapters in one line, by chapter and then by their order
/// in it; mission N opens when N−1 is won, and the first one is always open.
///
/// Chapter 0 holds the training mission. It is always open and is not in the
/// chain: the first mission of chapter 1 does not wait for it, so players
/// who skip it (or who played before it existed) are not locked out.
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

  /// The chapter number of the training missions.
  static const int trainingChapter = 0;

  /// Whether [id] is a training mission.
  bool isTraining(String id) => mission(id)?.chapter == trainingChapter;

  /// The first training mission, if the content has one.
  MissionDef? get training => sequence.where((m) => m.chapter == trainingChapter).firstOrNull;

  /// Whether [id] can be played now.
  bool isUnlocked(Progress p, String id) {
    final i = sequence.indexWhere((m) => m.id == id);
    if (i < 0) return false;
    if (sequence[i].chapter == trainingChapter) return true;
    // The mission before it in the chain, leaving the training out of it.
    for (var j = i - 1; j >= 0; j--) {
      if (sequence[j].chapter != trainingChapter) return isWon(p, sequence[j].id);
    }
    return true;
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
