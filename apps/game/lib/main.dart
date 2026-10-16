import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import 'app/long_ky_app.dart';
import 'data/battle_save_repository.dart';
import 'data/battle_save_store.dart';
import 'data/progress_repository.dart';
import 'data/progress_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LicenseRegistry.addLicense(() async* {
    final ofl = await rootBundle.loadString('assets/fonts/BeVietnamPro/OFL.txt');
    yield LicenseEntryWithLineBreaks(['Be Vietnam Pro'], ofl);
  });
  final directory = await getApplicationSupportDirectory();
  final repository = ProgressRepository(FileProgressStore(directory));
  final progress = await repository.load();
  runApp(
    LongKyApp(repository: repository, initial: progress, saves: BattleSaveRepository(FileBattleSaveStore(directory))),
  );
}
