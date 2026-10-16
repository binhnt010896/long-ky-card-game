import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:lk_rules/lk_rules.dart';
import 'package:long_ky_game/data/battle_save_repository.dart';
import 'package:long_ky_game/data/battle_save_store.dart';
import 'package:long_ky_game/features/battle/battle_cubit.dart';

import 'battle/board_support.dart';

SaveGame saveOf(GameState s, {String hash = 'h'}) =>
    SaveGame(missionId: s.missionId, contentHash: hash, seed: s.seed, actions: s.log);

/// A store whose writes can be made to fail.
class _FlakyStore implements BattleSaveStore {
  bool failNext = false;
  final List<String> order = [];
  String? text;

  @override
  Future<String?> read() async => text;

  @override
  Future<void> write(String text) async {
    if (failNext) {
      failNext = false;
      throw const FileSystemException('disk full');
    }
    await Future<void>.delayed(const Duration(milliseconds: 1));
    order.add(text);
    this.text = text;
  }

  @override
  Future<void> delete() async => text = null;

  @override
  Future<void> quarantine() async => text = null;
}

void main() {
  group('FileBattleSaveStore', () {
    late Directory dir;
    late FileBattleSaveStore store;

    setUp(() {
      dir = Directory.systemTemp.createTempSync('lk_save_');
      store = FileBattleSaveStore(Directory('${dir.path}/support'));
    });
    tearDown(() => dir.deleteSync(recursive: true));

    test('reads nothing before the first write, then what was written', () async {
      expect(await store.read(), isNull);
      await store.write('one');
      expect(await store.read(), 'one');
      await store.write('two');
      expect(await store.read(), 'two');
      expect(store.file.path.endsWith('battle.json'), isTrue);
    });

    test('a write goes through a temp file that is renamed, so no half-written file is ever the save', () async {
      await store.write('old');
      // A crash in the middle of a later write leaves only the temp file behind.
      File('${store.file.path}.tmp').writeAsStringSync('half-writt');
      expect(await store.read(), 'old', reason: 'the save is still the last complete one');
      await store.write('new');
      expect(await store.read(), 'new');
      expect(File('${store.file.path}.tmp').existsSync(), isFalse, reason: 'the rename consumed the temp file');
    });

    test('delete removes the save and any temp file', () async {
      await store.write('x');
      File('${store.file.path}.tmp').writeAsStringSync('y');
      await store.delete();
      expect(await store.read(), isNull);
      expect(File('${store.file.path}.tmp').existsSync(), isFalse);
      await store.delete(); // nothing to delete is fine
    });

    test('quarantine keeps the unreadable file aside', () async {
      await store.write('garbage');
      await store.quarantine();
      expect(await store.read(), isNull);
      expect(File('${store.file.path}.bad').readAsStringSync(), 'garbage');
    });
  });

  group('BattleSaveRepository', () {
    final engine = GameEngine(ruleset('ch1_m2'));

    test('nothing saved', () async {
      expect(await BattleSaveRepository(MemoryBattleSaveStore()).load(), isA<NoSavedBattle>());
    });

    test('a save comes back as it went, actions included', () async {
      final repo = BattleSaveRepository(MemoryBattleSaveStore());
      var s = engine.newGame(7).state;
      s = engine.apply(s, const GameAction.playCard(cardId: 'vuon-khong-nha-trong', target: 'binh-le-nguyen')).state;
      s = engine.apply(s, const GameAction.endPhase()).state;
      s = engine.apply(s, GameAction.setOrder(officerId: 'tran-thai-tong', order: Order.move('thang-long'))).state;
      await repo.save(saveOf(s, hash: 'abc'));
      final loaded = await repo.load();
      expect(loaded, isA<FoundSavedBattle>());
      final save = (loaded as FoundSavedBattle).save;
      expect(save.missionId, 'ch1_m2');
      expect(save.contentHash, 'abc');
      expect(save.seed, 7);
      expect(save.actions, s.log);
      expect(save.saveVersion, SaveGame.currentVersion);
    });

    test('the file has the documented shape', () async {
      final store = MemoryBattleSaveStore();
      final repo = BattleSaveRepository(store);
      final s = engine.apply(engine.newGame(3).state, const GameAction.endPhase()).state;
      await repo.save(saveOf(s));
      final json = jsonDecode(store.text!) as Map<String, Object?>;
      expect(json.keys, containsAll(['saveVersion', 'missionId', 'contentHash', 'seed', 'actions']));
      expect(json['saveVersion'], 1);
      expect(json['actions'], isA<List<Object?>>());
    });

    test('clear removes it', () async {
      final repo = BattleSaveRepository(MemoryBattleSaveStore());
      await repo.save(saveOf(engine.newGame(1).state));
      expect(await repo.exists(), isTrue);
      await repo.clear();
      expect(await repo.exists(), isFalse);
    });

    test('a damaged file is set aside, not used and not silently deleted', () async {
      for (final bad in ['not json', '[1,2]', '{"saveVersion":1}', '{"saveVersion":1,"missionId":3}']) {
        final store = MemoryBattleSaveStore(bad);
        final loaded = await BattleSaveRepository(store).load();
        expect(loaded, isA<UnusableSavedBattle>(), reason: bad);
        expect(store.text, isNull, reason: bad);
        expect(store.quarantined, bad);
      }
    });

    test('a save from another version of the app is unusable but kept, and names its mission', () async {
      const text = '{"saveVersion":99,"missionId":"ch1_m2","contentHash":"h","seed":1,"actions":[]}';
      final store = MemoryBattleSaveStore(text);
      final loaded = await BattleSaveRepository(store).load();
      expect(loaded, isA<UnusableSavedBattle>());
      expect((loaded as UnusableSavedBattle).missionId, 'ch1_m2');
      expect(store.text, text);
    });

    test('quick saves are written in order, so the file ends as the last one', () async {
      final store = _FlakyStore();
      final repo = BattleSaveRepository(store);
      var s = engine.newGame(1).state;
      final saves = <SaveGame>[saveOf(s)];
      for (final a in const [
        GameAction.endPhase(),
        GameAction.setOrder(officerId: 'tran-thai-tong', order: Order.hold),
        GameAction.clearOrder(officerId: 'tran-thai-tong'),
      ]) {
        s = engine.apply(s, a).state;
        saves.add(saveOf(s));
      }
      for (final save in saves) {
        unawaited(repo.save(save));
      }
      await repo.flush();
      expect(store.order, hasLength(4));
      final last = (await repo.load() as FoundSavedBattle).save;
      expect(last.actions, saves.last.actions);
    });

    test('a failed write does not block the next one', () async {
      final store = _FlakyStore()..failNext = true;
      final repo = BattleSaveRepository(store);
      final s = engine.newGame(1).state;
      await expectLater(repo.save(saveOf(s)), throwsA(isA<FileSystemException>()));
      await repo.save(saveOf(s));
      expect(await repo.exists(), isTrue);
    });
  });

  group('resuming a battle', () {
    final engine = GameEngine(ruleset('ch1_m2'));

    test('replays to the same state, the same log and the same events', () {
      final played = BattleCubit(engine, seed: 5);
      addTearDown(played.close);
      played.playCard('vuon-khong-nha-trong', target: 'binh-le-nguyen');
      played.endPhase();
      played.setOrder('tran-thai-tong', Order.move('thang-long'));
      played.setOrder('le-phu-tran', Order.rally);

      final resumed = BattleCubit.resume(engine, seed: played.game.seed, actions: played.game.log);
      addTearDown(resumed.close);
      expect(resumed.game, played.game);
      expect(stateHash(resumed.game), stateHash(played.game));
      expect(resumed.state.events.length, played.state.events.length);
      expect(resumed.state.lastEvents, isEmpty, reason: 'nothing to animate on resume');
      expect(resumed.state.step, 0);
      // And it carries on as the original would.
      played.endPhase();
      resumed.endPhase();
      expect(stateHash(resumed.game), stateHash(played.game));
    });

    test('an action that is no longer legal makes the save unusable', () {
      final tampered = [const GameAction.setOrder(officerId: 'tran-thai-tong', order: Order.hold)];
      expect(() => BattleCubit.resume(engine, seed: 1, actions: tampered), throwsA(isA<SaveReplayException>()));
    });

    test('killed at any point of 30 random games, the saved battle comes back identical', () {
      for (var seed = 1; seed <= 30; seed++) {
        final rng = Random(seed);
        final saved = <SaveGame>[];
        final live = BattleCubit(engine, seed: seed, onChanged: (v) => saved.add(saveOf(v.state)));
        addTearDown(live.close);
        saved.add(saveOf(live.game));
        for (var i = 0; i < 40 && !live.game.isOver; i++) {
          final legal = live.legalActions;
          live.perform(legal[rng.nextInt(legal.length)]);
        }
        // "Kill" after every step: the last save at that point must resume to that state.
        var s = engine.newGame(seed).state;
        for (var i = 0; i < saved.length; i++) {
          if (i > 0) s = engine.apply(s, saved[i].actions.last).state;
          final r = BattleCubit.resume(engine, seed: saved[i].seed, actions: saved[i].actions);
          expect(stateHash(r.game), stateHash(s), reason: 'seed $seed after $i actions');
          r.close();
        }
      }
    });

    test('autosave runs after every step and only for steps that happened', () {
      final seen = <int>[];
      final c = BattleCubit(engine, seed: 1, onChanged: (v) => seen.add(v.state.log.length));
      addTearDown(c.close);
      c.endPhase();
      c.setOrder('nobody', Order.hold); // refused
      c.setOrder('tran-thai-tong', Order.hold);
      expect(seen, [1, 2]);
    });
  });
}
