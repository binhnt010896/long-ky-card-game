import 'package:flutter_test/flutter_test.dart';
import 'package:lk_rules/lk_rules.dart';
import 'package:long_ky_game/features/battle/board/board_animator.dart';

import 'board_support.dart';

BattleResolved battleAt(String node, Side winner) => BattleResolved(
  BattleReport(
    kind: BattleKind.field,
    nodeId: node,
    officerIds: const ['a'],
    armyIds: const ['y'],
    daiVietPower: 1,
    yuanPower: 1,
    winner: winner,
    officerLosses: const {},
    armyLosses: const {},
  ),
);

String? nowhere(String id) => null;

void main() {
  group('BoardAnimator', () {
    test('is idle until something is queued, and events without an effect queue nothing', () {
      final a = BoardAnimator();
      expect(a.isBusy, isFalse);
      a.enqueue([
        const TurnStarted(2),
        const PhaseChanged(Phase.orders),
        const UnityChanged(Pillar.court, 5, 4),
      ], nodeOfOfficer: nowhere);
      expect(a.isBusy, isFalse);
      expect(a.active, isEmpty);
    });

    test('moves that follow each other play together; a battle is its own step', () {
      final a = BoardAnimator();
      a.enqueue([
        const OfficerMoved('king', 'x', 'y', MoveReason.order),
        const OfficerMoved('duke', 'x', 'y', MoveReason.order),
        const ArmyMoved('army', 'p', 'q', MoveReason.intent),
        battleAt('y', Side.yuan),
        const OfficerMoved('king', 'y', 'z', MoveReason.battleWithdraw),
      ], nodeOfOfficer: nowhere);
      expect(a.stepsLeft, 3);
      expect(a.active.map((e) => e.effect).whereType<MoveEffect>(), hasLength(3));
      a.update(0.41);
      expect(a.stepsLeft, 2);
      expect(a.active.single.effect, isA<BattleEffect>());
      a.update(0.61);
      expect(a.stepsLeft, 1);
      expect(a.active.single.effect, isA<MoveEffect>());
      a.update(0.5);
      expect(a.isBusy, isFalse);
      expect(a.active, isEmpty);
    });

    test('progress runs from 0 to 1 within a step', () {
      final a = BoardAnimator();
      a.enqueue([const Foraged('army', 'n', 2)], nodeOfOfficer: nowhere);
      expect(a.active.single.progress, 0);
      a.update(0.25);
      expect(a.active.single.progress, closeTo(0.5, 1e-9));
    });

    test('forage and defection play as effects at their node', () {
      final a = BoardAnimator();
      a.enqueue([
        const Foraged('army', 'n1', 2),
        const OfficerDefected('duke'),
        const OfficerDefected('ghost'),
      ], nodeOfOfficer: (id) => id == 'duke' ? 'n2' : null);
      expect(a.stepsLeft, 2, reason: 'an officer with no node has nothing to show');
      expect((a.active.single.effect as ForageEffect).nodeId, 'n1');
      a.update(0.51);
      expect((a.active.single.effect as DefectEffect).nodeId, 'n2');
    });

    test('moveOf: waiting units show their start, travelling ones their progress, finished ones nothing', () {
      final a = BoardAnimator();
      a.enqueue([
        const OfficerMoved('king', 'a', 'b', MoveReason.order),
        battleAt('b', Side.daiViet),
        const OfficerMoved('king', 'b', 'c', MoveReason.battleWithdraw),
        const OfficerMoved('other', 'x', 'y', MoveReason.battleWithdraw),
      ], nodeOfOfficer: nowhere);
      var m = a.moveOf('king')!;
      expect(m.move.from, 'a');
      expect(m.progress, 0);
      a.update(0.2);
      expect(a.moveOf('king')!.progress, closeTo(0.5, 1e-9));
      a.update(0.2 + 0.6); // the move and the battle are over
      m = a.moveOf('king')!;
      expect(m.move.from, 'b', reason: 'the second move is the next one');
      expect(a.moveOf('other')!.move.from, 'x');
      expect(a.moveOf('nobody'), isNull);
      a.update(1);
      expect(a.moveOf('king'), isNull);
    });

    test('events queued while busy join the queue; an idle queue starts afresh', () {
      final a = BoardAnimator();
      a.enqueue([const Foraged('army', 'n', 1)], nodeOfOfficer: nowhere);
      a.enqueue([battleAt('n', Side.yuan)], nodeOfOfficer: nowhere);
      expect(a.stepsLeft, 2);
      a.update(5);
      expect(a.isBusy, isFalse);
      a.enqueue([battleAt('n', Side.yuan)], nodeOfOfficer: nowhere);
      expect(a.stepsLeft, 1);
    });

    test('clear drops everything (reduce motion, skip)', () {
      final a = BoardAnimator();
      a.enqueue([battleAt('n', Side.yuan), battleAt('m', Side.daiViet)], nodeOfOfficer: nowhere);
      a.clear();
      expect(a.isBusy, isFalse);
      expect(a.moveOf('king'), isNull);
    });

    test('a very long turn is sped up to fit in the cap', () {
      final a = BoardAnimator();
      a.enqueue([for (var i = 0; i < 30; i++) battleAt('n$i', Side.yuan)], nodeOfOfficer: nowhere);
      var t = 0.0;
      while (a.isBusy && t < 60) {
        a.update(0.05);
        t += 0.05;
      }
      expect(a.isBusy, isFalse);
      expect(t, lessThanOrEqualTo(BoardAnimator.maxTotalSeconds + 0.5));
    });

    test('a real turn: ending Orders on ch1_m2 becomes moves and a battle', () {
      // Uses the engine's own events, so the mapping stays honest.
      final a = BoardAnimator();
      final e = GameEngine(ruleset('ch1_m2'));
      var s = e.newGame(1).state;
      s = e.apply(s, const GameAction.endPhase()).state;
      final r = e.apply(s, const GameAction.endPhase());
      a.enqueue(r.events, nodeOfOfficer: (id) => r.state.officers[id]?.nodeId);
      final seen = <Type>{};
      while (a.isBusy) {
        seen.addAll(a.active.map((x) => x.effect.runtimeType));
        a.update(0.05);
      }
      expect(seen, containsAll([MoveEffect, BattleEffect]));
    });
  });
}
