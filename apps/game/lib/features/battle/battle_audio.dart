import 'package:lk_rules/lk_rules.dart';

import '../../audio/audio_service.dart';
import 'battle_cubit.dart';

/// The effect to play for what happened in one step, or null for none.
/// Effects share a channel, so one step plays only its most important sound
/// (build-spec section 6, "Audio"): the end of the mission, a battle, an
/// officer lost, a card, an evacuation.
String? effectFor(Iterable<GameEvent> events) {
  String? best;
  var bestRank = -1;
  void offer(String id, int rank) {
    if (rank > bestRank) {
      best = id;
      bestRank = rank;
    }
  }

  for (final e in events) {
    switch (e) {
      case MissionEnded():
        offer(e.outcome == Outcome.won ? 'victory' : 'defeat', 5);
      case BattleResolved():
        offer('battle', 4);
      case OfficerCaptured():
        offer('captured', 3);
      case OfficerDefected():
        offer('defect', 3);
      case CardPlayed():
        offer('card', 2);
      case NodeEvacuated():
        offer('evacuate', 1);
      default:
        break;
    }
  }
  return best;
}

/// Plays the battle's music, its effects and the debrief narration. Safe to
/// use with a silent [AudioService]: nothing plays and nothing fails.
class BattleAudio {
  BattleAudio(this.audio, {required this.missionId, required this.chapter});

  final AudioService audio;
  final String missionId;
  final int chapter;

  /// The chapter's music starts (and keeps going if it already plays).
  Future<void> start() => audio.playMusic(AudioPaths.chapterMusic(chapter));

  /// Sounds for the step that just happened.
  void onStep(BattleViewState view) {
    final effect = effectFor(view.lastEvents);
    if (effect != null) audio.playEffect(effect);
    for (final e in view.lastEvents) {
      // The debrief is read out after a win; a loss has no debrief to hear.
      if (e is MissionEnded && e.outcome == Outcome.won) audio.playVoice(AudioPaths.debrief(missionId));
    }
  }

  /// Leaving the battle: the narration and the music stop.
  Future<void> stop() async {
    await audio.stopVoice();
    await audio.stopMusic();
  }
}
