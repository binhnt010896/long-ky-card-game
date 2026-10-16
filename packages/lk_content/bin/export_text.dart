import 'dart:io';

import 'package:lk_content/io.dart';
import 'package:lk_content/lk_content.dart';

const _usage = '''
Exports every vi/en text of the game content as CSV, with its content id and
sourceRefs, for the history reviewer (build-spec section 9, T-26).

Usage: dart run packages/lk_content/bin/export_text.dart [options]
  --content <dir>  content root (default: apps/game/assets/content)
  --out <file>     where to write the CSV (default: build/content-text.csv)
  --no-bom         leave out the UTF-8 byte-order mark (Excel wants it)
  -h, --help       show this help
''';

void main(List<String> args) {
  var bom = true;
  String? contentPath;
  var out = 'build/content-text.csv';
  for (var i = 0; i < args.length; i++) {
    switch (args[i]) {
      case '--no-bom':
        bom = false;
      case '--content':
        contentPath = i + 1 < args.length ? args[++i] : null;
      case '--out':
        out = i + 1 < args.length ? args[++i] : out;
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
  final rows = collectTextRows(readContentDir(dir));
  final file = File(out)..parent.createSync(recursive: true);
  file.writeAsStringSync(textRowsToCsv(rows, bom: bom));
  final missing = rows.where((r) => r.sourceRefs.isEmpty).length;
  stdout.writeln('${rows.length} texts written to $out ($missing without sourceRefs).');
}
