import 'package:lk_rules/lk_rules.dart';

import 'dart:io';

import 'describe.dart';
import 'invariants.dart';
import 'strategy.dart';

/// One finished game.
final class GameRecord {
  GameRecord({
    required this.seed,
    required this.end,
    required this.steps,
    required this.violations,
    required this.skipped,
  });

  final int seed;
  final GameState end;
  final int steps;
  final List<String> violations;
  final int skipped;
}

/// Plays one game of [engine] from [seed] with [strategy], checking the
/// invariants after every step. Throws if the game does not end.
GameRecord playGame(GameEngine engine, Strategy strategy, int seed, {int maxSteps = 5000}) {
  final deckSize = engine.def.mission.deck.fold(0, (sum, d) => sum + d.count);
  strategy.reset(seed);
  var s = engine.newGame(seed).state;
  final violations = [...checkInvariants(engine, s, deckSize: deckSize)];
  var steps = 0;
  while (!s.isOver) {
    if (++steps > maxSteps) {
      violations.add('game did not end within $maxSteps steps');
      break;
    }
    final action = strategy.next(engine, s);
    try {
      s = engine.apply(s, action).state;
    } on IllegalAction catch (e) {
      violations.add('strategy ${strategy.name} played an illegal action $action: $e');
      break;
    }
    violations.addAll(checkInvariants(engine, s, deckSize: deckSize));
  }
  if (s.isOver && s.turn > engine.def.mission.seasonTurns) {
    violations.add('the game ended after seasonTurns');
  }
  return GameRecord(seed: seed, end: s, steps: steps, violations: violations, skipped: strategy.skipped);
}

/// Totals over many games of one mission and strategy.
final class StrategyReport {
  StrategyReport(this.missionId, this.strategy);

  final String missionId;
  final String strategy;
  int games = 0;
  int wins = 0;
  int totalTurns = 0;
  int totalTurnsWon = 0;
  int defections = 0;
  int captures = 0;
  int totalSkipped = 0;
  final Map<String, int> supplyLeft = {};
  final Map<String, int> routed = {};
  final Map<String, int> cardPlays = {};
  final Map<String, int> skillUses = {};
  final Map<String, int> lossReasons = {};
  final List<int> stars = [0, 0, 0];
  final List<String> violations = [];

  void add(GameRecord r) {
    final s = r.end;
    games++;
    totalTurns += s.turn;
    if (s.outcome == Outcome.won) {
      wins++;
      totalTurnsWon += s.turn;
    } else {
      final reason = s.lossReason ?? 'unknown';
      lossReasons[reason] = (lossReasons[reason] ?? 0) + 1;
    }
    for (var i = 0; i < s.stars.length && i < stars.length; i++) {
      if (s.stars[i]) stars[i]++;
    }
    defections += s.missionStats.defections;
    captures += s.missionStats.captures;
    totalSkipped += r.skipped;
    for (final MapEntry(key: id, value: a) in s.armies.entries) {
      supplyLeft[id] = (supplyLeft[id] ?? 0) + a.supply;
      if (a.status == ArmyStatus.routed) routed[id] = (routed[id] ?? 0) + 1;
    }
    s.missionStats.cardsPlayed.forEach((k, v) => cardPlays[k] = (cardPlays[k] ?? 0) + v);
    s.missionStats.skillsUsed.forEach((k, v) => skillUses[k] = (skillUses[k] ?? 0) + v);
    for (final v in r.violations) {
      if (violations.length < 20) violations.add('seed ${r.seed}: $v');
    }
    _violationCount += r.violations.length;
  }

  int _violationCount = 0;
  int get violationCount => _violationCount;

  double get winRate => games == 0 ? 0 : wins / games;
  double get avgTurns => games == 0 ? 0 : totalTurns / games;
  double get avgTurnsWon => wins == 0 ? 0 : totalTurnsWon / wins;

  Map<String, Object?> toJson() => {
        'mission': missionId,
        'strategy': strategy,
        'games': games,
        'wins': wins,
        'winRate': _round(winRate),
        'avgTurns': _round(avgTurns),
        'avgTurnsWhenWon': _round(avgTurnsWon),
        'avgSupplyLeft': {for (final e in supplyLeft.entries) e.key: _round(e.value / games)},
        'armyRoutedRate': {for (final e in routed.entries) e.key: _round(e.value / games)},
        'avgDefections': _round(defections / games),
        'avgCaptures': _round(captures / games),
        'starRates': [for (final x in stars) _round(x / games)],
        'cardPlays': Map.fromEntries(cardPlays.entries.toList()..sort((a, b) => a.key.compareTo(b.key))),
        'skillUses': Map.fromEntries(skillUses.entries.toList()..sort((a, b) => a.key.compareTo(b.key))),
        'lossReasons': Map.fromEntries(lossReasons.entries.toList()..sort((a, b) => b.value.compareTo(a.value))),
        'skippedActions': totalSkipped,
        'invariantViolations': violationCount,
        'violationSamples': violations,
      };
}

double _round(double x) => (x * 1000).round() / 1000;

/// Runs [games] games with seeds `seed, seed + 1, ...`.
StrategyReport runGames(GameEngine engine, Strategy strategy, {required int games, required int seed}) {
  final report = StrategyReport(engine.def.mission.id, strategy.name);
  for (var i = 0; i < games; i++) {
    report.add(playGame(engine, strategy, seed + i));
  }
  return report;
}

/// Plays one game and prints every action and event (for debugging plans).
void traceGame(GameEngine engine, Strategy strategy, int seed, IOSink out) {
  final d = Describer(engine);
  strategy.reset(seed);
  final start = engine.newGame(seed);
  var s = start.state;
  for (final e in start.events) {
    out.writeln('  ${d.event(s, e)}');
  }
  out.write(d.board(s));
  while (!s.isOver) {
    final action = strategy.next(engine, s);
    final before = s;
    final r = engine.apply(s, action);
    s = r.state;
    out.writeln('» ${d.action(before, action)}');
    for (final e in r.events) {
      out.writeln('  ${d.event(s, e)}');
    }
    if (!s.isOver && s.turn != before.turn) out.write(d.board(s));
  }
}
