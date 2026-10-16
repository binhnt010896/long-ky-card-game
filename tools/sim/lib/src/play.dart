import 'dart:io';

import 'package:lk_rules/lk_rules.dart';

import 'describe.dart';

const _help = '''
Commands: a number picks that action · e = end phase · b = show the board ·
l = list actions again · s = show the save (action log) · h = help · q = quit
''';

/// Text-mode game for checking rules before the UI exists. Reads commands
/// with [readLine] (one per line; null at end of input) and writes to [out].
/// Returns the final state.
GameState playInTerminal(GameEngine engine, int seed, {String? Function()? readLine, StringSink? out}) {
  final o = out ?? stdout;
  final read = readLine ?? stdin.readLineSync;
  return _play(engine, seed, read, o);
}

GameState _play(GameEngine engine, int seed, String? Function() read, StringSink out) {
  final d = Describer(engine);
  final start = engine.newGame(seed);
  var s = start.state;
  out
    ..writeln('Long Ký - The Game · text mode · seed $seed')
    ..writeln(engine.def.mission.briefing.vi)
    ..writeln(_help);
  for (final e in start.events) {
    out.writeln('  ${d.event(s, e)}');
  }
  out.write(d.board(s));
  var legal = engine.legalActions(s);
  _list(out, d, s, legal);

  while (!s.isOver) {
    out.write('> ');
    final line = read()?.trim();
    if (line == null) {
      out.writeln('\n(input closed)');
      return s;
    }
    if (line.isEmpty) continue;
    GameAction? action;
    switch (line) {
      case 'q':
        out.writeln('Quit.');
        return s;
      case 'h':
        out.write(_help);
        continue;
      case 'b':
        out.write(d.board(s));
        continue;
      case 'l':
        _list(out, d, s, legal);
        continue;
      case 's':
        out.writeln(SaveGame(missionId: s.missionId, contentHash: '-', seed: seed, actions: s.log).toJson());
        continue;
      case 'e':
        action = const GameAction.endPhase();
      default:
        final n = int.tryParse(line);
        if (n == null || n < 1 || n > legal.length) {
          out.writeln('Unknown command "$line". Type h for help.');
          continue;
        }
        action = legal[n - 1];
    }
    final before = s;
    try {
      final r = engine.apply(s, action);
      s = r.state;
      out.writeln('» ${d.action(before, action)}');
      for (final e in r.events) {
        out.writeln('  ${d.event(s, e)}');
      }
    } on IllegalAction catch (e) {
      out.writeln('Not legal now: $e');
      continue;
    }
    if (s.isOver) break;
    if (s.turn != before.turn || s.phase != before.phase) out.write(d.board(s));
    legal = engine.legalActions(s);
    _list(out, d, s, legal);
  }
  out
    ..writeln(s.outcome == Outcome.won ? engine.def.mission.debrief.vi : 'Defeat: ${s.lossReason}')
    ..writeln('Stars: ${[for (final x in s.stars) x ? '★' : '☆'].join()}');
  return s;
}

void _list(StringSink out, Describer d, GameState s, List<GameAction> legal) {
  if (s.pendingChoice != null) out.writeln('A choice is pending:');
  for (var i = 0; i < legal.length; i++) {
    out.writeln('  ${(i + 1).toString().padLeft(2)}) ${d.action(s, legal[i])}');
  }
}
