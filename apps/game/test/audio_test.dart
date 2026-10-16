import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lk_content/io.dart';
import 'package:lk_content/lk_content.dart';
import 'package:lk_rules/lk_rules.dart';
import 'package:long_ky_game/app/audio_scope.dart';
import 'package:long_ky_game/audio/audio_backend.dart';
import 'package:long_ky_game/audio/audio_service.dart';
import 'package:long_ky_game/data/progress.dart';
import 'package:long_ky_game/data/progress_repository.dart';
import 'package:long_ky_game/data/progress_store.dart';
import 'package:long_ky_game/features/battle/battle_audio.dart';
import 'package:long_ky_game/features/battle/battle_cubit.dart';
import 'package:long_ky_game/features/settings/progress_cubit.dart';

import 'battle/overlay_support.dart' show winM2;

import 'battle/board_support.dart' show ruleset;

/// Records what the service asks of the backend.
class RecordingBackend implements AudioBackend {
  final List<String> log = [];
  final List<({AudioChannel channel, String path, double volume, bool loop})> played = [];
  final Map<AudioChannel, double> volumes = {};
  final StreamController<AudioChannel> _done = StreamController<AudioChannel>.broadcast();
  bool failing = false;

  void finish(AudioChannel c) => _done.add(c);

  @override
  Stream<AudioChannel> get completions => _done.stream;

  @override
  Future<void> play(AudioChannel channel, String path, {required double volume, bool loop = false}) async {
    if (failing) throw StateError('no audio device');
    log.add('play ${channel.name} $path');
    played.add((channel: channel, path: path, volume: volume, loop: loop));
  }

  @override
  Future<void> stop(AudioChannel channel) async => log.add('stop ${channel.name}');

  @override
  Future<void> setVolume(AudioChannel channel, double volume) async {
    volumes[channel] = volume;
    log.add('volume ${channel.name} $volume');
  }

  @override
  Future<void> pauseAll() async => log.add('pause');

  @override
  Future<void> resumeAll() async => log.add('resume');

  @override
  Future<void> dispose() async => log.add('dispose');
}

AudioService serviceWith(RecordingBackend b, Set<String> assets, {GameSettings settings = const GameSettings()}) =>
    AudioService(backend: b, hasAsset: assets.contains, settings: settings);

void main() {
  group('AudioService', () {
    test('plays voice, music and effects from the id-named paths, on their own channels', () async {
      final b = RecordingBackend();
      final a = serviceWith(b, {'voice/ch1_m2_briefing.mp3', 'music/chapter1.mp3', 'effects/battle.mp3'});
      expect(await a.playVoice('ch1_m2_briefing'), isTrue);
      expect(await a.playMusic('chapter1'), isTrue);
      expect(await a.playEffect('battle'), isTrue);
      expect(b.log, [
        'play voice voice/ch1_m2_briefing.mp3',
        'play music music/chapter1.mp3',
        'play effects effects/battle.mp3',
      ]);
      expect(b.played[1].loop, isTrue, reason: 'music loops');
      expect(b.played[0].loop, isFalse);
    });

    test('a file that is not there is skipped without a sound or an error', () async {
      final b = RecordingBackend();
      final a = serviceWith(b, {});
      expect(await a.playVoice('ch1_m2_briefing'), isFalse);
      expect(await a.playMusic('chapter1'), isFalse);
      expect(await a.playEffect('battle'), isFalse);
      expect(b.log, isEmpty);
      expect(a.playingVoice, isNull);
      expect(a.playingMusic, isNull);
    });

    test('plays at the volume of its channel in Settings, and follows changes at once', () async {
      final b = RecordingBackend();
      final a = serviceWith(b, {
        'voice/x.mp3',
        'music/m.mp3',
        'effects/e.mp3',
      }, settings: const GameSettings(musicVolume: 0.2, voiceVolume: 0.9, effectsVolume: 0.4));
      await a.playVoice('x');
      await a.playMusic('m');
      await a.playEffect('e');
      expect([for (final p in b.played) p.volume], [0.9, 0.2, 0.4]);

      a.applySettings(const GameSettings(musicVolume: 0.0, voiceVolume: 0.5, effectsVolume: 1.0));
      await Future<void>.delayed(Duration.zero);
      expect(b.volumes, {AudioChannel.music: 0.0, AudioChannel.voice: 0.5, AudioChannel.effects: 1.0});
      await a.playEffect('e');
      expect(b.played.last.volume, 1.0);
    });

    test('the same music is not restarted; other music replaces it; stopping works', () async {
      final b = RecordingBackend();
      final a = serviceWith(b, {'music/one.mp3', 'music/two.mp3'});
      await a.playMusic('one');
      await a.playMusic('one');
      expect(b.played, hasLength(1));
      await a.playMusic('two');
      expect(b.played.last.path, 'music/two.mp3');
      await a.stopMusic();
      expect(b.log.last, 'stop music');
      await a.stopMusic();
      expect(b.log.where((e) => e == 'stop music'), hasLength(1), reason: 'nothing left to stop');
    });

    test('knows which narration is playing, until it ends or is stopped', () async {
      final b = RecordingBackend();
      final a = serviceWith(b, {'voice/one.mp3', 'voice/two.mp3'});
      final seen = <String?>[];
      a.voiceChanges.listen(seen.add);
      await a.playVoice('one');
      expect(a.playingVoice, 'one');
      b.finish(AudioChannel.voice);
      await Future<void>.delayed(Duration.zero);
      expect(a.playingVoice, isNull, reason: 'it played to its end');
      await a.playVoice('two');
      await a.stopVoice();
      expect(a.playingVoice, isNull);
      await Future<void>.delayed(Duration.zero);
      expect(seen, ['one', null, 'two', null]);
      b.finish(AudioChannel.music); // other channels do not touch the voice state
    });

    test('a backend that fails never fails the game', () async {
      final b = RecordingBackend()..failing = true;
      final a = serviceWith(b, {'voice/x.mp3', 'music/m.mp3', 'effects/e.mp3'});
      expect(await a.playVoice('x'), isFalse);
      expect(await a.playMusic('m'), isFalse);
      expect(await a.playEffect('e'), isFalse);
    });

    test('pause and resume reach the backend; dispose closes it', () async {
      final b = RecordingBackend();
      final a = serviceWith(b, {});
      await a.pause();
      await a.resume();
      await a.dispose();
      expect(b.log, ['pause', 'resume', 'dispose']);
    });

    test('the silent service plays nothing and says so', () async {
      final a = AudioService.silent();
      expect(await a.playVoice('x'), isFalse);
      expect(await a.playMusic('m'), isFalse);
      await a.stopVoice();
      await a.dispose();
    });
  });

  group('audio ids match the content validator', () {
    test('the narration of every mission is where the validator looks for it', () {
      final files = readContentDir(findContentDir()!);
      final bundle = loadContent(files);
      // Every briefing and debrief file, named as the player will look for it.
      final shipped = {
        for (final id in bundle.missions.keys) ...[
          'audio/${AudioPaths.voice(AudioPaths.briefing(id))}',
          'audio/${AudioPaths.voice(AudioPaths.debrief(id))}',
        ],
      };
      final r = validateContent(files, assetPaths: shipped, release: true);
      final audioErrors = [
        for (final i in r.issues)
          if (i.message.contains('audio file')) i.message,
      ];
      expect(audioErrors, isEmpty, reason: 'the player and the validator must agree on the file names');
      // And with none shipped, it is exactly these files that are missing.
      final none = validateContent(files, assetPaths: <String>{}, release: false);
      final missing = {
        for (final i in none.issues)
          if (i.message.contains('audio file')) i.message.split('assets/').last,
      };
      expect(missing, shipped);
    });

    test('the audio folders are declared as assets, so shipped files are found', () {
      final pubspec = File('pubspec.yaml').readAsStringSync();
      for (final d in ['voice', 'music', 'effects']) {
        expect(pubspec, contains('- assets/audio/$d/'));
        expect(Directory('assets/audio/$d').existsSync(), isTrue);
      }
    });
  });

  group('effectFor', () {
    BattleReport report() => const BattleReport(
      kind: BattleKind.field,
      nodeId: 'n',
      officerIds: [],
      armyIds: [],
      daiVietPower: 1,
      yuanPower: 1,
      winner: Side.daiViet,
      officerLosses: {},
      armyLosses: {},
    );

    test('nothing for steps with nothing worth a sound', () {
      expect(effectFor(const []), isNull);
      expect(effectFor(const [TurnStarted(2), PhaseChanged(Phase.orders), OrderSet('x', null)]), isNull);
    });

    test('one sound per step: the most important thing that happened', () {
      expect(effectFor(const [CardPlayed('c')]), 'card');
      expect(effectFor(const [NodeEvacuated('n', 3)]), 'evacuate');
      expect(effectFor([BattleResolved(report())]), 'battle');
      expect(effectFor(const [OfficerDefected('x')]), 'defect');
      expect(effectFor(const [OfficerCaptured('x', 'n')]), 'captured');
      expect(effectFor([const CardPlayed('c'), BattleResolved(report())]), 'battle');
      expect(effectFor([BattleResolved(report()), const OfficerCaptured('x', 'n')]), 'battle');
      expect(effectFor([BattleResolved(report()), const MissionEnded(Outcome.won)]), 'victory');
      expect(effectFor(const [MissionEnded(Outcome.lost)]), 'defeat');
    });
  });

  group('BattleAudio', () {
    final rules = ruleset('ch1_m2');
    final assets = {
      'music/chapter1.mp3',
      'effects/card.mp3',
      'effects/battle.mp3',
      'effects/victory.mp3',
      'voice/ch1_m2_debrief.mp3',
    };

    test('starts the chapter music, plays an effect per step, reads the debrief after a win, then stops', () async {
      final b = RecordingBackend();
      final audio = serviceWith(b, assets);
      final sounds = BattleAudio(audio, missionId: 'ch1_m2', chapter: rules.mission.chapter);
      final cubit = BattleCubit(GameEngine(rules), seed: 1);
      addTearDown(cubit.close);
      final sub = cubit.stream.listen(sounds.onStep);
      addTearDown(sub.cancel);

      await sounds.start();
      expect(b.log, ['play music music/chapter1.mp3']);

      cubit.playCard('vuon-khong-nha-trong', target: 'binh-le-nguyen');
      await Future<void>.delayed(Duration.zero);
      expect(b.log.last, 'play effects effects/card.mp3');

      winM2(cubit);
      await Future<void>.delayed(Duration.zero);
      expect(b.log, contains('play effects effects/victory.mp3'));
      expect(b.log, contains('play voice voice/ch1_m2_debrief.mp3'));

      await sounds.stop();
      expect(b.log.sublist(b.log.length - 2), ['stop voice', 'stop music']);
    });

    test('with no audio files at all, the whole battle is silent and nothing fails', () async {
      final b = RecordingBackend();
      final sounds = BattleAudio(serviceWith(b, {}), missionId: 'ch1_m2', chapter: 1);
      final cubit = BattleCubit(GameEngine(rules), seed: 1);
      addTearDown(cubit.close);
      final sub = cubit.stream.listen(sounds.onStep);
      addTearDown(sub.cancel);
      await sounds.start();
      cubit.playCard('vuon-khong-nha-trong', target: 'binh-le-nguyen');
      cubit.endPhase();
      await Future<void>.delayed(Duration.zero);
      expect(b.played, isEmpty);
    });

    test('a lost mission has no debrief to hear', () async {
      final b = RecordingBackend();
      final sounds = BattleAudio(serviceWith(b, assets), missionId: 'ch1_m2', chapter: 1);
      sounds.onStep(
        BattleViewState(state: GameEngine(rules).newGame(1).state, lastEvents: const [MissionEnded(Outcome.lost)]),
      );
      await Future<void>.delayed(Duration.zero);
      expect(b.played.where((p) => p.channel == AudioChannel.voice), isEmpty);
    });
  });

  group('AudioScope', () {
    testWidgets('Settings volumes reach the audio as they change; the background pauses it', (tester) async {
      final b = RecordingBackend();
      final audio = serviceWith(b, {});
      final progress = ProgressCubit(ProgressRepository(MemoryProgressStore()), const Progress());
      await tester.pumpWidget(
        BlocProvider.value(
          value: progress,
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: AudioScope(audio: audio, child: const SizedBox()),
          ),
        ),
      );
      await tester.pump();
      expect(
        b.volumes[AudioChannel.music],
        const GameSettings().musicVolume,
        reason: 'the first settings apply at once',
      );

      await progress.updateSettings((s) => s.copyWith(musicVolume: 0.1, voiceVolume: 0.3));
      await tester.pump();
      expect(b.volumes[AudioChannel.music], 0.1);
      expect(b.volumes[AudioChannel.voice], 0.3);

      final before = b.log.length;
      await progress.setLanguage('en'); // not a volume: nothing to tell the audio
      await tester.pump();
      expect(b.log.length, before);

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump();
      expect(b.log.last, 'pause');
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      expect(b.log.last, 'resume');
    });
  });
}
