import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lk_rules/lk_rules.dart';
import 'package:long_ky_game/features/battle/labels.dart';
import 'package:long_ky_game/features/battle/overlays/result_screen.dart';

import 'overlay_support.dart';

/// The Result screen, at both layouts and in both languages.
void main() {
  final rules = ruleset(mission);
  final engine = GameEngine(rules);
  final start = engine.newGame(1).state;
  final l = strings('vi');
  final namer = Namer(l, rules);

  GameState won(List<bool> stars) => start.copyWith(phase: Phase.ended, outcome: Outcome.won, stars: stars);
  GameState lost(String? reason) =>
      start.copyWith(phase: Phase.ended, outcome: Outcome.lost, lossReason: reason, stars: const [false, false, false]);

  Widget screen(
    GameState s, {
    VoidCallback? onBack,
    VoidCallback? onRetry,
    Ruleset? r,
    LocalizedText? next,
    bool unlocked = false,
    VoidCallback? onNext,
  }) => SizedBox(
    width: double.infinity,
    height: double.infinity,
    child: ResultScreen(
      state: s,
      ruleset: r ?? rules,
      onBack: onBack,
      onRetry: onRetry,
      nextTitle: next,
      newlyUnlocked: unlocked,
      onNext: onNext,
    ),
  );
  const nextTitle = LocalizedText(vi: 'Trận kế', en: 'Next battle');

  for (final (name, size, _) in layouts) {
    group('result screen ($name)', () {
      testWidgets('a win shows the mission, the stars, each objective, the debrief and the buttons', (tester) async {
        var back = 0;
        var retry = 0;
        await pumpOverlay(tester, size, screen(won([true, true, false]), onBack: () => back++, onRetry: () => retry++));
        expect(find.text(l.content(rules.mission.title)), findsOneWidget);
        expect(find.byKey(const Key('result-title')), findsOneWidget);
        expect(find.text(l.outcomeWon), findsOneWidget);
        expect(find.text(l.outcomeStars(2, 3)), findsOneWidget);
        // The objectives are the mission's, in order, with the sentence built from their type.
        expect(rules.mission.stars, hasLength(3));
        for (var i = 0; i < 3; i++) {
          final row = find.byKey(Key('objective-$i'));
          expect(row, findsOneWidget);
          expect(
            find.descendant(of: row, matching: find.text(namer.objective(start, rules.mission.stars[i]))),
            findsOneWidget,
          );
          expect(
            find.descendant(of: row, matching: find.byIcon(i < 2 ? Icons.star : Icons.star_border)),
            findsOneWidget,
            reason: 'met stars are filled, missed ones outlined',
          );
          expect(find.descendant(of: row, matching: find.text(i < 2 ? l.resultMet : l.resultNotMet)), findsOneWidget);
        }
        expect(find.byKey(const Key('result-debrief')), findsOneWidget);
        expect(find.text(l.content(rules.mission.debrief)), findsOneWidget);
        await tester.tap(find.byKey(const Key('result-back')));
        await tester.tap(find.byKey(const Key('result-retry')));
        expect([back, retry], [1, 1]);
        expect(tester.getSize(find.byKey(const Key('result-back'))).height, greaterThanOrEqualTo(48));
        expect(tester.takeException(), isNull);
      });

      testWidgets('a loss says why and offers no stars or debrief', (tester) async {
        final reasons = {
          LossReasons.kingCaptured: l.lossKingCaptured,
          LossReasons.seasonEnded: l.lossSeasonEnded,
          '${LossReasons.unityPrefix}clan': l.lossUnity(l.unityClan),
          '${LossReasons.objectivePrefix}x': l.lossObjective,
          null: l.lossObjective,
        };
        for (final e in reasons.entries) {
          await pumpOverlay(tester, size, screen(lost(e.key), onBack: () {}, onRetry: () {}));
          expect(find.text(l.outcomeLost), findsOneWidget);
          expect(find.byKey(const Key('result-reason')), findsOneWidget);
          expect(find.text(e.value), findsOneWidget, reason: '${e.key}');
          expect(find.byKey(const Key('result-stars')), findsNothing);
          expect(find.byKey(const Key('result-debrief')), findsNothing);
          expect(find.byKey(const Key('result-retry')), findsOneWidget);
        }
      });

      testWidgets('a first win announces the unlocked mission and offers it; a replay only offers it', (tester) async {
        var next = 0;
        await pumpOverlay(
          tester,
          size,
          screen(won([true, false, false]), next: nextTitle, unlocked: true, onNext: () => next++, onBack: () {}),
        );
        expect(find.byKey(const Key('result-unlocked')), findsOneWidget);
        expect(find.text(l.resultUnlocked('Trận kế')), findsOneWidget);
        await tester.tap(find.byKey(const Key('result-next')));
        expect(next, 1);
        expect(find.text(l.resultNext), findsOneWidget);
        expect(tester.getSize(find.byKey(const Key('result-next'))).height, greaterThanOrEqualTo(48));

        await pumpOverlay(tester, size, screen(won([true, false, false]), next: nextTitle, onNext: () {}));
        expect(find.byKey(const Key('result-unlocked')), findsNothing);
        expect(find.byKey(const Key('result-next')), findsOneWidget);
      });

      testWidgets('no next mission, no unlock line; a loss never offers the next mission', (tester) async {
        await pumpOverlay(tester, size, screen(won([true, true, true]), unlocked: true));
        expect(find.byKey(const Key('result-unlocked')), findsNothing);
        expect(find.byKey(const Key('result-next')), findsNothing);

        await pumpOverlay(
          tester,
          size,
          screen(lost(null), next: nextTitle, unlocked: true, onNext: () {}, onRetry: () {}),
        );
        expect(find.byKey(const Key('result-unlocked')), findsNothing);
        expect(find.byKey(const Key('result-next')), findsNothing);
      });

      testWidgets('the unlock line is in English too', (tester) async {
        await pumpOverlay(
          tester,
          size,
          screen(won([true, false, false]), next: nextTitle, unlocked: true, onNext: () {}),
          lang: 'en',
        );
        expect(find.text('Unlocked: Next battle'), findsOneWidget);
        expect(find.text('Next mission'), findsOneWidget);
      });

      testWidgets('buttons only appear when they have somewhere to go', (tester) async {
        await pumpOverlay(tester, size, screen(won([true, false, false])));
        expect(find.byKey(const Key('result-back')), findsNothing);
        expect(find.byKey(const Key('result-retry')), findsNothing);
      });

      testWidgets('in English', (tester) async {
        await pumpOverlay(
          tester,
          size,
          screen(won([true, true, true]), onBack: () {}, onRetry: () {}),
          lang: 'en',
        );
        expect(find.text('Victory'), findsOneWidget);
        expect(find.text('Stars earned: 3/3'), findsOneWidget);
        expect(find.text('Play again'), findsOneWidget);
        expect(find.text('Met'), findsNWidgets(3));
      });

      testWidgets('long text scrolls instead of overflowing, even at 150% text', (tester) async {
        await pumpOverlay(tester, size, screen(won([true, true, true]), onBack: () {}, onRetry: () {}), textScale: 1.5);
        expect(tester.takeException(), isNull);
        // The buttons stay on screen, whatever the text length.
        expect(tester.getRect(find.byKey(const Key('result-back'))).bottom, lessThanOrEqualTo(size.height));
      });

      testWidgets('an objective is read out with whether it was met', (tester) async {
        final semantics = tester.ensureSemantics();
        await pumpOverlay(tester, size, screen(won([true, false, false])));
        final first = namer.objective(start, rules.mission.stars[0]);
        expect(find.bySemanticsLabel('$first, ${l.resultMet}'), findsOneWidget);
        semantics.dispose();
      });
    });
  }

  group('objective text', () {
    final all = <ObjectiveDef>[
      const WonObjective(),
      const AllArmiesBrokenObjective(),
      const ArmyBrokenObjective('mong-co-1258'),
      const CounterattackAtObjective('binh-le-nguyen'),
      const SurviveTurnsObjective(4),
      const KingAtObjective('thang-long', 4),
      const ArmySupplyAtMostObjective('mong-co-1258', 0.25),
      const KingNotCapturedObjective(),
      const CapitalHeldObjective(),
      const UnityAllAboveObjective(5),
      const UnityAtLeastAtEndObjective(Pillar.court, 7),
      const NoDefectionsObjective(),
      const NoCapturesObjective(),
      const TroopsLostAtMostObjective(10),
      const WinByTurnObjective(4),
      const AnyOfObjective([WonObjective(), NoCapturesObjective()]),
    ];

    test('every objective type reads as a sentence in both languages', () {
      expect(all.map((o) => o.type).toSet(), containsAll(objectiveTypes), reason: 'covers the closed list');
      for (final lang in ['vi', 'en']) {
        final n = Namer(strings(lang), rules);
        for (final o in all) {
          final text = n.objective(start, o);
          expect(text.trim(), isNotEmpty, reason: '${o.type} in $lang');
          expect(text, isNot(contains('{')), reason: '${o.type} in $lang: $text');
        }
      }
    });

    test('numbers and places appear in the sentence', () {
      expect(namer.objective(start, const SurviveTurnsObjective(4)), contains('4'));
      expect(namer.objective(start, const KingAtObjective('thang-long', 4)), contains('Thăng Long'));
      expect(namer.objective(start, const ArmySupplyAtMostObjective('mong-co-1258', 0.25)), contains('25%'));
      expect(
        Namer(strings('en'), rules).objective(start, const TroopsLostAtMostObjective(10)),
        'Lose at most 10,000 troops',
      );
    });

    test('every star objective of every mission has text', () {
      for (final id in content.missions.keys) {
        final r = content.ruleset(id);
        final s = GameEngine(r).newGame(1).state;
        for (final lang in ['vi', 'en']) {
          for (final o in r.mission.stars) {
            expect(Namer(strings(lang), r).objective(s, o), isNotEmpty, reason: '$id ${o.type} $lang');
          }
        }
      }
    });
  });
}
