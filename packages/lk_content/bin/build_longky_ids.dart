import 'dart:convert';
import 'dart:io';

import 'package:lk_content/src/longky_ids.dart';

const _usage = '''
Builds apps/game/assets/content/longky_ids.json from Long Ký's data files.

Usage: dart run packages/lk_content/bin/build_longky_ids.dart \\
         --people <people.json> --events <events.json> [--out <longky_ids.json>]
''';

void main(List<String> args) {
  String? people;
  String? events;
  var out = 'apps/game/assets/content/longky_ids.json';
  for (var i = 0; i < args.length; i++) {
    final value = i + 1 < args.length ? args[i + 1] : null;
    switch (args[i]) {
      case '--people':
        people = value;
        i++;
      case '--events':
        events = value;
        i++;
      case '--out':
        out = value ?? out;
        i++;
      case '-h' || '--help':
        stdout.write(_usage);
        return;
      default:
        stderr.write('Unknown option ${args[i]}\n$_usage');
        exitCode = 64;
        return;
    }
  }
  if (people == null || events == null) {
    stderr.write(_usage);
    exitCode = 64;
    return;
  }
  try {
    final text = buildLongKyIdsJson(
      people: jsonDecode(File(people).readAsStringSync()),
      events: jsonDecode(File(events).readAsStringSync()),
      generatedFrom: 'Long Ký ${File(people).uri.pathSegments.last} and ${File(events).uri.pathSegments.last}',
    );
    File(out).writeAsStringSync(text);
    stdout.writeln('Wrote $out');
  } on FormatException catch (e) {
    stderr.writeln('Cannot read the Long Ký data: ${e.message}');
    exitCode = 65;
  } on FileSystemException catch (e) {
    stderr.writeln('${e.message}: ${e.path}');
    exitCode = 66;
  }
}
