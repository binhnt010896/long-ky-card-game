import 'package:lk_rules/lk_rules.dart';
import 'package:test/test.dart';

import 'support/fixture.dart';

void main() {
  group('parse', () {
    test('reads every condition of the closed list and keeps its text', () {
      const texts = [
        'next',
        'hand',
        'zoom',
        'select:any',
        'select:node:thang-long',
        'select:officer:tran-thai-tong',
        'select:army:mong-co-1258',
        'card:vuon-khong-nha-trong',
        'skill:tran-thu-do',
        'order:tran-khanh-du:raid',
        'order:x:hold',
        'order:x:move',
        'phase:council',
        'phase:orders',
        'turn:3',
      ];
      for (final t in texts) {
        final c = TutorialCondition.parse(t);
        expect(c, isNotNull, reason: t);
        expect(c!.source, t);
      }
    });

    test('rejects everything else', () {
      for (final t in [
        '',
        'wait',
        'select',
        'select:node',
        'select:tree:x',
        'select:node:',
        'card',
        'card:',
        'order:x',
        'order:x:fly',
        'phase:resolution',
        'phase:upkeep',
        'turn:0',
        'turn:x',
        'next:now',
        'zoom:2',
      ]) {
        expect(TutorialCondition.parse(t), isNull, reason: '"$t"');
      }
    });

    test('only the state-based ones can be judged without the screen', () {
      bool screen(String t) => TutorialCondition.parse(t)!.needsScreen;
      for (final t in ['next', 'hand', 'zoom', 'select:any', 'select:officer:x']) {
        expect(screen(t), isTrue, reason: t);
      }
      for (final t in ['card:x', 'skill:x', 'order:x:hold', 'phase:orders', 'turn:2']) {
        expect(screen(t), isFalse, reason: t);
      }
    });
  });

  group('holds', () {
    final e = engineFor(mission(officers: [at('king', 'cap', 12), at('chancellor', 'cap', 6)], armies: [army('hl')]));
    GameState start() => e.newGame(1).state;
    TutorialContext ctx(GameState s, {SelectionTarget? kind, String? id, bool hand = false, bool zoomed = false}) =>
        TutorialContext(state: s, ruleset: e.def, selectedKind: kind, selectedId: id, handOpen: hand, zoomed: zoomed);
    bool holds(String t, TutorialContext c) => TutorialCondition.parse(t)!.holds(c);

    test('next never holds by itself', () => expect(holds('next', ctx(start())), isFalse));

    test('selection: any, or a specific node, officer or army', () {
      final s = start();
      expect(holds('select:any', ctx(s)), isFalse);
      expect(holds('select:any', ctx(s, kind: SelectionTarget.node, id: 'cap')), isTrue);
      expect(holds('select:node:cap', ctx(s, kind: SelectionTarget.node, id: 'cap')), isTrue);
      expect(holds('select:node:pl', ctx(s, kind: SelectionTarget.node, id: 'cap')), isFalse);
      expect(holds('select:officer:cap', ctx(s, kind: SelectionTarget.node, id: 'cap')), isFalse, reason: 'wrong kind');
      expect(holds('select:officer:king', ctx(s, kind: SelectionTarget.officer, id: 'king')), isTrue);
      expect(holds('select:army:y1', ctx(s, kind: SelectionTarget.army, id: 'y1')), isTrue);
    });

    test('cards, skills, orders, phases and turns come from the game state', () {
      var s = start().copyWith(hand: const ['evac']);
      expect(holds('card:evac', ctx(s)), isFalse);
      s = e.apply(s, const GameAction.playCard(cardId: 'evac', target: 'cap')).state;
      expect(holds('card:evac', ctx(s)), isTrue);

      expect(holds('skill:chancellor', ctx(s)), isFalse);
      s = e.apply(s, const GameAction.useSkill(officerId: 'chancellor')).state;
      expect(holds('skill:chancellor', ctx(s)), isTrue);
      expect(holds('skill:king', ctx(s)), isFalse, reason: 'the king has a passive');
      expect(holds('skill:nobody', ctx(s)), isFalse);

      expect(holds('phase:council', ctx(s)), isTrue);
      expect(holds('phase:orders', ctx(s)), isFalse);
      s = e.apply(s, const GameAction.endPhase()).state;
      expect(holds('phase:orders', ctx(s)), isTrue);

      expect(holds('order:king:hold', ctx(s)), isFalse);
      s = e.apply(s, const GameAction.setOrder(officerId: 'king', order: Order.hold)).state;
      expect(holds('order:king:hold', ctx(s)), isTrue);
      expect(holds('order:king:move', ctx(s)), isFalse);

      expect(holds('turn:1', ctx(s)), isTrue);
      expect(holds('turn:2', ctx(s)), isFalse);
      s = e.apply(s, const GameAction.endPhase()).state;
      expect(holds('turn:2', ctx(s)), isTrue);
    });

    test('the hand and the zoom come from the screen', () {
      final s = start();
      expect(holds('hand', ctx(s)), isFalse);
      expect(holds('hand', ctx(s, hand: true)), isTrue);
      expect(holds('zoom', ctx(s)), isFalse);
      expect(holds('zoom', ctx(s, zoomed: true)), isTrue);
    });
  });
}
