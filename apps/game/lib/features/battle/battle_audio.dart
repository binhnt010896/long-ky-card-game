import 'package:lk_rules/lk_rules.dart';

import '../../audio/audio_service.dart';
import 'battle_cubit.dart';
import 'turn_orders.dart';

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
      case FreePlayEnded():
        offer(e.playerWon ? 'victory' : 'defeat', 5);
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

  /// The battle's music starts, replacing the menu music, and plays throughout.
  Future<void> start() => audio.playMusic(AudioPaths.battleMusic);

  /// Which end-of-turn shout comes next: the two recordings take turns.
  int _endTurns = 0;

  /// Sounds for the step that just happened.
  void onStep(BattleViewState view) {
    final events = view.lastEvents;
    final effect = effectFor(events);
    if (effect != null) audio.playEffect(effect);
    final voice = _voiceFor(events, view.previous);
    if (voice != null) audio.playVoice(voice);
  }

  /// The voice line of the step, if it has one: how the mission or free play
  /// ended, an officer's skill, or the king's shout when the turn is resolved.
  String? _voiceFor(List<GameEvent> events, GameState? previous) {
    bool? won;
    for (final e in events) {
      if (e is MissionEnded) won = e.outcome == Outcome.won;
      if (e is FreePlayEnded) won = e.playerWon;
    }
    if (won != null) {
      if (!won) return audio.hasVoice(AudioPaths.defeated) ? AudioPaths.defeated : null;
      if (audio.hasVoice(AudioPaths.victorious)) return AudioPaths.victorious;
      // Without the victory line, the debrief is read out after a win.
      return events.any((e) => e is MissionEnded) ? AudioPaths.debrief(missionId) : null;
    }
    for (final e in events) {
      if (e is SkillUsed) {
        final id = AudioPaths.skillVoice(e.officerId);
        if (audio.hasVoice(id)) return id;
      }
    }
    // The shout is for a turn in which someone advances or attacks.
    final resolving = events.any((e) => e is PhaseChanged && e.phase == Phase.resolution);
    if (resolving && previous != null && turnAdvances(previous)) {
      _endTurns++;
      final id = _endTurns.isOdd ? AudioPaths.endTurn : AudioPaths.endTurnAlt;
      if (audio.hasVoice(id)) return id;
    }
    return null;
  }

  /// Leaving the battle: the narration stops and the menu music comes back.
  Future<void> stop() async {
    await audio.stopVoice();
    await audio.playMusic(AudioPaths.menuMusic);
  }
}
