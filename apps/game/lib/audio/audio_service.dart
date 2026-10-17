import 'dart:async';

import 'package:flutter/services.dart';

import '../data/progress.dart';
import 'audio_backend.dart';

/// Where each kind of sound lives under `assets/audio/`, by content id
/// (build-spec section 6): `voice/ch1_m2_briefing.mp3`.
abstract final class AudioPaths {
  static String voice(String id) => 'voice/$id.mp3';
  static String music(String id) => 'music/$id.mp3';
  static String effect(String id) => 'effects/$id.mp3';

  /// The narration ids of a mission, as the content validator expects them.
  static String briefing(String missionId) => '${missionId}_briefing';
  static String debrief(String missionId) => '${missionId}_debrief';

  /// Voice lines of the battle (`assets/audio/voice/`).
  static const String victorious = 'victorious';
  static const String defeated = 'defeated';

  /// The king's shout when the turn is resolved; the two take turns.
  static const String endTurn = 'end-turn';
  static const String endTurnAlt = 'end-turn-2';

  /// The line an officer says when they use their skill.
  static String skillVoice(String officerId) => '$officerId-skill';

  /// The music of the menus (from the moment the game opens) and of a battle
  /// (from the moment it starts until it is left).
  static const String menuMusic = 'bg1';
  static const String battleMusic = 'bg-battle';
}

/// Whether the app ships the audio file `assets/audio/[path]`.
typedef AssetCheck = bool Function(String path);

/// Plays narration, music and effects on three channels, at the volumes in
/// Settings. A file that is not there is skipped without a sound or an error:
/// code ships before audio does, and the content validator (not the player)
/// is what fails a release that lacks it.
class AudioService {
  AudioService({required this.backend, required this.hasAsset, this.settings = const GameSettings()}) {
    _done = backend.completions.listen((c) {
      if (c == AudioChannel.voice) _setVoice(null);
    });
  }

  /// A service that plays nothing: for tests and for builds without sound.
  AudioService.silent() : this(backend: _SilentBackend(), hasAsset: _none);

  /// Reads the bundle's asset list once; the real service in the app.
  static Future<AudioService> fromBundle(AudioBackend backend, AssetBundle bundle, GameSettings settings) async {
    final manifest = await AssetManifest.loadFromAssetBundle(bundle);
    final assets = manifest.listAssets().toSet();
    return AudioService(backend: backend, hasAsset: (p) => assets.contains('assets/audio/$p'), settings: settings);
  }

  static bool _none(String path) => false;

  final AudioBackend backend;
  final AssetCheck hasAsset;

  /// The settings in force: the volumes come from here.
  GameSettings settings;
  StreamSubscription<AudioChannel>? _done;

  String? _music;
  String? _voice;

  /// The narration playing now, for the "listening" state of a button.
  final StreamController<String?> _voiceChanges = StreamController<String?>.broadcast();
  Stream<String?> get voiceChanges => _voiceChanges.stream;
  String? get playingVoice => _voice;
  String? get playingMusic => _music;

  /// The music is a bed under the voices, never over them: it plays at this
  /// share of its Settings volume, and at [musicDuck] of that while a voice
  /// line is playing.
  static const double musicGain = 0.45;
  static const double musicDuck = 0.5;

  double volumeOf(AudioChannel c) => switch (c) {
    AudioChannel.music => settings.musicVolume * musicGain * (_voice != null ? musicDuck : 1.0),
    AudioChannel.voice => settings.voiceVolume,
    AudioChannel.effects => settings.effectsVolume,
  };

  /// Takes the volumes of [settings], at once, for what is playing too.
  void applySettings(GameSettings settings) {
    this.settings = settings;
    for (final c in AudioChannel.values) {
      unawaited(_safe(() => backend.setVolume(c, volumeOf(c))));
    }
  }

  /// Whether the narration or character line [id] has a file to play.
  bool hasVoice(String id) => hasAsset(AudioPaths.voice(id));

  /// Plays the narration or character line [id]; returns whether there was
  /// a file to play.
  Future<bool> playVoice(String id) async {
    final path = AudioPaths.voice(id);
    if (!hasAsset(path)) return false;
    _setVoice(id);
    return _safe(() => backend.play(AudioChannel.voice, path, volume: volumeOf(AudioChannel.voice)));
  }

  Future<void> stopVoice() async {
    if (_voice == null) return;
    _setVoice(null);
    await _safe(() => backend.stop(AudioChannel.voice));
  }

  /// Starts looping the music [id], unless it is already playing.
  Future<bool> playMusic(String id) async {
    if (_music == id) return true;
    final path = AudioPaths.music(id);
    if (!hasAsset(path)) return false;
    _music = id;
    return _safe(() => backend.play(AudioChannel.music, path, volume: volumeOf(AudioChannel.music), loop: true));
  }

  Future<void> stopMusic() async {
    if (_music == null) return;
    _music = null;
    await _safe(() => backend.stop(AudioChannel.music));
  }

  Future<bool> playEffect(String id) async {
    final path = AudioPaths.effect(id);
    if (!hasAsset(path)) return false;
    return _safe(() => backend.play(AudioChannel.effects, path, volume: volumeOf(AudioChannel.effects)));
  }

  Future<void> pause() => _safe(backend.pauseAll);

  Future<void> resume() => _safe(backend.resumeAll);

  Future<void> dispose() async {
    await _done?.cancel();
    await _voiceChanges.close();
    await _safe(backend.dispose);
  }

  void _setVoice(String? id) {
    final wasTalking = _voice != null;
    _voice = id;
    if (!_voiceChanges.isClosed) _voiceChanges.add(id);
    // The music steps back while someone speaks, and comes back after.
    if (wasTalking != (id != null) && _music != null) {
      unawaited(_safe(() => backend.setVolume(AudioChannel.music, volumeOf(AudioChannel.music))));
    }
  }

  /// A sound that cannot play (no audio device, a damaged file) is never a
  /// reason to stop the game.
  Future<bool> _safe(Future<void> Function() job) async {
    try {
      await job();
      return true;
    } on Object {
      return false;
    }
  }
}

final class _SilentBackend implements AudioBackend {
  @override
  Stream<AudioChannel> get completions => const Stream.empty();

  @override
  Future<void> play(AudioChannel channel, String path, {required double volume, bool loop = false}) async {}

  @override
  Future<void> stop(AudioChannel channel) async {}

  @override
  Future<void> setVolume(AudioChannel channel, double volume) async {}

  @override
  Future<void> pauseAll() async {}

  @override
  Future<void> resumeAll() async {}

  @override
  Future<void> dispose() async {}
}
