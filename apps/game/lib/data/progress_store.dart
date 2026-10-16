import 'dart:io';

/// Raw storage for `progress.json`.
abstract interface class ProgressStore {
  /// The file text, or null if there is none.
  Future<String?> read();

  /// Replaces the file text atomically.
  Future<void> write(String text);

  /// Keeps an unreadable file aside so it is not overwritten silently.
  Future<void> quarantine();
}

/// `progress.json` in [directory] (the app support directory). Writes go
/// to a temp file that is then renamed, so a crash cannot corrupt the save.
final class FileProgressStore implements ProgressStore {
  FileProgressStore(this.directory);

  final Directory directory;
  static const String fileName = 'progress.json';

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
  Future<void> quarantine() async {
    if (await file.exists()) await file.rename('${file.path}.bad');
  }
}

/// In-memory store for tests.
final class MemoryProgressStore implements ProgressStore {
  MemoryProgressStore([this.text]);

  String? text;
  String? quarantined;

  @override
  Future<String?> read() async => text;

  @override
  Future<void> write(String text) async => this.text = text;

  @override
  Future<void> quarantine() async {
    quarantined = text;
    text = null;
  }
}
