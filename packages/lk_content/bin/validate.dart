import 'dart:convert';
import 'dart:io';

import 'package:lk_content/io.dart';
import 'package:lk_content/lk_content.dart';

const _usage = '''
Validates the game content JSON (build-spec section 3, rules 1–8).

Usage: dart run packages/lk_content/bin/validate.dart [options]
  --content <dir>  content root (default: apps/game/assets/content)
  --release        missing art or audio is an error, not a warning
  --json           print the issues as JSON
  -h, --help       show this help
''';

void main(List<String> args) {
  var release = false;
  var asJson = false;
  String? contentPath;
  for (var i = 0; i < args.length; i++) {
    switch (args[i]) {
      case '--release':
        release = true;
      case '--json':
        asJson = true;
      case '--content':
        contentPath = i + 1 < args.length ? args[++i] : null;
      case '-h' || '--help':
        stdout.write(_usage);
        return;
      default:
        stderr.write('Unknown option ${args[i]}\n$_usage');
        exitCode = 64;
        return;
    }
  }

  final dir = contentPath != null ? Directory(contentPath) : findContentDir();
  if (dir == null || !dir.existsSync()) {
    stderr.writeln('Content directory not found (${contentPath ?? 'apps/game/assets/content'}).');
    exitCode = 66;
    return;
  }

  final files = readContentDir(dir);
  final assets = listAssetPaths(dir.parent);
  final result = validateContent(files, assetPaths: assets, release: release);

  if (asJson) {
    stdout.writeln(const JsonEncoder.withIndent('  ').convert({
      'contentDir': dir.path,
      'errors': result.errors.length,
      'warnings': result.warnings.length,
      'contentHash': result.bundle?.contentHash,
      'issues': [
        for (final i in result.issues)
          {
            'rule': i.rule,
            'severity': i.severity.name,
            'code': i.code,
            'file': i.file,
            'path': i.path,
            'message': i.message,
          },
      ],
    }));
  } else {
    for (final i in result.errors) {
      stdout.writeln(i);
    }
    final missingAssets = result.warnings.where((w) => w.code == 'missingAsset').length;
    for (final w in result.warnings.where((w) => w.code != 'missingAsset')) {
      stdout.writeln(w);
    }
    if (missingAssets > 0) {
      stdout.writeln('WARNING [rule 8] $missingAssets art/audio files are missing (placeholders are drawn; '
          'run with --release to fail on them).');
    }
    final b = result.bundle;
    if (b != null) {
      stdout.writeln('Content OK: ${b.officers.length} officers, ${b.commanders.length} enemies, '
          '${b.cards.length} cards, ${b.maps.length} maps, ${b.missions.length} missions, '
          '${b.sources.length} sources. Hash ${b.contentHash}.');
    }
    stdout.writeln('${result.errors.length} errors, ${result.warnings.length} warnings.');
  }
  if (!result.ok) exitCode = 1;
}
