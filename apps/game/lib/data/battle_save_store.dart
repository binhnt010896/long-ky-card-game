import 'dart:io';

/// Raw storage for `battle.json`, the save of the mission being played.
abstract interface class BattleSaveStore {
  /// The file text, or null if there is none.
  Future<String?> read();

  /// Replaces the file text atomically.
  Future<void> write(String text);

  /// Removes the save (the mission ended, or it was restarted).
  Future<void> delete();

  /// Keeps an unreadable file aside so it is not overwritten silently.
  Future<void> quarantine();
}

/// `battle.json` in [directory] (the app support directory). Writes go to a
/// temp file that is then renamed, so a crash cannot corrupt the save: the
/// file is always either the old save or the new one.
final class FileBattleSaveStore implements BattleSaveStore {
  FileBattleSaveStore(this.directory);

  final Directory directory;
  static const String fileName = 'battle.json';

  File get file => File('${directory.path}/$fileName');

  @override
  Future<String?> read() async => await file.exists() ? file.readAsString() : null;

  @override
  Future<void> write(String text) async {
    await directory.create(recursive: true);
    final tmp = File('${file.path}.tmp');
    await tmp.writeAsString(text, flush: true);
    await tmp.rename(file.path);
  }

  @override
  Future<void> delete() async {
    if (await file.exists()) await file.delete();
    final tmp = File('${file.path}.tmp');
    if (await tmp.exists()) await tmp.delete();
  }

  @override
  Future<void> quarantine() async {
    if (await file.exists()) await file.rename('${file.path}.bad');
  }
}

/// In-memory store for tests. [writes] counts how often it was written.
final class MemoryBattleSaveStore implements BattleSaveStore {
  MemoryBattleSaveStore([this.text]);

  String? text;
  String? quarantined;
  int writes = 0;

  @override
  Future<String?> read() async => text;

  @override
  Future<void> write(String text) async {
    this.text = text;
    writes++;
  }

  @override
  Future<void> delete() async => text = null;

  @override
  Future<void> quarantine() async {
    quarantined = text;
    text = null;
  }
}
