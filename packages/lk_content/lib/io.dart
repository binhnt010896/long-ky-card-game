/// File-system helpers for the CLIs, the simulator and tests (uses dart:io;
/// not for the Flutter app, which loads content from its asset bundle).
library;

import 'dart:io';

/// Every file under [contentDir], keyed by its path relative to it.
Map<String, String> readContentDir(Directory contentDir) {
  final out = <String, String>{};
  for (final e in contentDir.listSync(recursive: true)) {
    if (e is! File) continue;
    final rel = _relative(e.path, contentDir.path);
    if (rel.split('/').any((part) => part.startsWith('.'))) continue;
    out[rel] = e.readAsStringSync();
  }
  return out;
}

/// Files under `assets/images` and `assets/audio`, as `images/...` paths.
Set<String> listAssetPaths(Directory assetsDir) {
  final out = <String>{};
  for (final sub in ['images', 'audio']) {
    final d = Directory('${assetsDir.path}/$sub');
    if (!d.existsSync()) continue;
    for (final e in d.listSync(recursive: true)) {
      if (e is File) out.add(_relative(e.path, assetsDir.path));
    }
  }
  return out;
}

/// The repo's `apps/game/assets/content`, searching up from [start].
Directory? findContentDir([Directory? start]) {
  var dir = (start ?? Directory.current).absolute;
  while (true) {
    final candidate = Directory('${dir.path}/apps/game/assets/content');
    if (candidate.existsSync()) return candidate;
    final parent = dir.parent;
    if (parent.path == dir.path) return null;
    dir = parent;
  }
}

String _relative(String path, String root) {
  final p = path.replaceAll('\\', '/');
  final r = root.replaceAll('\\', '/');
  final base = r.endsWith('/') ? r : '$r/';
  return p.startsWith(base) ? p.substring(base.length) : p;
}
