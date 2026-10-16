import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lk_rules/lk_rules.dart';
import 'package:long_ky_game/app/theme.dart';
import 'package:long_ky_game/features/battle/labels.dart';
import 'package:long_ky_game/features/battle/overlays/top_bar.dart';
import 'package:long_ky_game/features/cards/card_frame.dart';

import '../art_support.dart';
import '../battle/overlay_support.dart';
import 'golden_support.dart';

/// Goldens for the card frame and the top bar (build-spec section 7), on
/// Linux only. See golden_support.dart to regenerate them.
void main() {
  setUpAll(loadGoldenFonts);

  final rules = ruleset('ch1_m2');
  final stratagem = rules.cards['vuon-khong-nha-trong']!;
  final ambush = rules.cards['phuc-kich-ben-song']!;
  final event = ruleset('ch1_m1').cards['su-gia-phuong-bac']!;
  final king = rules.officers['tran-thai-tong']!;
  const intent = CardDef(
    id: 'test-intent',
    type: CardType.intent,
    name: LocalizedText(vi: 'Tấn công', en: 'Assault'),
    text: LocalizedText(vi: 'Quân Nguyên tiến đánh nút này trong lượt.', en: 'The Yuan attack this node this turn.'),
  );
  const free = (rice: 0, support: 0, surcharge: false);

  Future<void> sheet(
    WidgetTester tester,
    String name,
    List<Widget> children, {
    String lang = 'vi',
    Size size = const Size(1100, 380),
    Widget Function(Widget)? wrap,
  }) async {
    setViewSize(tester, size);
    final content = RepaintBoundary(
      key: const Key('golden'),
      child: ColoredBox(
        color: LongKyColors.lacquer,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Align(
            alignment: Alignment.topLeft,
            child: Wrap(spacing: 14, runSpacing: 14, children: children),
          ),
        ),
      ),
    );
    await tester.pumpWidget(
      appAround(
        Scaffold(backgroundColor: LongKyColors.lacquer, body: wrap?.call(content) ?? content),
        lang: lang,
      ),
    );
    await tester.pump();
    await expectLater(find.byKey(const Key('golden')), matchesGoldenFile('goldens/$name.png'));
  }

  group('card frame', () {
    testWidgets('the four kinds, full size, in Vietnamese', (tester) async {
      final l = strings('vi');
      await sheet(tester, 'card_frames_vi', [
        frameForCard(l, stratagem, width: 240, cost: (rice: 0, support: 2, surcharge: false)),
        frameForCard(l, event, width: 240, cost: free),
        frameForCard(l, intent, width: 240, cost: free),
        frameForOfficer(l, king, width: 240),
      ], size: const Size(1040, 400));
    }, skip: goldenSkip);

    testWidgets('the four kinds, full size, in English', (tester) async {
      final l = strings('en');
      await sheet(
        tester,
        'card_frames_en',
        [
          frameForCard(l, stratagem, width: 240, cost: (rice: 0, support: 2, surcharge: false)),
          frameForCard(l, event, width: 240, cost: free),
          frameForCard(l, intent, width: 240, cost: free),
          frameForOfficer(l, king, width: 240),
        ],
        lang: 'en',
        size: const Size(1040, 400),
      );
    }, skip: goldenSkip);

    testWidgets('hand size: plain, with a Support surcharge, selected, unaffordable', (tester) async {
      final l = strings('vi');
      await sheet(tester, 'card_frames_hand', [
        frameForCard(l, ambush, width: 128, cost: (rice: 2, support: 0, surcharge: false)),
        frameForCard(l, stratagem, width: 128, cost: (rice: 0, support: 3, surcharge: true)),
        frameForCard(l, stratagem, width: 128, cost: (rice: 0, support: 2, surcharge: false), selected: true),
        frameForCard(l, ambush, width: 128, cost: (rice: 2, support: 0, surcharge: false), dimmed: true),
        frameForCard(l, stratagem, width: 118, cost: free),
      ], size: const Size(760, 220));
    }, skip: goldenSkip);

    testWidgets('with painted art, in place of the placeholder', (tester) async {
      final l = strings('vi');
      final png = await tester.runAsync(makePng);
      final bundle = MemoryArtBundle({'assets/images/${stratagem.art}': png!, 'assets/images/${king.cardArt}': png});
      setViewSize(tester, const Size(560, 400));
      await tester.pumpWidget(
        RepositoryProvider.value(
          value: bundle.library,
          child: appAround(
            Scaffold(
              backgroundColor: LongKyColors.lacquer,
              body: RepaintBoundary(
                key: const Key('golden'),
                child: ColoredBox(
                  color: LongKyColors.lacquer,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Wrap(
                      spacing: 14,
                      children: [
                        frameForCard(l, stratagem, width: 240, cost: (rice: 0, support: 2, surcharge: false)),
                        frameForOfficer(l, king, width: 240),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.runAsync(() async {
        final context = tester.element(find.byType(CardFrame).first);
        await precacheImage(bundle.library.provider(stratagem.art)!, context);
        await precacheImage(bundle.library.provider(king.cardArt)!, context);
      });
      await tester.pump();
      expect(find.byType(Image), findsNWidgets(2));
      await expectLater(find.byKey(const Key('golden')), matchesGoldenFile('goldens/card_frames_with_art.png'));
    }, skip: goldenSkip);
  });

  group('top bar', () {
    final start = GameEngine(rules).newGame(1).state;

    Future<void> bar(
      WidgetTester tester,
      String name,
      GameState s,
      Size size,
      BattleLayoutMode mode, {
      String lang = 'vi',
    }) async {
      setViewSize(tester, Size(size.width, BattleTopBar.heightFor(mode)));
      await tester.pumpWidget(
        appAround(
          // As on the battle screen: a Scaffold gives the text its theme.
          Scaffold(
            backgroundColor: LongKyColors.lacquer,
            body: RepaintBoundary(
              key: const Key('golden'),
              child: Align(
                alignment: Alignment.topLeft,
                child: SizedBox(
                  width: size.width,
                  child: BattleTopBar(state: s, seasonTurns: rules.mission.seasonTurns, mode: mode),
                ),
              ),
            ),
          ),
          lang: lang,
        ),
      );
      await tester.pump();
      await expectLater(find.byKey(const Key('golden')), matchesGoldenFile('goldens/$name.png'));
    }

    final late = start.copyWith(
      turn: 3,
      phase: Phase.orders,
      rice: 11,
      support: 1,
      unity: const Unity(court: 3, clan: 9, people: 5),
    );

    testWidgets('compact, at the start', (tester) async {
      await bar(tester, 'top_bar_compact', start, const Size(790, 48), BattleLayoutMode.compact);
    }, skip: goldenSkip);

    testWidgets('regular, at the start', (tester) async {
      await bar(tester, 'top_bar_regular', start, const Size(1600, 56), BattleLayoutMode.regular);
    }, skip: goldenSkip);

    testWidgets('compact, turn 3 in Orders with Court low', (tester) async {
      await bar(tester, 'top_bar_compact_low_court', late, const Size(790, 48), BattleLayoutMode.compact);
    }, skip: goldenSkip);

    testWidgets('regular, in English', (tester) async {
      await bar(tester, 'top_bar_regular_en', late, const Size(1600, 56), BattleLayoutMode.regular, lang: 'en');
    }, skip: goldenSkip);
  });
}
