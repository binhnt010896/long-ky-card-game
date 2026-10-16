import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Goldens are compared on one fixed OS only (build-spec section 7): text
/// rasterises a little differently elsewhere. CI runs on Linux, so do they.
/// Regenerate on Linux with `flutter test --update-goldens test/golden`.
final bool goldenSkip = !Platform.isLinux;

/// Loads the real typeface and the icon font, so goldens show the glyphs the
/// app shows rather than the test font's boxes.
Future<void> loadGoldenFonts() async {
  final family = FontLoader('BeVietnamPro');
  for (final w in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
    family.addFont(_bytes(File('assets/fonts/BeVietnamPro/BeVietnamPro-$w.ttf')));
  }
  await family.load();

  final root = Platform.environment['FLUTTER_ROOT'] ?? _flutterRootFromPath();
  final icons = File('$root/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf');
  if (icons.existsSync()) {
    await (FontLoader('MaterialIcons')..addFont(_bytes(icons))).load();
  }
}

Future<ByteData> _bytes(File f) async => ByteData.sublistView(await f.readAsBytes());

String _flutterRootFromPath() {
  // `flutter` on the PATH: <root>/bin/flutter
  final exe = Platform.environment['PATH']!
      .split(Platform.isWindows ? ';' : ':')
      .map((d) => File('$d/flutter'))
      .firstWhere((f) => f.existsSync(), orElse: () => File('/opt/flutter/bin/flutter'));
  return exe.resolveSymbolicLinksSync().replaceFirst(RegExp(r'/bin/flutter$'), '');
}
