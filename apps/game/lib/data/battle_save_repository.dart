import 'dart:async';
import 'dart:convert';

import 'package:lk_rules/lk_rules.dart';

import 'battle_save_store.dart';

/// What [BattleSaveRepository.load] found.
sealed class SavedBattle {
  const SavedBattle();
}

/// No battle is saved.
final class NoSavedBattle extends SavedBattle {
  const NoSavedBattle();
}

/// A save, ready to be replayed.
final class FoundSavedBattle extends SavedBattle {
  const FoundSavedBattle(this.save);

  final SaveGame save;
}

/// A file that cannot be read, or that this app version cannot replay. An
/// unreadable one has been set aside, not deleted.
final class UnusableSavedBattle extends SavedBattle {
  const UnusableSavedBattle({this.missionId});

  /// The mission the save was for, when that much could be read.
  final String? missionId;
}

/// Loads, saves and clears the battle save (build-spec section 4, "Save
/// format"): the mission, the content hash, the seed and every action.
/// Loading replays the actions, so nothing else needs saving.
final class BattleSaveRepository {
  BattleSaveRepository(this.store);

  final BattleSaveStore store;

  Future<void> _queue = Future.value();

  Future<SavedBattle> load() async {
    await _queue;
    final text = await store.read();
    if (text == null) return const NoSavedBattle();
    try {
      final json = jsonDecode(text);
      if (json is! Map<String, Object?>) throw const FormatException('not an object');
      final version = json['saveVersion'];
      if (version is int && version != SaveGame.currentVersion) {
        // From another version of the app: not damaged, but not ours to replay.
        return UnusableSavedBattle(missionId: json['missionId'] as String?);
      }
      return FoundSavedBattle(SaveGame.fromJson(json));
    } on Object {
      await store.quarantine();
      return const UnusableSavedBattle();
    }
  }

  Future<bool> exists() async => await load() is! NoSavedBattle;

  /// Saves [save]. Writes happen one after the other, so the file always ends
  /// up as the latest save even when actions follow each other quickly.
  Future<void> save(SaveGame save) {
    final text = '${jsonEncode(save.toJson())}\n';
    return _enqueue(() => store.write(text));
  }

  /// Removes the save (the mission is over, or the player starts it again).
  Future<void> clear() => _enqueue(store.delete);

  Future<void> _enqueue(Future<void> Function() job) {
    final next = _queue.then((_) => job());
    // A failed write must not block the ones after it.
    _queue = next.catchError((Object _) {});
    return next;
  }

  /// Completes when every write queued so far is done.
  Future<void> flush() => _queue;
}
