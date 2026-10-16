import 'dart:convert';
import 'dart:io';

import 'package:lk_content/io.dart';
import 'package:lk_content/lk_content.dart';
import 'package:lk_rules/lk_rules.dart';
import 'package:sim/sim.dart';

const _usage = '''
Long Ký - The Game: headless balance simulator and text-mode player.

Usage:
  dart run tools/sim/bin/sim.dart [--mission ch1_m2|all] [--strategy expert|naive|passive|random|all]
                                  [--games 1000] [--seed 1] [--json report.json|-] [--content <dir>]
  dart run tools/sim/bin/sim.dart --play --mission ch1_m2 [--seed 1]
  dart run tools/sim/bin/sim.dart --trace --mission ch1_m3 --strategy expert [--seed 1]
  dart run tools/sim/bin/sim.dart --bench [--mission ch1_m3|all] [--strategy expert|...] [--games 200]

Prints win rate, average turns, average Supply left per army, defections and
card play counts per mission and strategy, and checks the build-spec section 7
invariants after every step. Exits with code 1 if any invariant fails.
''';

void main(List<String> args) {
  var mission = 'ch1_m2';
  var strategies = 'all';
  var games = 1000;
  var seed = 1;
  var play = false;
  var trace = false;
  var bench = false;
  String? jsonOut;
  String? contentPath;
  for (var i = 0; i < args.length; i++) {
    String value() {
      if (i + 1 >= args.length) throw FormatException('${args[i]} needs a value');
      return args[++i];
    }

    try {
      switch (args[i]) {
        case '--mission':
          mission = value();
        case '--strategy':
          strategies = value();
        case '--games':
          games = int.parse(value());
        case '--seed':
          seed = int.parse(value());
        case '--json':
          jsonOut = value();
        case '--content':
          contentPath = value();
        case '--play':
          play = true;
        case '--trace':
          trace = true;
        case '--bench':
          bench = true;
        case '-h' || '--help':
          stdout.write(_usage);
          return;
        default:
          throw FormatException('unknown option ${args[i]}');
      }
    } on FormatException catch (e) {
      stderr.write('${e.message}\n\n$_usage');
      exitCode = 64;
      return;
    }
  }

  final dir = contentPath != null ? Directory(contentPath) : findContentDir();
  if (dir == null || !dir.existsSync()) {
    stderr.writeln('Content directory not found.');
    exitCode = 66;
    return;
  }
  final files = readContentDir(dir);
  final ContentBundle content;
  try {
    content = loadContent(files);
  } on ContentException catch (e) {
    stderr.writeln(e);
    exitCode = 65;
    return;
  }

  final missionIds = mission == 'all' ? content.missions.keys.toList() : [mission];
  for (final id in missionIds) {
    if (!content.missions.containsKey(id)) {
      stderr.writeln('No mission "$id". Missions: ${content.missions.keys.join(', ')}');
      exitCode = 64;
      return;
    }
  }

  if (play) {
    playInTerminal(GameEngine(content.ruleset(missionIds.first)), seed);
    return;
  }

  final names = strategies == 'all' ? strategyNames : strategies.split(',');
  if (trace) {
    final engine = GameEngine(content.ruleset(missionIds.first));
    traceGame(engine, strategyByName(names.first.trim()), seed, stdout);
    return;
  }
  if (bench) {
    stdout.writeln('mission  strategy  steps   mean µs  p50  p95  p99  max   | Resolution steps: p99  max (µs)');
    for (final id in missionIds) {
      final engine = GameEngine(content.ruleset(id));
      for (final name in names) {
        final t = benchSteps(engine, strategyByName(name.trim()), games: games, seed: seed);
        stdout.writeln('${id.padRight(8)} ${name.trim().padRight(9)} ${t.count.toString().padLeft(5)} '
            '${t.mean.round().toString().padLeft(8)} ${t.percentile(0.5).toString().padLeft(4)} '
            '${t.percentile(0.95).toString().padLeft(4)} ${t.percentile(0.99).toString().padLeft(4)} '
            '${t.max.toString().padLeft(5)}   | ${t.resolutionPercentile(0.99).toString().padLeft(5)} '
            '${t.resolutionMax.toString().padLeft(5)}');
      }
    }
    return;
  }
  final reports = <StrategyReport>[];
  final watch = Stopwatch()..start();
  for (final id in missionIds) {
    final engine = GameEngine(content.ruleset(id));
    for (final name in names) {
      final Strategy strategy;
      try {
        strategy = strategyByName(name.trim());
      } on ArgumentError catch (e) {
        stderr.writeln(e.message);
        exitCode = 64;
        return;
      }
      reports.add(runGames(engine, strategy, games: games, seed: seed));
    }
  }
  watch.stop();

  final violations = reports.fold(0, (sum, r) => sum + r.violationCount);
  if (jsonOut != '-') {
    _printTable(reports, content);
    stdout.writeln('${reports.length * games} games in ${(watch.elapsedMilliseconds / 1000).toStringAsFixed(1)} s; '
        'invariant violations: $violations.');
  }
  if (jsonOut != null) {
    final json = const JsonEncoder.withIndent('  ').convert({
      'games': games,
      'seed': seed,
      'contentHash': content.contentHash,
      'invariantViolations': violations,
      'reports': [for (final r in reports) r.toJson()],
    });
    if (jsonOut == '-') {
      stdout.writeln(json);
    } else {
      File(jsonOut)
        ..parent.createSync(recursive: true)
        ..writeAsStringSync('$json\n');
      stdout.writeln('JSON report: $jsonOut');
    }
  }
  if (violations > 0) {
    for (final r in reports) {
      for (final v in r.violations) {
        stderr.writeln('${r.missionId}/${r.strategy}: $v');
      }
    }
    exitCode = 1;
  }
}

void _printTable(List<StrategyReport> reports, ContentBundle content) {
  String pct(double x) => '${(x * 100).toStringAsFixed(1)}%'.padLeft(6);
  stdout.writeln('mission  strategy  games   win%  turns  turns(won)  supply left      defect  stars 1/2/3          cards played');
  for (final r in reports) {
    final supply = r.supplyLeft.entries.map((e) => (e.value / r.games).toStringAsFixed(1)).join(',');
    final stars = r.stars.map((x) => pct(x / r.games).trim()).join(' / ');
    final cards = (r.cardPlays.entries.toList()..sort((a, b) => b.value.compareTo(a.value)))
        .map((e) => '${e.key}:${(e.value / r.games).toStringAsFixed(2)}')
        .join(' ');
    stdout.writeln('${r.missionId.padRight(8)} ${r.strategy.padRight(9)} ${r.games.toString().padLeft(5)} ${pct(r.winRate)} '
        '${r.avgTurns.toStringAsFixed(2).padLeft(6)} ${r.avgTurnsWon.toStringAsFixed(2).padLeft(10)}  '
        '${supply.padRight(15)} ${(r.defections / r.games).toStringAsFixed(2).padLeft(6)}  ${stars.padRight(20)} $cards');
    if (r.lossReasons.isNotEmpty) {
      final reasons = r.lossReasons.entries.map((e) => '${e.key} ${pct(e.value / r.games).trim()}').join(', ');
      stdout.writeln('         losses: $reasons');
    }
  }
}
