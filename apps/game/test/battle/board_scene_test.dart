import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:lk_rules/lk_rules.dart';
import 'package:long_ky_game/features/battle/board/board_layout.dart';
import 'package:long_ky_game/features/battle/board/board_scene.dart';

import 'board_support.dart';

void main() {
  group('BoardLayout', () {
    final map = ruleset('ch1_m2').map;

    test('the map rectangle keeps the 16:9 aspect, is centred and fits with padding', () {
      for (final size in [compact, regular, const Size(1000, 1000), const Size(500, 900)]) {
        final l = BoardLayout(map, size);
        expect(l.mapRect.width / l.mapRect.height, closeTo(16 / 9, 1e-9), reason: '$size');
        expect(l.mapRect.center.dx, closeTo(size.width / 2, 1e-9));
        expect(l.mapRect.center.dy, closeTo(size.height / 2, 1e-9));
        expect(l.mapRect.left, greaterThanOrEqualTo(BoardLayout.padding - 1e-9));
        expect(l.mapRect.right, lessThanOrEqualTo(size.width - BoardLayout.padding + 1e-9));
        expect(l.mapRect.top, greaterThanOrEqualTo(BoardLayout.padding - 1e-9));
        expect(l.mapRect.bottom, lessThanOrEqualTo(size.height - BoardLayout.padding + 1e-9));
      }
    });

    test('node centres follow the 0–1 x, y of the map file', () {
      final l = BoardLayout(map, regular);
      final thangLong = map.nodes.firstWhere((n) => n.id == 'thang-long');
      expect(l.nodeCenter('thang-long').dx, closeTo(l.mapRect.left + thangLong.x * l.mapRect.width, 1e-9));
      expect(l.nodeCenter('thang-long').dy, closeTo(l.mapRect.top + thangLong.y * l.mapRect.height, 1e-9));
    });

    test('compact below 900 logical pixels, regular from 900', () {
      expect(BoardLayout(map, const Size(899, 400)).isCompact, isTrue);
      expect(BoardLayout(map, const Size(900, 400)).isCompact, isFalse);
    });

    test('medallions never overlap, at any size', () {
      for (final size in [compact, regular, const Size(480, 270), const Size(2400, 1200)]) {
        final l = BoardLayout(map, size);
        for (final a in map.nodes) {
          for (final b in map.nodes) {
            if (a.id.compareTo(b.id) >= 0) continue;
            final d = (l.nodeCenter(a.id) - l.nodeCenter(b.id)).distance;
            expect(d, greaterThanOrEqualTo(2 * l.nodeRadius), reason: '${a.id}/${b.id} at $size');
          }
        }
      }
    });

    test('touch targets are at least 48 logical pixels', () {
      final l = BoardLayout(map, compact);
      expect(l.nodeHitRadius() * 2, greaterThanOrEqualTo(48));
      expect(l.tokenHitRadius() * 2, greaterThanOrEqualTo(48));
    });

    test('fanned tokens do not overlap each other, in rings of four', () {
      final l = BoardLayout(map, regular);
      for (final count in [1, 3, 4, 6, 9]) {
        final centers = l.tokenCenters('binh-le-nguyen', count: count, centerAngle: -math.pi / 2);
        expect(centers, hasLength(count));
        for (var i = 0; i < count; i++) {
          expect((centers[i] - l.nodeCenter('binh-le-nguyen')).distance, greaterThan(l.nodeRadius + l.tokenRadius - 1e-9));
          for (var j = i + 1; j < count; j++) {
            expect((centers[i] - centers[j]).distance, greaterThanOrEqualTo(2 * l.tokenRadius - 1e-6), reason: 'count $count: $i vs $j');
          }
        }
      }
    });

    test('a fan points into the free gap between edges', () {
      final l = BoardLayout(map, regular);
      // thien-mac has two edges, both up-left: the free side is down-right.
      final a = l.fanDirection('thien-mac', prefer: -math.pi / 2, count: 1);
      for (final e in l.edgeAngles('thien-mac')) {
        expect(BoardLayout.angleDistance(a, e), greaterThan(math.pi / 3));
      }
    });

    test('arrows start and end on the medallion edges, shifted by the lane', () {
      final l = BoardLayout(map, regular);
      final a = l.nodeCenter('bach-hac');
      final b = l.nodeCenter('binh-le-nguyen');
      final straight = l.arrowBetween('bach-hac', 'binh-le-nguyen');
      expect((straight.start - a).distance, closeTo(l.nodeRadius + 4, 1e-9));
      expect((straight.end - b).distance, closeTo(l.nodeRadius + 4, 1e-9));
      final shifted = l.arrowBetween('bach-hac', 'binh-le-nguyen', lane: 10);
      expect((shifted.start - straight.start).distance, closeTo(10, 1e-9));
    });
  });

  group('ch1_m2 start state', () {
    for (final size in [compact, regular]) {
      group('at ${size.width.toInt()}×${size.height.toInt()}', () {
        final scene = sceneFor('ch1_m2', size);

        test('draws every node and edge of the Chapter 1 map', () {
          expect(scene.nodes.map((n) => n.id).toSet(), ruleset('ch1_m2').map.nodes.map((n) => n.id).toSet());
          expect(scene.nodes, hasLength(9));
          expect(scene.edges, hasLength(12));
          expect(scene.edges.where((e) => e.kind == EdgeKind.river), hasLength(7));
          expect(scene.edges.where((e) => e.kind == EdgeKind.land), hasLength(5));
        });

        test('everything lies inside the viewport', () {
          final bounds = Offset.zero & size;
          for (final n in scene.nodes) {
            expect(bounds.contains(n.center), isTrue, reason: n.id);
            expect(bounds.inflate(1).contains(n.labelCenter - Offset(scene.layout.labelSize(n.name).width / 2, 0)), isTrue, reason: '${n.id} label');
          }
          for (final t in scene.tokens) {
            expect(bounds.contains(t.center), isTrue, reason: t.id);
          }
        });

        test('three officers at Bình Lệ Nguyên, the Yuan army at Bạch Hạc, with troop counts', () {
          final officers = scene.tokensOf(TokenKind.officer).toList();
          expect(officers.map((t) => t.id).toSet(), {'tran-thai-tong', 'le-phu-tran', 'tran-thu-do'});
          expect(officers.every((t) => t.nodeId == 'binh-le-nguyen'), isTrue);
          expect({for (final t in officers) t.id: t.troops}, {'tran-thai-tong': 12, 'le-phu-tran': 6, 'tran-thu-do': 6});
          expect({for (final t in officers) t.id: t.initials}, {'tran-thai-tong': 'TT', 'le-phu-tran': 'PT', 'tran-thu-do': 'TĐ'});
          expect(officers.singleWhere((t) => t.isKing).id, 'tran-thai-tong');
          final armies = scene.tokensOf(TokenKind.army).toList();
          expect(armies, hasLength(1));
          expect((armies.single.nodeId, armies.single.troops, armies.single.id), ('bach-hac', 30, 'mong-co-1258'));
        });

        test('node control: Bạch Hạc is Yuan, the rest Đại Việt, none evacuated', () {
          expect(scene.node('bach-hac').controller, Side.yuan);
          expect(scene.nodes.where((n) => n.id != 'bach-hac').every((n) => n.controller == Side.daiViet), isTrue);
          expect(scene.nodes.any((n) => n.evacuated), isFalse);
          expect(scene.node('thang-long').isCapital, isTrue);
          expect(scene.nodes.where((n) => n.isBorder).map((n) => n.id).toSet(), {'bien-gioi', 'song-thao'});
        });

        test('the Yuan intent is an assault arrow from Bạch Hạc to Bình Lệ Nguyên', () {
          expect(scene.arrows, hasLength(1));
          final a = scene.arrows.single;
          expect((a.armyId, a.intent, a.predicted), ('mong-co-1258', IntentKind.assault, false));
          final l = scene.layout;
          expect((a.start - l.nodeCenter('bach-hac')).distance, lessThan((a.end - l.nodeCenter('bach-hac')).distance));
          expect((a.end - l.nodeCenter('binh-le-nguyen')).distance, lessThan(l.nodeRadius + 12));
          expect(scene.badges, isEmpty);
        });

        test('name labels do not overlap each other or any medallion', () {
          final l = scene.layout;
          final rects = {
            for (final n in scene.nodes) n.id: Rect.fromCenter(center: n.labelCenter, width: l.labelSize(n.name).width, height: l.labelSize(n.name).height),
          };
          for (final a in scene.nodes) {
            for (final b in scene.nodes) {
              if (a.id == b.id) continue;
              if (a.id.compareTo(b.id) < 0) {
                expect(rects[a.id]!.overlaps(rects[b.id]!), isFalse, reason: 'labels ${a.id}/${b.id}');
              }
              final nearest = Offset(
                b.center.dx.clamp(rects[a.id]!.left, rects[a.id]!.right),
                b.center.dy.clamp(rects[a.id]!.top, rects[a.id]!.bottom),
              );
              expect((nearest - b.center).distance, greaterThanOrEqualTo(b.radius), reason: 'label ${a.id} over node ${b.id}');
            }
          }
        });

        test('no token covers another token or a medallion', () {
          final tokens = scene.tokens;
          for (var i = 0; i < tokens.length; i++) {
            for (var j = i + 1; j < tokens.length; j++) {
              expect((tokens[i].center - tokens[j].center).distance, greaterThanOrEqualTo(2 * scene.layout.tokenRadius - 1e-6),
                  reason: '${tokens[i].id}/${tokens[j].id}');
            }
            for (final n in scene.nodes) {
              expect((tokens[i].center - n.center).distance, greaterThanOrEqualTo(n.radius + scene.layout.tokenRadius - 1e-6),
                  reason: '${tokens[i].id} over ${n.id}');
            }
          }
        });
      });
    }

    test('the layout switches at 900 px: compact nodes are smaller than regular ones', () {
      expect(sceneFor('ch1_m2', compact).layout.isCompact, isTrue);
      expect(sceneFor('ch1_m2', regular).layout.isCompact, isFalse);
      expect(sceneFor('ch1_m2', compact).layout.nodeRadius, lessThan(sceneFor('ch1_m2', regular).layout.nodeRadius));
    });

    test('Vietnamese names by default, English names in English', () {
      expect(sceneFor('ch1_m2', regular).node('song-thao').name, 'Sông Thao');
      expect(sceneFor('ch1_m2', regular, lang: 'en').node('song-thao').name, 'Thao River');
      expect(sceneFor('ch1_m2', regular).node('bien-gioi').name, 'Biên giới (hướng Vân Nam)');
    });
  });

  group('selection', () {
    final scene = sceneFor('ch1_m2', regular);

    test('a tap on a token selects it; on a medallion its node; on empty ground nothing', () {
      final king = scene.tokens.firstWhere((t) => t.id == 'tran-thai-tong');
      expect(scene.hitTest(king.center), const Selection(SelectionKind.officer, 'tran-thai-tong'));
      final army = scene.tokens.firstWhere((t) => t.id == 'mong-co-1258');
      expect(scene.hitTest(army.center), const Selection(SelectionKind.army, 'mong-co-1258'));
      expect(scene.hitTest(scene.node('thang-long').center), const Selection(SelectionKind.node, 'thang-long'));
      expect(scene.hitTest(const Offset(5, 5)), isNull);
    });

    test('hit areas are at least 48 logical pixels wide', () {
      final c = sceneFor('ch1_m2', compact);
      final n = c.node('thien-mac');
      expect(c.hitTest(n.center + const Offset(23, 0)), const Selection(SelectionKind.node, 'thien-mac'));
      expect(c.hitTest(n.center + const Offset(0, -23)), const Selection(SelectionKind.node, 'thien-mac'));
    });

    test('the selection is carried into the scene and has a centre', () {
      final s = sceneFor('ch1_m2', regular, selection: const Selection(SelectionKind.officer, 'tran-thu-do'));
      expect(s.selection, const Selection(SelectionKind.officer, 'tran-thu-do'));
      expect(s.selectedCenter, s.tokens.firstWhere((t) => t.id == 'tran-thu-do').center);
      expect(sceneFor('ch1_m2', regular).selectedCenter, isNull);
      expect(
        sceneFor('ch1_m2', regular, selection: const Selection(SelectionKind.node, 'phu-lo')).selectedCenter,
        s.node('phu-lo').center,
      );
    });
  });

  group('other states', () {
    test('evacuated nodes and ambushed edges are marked', () {
      final rs = ruleset('ch1_m2');
      final e = GameEngine(rs);
      var s = e.newGame(1).state.copyWith(hand: const ['vuon-khong-nha-trong'], rice: 9, support: 9);
      s = e.apply(s, const GameAction.playCard(cardId: 'vuon-khong-nha-trong', target: 'thang-long')).state;
      s = s.copyWith(ambushes: [Ambush(edge: edgeKey('thang-long', 'thien-mac'), officerId: 'tran-thai-tong')]);
      final scene = sceneFor('ch1_m2', regular, state: s);
      expect(scene.node('thang-long').evacuated, isTrue);
      expect(scene.edges.where((x) => x.ambushed).map((x) => x.key), [edgeKey('thang-long', 'thien-mac')]);
    });

    test('defected, captured and routed units are not drawn', () {
      var s = startState('ch1_m2');
      s = s.copyWith(
        officers: {...s.officers, 'tran-thu-do': s.officers['tran-thu-do']!.copyWith(status: OfficerStatus.captured)},
        armies: {...s.armies, 'mong-co-1258': s.armies['mong-co-1258']!.copyWith(status: ArmyStatus.routed)},
      );
      final scene = sceneFor('ch1_m2', regular, state: s);
      expect(scene.tokens.map((t) => t.id).toSet(), {'tran-thai-tong', 'le-phu-tran'});
      expect(scene.arrows, isEmpty);
    });

    test('an intent that does not move (hold, forage in place) becomes a badge', () {
      var s = startState('ch1_m1');
      expect(s.armies['mong-co-1258']!.intent!.kind, IntentKind.hold);
      final scene = sceneFor('ch1_m1', regular, state: s);
      expect(scene.arrows, isEmpty);
      expect(scene.badges.single.intent, IntentKind.hold);
      s = s.copyWith(armies: {
        'mong-co-1258': s.armies['mong-co-1258']!.copyWith(intent: const Intent(kind: IntentKind.forage, targetNodeId: 'bien-gioi')),
      });
      expect(sceneFor('ch1_m1', regular, state: s).badges.single.intent, IntentKind.forage);
    });

    test('borderWatch: next turn\'s intent is drawn as a predicted arrow (ch1_m1, Quốc Tuấn on the border)', () {
      // In ch1_m1 Trần Quốc Tuấn starts at Sông Thao (a border node).
      var s = startState('ch1_m1');
      expect(s.revealDepth, 2);
      s = s.copyWith(armies: {
        'mong-co-1258': s.armies['mong-co-1258']!.copyWith(
          intent: const Intent(kind: IntentKind.advance, moveTo: 'song-thao', targetNodeId: 'thang-long'),
          predictedIntent: const Intent(kind: IntentKind.advance, moveTo: 'bach-hac', targetNodeId: 'thang-long'),
        ),
      });
      final arrows = sceneFor('ch1_m1', regular, state: s).arrows;
      expect(arrows.map((a) => a.predicted), [false, true]);
      final l = sceneFor('ch1_m1', regular).layout;
      expect((arrows.last.start - l.nodeCenter('song-thao')).distance, lessThan(l.nodeRadius + 12),
          reason: 'the predicted arrow starts where the army will stand');
    });

    test('every Chapter 1 mission draws at both sizes with tokens inside the viewport', () {
      for (final id in content.missions.keys) {
        for (final size in [compact, regular]) {
          final scene = sceneFor(id, size);
          expect(scene.tokens, isNotEmpty, reason: id);
          for (final t in scene.tokens) {
            expect((Offset.zero & size).contains(t.center), isTrue, reason: '$id ${t.id}');
          }
        }
      }
    });
  });

  test('initialsOf takes the first letters of the last two words', () {
    expect(initialsOf('Trần Thái Tông'), 'TT');
    expect(initialsOf('Trần Thủ Độ'), 'TĐ');
    expect(initialsOf('Lê Phụ Trần'), 'PT');
    expect(initialsOf('Ngột Lương Hợp Thai'), 'HT');
    expect(initialsOf('Khan'), 'K');
    expect(initialsOf('  '), '?');
  });
}
