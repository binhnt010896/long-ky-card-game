import 'package:flutter_test/flutter_test.dart';
import 'package:lk_rules/lk_rules.dart';
import 'package:long_ky_game/features/battle/battle_cubit.dart';
import 'package:long_ky_game/features/battle/battle_preview.dart';

import 'board_support.dart';

void main() {
  final rules = ruleset('ch1_m2');
  final engine = GameEngine(rules);
  final start = engine.newGame(1).state;
  final orders = engine.apply(start, const GameAction.endPhase()).state;

  group('battle preview (which orders cause a battle)', () {
    test('holding at the node the Yuan assault: a field battle with all three officers', () {
      final p = battlePreviewsFor(engine, orders, 'tran-thai-tong', Order.hold);
      expect(p, hasLength(1));
      expect(p.single.kind, BattleKind.field);
      expect(p.single.nodeId, 'binh-le-nguyen');
      expect(p.single.officerIds, unorderedEquals(['tran-thai-tong', 'le-phu-tran', 'tran-thu-do']));
      expect(p.single.armyIds, ['mong-co-1258']);
    });

    test('the forecast is the engine\'s own, losses included', () {
      final p = battlePreviewsFor(engine, orders, 'tran-thai-tong', Order.hold).single;
      final f = engine.forecastBattle(
        orders,
        'binh-le-nguyen',
        officerIds: p.officerIds,
        armyIds: p.armyIds,
        orders: {for (final id in p.officerIds) id: id == 'tran-thai-tong' ? Order.hold : null},
      );
      expect(p.forecast.daiVietPower, f.daiVietPower);
      expect(p.forecast.yuanPower, f.yuanPower);
      expect(p.forecast.winner, f.winner);
      expect(p.forecast.daiVietLosses, f.daiVietLosses);
      expect(p.certain, isTrue);
      expect(p.isRange, isFalse);
    });

    test('a move away from the assault causes no battle for that officer', () {
      // The preview is about where this officer fights. What the officers left
      // behind will face is shown when they are given their own orders.
      final p = battlePreviewsFor(engine, orders, 'tran-thai-tong', Order.move('thang-long'));
      expect(p, isEmpty, reason: 'Thăng Long is empty');
    });

    test('moving where no army is going: no preview', () {
      // All three have left for Thăng Long, so nobody is left for the army to fight.
      var s = orders;
      for (final id in ['le-phu-tran', 'tran-thu-do']) {
        s = engine.apply(s, GameAction.setOrder(officerId: id, order: Order.move('thang-long'))).state;
      }
      expect(battlePreviewsFor(engine, s, 'tran-thai-tong', Order.move('thang-long')), isEmpty);
    });

    test('moving into the army\'s own node is a battle you start', () {
      final p = battlePreviewsFor(engine, orders, 'tran-thai-tong', Order.move('bach-hac'));
      final atBachHac = p.where((x) => x.nodeId == 'bach-hac');
      expect(atBachHac, hasLength(0), reason: 'the army leaves Bạch Hạc for Bình Lệ Nguyên this turn');
    });

    test('an ambush on the edge the army crosses shows a range', () {
      // Move the army so that it crosses a river edge a Đại Việt officer touches.
      final s = orders.copyWith(
        armies: {
          'mong-co-1258': orders.armies['mong-co-1258']!.copyWith(
            nodeId: 'song-thao',
            intent: const Intent(kind: IntentKind.advance, moveTo: 'bach-hac', targetNodeId: 'bach-hac'),
          ),
        },
        officers: {
          ...orders.officers,
          'le-phu-tran': orders.officers['le-phu-tran']!.copyWith(nodeId: 'bach-hac'),
        },
      );
      final edge = engine.graph.edge('song-thao', 'bach-hac')!;
      expect(edge.kind, EdgeKind.river);
      final p = battlePreviewsFor(engine, s, 'le-phu-tran', Order.ambush(edge.key));
      final ambush = p.firstWhere((x) => x.kind == BattleKind.ambush);
      expect(ambush.isRange, isTrue);
      expect(ambush.edge, edge.key);
      expect(ambush.forecast.daiVietPowerMax, greaterThan(ambush.forecast.daiVietPower));
    });

    test('orders that stay away from any army have no preview', () {
      final s = orders.copyWith(
        armies: {'mong-co-1258': orders.armies['mong-co-1258']!.copyWith(intent: const Intent(kind: IntentKind.hold))},
      );
      expect(battlePreviewsFor(engine, s, 'tran-thai-tong', Order.rally), isEmpty);
    });
  });

  group('BattleCubit', () {
    test('starts at Council with the opening events', () {
      final c = BattleCubit(engine, seed: 1);
      addTearDown(c.close);
      expect(c.game.phase, Phase.council);
      expect(c.state.events, isNotEmpty);
      expect(c.state.step, 0);
    });

    test('a legal action changes the state and counts as a step with its events', () {
      final c = BattleCubit(engine, seed: 1);
      addTearDown(c.close);
      final before = c.state.events.length;
      expect(c.endPhase(), isTrue);
      expect(c.game.phase, Phase.orders);
      expect(c.state.step, 1);
      expect(c.state.lastEvents, isNotEmpty);
      expect(c.state.events.length, before + c.state.lastEvents.length);
    });

    test('an illegal action is refused and changes nothing', () {
      final c = BattleCubit(engine, seed: 1);
      addTearDown(c.close);
      final s = c.state;
      expect(c.setOrder('tran-thai-tong', Order.hold), isFalse, reason: 'not the Orders phase');
      expect(c.playCard('lui-binh-bao-toan', target: 'nobody'), isFalse);
      expect(identical(c.state, s), isTrue);
    });

    test('orders can be changed freely and cleared until the phase ends', () {
      final c = BattleCubit(engine, seed: 1);
      addTearDown(c.close);
      c.endPhase();
      expect(c.setOrder('tran-thai-tong', Order.hold), isTrue);
      expect(c.setOrder('tran-thai-tong', Order.move('thang-long')), isTrue);
      expect(c.game.officers['tran-thai-tong']!.order, Order.move('thang-long'));
      expect(c.clearOrder('tran-thai-tong'), isTrue);
      expect(c.game.officers['tran-thai-tong']!.order, isNull);
    });

    test('a played card is final: it leaves the hand and cannot be played again', () {
      final c = BattleCubit(engine, seed: 1);
      addTearDown(c.close);
      final hand = c.game.hand.length;
      expect(c.playCard('vuon-khong-nha-trong', target: 'binh-le-nguyen'), isTrue);
      expect(c.game.hand.length, hand - 1);
      expect(c.playCard('vuon-khong-nha-trong', target: 'binh-le-nguyen'), isFalse);
    });

    test('legalActions is cached per state and follows the state', () {
      final c = BattleCubit(engine, seed: 1);
      addTearDown(c.close);
      final a = c.legalActions;
      expect(identical(a, c.legalActions), isTrue);
      c.endPhase();
      expect(c.legalActions.whereType<SetOrder>(), isNotEmpty);
      expect(c.legalActions.whereType<PlayCard>(), isEmpty);
    });

    test('a pending choice blocks everything but the choice, and resolving it carries on', () {
      final e = GameEngine(ruleset('ch1_m1'));
      final c = BattleCubit(e, seed: 1);
      addTearDown(c.close);
      expect(c.game.pendingChoice, isNotNull);
      expect(c.endPhase(), isFalse);
      expect(c.resolveChoice(0), isTrue);
      expect(c.game.pendingChoice, isNull);
      expect(c.endPhase(), isTrue);
    });
  });
}
