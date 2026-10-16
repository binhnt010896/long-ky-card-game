import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:long_ky_game/app/long_ky_app.dart';
import 'package:long_ky_game/data/progress_repository.dart';
import 'package:long_ky_game/data/progress_store.dart';

/// Starts the app the way main() does, on [store] (a fresh one by default).
/// Calling it again with the same store is an app restart.
Future<MemoryProgressStore> startApp(WidgetTester tester, {MemoryProgressStore? store}) async {
  final s = store ?? MemoryProgressStore();
  final repository = ProgressRepository(s);
  final progress = await repository.load();
  await tester.pumpWidget(LongKyApp(key: UniqueKey(), repository: repository, initial: progress));
  await tester.pumpAndSettle();
  return s;
}
