import 'dart:async';

import 'package:flame_audio/flame_audio.dart';

/// The three audio channels (build-spec section 6): music loops quietly,
/// voice carries narration and character lines, effects are short sounds.
enum AudioChannel { music, voice, effects }

/// Plays files for the [AudioService]. [FlameAudioBackend] does it with
/// `flame_audio`; tests use a recorder.
abstract interface class AudioBackend {
  /// Plays [path] (relative to `assets/audio/`) on [channel], replacing what
  /// that channel was playing.
  Future<void> play(AudioChannel channel, String path, {required double volume, bool loop = false});

  Future<void> stop(AudioChannel channel);

  /// Fires when a (non-looping) sound on a channel has played to its end.
  Stream<AudioChannel> get completions;

  Future<void> setVolume(AudioChannel channel, double volume);

  /// For when the app goes to the background and comes back.
  Future<void> pauseAll();

  Future<void> resumeAll();

  Future<void> dispose();
}

/// One `AudioPlayer` per channel, from the `flame_audio` package, which
/// reads assets from the bundle (never from the network).
final class FlameAudioBackend implements AudioBackend {
  FlameAudioBackend() {
    final setups = <Future<void>>[];
    for (final c in AudioChannel.values) {
      final player = AudioPlayer()..audioCache = FlameAudio.audioCache;
      _players[c] = player;
      // The channels play together, on top of each other: none may ask the
      // system for audio focus, or the voice would stop the music (on Android
      // a player that gains focus makes the others pause).
      setups.add(_mix(player));
    }
    _ready = Future.wait(setups);
  }

  /// The players are set up before anything plays: changing a player's audio
  /// context while it plays stops it.
  late final Future<void> _ready;

  static final AudioContext _mixing = AudioContextConfig(focus: AudioContextConfigFocus.mixWithOthers).build();

  static Future<void> _mix(AudioPlayer player) async {
    try {
      await player.setAudioContext(_mixing);
    } on Object {
      // No audio device or an unsupported platform: nothing to configure.
    }
  }

  final Map<AudioChannel, AudioPlayer> _players = {};

  @override
  Stream<AudioChannel> get completions => Stream.multi((controller) {
    final subs = [for (final e in _players.entries) e.value.onPlayerComplete.listen((_) => controller.add(e.key))];
    controller.onCancel = () {
      for (final s in subs) {
        s.cancel();
      }
    };
  }, isBroadcast: true);

  @override
  Future<void> play(AudioChannel channel, String path, {required double volume, bool loop = false}) async {
    await _ready;
    final p = _players[channel]!;
    await p.stop();
    await p.setReleaseMode(loop ? ReleaseMode.loop : ReleaseMode.release);
    await p.setVolume(volume);
    await p.play(AssetSource(path));
  }

  @override
  Future<void> stop(AudioChannel channel) => _players[channel]!.stop();

  @override
  Future<void> setVolume(AudioChannel channel, double volume) => _players[channel]!.setVolume(volume);

  @override
  Future<void> pauseAll() async {
    for (final p in _players.values) {
      if (p.state == PlayerState.playing) await p.pause();
    }
  }

  @override
  Future<void> resumeAll() async {
    for (final p in _players.values) {
      if (p.state == PlayerState.paused) await p.resume();
    }
  }

  @override
  Future<void> dispose() async {
    for (final p in _players.values) {
      await p.dispose();
    }
  }
}
