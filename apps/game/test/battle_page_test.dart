import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lk_rules/lk_rules.dart';
import 'package:long_ky_game/data/battle_save_repository.dart';
import 'package:long_ky_game/data/campaign.dart';
import 'package:long_ky_game/data/progress.dart';
import 'package:long_ky_game/data/battle_save_store.dart';
import 'package:long_ky_game/data/progress_repository.dart';
import 'package:long_ky_game/data/progress_store.dart';
import 'package:long_ky_game/features/battle/battle_cubit.dart';
import 'package:long_ky_game/features/battle/battle_page.dart';
import 'package:long_ky_game/features/battle/battle_screen.dart';
import 'package:long_ky_game/features/briefing/briefing_screen.dart';
import 'package:long_ky_game/features/settings/progress_cubit.dart';

import 'battle/overlay_support.dart';
import 'support.dart';

/// The battle page: autosave, resume after the app is killed, the restart
/// prompt, stars on a win, and the Continue button on the title screen.
void main() {
  final l = strings('vi');

  late MemoryBattleSaveStore store;
  late BattleSaveRepository saves;
  late ProgressCubit progress;

  /// A widget test with fresh stores, made inside the test's own (fake-async)
  /// zone: futures created outside it would not run when the test pumps.
  void pageTest(String name, Future<void> Function(WidgetTester tester) body) {
    testWidgets(name, (tester) async {
      store = MemoryBattleSaveStore();
      saves = BattleSaveRepository(store);
      progress = ProgressCubit(ProgressRepository(MemoryProgressStore()), const Progress());
      await body(tester);
    });
  }

  /// Waits for [f] by pumping, so futures of the stores (made in the test's
  /// fake-async zone) get to run.
  Future<T> pumped<T>(WidgetTester tester, Future<T> f) async {
    T? result;
    var done = false;
    unawaited(
      f.then((v) {
        result = v;
        done = true;
      }),
    );
    for (var i = 0; i < 50 && !done; i++) {
      await tester.pump(const Duration(milliseconds: 10));
    }
    expect(done, isTrue, reason: 'the store should have answered');
    return result as T;
  }

  /// The page loads its content on the first frames.
  Future<void> loaded(WidgetTester tester) async {
    await tester.pump();
    await settle(tester);
    expect(
      find.byType(BattleScreen).evaluate().isNotEmpty || find.byKey(const Key('cannot-resume')).evaluate().isNotEmpty,
      isTrue,
      reason: 'the page should have loaded',
    );
  }

  Future<BattleCubit> pumpPage(
    WidgetTester tester, {
    Size size = regular,
    bool resume = false,
    String missionId = mission,
    int? seed = 1,
    ProgressCubit? progressCubit,
  }) async {
    setViewSize(tester, size);
    await tester.pumpWidget(
      appAround(
        BattlePage(
          missionId: missionId,
          resume: resume,
          seed: seed,
          saves: saves,
          progress: progressCubit ?? progress,
          bundle: DiskAssetBundle(),
        ),
      ),
    );
    await loaded(tester);
    return tester.element(find.byType(BattleScreen)).read<BattleCubit>();
  }

  /// The real hash of the installed content, as a save would carry it.
  String contentHashNow() => content.contentHash;

  Future<SaveGame> savedNow(WidgetTester tester) async {
    await pumped(tester, saves.flush());
    final found = await pumped(tester, saves.load());
    return (found as FoundSavedBattle).save;
  }

  group('autosave', () {
    pageTest('a new battle is saved at once, and after every action', (tester) async {
      final cubit = await pumpPage(tester);
      var save = await savedNow(tester);
      expect(save.missionId, mission);
      expect(save.seed, 1);
      expect(save.actions, isEmpty);
      expect(save.contentHash, contentHashNow());

      cubit.endPhase();
      cubit.setOrder('tran-thai-tong', Order.move('thang-long'));
      cubit.playCard('vuon-khong-nha-trong', target: 'binh-le-nguyen'); // refused: not Council
      cubit.clearOrder('tran-thai-tong');
      save = await savedNow(tester);
      expect(save.actions, cubit.game.log);
      expect(save.actions, hasLength(3), reason: 'the refused action is not saved');
    });

    pageTest('every written save is the last complete one (writes never overlap)', (tester) async {
      final cubit = await pumpPage(tester);
      cubit.endPhase();
      for (final id in ['tran-thai-tong', 'le-phu-tran', 'tran-thu-do']) {
        cubit.setOrder(id, Order.move('thang-long'));
      }
      final save = await savedNow(tester);
      expect(save.actions, hasLength(4));
      expect(store.writes, greaterThanOrEqualTo(2));
    });
  });

  group('killing the app and reopening', () {
    for (final (name, size) in [('compact', compact), ('regular', regular)]) {
      pageTest('mid-turn, the same state comes back ($name)', (tester) async {
        final cubit = await pumpPage(tester, size: size, seed: 11);
        cubit.playCard('vuon-khong-nha-trong', target: 'binh-le-nguyen');
        cubit.endPhase();
        cubit.setOrder('tran-thai-tong', Order.move('thang-long'));
        cubit.setOrder('le-phu-tran', Order.rally);
        await settle(tester);
        final before = cubit.game;
        final lineCount = cubit.state.events.length;
        await pumped(tester, saves.flush());

        // The app is killed: nothing of the old page survives.
        await tester.pumpWidget(const SizedBox());
        await tester.pump();

        final resumed = await pumpPage(tester, size: size, resume: true, seed: 999);
        expect(resumed, isNot(same(cubit)));
        expect(resumed.game, before, reason: 'same state, down to the hand and the orders');
        expect(stateHash(resumed.game), stateHash(before));
        expect(resumed.game.seed, 11, reason: 'the saved seed, not a new one');
        expect(resumed.game.phase, Phase.orders);
        expect(resumed.state.events.length, lineCount, reason: 'the log is rebuilt too');
        // The screen shows it: the Orders button, and the orders given.
        expect(find.text(l.phaseButtonOrders), findsOneWidget);
        expect(find.textContaining(l.orderRally), findsWidgets);
        // And it plays on, and saves on, from there.
        resumed.setOrder('tran-thu-do', Order.hold);
        final save = await savedNow(tester);
        expect(save.actions, resumed.game.log);
        expect(find.byKey(const Key('result-screen')), findsNothing);
      });
    }

    pageTest('nothing is animated on resume', (tester) async {
      final cubit = await pumpPage(tester);
      cubit.endPhase();
      cubit.setOrder('tran-thai-tong', Order.move('thang-long'));
      await pumped(tester, saves.flush());
      await tester.pumpWidget(const SizedBox());
      await pumpPage(tester, resume: true);
      expect(boardGame(tester).busy.value, isFalse);
      expect(boardGame(tester).animator.isBusy, isFalse);
    });

    pageTest('continuing with no save starts a new battle', (tester) async {
      final cubit = await pumpPage(tester, resume: true, seed: 4);
      expect(cubit.game.phase, Phase.council);
      expect(cubit.game.seed, 4);
      expect((await savedNow(tester)).actions, isEmpty);
    });
  });

  group('a save that cannot be used', () {
    Future<void> saveWith(WidgetTester tester, {String? hash, String? missionId, List<GameAction>? actions}) async {
      await pumped(
        tester,
        saves.save(
          SaveGame(
            missionId: missionId ?? mission,
            contentHash: hash ?? contentHashNow(),
            seed: 1,
            actions: actions ?? const [GameAction.endPhase()],
          ),
        ),
      );
    }

    pageTest('other content: offers to start again; starting again replaces the save', (tester) async {
      await saveWith(tester, hash: 'content-from-an-older-version');
      setViewSize(tester, regular);
      await tester.pumpWidget(
        appAround(BattlePage(missionId: mission, resume: true, seed: 5, saves: saves, bundle: DiskAssetBundle())),
      );
      await loaded(tester);
      expect(find.byKey(const Key('cannot-resume')), findsOneWidget);
      expect(find.text(l.resumeUnusableTitle), findsOneWidget);
      expect(find.byType(BattleScreen), findsNothing);

      await tester.tap(find.byKey(const Key('resume-restart')));
      await loaded(tester);
      expect(find.byType(BattleScreen), findsOneWidget);
      final cubit = tester.element(find.byType(BattleScreen)).read<BattleCubit>();
      expect(cubit.game.seed, 5);
      final save = await savedNow(tester);
      expect(save.contentHash, contentHashNow());
      expect(save.actions, isEmpty);
    });

    pageTest('an action the engine now refuses: the same offer', (tester) async {
      await saveWith(
        tester,
        actions: [GameAction.setOrder(officerId: 'tran-thai-tong', order: Order.hold)], // not in Orders
      );
      setViewSize(tester, regular);
      await tester.pumpWidget(
        appAround(BattlePage(missionId: mission, resume: true, saves: saves, bundle: DiskAssetBundle())),
      );
      await loaded(tester);
      expect(find.byKey(const Key('cannot-resume')), findsOneWidget);
    });

    pageTest('a save of another mission is not played as this one', (tester) async {
      await saveWith(tester, missionId: 'ch1_m1');
      setViewSize(tester, regular);
      await tester.pumpWidget(
        appAround(BattlePage(missionId: mission, resume: true, saves: saves, bundle: DiskAssetBundle())),
      );
      await loaded(tester);
      expect(find.byKey(const Key('cannot-resume')), findsOneWidget);
    });

    pageTest('Back leaves, and keeps the save for now', (tester) async {
      await saveWith(tester, hash: 'old');
      setViewSize(tester, regular);
      await tester.pumpWidget(
        appAround(
          Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        BattlePage(missionId: mission, resume: true, saves: saves, bundle: DiskAssetBundle()),
                  ),
                ),
                child: const Text('go'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('go'));
      await tester.pump();
      await loaded(tester);
      await tester.tap(find.byKey(const Key('resume-back')));
      await tester.pumpAndSettle();
      expect(find.text('go'), findsOneWidget);
      expect(await saves.exists(), isTrue);
    });
  });

  group('winning', () {
    /// ch1_m2 in one turn: everyone to Thăng Long.
    Future<void> win(WidgetTester tester, BattleCubit cubit) async {
      cubit.endPhase();
      for (final id in ['tran-thai-tong', 'le-phu-tran', 'tran-thu-do']) {
        cubit.setOrder(id, Order.move('thang-long'));
      }
      cubit.endPhase();
      await settle(tester);
      await playOut(tester);
    }

    pageTest('the save is cleared, the stars are recorded and the Result screen shows them', (tester) async {
      final cubit = await pumpPage(tester);
      expect(await saves.exists(), isTrue);
      await win(tester, cubit);
      expect(cubit.game.outcome, Outcome.won);

      await pumped(tester, saves.flush());
      expect(await pumped(tester, saves.exists()), isFalse, reason: 'a finished mission is not continued');
      expect(progress.state.stars[mission], cubit.game.stars);
      expect(progress.state.stars[mission]!.first, isTrue);
      expect(find.byKey(const Key('result-screen')), findsOneWidget);
      expect(find.byKey(const Key('objective-0')), findsOneWidget);
      expect(find.text(l.outcomeStars(cubit.game.stars.where((s) => s).length, 3)), findsOneWidget);
    });

    pageTest('a first win opens the next mission; Next mission goes to its briefing', (tester) async {
      final cubit = await pumpPage(tester, seed: 21);
      expect(Campaign.isWon(progress.state, 'ch1_m3'), isFalse);
      await win(tester, cubit);
      expect(find.byKey(const Key('result-unlocked')), findsOneWidget);
      expect(find.byKey(const Key('result-next')), findsOneWidget);

      await tester.tap(find.byKey(const Key('result-next')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(BriefingScreen), findsOneWidget);
      expect(tester.widget<BriefingScreen>(find.byType(BriefingScreen)).missionId, 'ch1_m3');
    });

    pageTest('winning a mission already won does not announce an unlock again', (tester) async {
      await progress.recordStars(mission, const [true, false, false]);
      final cubit = await pumpPage(tester, seed: 21);
      await win(tester, cubit);
      expect(find.byKey(const Key('result-screen')), findsOneWidget);
      expect(find.byKey(const Key('result-unlocked')), findsNothing);
      expect(find.byKey(const Key('result-next')), findsOneWidget);
    });

    pageTest('Play again starts the mission afresh, with a new save', (tester) async {
      final cubit = await pumpPage(tester, seed: 21);
      await win(tester, cubit);
      expect(find.byKey(const Key('result-screen')), findsOneWidget);

      await tester.tap(find.byKey(const Key('result-retry')));
      await loaded(tester);
      expect(find.byKey(const Key('result-screen')), findsNothing);
      final again = tester.element(find.byType(BattleScreen)).read<BattleCubit>();
      expect(again, isNot(same(cubit)));
      expect(again.game.phase, Phase.council);
      expect(again.game.log, isEmpty);
      expect((await savedNow(tester)).actions, isEmpty);
    });

    pageTest('a battle without a progress or save repository still plays', (tester) async {
      setViewSize(tester, regular);
      await tester.pumpWidget(appAround(BattlePage(missionId: mission, seed: 1, bundle: DiskAssetBundle())));
      await loaded(tester);
      final cubit = tester.element(find.byType(BattleScreen)).read<BattleCubit>();
      await win(tester, cubit);
      expect(find.byKey(const Key('result-screen')), findsOneWidget);
    });
  });

  group('ProgressCubit.recordStars', () {
    test('keeps the best of every star, never losing one', () async {
      final p = ProgressCubit(ProgressRepository(MemoryProgressStore()), const Progress());
      await p.recordStars('m', [true, false, false]);
      expect(p.state.stars['m'], [true, false, false]);
      await p.recordStars('m', [true, true, false]);
      expect(p.state.stars['m'], [true, true, false]);
      await p.recordStars('m', [true, false, true]);
      expect(p.state.stars['m'], [true, true, true], reason: 'stars once earned stay earned');
      await p.recordStars('m', [true, false, false]);
      expect(p.state.stars['m'], [true, true, true]);
    });

    test('an unchanged result writes nothing', () async {
      final store = MemoryProgressStore();
      final p = ProgressCubit(ProgressRepository(store), const Progress());
      await p.recordStars('m', [true, true, true]);
      final text = store.text;
      store.text = 'sentinel';
      await p.recordStars('m', [true, false, false]);
      expect(store.text, 'sentinel', reason: 'nothing new, so nothing written');
      expect(text, contains('"m"'));
    });

    test('is saved to progress.json and survives a restart', () async {
      final store = MemoryProgressStore();
      final p = ProgressCubit(ProgressRepository(store), const Progress());
      await p.recordStars('ch1_m2', [true, true, false]);
      final reloaded = await ProgressRepository(store).load();
      expect(reloaded.stars['ch1_m2'], [true, true, false]);
    });
  });

  group('title screen: Continue', () {
    pageTest('is off without a save and on with one; it resumes the saved battle', (tester) async {
      final repo = BattleSaveRepository(MemoryBattleSaveStore());
      await startApp(tester, saves: repo);
      expect(tester.widget<FilledButton>(find.byKey(const Key('menu-continue'))).onPressed, isNull);

      // A battle was left half-way by an earlier session.
      final engine = GameEngine(ruleset(mission));
      var s = engine.newGame(8).state;
      s = engine.apply(s, const GameAction.endPhase()).state;
      await pumped(
        tester,
        repo.save(SaveGame(missionId: mission, contentHash: contentHashNow(), seed: 8, actions: s.log)),
      );
      await startApp(tester, saves: repo);
      final button = tester.widget<FilledButton>(find.byKey(const Key('menu-continue')));
      expect(button.onPressed, isNotNull);

      await tester.tap(find.byKey(const Key('menu-continue')));
      await tester.pump();
      await loaded(tester);
      final cubit = tester.element(find.byType(BattleScreen)).read<BattleCubit>();
      expect(cubit.game, s);
      expect(cubit.game.phase, Phase.orders);
    });

    pageTest('after the battle is won there is nothing to continue', (tester) async {
      final repo = BattleSaveRepository(MemoryBattleSaveStore());
      await startApp(tester, saves: repo);
      await pumped(
        tester,
        repo.save(SaveGame(missionId: mission, contentHash: contentHashNow(), seed: 1, actions: const [])),
      );
      await startApp(tester, saves: repo);
      await tester.tap(find.byKey(const Key('menu-continue')));
      await tester.pump();
      await loaded(tester);
      final cubit = tester.element(find.byType(BattleScreen)).read<BattleCubit>();
      cubit.endPhase();
      for (final id in ['tran-thai-tong', 'le-phu-tran', 'tran-thu-do']) {
        cubit.setOrder(id, Order.move('thang-long'));
      }
      cubit.endPhase();
      await settle(tester);
      await playOut(tester);
      await tester.tap(find.byKey(const Key('result-back')));
      await tester.pump();
      await tester.pumpAndSettle();
      expect(tester.widget<FilledButton>(find.byKey(const Key('menu-continue'))).onPressed, isNull);
    });

    pageTest('a save from other content still offers Continue, then the restart prompt', (tester) async {
      final repo = BattleSaveRepository(MemoryBattleSaveStore());
      await pumped(tester, repo.save(const SaveGame(missionId: mission, contentHash: 'old', seed: 1, actions: [])));
      await startApp(tester, saves: repo);
      await tester.tap(find.byKey(const Key('menu-continue')));
      await tester.pump();
      await loaded(tester);
      expect(find.byKey(const Key('cannot-resume')), findsOneWidget);
    });
  });
}
