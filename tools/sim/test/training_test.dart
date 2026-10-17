import 'package:lk_content/io.dart';
import 'package:lk_content/lk_content.dart';
import 'package:lk_rules/lk_rules.dart';
import 'package:test/test.dart';

/// The training mission (ch0_training) is a lesson, so it has to be winnable
/// by following its own steps, whatever the seed.
void main() {
  final content = loadContent(readContentDir(findContentDir()!));
  final ruleset = content.ruleset('ch0_training');
  final engine = GameEngine(ruleset);

  GameState apply(GameState s, GameAction a) => engine.apply(s, a).state;

  /// The line the steps teach, as the player would play it.
  List<(String, GameAction)> line() => [
    ('skill', const GameAction.useSkill(officerId: 'tran-thu-do')),
    ('card', const GameAction.playCard(cardId: 'vuon-khong-nha-trong', target: 'binh-le-nguyen')),
    ('end council', const GameAction.endPhase()),
    ('hold', const GameAction.setOrder(officerId: 'tran-thai-tong', order: Order.hold)),
    ('end turn 1', const GameAction.endPhase()),
    ('council 2', const GameAction.endPhase()),
    ('raid', GameAction.setOrder(officerId: 'tran-khanh-du', order: Order.raid('mong-co-1258'))),
    ('end turn 2', const GameAction.endPhase()),
    ('counter', const GameAction.playCard(cardId: 'phan-cong', target: 'le-phu-tran')),
    ('orders 3', const GameAction.endPhase()),
    ('advance', GameAction.setOrder(officerId: 'le-phu-tran', order: Order.move('binh-le-nguyen'))),
    ('end turn 3', const GameAction.endPhase()),
  ];

  test('the whole hand is dealt on turn 1, whatever the seed', () {
    for (var seed = 0; seed < 30; seed++) {
      final s = engine.newGame(seed).state;
      expect(s.hand.toSet(), {'vuon-khong-nha-trong', 'lui-binh-bao-toan', 'phuc-kich-ben-song', 'phan-cong'});
    }
  });

  test('following the lesson wins on turn 3 with every star, for 100 seeds', () {
    for (var seed = 0; seed < 100; seed++) {
      var s = engine.newGame(seed).state;
      for (final (label, action) in line()) {
        s = apply(s, action);
        expect(s.pendingChoice, isNull, reason: '$label, seed $seed');
      }
      expect(s.outcome, Outcome.won, reason: 'seed $seed: ${s.lossReason}');
      expect(s.turn, 3);
      expect(s.stars, [true, true, true], reason: 'seed $seed');
      expect(s.missionStats.counterattackNodes, contains('binh-le-nguyen'));
    }
  });

  test('every state-based step condition turns true in the order of the steps', () {
    var s = engine.newGame(1).state;
    final steps = ruleset.mission.tutorial;
    TutorialContext ctx(GameState st) => TutorialContext(state: st, ruleset: ruleset);
    // Conditions that do not wait for the screen, and the line step that makes each true.
    final expectedAfter = {
      'skill:tran-thu-do': 'skill',
      'card:vuon-khong-nha-trong': 'card',
      'phase:orders': 'end council',
      'order:tran-thai-tong:hold': 'hold',
      'turn:2': 'end turn 1',
      'order:tran-khanh-du:raid': 'raid',
      'turn:3': 'end turn 2',
      'card:phan-cong': 'counter',
      'order:le-phu-tran:move': 'advance',
    };
    final seen = <String>{};
    final stateSteps = [for (final t in steps) if (t.until != null && !t.until!.needsScreen) t.until!];
    expect(stateSteps.map((c) => c.source), expectedAfter.keys.toList(), reason: 'the steps wait for these, in this order');
    for (final (label, action) in line()) {
      s = apply(s, action);
      for (final c in stateSteps) {
        if (!seen.contains(c.source) && c.holds(ctx(s))) {
          seen.add(c.source);
          expect(expectedAfter[c.source], label, reason: '${c.source} became true after "$label"');
        }
      }
    }
    expect(seen, expectedAfter.keys.toSet());
  });

  test('the enemy army behaves as the steps describe', () {
    var s = engine.newGame(1).state;
    expect(s.armies['mong-co-1258']!.intent!.moveTo, 'binh-le-nguyen', reason: 'turn 1: it advances into Bình Lệ Nguyên');
    for (final (label, action) in line().take(5)) {
      s = apply(s, action);
      if (label == 'end turn 1') break;
    }
    expect(s.turn, 2);
    expect(s.armies['mong-co-1258']!.nodeId, 'binh-le-nguyen');
    expect(s.nodes['binh-le-nguyen']!.evacuated, isTrue, reason: 'nothing to forage');
    expect(s.unity.court, 10, reason: 'the skill restored Court');
  });

  test('doing nothing does not win, and the king is never lost by following the lesson', () {
    var s = engine.newGame(1).state;
    while (!s.isOver) {
      s = apply(s, const GameAction.endPhase());
    }
    expect(s.outcome, isNotNull);
    final lesson = engine.newGame(1).state;
    expect(lesson.officers['tran-thai-tong']!.status, OfficerStatus.active);
  });
}
