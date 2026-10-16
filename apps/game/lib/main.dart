import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import 'app/long_ky_app.dart';
import 'data/progress_repository.dart';
import 'data/progress_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LicenseRegistry.addLicense(() async* {
    final ofl = await rootBundle.loadString('assets/fonts/BeVietnamPro/OFL.txt');
    yield LicenseEntryWithLineBreaks(['Be Vietnam Pro'], ofl);
  });
  final repository = ProgressRepository(FileProgressStore(await getApplicationSupportDirectory()));
  final progress = await repository.load();
  runApp(LongKyApp(repository: repository, initial: progress));
}
