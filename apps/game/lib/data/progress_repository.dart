import 'dart:convert';

import 'progress.dart';
import 'progress_store.dart';

/// Loads and saves [Progress].
final class ProgressRepository {
  ProgressRepository(this.store);

  final ProgressStore store;

  /// The saved progress; defaults if there is none. An unreadable file is
  /// set aside (not deleted) and the defaults are used.
  Future<Progress> load() async {
    final text = await store.read();
    if (text == null) return const Progress();
    try {
      final json = jsonDecode(text);
      if (json is! Map<String, Object?>) throw const FormatException('not an object');
      return Progress.fromJson(json);
    } on FormatException {
      await store.quarantine();
      return const Progress();
    }
  }

  Future<void> save(Progress progress) => store.write('${const JsonEncoder.withIndent('  ').convert(progress.toJson())}\n');
}
