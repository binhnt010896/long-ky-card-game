import 'package:lk_content/io.dart';
import 'package:lk_content/lk_content.dart';
import 'package:lk_rules/lk_rules.dart';
import 'package:sim/sim.dart';
import 'package:test/test.dart';

void main() {
  final content = loadContent(readContentDir(findContentDir()!));

  group('strategies', () {
    for (final missionId in content.missions.keys) {
      for (final name in strategyNames) {
        test('$name plays $missionId to the end with every invariant holding', () {
          final engine = GameEngine(content.ruleset(missionId));
          final report = runGames(engine, strategyByName(name), games: 25, seed: 1);
          expect(report.games, 25);
          expect(report.violationCount, 0, reason: report.violations.join('\n'));
          expect(report.avgTurns, inInclusiveRange(1, engine.def.mission.seasonTurns));
        });
      }
    }

    test('runs are deterministic for a seed', () {
      final engine = GameEngine(content.ruleset('ch1_m3'));
      final a = runGames(engine, strategyByName('random'), games: 30, seed: 7).toJson();
      final b = runGames(engine, strategyByName('random'), games: 30, seed: 7).toJson();
      expect(a, b);
    });

    test('expert follows the plan: the king escapes in ch1_m2', () {
      final engine = GameEngine(content.ruleset('ch1_m2'));
      final r = playGame(engine, strategyByName('expert'), 1);
      expect(r.end.outcome, Outcome.won);
      expect(r.end.officers['tran-thai-tong']!.nodeId, anyOf('thang-long', 'song-lo'));
      expect(r.end.missionStats.captures, 0);
    });

    test('expert counterattacks at Đông Bộ Đầu in ch1_m5', () {
      final engine = GameEngine(content.ruleset('ch1_m5'));
      final r = playGame(engine, strategyByName('expert'), 1);
      expect(r.end.outcome, Outcome.won);
      expect(r.end.missionStats.counterattackNodes, contains('dong-bo-dau'));
    });

    test('unknown strategy names are rejected', () {
      expect(() => strategyByName('cheater'), throwsArgumentError);
    });
  });

  group('invariant checker', () {
    test('reports broken states', () {
      final engine = GameEngine(content.ruleset('ch1_m2'));
      final s = engine.newGame(1).state;
      expect(checkInvariants(engine, s, deckSize: 7), isEmpty);
      final broken = s.copyWith(
        unity: s.unity.copyWith(court: 11),
        rice: -1,
        turn: 9,
        hand: [...s.hand, 'x', 'y'],
      );
      final problems = checkInvariants(engine, broken, deckSize: 7);
      expect(problems.join('\n'), allOf(contains('Unity court'), contains('Rice'), contains('seasonTurns'), contains('hand')));
    });
  });

  group('report', () {
    test('JSON carries the fields CI reads', () {
      final engine = GameEngine(content.ruleset('ch1_m1'));
      final json = runGames(engine, strategyByName('expert'), games: 5, seed: 1).toJson();
      expect(json.keys, containsAll([
        'mission',
        'strategy',
        'games',
        'winRate',
        'avgTurns',
        'avgSupplyLeft',
        'avgDefections',
        'cardPlays',
        'starRates',
        'invariantViolations',
      ]));
      expect(json['winRate'], 1.0);
    });
  });

  group('text mode (--play)', () {
    String? Function() scripted(List<String> lines) {
      var i = 0;
      return () => i < lines.length ? lines[i++] : null;
    }

    test('ch1_m2 can be played start to finish in the terminal', () {
      final engine = GameEngine(content.ruleset('ch1_m2'));
      final out = StringBuffer();
      // Help, board, a bad command, then end every phase for the four turns
      // (the king holds, loses the battle at Bình Lệ Nguyên and withdraws;
      // doing nothing does not win the mission, since T-25).
      final end = playInTerminal(
        engine,
        1,
        readLine: scripted(['h', 'b', 'nope', '999', ...List.filled(8, 'e')]),
        out: out,
      );
      final text = out.toString();
      expect(end.isOver, isTrue);
      expect(end.outcome, Outcome.lost);
      expect(text, contains('Unknown command "nope"'));
      expect(text, contains('Battle at Bình Lệ Nguyên'));
      expect(text, contains('Mission LOST'));
    });

    test('choices are offered and resolved by number in ch1_m1', () {
      final engine = GameEngine(content.ruleset('ch1_m1'));
      final out = StringBuffer();
      final lines = <String>[];
      for (var turn = 0; turn < 3; turn++) {
        lines.addAll(['1', 'e', 'e']);
      }
      final end = playInTerminal(engine, 1, readLine: scripted(lines), out: out);
      expect(out.toString(), contains('A choice is pending'));
      expect(out.toString(), contains('Khước từ / Refuse'));
      expect(end.outcome, Outcome.won);
      expect(end.unity.people, 9);
    });

    test('closed input ends the session without an error', () {
      final engine = GameEngine(content.ruleset('ch1_m2'));
      final out = StringBuffer();
      final end = playInTerminal(engine, 1, readLine: scripted(const []), out: out);
      expect(end.isOver, isFalse);
      expect(out.toString(), contains('(input closed)'));
    });
  });
}
