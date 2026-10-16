import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lk_content/lk_content.dart';
import 'package:lk_rules/lk_rules.dart' show SaveGame;
import 'package:long_ky_game/data/battle_save_repository.dart';
import 'package:long_ky_game/data/battle_save_store.dart';
import 'package:long_ky_game/data/campaign.dart';
import 'package:long_ky_game/data/content_repository.dart';
import 'package:long_ky_game/data/progress.dart';
import 'package:long_ky_game/data/progress_repository.dart';
import 'package:long_ky_game/data/progress_store.dart';
import 'package:long_ky_game/features/briefing/briefing_screen.dart';
import 'package:long_ky_game/features/campaign/campaign_screen.dart';
import 'package:long_ky_game/features/settings/progress_cubit.dart';

import 'battle/overlay_support.dart';

/// The campaign: the unlock rule over the five missions of chapter 1, and its
/// screens at both layouts and in both languages.
void main() {
  late ContentBundle content;
  late Campaign campaign;

  setUpAll(() async {
    content = await loadContentFromAssets(DiskAssetBundle());
    campaign = Campaign(content.missions.values);
  });

  const ids = ['ch1_m1', 'ch1_m2', 'ch1_m3', 'ch1_m4', 'ch1_m5'];

  Progress won(Iterable<String> missions, {Map<String, List<bool>> extra = const {}}) => Progress(
    stars: {
      for (final m in missions) m: const [true, false, false],
      ...extra,
    },
  );

  group('Campaign rules', () {
    test('the missions run in chapter order', () {
      expect([for (final m in campaign.sequence) m.id], ids);
      expect(campaign.chapters, [1]);
      expect(campaign.next('ch1_m2')?.id, 'ch1_m3');
      expect(campaign.next('ch1_m5'), isNull);
      expect(campaign.next('nope'), isNull);
    });

    test('a new player has only the first mission; winning N opens N+1', () {
      var p = const Progress();
      expect([for (final id in ids) campaign.isUnlocked(p, id)], [true, false, false, false, false]);
      for (var i = 0; i < ids.length - 1; i++) {
        p = won(ids.take(i + 1));
        expect(campaign.isUnlocked(p, ids[i + 1]), isTrue, reason: 'after ${ids[i]}');
        if (i + 2 < ids.length) expect(campaign.isUnlocked(p, ids[i + 2]), isFalse, reason: 'after ${ids[i]}');
      }
      expect(campaign.isUnlocked(const Progress(), 'nope'), isFalse);
    });

    test('only the first star counts as a win; later stars do not open anything', () {
      const p = Progress(
        stars: {
          'ch1_m1': [false, true, true],
        },
      );
      expect(Campaign.isWon(p, 'ch1_m1'), isFalse);
      expect(campaign.isUnlocked(p, 'ch1_m2'), isFalse);
    });

    test('stars are counted per chapter', () {
      final p = Progress(
        stars: {
          'ch1_m1': [true, true, false],
          'ch1_m2': [true, false, false],
        },
      );
      expect(Campaign.starsEarned(p, 'ch1_m1'), 2);
      expect(campaign.starsInChapter(p, 1), 3);
      expect(campaign.wonInChapter(p, 1), 2);
      expect(campaign.starsPossible(1), campaign.sequence.fold(0, (n, m) => n + m.stars.length));
      expect(campaign.chapterUnlocked(const Progress(), 1), isTrue);
      expect(campaign.chapterUnlocked(const Progress(), 2), isFalse);
    });
  });

  group('Campaign screens', () {
    late MemoryBattleSaveStore store;

    Future<ProgressCubit> pump(
      WidgetTester tester,
      Size size,
      Progress progress, {
      String lang = 'vi',
      Widget home = const CampaignScreen(),
    }) async {
      setViewSize(tester, size);
      store = MemoryBattleSaveStore();
      final cubit = ProgressCubit(ProgressRepository(MemoryProgressStore()), progress);
      await tester.pumpWidget(
        MultiRepositoryProvider(
          providers: [RepositoryProvider(create: (_) => BattleSaveRepository(store))],
          child: BlocProvider.value(
            value: cubit,
            child: DefaultAssetBundle(
              bundle: DiskAssetBundle(),
              child: appAround(home, lang: lang),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      return cubit;
    }

    for (final (name, size, _) in layouts) {
      group(name, () {
        testWidgets('chapter 1 is open and shows how far the player has got', (tester) async {
          await pump(tester, size, won(['ch1_m1']));
          final l = strings('vi');
          expect(find.byKey(const Key('chapter-1')), findsOneWidget);
          expect(find.text(l.campaignChapter(1)), findsOneWidget);
          expect(find.text(l.campaignChapterSummary(1, 5, 1, campaign.starsPossible(1))), findsOneWidget);
          expect(find.byKey(const Key('lock')), findsNothing);
          expect(tester.takeException(), isNull);
        });

        testWidgets('a new player sees one open mission and four locks; locked ones do nothing', (tester) async {
          await pump(tester, size, const Progress(), home: const ChapterScreen(chapter: 1));
          expect(find.byKey(const Key('lock')), findsNWidgets(4));
          expect(find.byKey(const Key('stars')), findsOneWidget);
          await tester.tap(find.byKey(const Key('mission-ch1_m2')));
          await tester.pump();
          expect(find.byType(BriefingScreen), findsNothing);
          expect(
            tester.getSize(find.byKey(const Key('mission-ch1_m1'))).height,
            greaterThanOrEqualTo(48),
            reason: 'touch target',
          );
          expect(tester.takeException(), isNull);
        });

        testWidgets('stars are shown filled or outlined, and winning opens the next mission live', (tester) async {
          final cubit = await pump(
            tester,
            size,
            won(
              ['ch1_m1'],
              extra: {
                'ch1_m1': const [true, true, false],
              },
            ),
            home: const ChapterScreen(chapter: 1),
          );
          Finder starsOf(String id, IconData icon) =>
              find.descendant(of: find.byKey(Key('mission-$id')), matching: find.byIcon(icon));
          expect(starsOf('ch1_m1', Icons.star), findsNWidgets(2));
          expect(starsOf('ch1_m1', Icons.star_border), findsNWidgets(1));
          expect(
            find.descendant(of: find.byKey(const Key('mission-ch1_m2')), matching: find.byKey(const Key('lock'))),
            findsNothing,
          );
          expect(
            find.descendant(of: find.byKey(const Key('mission-ch1_m3')), matching: find.byKey(const Key('lock'))),
            findsOneWidget,
          );

          await cubit.recordStars('ch1_m2', const [true, false, false]);
          await tester.pump();
          expect(
            find.descendant(of: find.byKey(const Key('mission-ch1_m3')), matching: find.byKey(const Key('lock'))),
            findsNothing,
          );
        });

        testWidgets('tapping an open mission opens its briefing', (tester) async {
          await pump(tester, size, const Progress(), home: const ChapterScreen(chapter: 1));
          await tester.tap(find.byKey(const Key('mission-ch1_m1')));
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 400));
          expect(find.byType(BriefingScreen), findsOneWidget);
          expect(tester.takeException(), isNull);
        });
      });
    }

    testWidgets('the chapter card opens the chapter', (tester) async {
      await pump(tester, compact, const Progress());
      await tester.tap(find.byKey(const Key('chapter-1')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(ChapterScreen), findsOneWidget);
    });

    testWidgets('a saved battle is not thrown away without asking', (tester) async {
      await pump(tester, regular, const Progress(), home: const ChapterScreen(chapter: 1));
      store.text = jsonEncode(SaveGame(missionId: 'ch1_m1', contentHash: 'x', seed: 1, actions: []).toJson());
      await tester.tap(find.byKey(const Key('mission-ch1_m1')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byKey(const Key('replace-save')), findsOneWidget);
      expect(find.byType(BriefingScreen), findsNothing);

      await tester.tap(find.text(strings('vi').actionCancel));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byKey(const Key('replace-save')), findsNothing);
      expect(find.byType(BriefingScreen), findsNothing);

      await tester.tap(find.byKey(const Key('mission-ch1_m1')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(find.byKey(const Key('replace-confirm')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(BriefingScreen), findsOneWidget);
    });

    testWidgets('the titles follow the language', (tester) async {
      await pump(tester, regular, const Progress(), lang: 'en', home: const ChapterScreen(chapter: 1));
      expect(find.text(campaign.sequence.first.title.en), findsOneWidget);
      expect(find.text(strings('en').campaignLockedHint), findsNWidgets(4));
    });
  });
}
