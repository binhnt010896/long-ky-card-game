import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import 'app/long_ky_app.dart';
import 'audio/audio_backend.dart';
import 'audio/audio_service.dart';
import 'data/battle_save_repository.dart';
import 'data/battle_save_store.dart';
import 'data/progress_repository.dart';
import 'data/progress_store.dart';
import 'platform/desktop_window.dart';
import 'platform/mobile_orientation.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await lockLandscape();
  await configureDesktopWindow();
  LicenseRegistry.addLicense(() async* {
    final ofl = await rootBundle.loadString('assets/fonts/BeVietnamPro/OFL.txt');
    yield LicenseEntryWithLineBreaks(['Be Vietnam Pro'], ofl);
  });
  final directory = await getApplicationSupportDirectory();
  final repository = ProgressRepository(FileProgressStore(directory));
  final progress = await repository.load();
  final audio = await AudioService.fromBundle(FlameAudioBackend(), rootBundle, progress.settings);
  runApp(
    LongKyApp(
      repository: repository,
      initial: progress,
      saves: BattleSaveRepository(FileBattleSaveStore(directory)),
      audio: audio,
    ),
  );
}
