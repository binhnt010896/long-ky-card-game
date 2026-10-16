import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lk_rules/lk_rules.dart';
import 'package:long_ky_game/audio/audio_backend.dart';
import 'package:long_ky_game/audio/audio_service.dart';
import 'package:long_ky_game/features/battle/battle_cubit.dart';
import 'package:long_ky_game/features/battle/battle_page.dart';
import 'package:long_ky_game/features/battle/battle_screen.dart';
import 'package:long_ky_game/features/battle/labels.dart';
import 'package:long_ky_game/features/briefing/briefing_screen.dart';

import '../audio_test.dart' show RecordingBackend, serviceWith;
import 'overlay_support.dart';

/// The Briefing: narration with subtitles in both languages, the objectives,
/// the officers, and Start; at both layouts.
void main() {
  final rules = ruleset(mission);
  const voiceFiles = {'voice/ch1_m2_briefing.mp3', 'voice/ch1_m2_debrief.mp3', 'music/chapter1.mp3'};

  Future<void> pumpBriefing(
    WidgetTester tester,
    Size size,
    AudioService audio, {
    String lang = 'vi',
    double textScale = 1,
  }) async {
    setViewSize(tester, size);
    await tester.pumpWidget(
      appAround(
        BriefingScreen(key: UniqueKey(), missionId: mission, bundle: DiskAssetBundle(), audio: audio),
        lang: lang,
        textScale: textScale,
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
  }

  for (final (name, size, _) in layouts) {
    group('briefing ($name)', () {
      testWidgets('shows the title, the narration as subtitles, the objectives and the officers', (tester) async {
        final b = RecordingBackend();
        await pumpBriefing(tester, size, serviceWith(b, voiceFiles));
        final l = strings('vi');
        final namer = Namer(l, rules);
        expect(find.byKey(const Key('briefing-title')), findsOneWidget);
        expect(find.text(l.content(rules.mission.title)), findsOneWidget);
        expect(
          find.descendant(
            of: find.byKey(const Key('briefing-subtitles')),
            matching: find.text(l.content(rules.mission.briefing)),
          ),
          findsOneWidget,
        );
        final state = GameEngine(rules).newGame(1).state;
        for (var i = 0; i < rules.mission.win.length; i++) {
          expect(find.text(namer.objective(state, rules.mission.win[i])), findsOneWidget);
        }
        expect(rules.mission.win, isNotEmpty);
        for (final p in rules.mission.playerOfficers) {
          expect(find.textContaining(namer.officer(p.officerId), findRichText: true), findsWidgets);
        }
        expect(find.text(l.briefingObjectives), findsOneWidget);
        expect(find.text(l.briefingOfficers), findsOneWidget);
        expect(find.byKey(const Key('briefing-start')), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('the subtitles follow the chosen language; the voice is the Vietnamese one in both', (tester) async {
        for (final lang in ['vi', 'en']) {
          final b = RecordingBackend();
          await pumpBriefing(tester, size, serviceWith(b, voiceFiles), lang: lang);
          final l = strings(lang);
          expect(find.text(l.content(rules.mission.briefing)), findsOneWidget, reason: lang);
          expect(find.text(l.briefingStart), findsOneWidget, reason: lang);
          // One recording, whichever language the text is in.
          expect(b.log, contains('play voice voice/ch1_m2_briefing.mp3'), reason: lang);
        }
        expect(rules.mission.briefing.vi, isNot(rules.mission.briefing.en));
      });

      testWidgets('the narration and the chapter music start by themselves, at the volumes of Settings', (
        tester,
      ) async {
        final b = RecordingBackend();
        await pumpBriefing(tester, size, serviceWith(b, voiceFiles));
        expect(b.log, ['play music music/chapter1.mp3', 'play voice voice/ch1_m2_briefing.mp3']);
        expect(b.played.last.volume, 1.0);
        expect(b.played.first.volume, 0.6);
      });

      testWidgets('the voice button stops and replays it, and follows its end', (tester) async {
        final b = RecordingBackend();
        await pumpBriefing(tester, size, serviceWith(b, voiceFiles));
        final l = strings('vi');
        expect(find.text(l.briefingStopVoice), findsOneWidget, reason: 'it is playing');
        await tester.tap(find.byKey(const Key('briefing-voice')));
        await tester.pump();
        expect(b.log.last, 'stop voice');
        expect(find.text(l.briefingPlayVoice), findsOneWidget);
        await tester.tap(find.byKey(const Key('briefing-voice')));
        await tester.pump();
        expect(b.log.last, 'play voice voice/ch1_m2_briefing.mp3');
        expect(find.text(l.briefingStopVoice), findsOneWidget);
        b.finish(AudioChannel.voice);
        await tester.pump();
        await tester.pump();
        expect(find.text(l.briefingPlayVoice), findsOneWidget, reason: 'it played to its end');
      });

      testWidgets('without a voice file the subtitles are all there is: no button, no error', (tester) async {
        final b = RecordingBackend();
        await pumpBriefing(tester, size, serviceWith(b, {}));
        expect(find.byKey(const Key('briefing-voice')), findsNothing);
        expect(find.byKey(const Key('briefing-subtitles')), findsOneWidget);
        expect(find.text(strings('vi').content(rules.mission.briefing)), findsOneWidget);
        expect(b.log, isEmpty);
        expect(tester.takeException(), isNull);
      });

      testWidgets('Start stops the narration and opens the battle', (tester) async {
        final b = RecordingBackend();
        final audio = serviceWith(b, voiceFiles);
        await pumpBriefing(tester, size, audio);
        await tester.tap(find.byKey(const Key('briefing-start')));
        await tester.pump();
        await tester.pump(const Duration(seconds: 1)); // the page transition
        expect(b.log, contains('stop voice'));
        expect(find.byType(BattlePage), findsOneWidget);
        await settle(tester);
        expect(find.byType(BattleScreen), findsOneWidget);
        expect(find.byType(BriefingScreen), findsNothing, reason: 'the briefing is replaced, not stacked');
      });

      testWidgets('leaving stops the narration', (tester) async {
        final b = RecordingBackend();
        await pumpBriefing(tester, size, serviceWith(b, voiceFiles));
        await tester.pumpWidget(const SizedBox());
        expect(b.log, contains('stop voice'));
      });

      testWidgets('150% text and long subtitles scroll instead of overflowing; the buttons are 48 px', (tester) async {
        await pumpBriefing(tester, size, serviceWith(RecordingBackend(), voiceFiles), textScale: 1.5);
        expect(tester.takeException(), isNull);
        expect(tester.getSize(find.byKey(const Key('briefing-start'))).height, greaterThanOrEqualTo(48));
        expect(tester.getSize(find.byKey(const Key('briefing-voice'))).height, greaterThanOrEqualTo(48));
        final screen = Offset.zero & size;
        final start = tester.getRect(find.byKey(const Key('briefing-start')));
        expect(screen.contains(start.bottomRight - const Offset(1, 1)), isTrue, reason: 'Start stays on screen');
      });
    });
  }

  testWidgets('a mission that does not exist shows an error, not a crash', (tester) async {
    setViewSize(tester, regular);
    await tester.pumpWidget(
      appAround(BriefingScreen(missionId: 'nope', bundle: DiskAssetBundle(), audio: AudioService.silent())),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text(strings('vi').briefingLoadError), findsOneWidget);
  });

  testWidgets('the battle plays its music and effects, reads the debrief after a win and stops on leaving', (
    tester,
  ) async {
    final b = RecordingBackend();
    final audio = serviceWith(b, {...voiceFiles, 'effects/card.mp3', 'effects/victory.mp3'});
    setViewSize(tester, regular);
    await tester.pumpWidget(
      appAround(BattlePage(missionId: mission, seed: 1, bundle: DiskAssetBundle(), audio: audio)),
    );
    await tester.pump();
    await settle(tester);
    expect(b.log, contains('play music music/chapter1.mp3'));
    final cubit = tester.element(find.byType(BattleScreen)).read<BattleCubit>();
    cubit.playCard('vuon-khong-nha-trong', target: 'binh-le-nguyen');
    await tester.pump();
    expect(b.log, contains('play effects effects/card.mp3'));
    cubit.endPhase();
    for (final id in ['tran-thai-tong', 'le-phu-tran', 'tran-thu-do']) {
      cubit.setOrder(id, Order.move('thang-long'));
    }
    cubit.endPhase();
    await settle(tester);
    expect(b.log, contains('play voice voice/ch1_m2_debrief.mp3'));
    await tester.pumpWidget(const SizedBox());
    expect(b.log.sublist(b.log.length - 2), ['stop voice', 'stop music']);
  });
}
