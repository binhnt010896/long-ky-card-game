import 'package:lk_rules/lk_rules.dart';
import 'package:test/test.dart';

import 'support/fixture.dart';

void main() {
  MissionDef m() => mission(officers: [at('king', 'cap', 12), at('scholar', 'cap', 4)], armies: [army('hl')]);

  /// A game whose mission ended in Council as a loss (the king was captured).
  GameState lostInCouncil(GameEngine e) {
    final s = e.newGame(1).state;
    return s.copyWith(
      phase: Phase.ended,
      endedIn: Phase.council,
      outcome: Outcome.lost,
      lossReason: LossReasons.kingCaptured,
      stars: const [false],
    );
  }

  test('free play cannot start before the mission has ended', () {
    final e = engineFor(m());
    final s = e.newGame(1).state;
    expect(() => e.apply(s, const GameAction.continueFreePlay()), throwsA(isA<IllegalAction>()));
  });

  test('after the mission ended, Continue starts free play where it stopped; the result stands', () {
    final e = engineFor(m());
    final over = lostInCouncil(e);
    final r = e.apply(over, const GameAction.continueFreePlay());
    expect(r.events.whereType<FreePlayStarted>(), hasLength(1));
    expect(r.state.freePlay, isTrue);
    expect(r.state.isOver, isFalse);
    expect(r.state.phase, Phase.council);
    expect(r.state.outcome, Outcome.lost, reason: 'the mission result is not rewritten');
    expect(r.state.lossReason, LossReasons.kingCaptured);
    expect(e.legalActions(r.state), isNotEmpty);
    // It can be started only once.
    expect(() => e.apply(r.state, const GameAction.continueFreePlay()), throwsA(isA<IllegalAction>()));
  });

  test('a mission cut short in Resolution is finished: the turn moves on', () {
    final e = engineFor(m());
    final s = e.newGame(1).state;
    final over = s.copyWith(
      phase: Phase.ended,
      endedIn: Phase.resolution,
      outcome: Outcome.won,
      stars: const [true],
    );
    final r = e.apply(over, const GameAction.continueFreePlay());
    expect(r.state.turn, s.turn + 1);
    expect(r.state.phase, Phase.council);
    expect(r.state.freePlay, isTrue);
  });

  test('free play ignores the mission rules: a king captured or a past season do not end it', () {
    final e = engineFor(m());
    var s = e.apply(lostInCouncil(e), const GameAction.continueFreePlay()).state;
    s = s.copyWith(turn: e.def.mission.seasonTurns + 3);
    s = e.apply(s, const GameAction.endPhase()).state;
    expect(s.isOver, isFalse);
  });

  test('free play ends, truly, when the Yuan have no troops left: a free-play win', () {
    final e = engineFor(m());
    var s = e.apply(lostInCouncil(e), const GameAction.continueFreePlay()).state;
    s = s.copyWith(armies: {for (final a in s.armies.entries) a.key: a.value.copyWith(troops: 0)});
    final r = e.apply(s, const GameAction.endPhase());
    expect(r.state.isOver, isTrue);
    expect(r.state.freePlayOutcome, Outcome.won);
    expect(r.events.whereType<FreePlayEnded>().single.playerWon, isTrue);
    expect(r.state.outcome, Outcome.lost, reason: 'the mission result still stands');
    expect(() => e.apply(r.state, const GameAction.endPhase()), throwsA(isA<IllegalAction>()));
    expect(() => e.apply(r.state, const GameAction.continueFreePlay()), throwsA(isA<IllegalAction>()));
  });

  test('free play ends when our officers have no troops left: a free-play loss', () {
    final e = engineFor(m());
    var s = e.apply(lostInCouncil(e), const GameAction.continueFreePlay()).state;
    s = s.copyWith(officers: {for (final o in s.officers.entries) o.key: o.value.copyWith(troops: 0)});
    final r = e.apply(s, const GameAction.endPhase());
    expect(r.state.isOver, isTrue);
    expect(r.state.freePlayOutcome, Outcome.lost);
  });

  test('replaying the log of a free play gives the same state', () {
    final e = engineFor(m());
    var s = e.newGame(7).state;
    final log = <GameAction>[const GameAction.endPhase(), const GameAction.endPhase()];
    for (final a in log) {
      s = e.apply(s, a).state;
    }
    final replayed = e.replay(7, s.log);
    expect(stateHash(replayed), stateHash(s));
  });
}
