import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lk_rules/lk_rules.dart';
import 'package:long_ky_game/features/battle/labels.dart';
import 'package:long_ky_game/features/cards/card_frame.dart';

import 'art_support.dart';
import 'battle/overlay_support.dart';

/// The lacquer frame: 3:4, four kinds, art by id with a placeholder, and no
/// look of a playing card (build-spec section 6; guardrail 6).
void main() {
  final rules = ruleset('ch1_m2');
  final l = strings('vi');
  final stratagem = rules.cards['vuon-khong-nha-trong']!;
  final event = ruleset('ch1_m1').cards['su-gia-phuong-bac']!;
  final king = rules.officers['tran-thai-tong']!;
  const free = (rice: 0, support: 0, surcharge: false);

  /// A card the content does not have yet: an enemy intent.
  const intent = CardDef(
    id: 'test-intent',
    type: CardType.intent,
    name: LocalizedText(vi: 'Tấn công', en: 'Assault'),
    text: LocalizedText(vi: 'Quân Nguyên tiến đánh.', en: 'The Yuan attack.'),
  );

  Widget frames(List<Widget> children, {String lang = 'vi'}) => Wrap(spacing: 12, runSpacing: 12, children: children);

  for (final (name, size, _) in layouts) {
    group('card frame ($name)', () {
      testWidgets('every kind is 3:4 portrait, at every size', (tester) async {
        final list = <CardFrame>[
          for (final w in [100.0, 118.0, 128.0, 190.0, 240.0])
            for (final f in [
              frameForCard(l, stratagem, width: w, cost: (rice: 0, support: 2, surcharge: false)),
              frameForCard(l, event, width: w, cost: free),
              frameForCard(l, intent, width: w, cost: free),
              frameForOfficer(l, king, width: w),
            ])
              f,
        ];
        await pumpOverlay(tester, size, SingleChildScrollView(child: frames(list)));
        expect(tester.takeException(), isNull);
        for (final f in find.byType(CardFrame).evaluate()) {
          final box = tester.getSize(find.byWidget(f.widget));
          expect(box.width / box.height, closeTo(3 / 4, 0.001), reason: '${(f.widget as CardFrame).width}');
        }
        expect(find.byType(CardFrame), findsNWidgets(list.length));
      });

      testWidgets('shows the type, the name, the art and the cost; the text only when there is room', (tester) async {
        await pumpOverlay(
          tester,
          size,
          frames([
            frameForCard(l, stratagem, width: 120, cost: (rice: 1, support: 2, surcharge: true)),
            frameForCard(l, stratagem, width: 240, cost: (rice: 1, support: 2, surcharge: true)),
          ]),
        );
        expect(find.text(l.cardTypeName(CardType.stratagem)), findsNWidgets(2));
        expect(find.text(l.content(stratagem.name)), findsNWidgets(2));
        expect(find.byKey(const Key('art-placeholder')), findsNWidgets(2), reason: 'no art ships yet');
        expect(find.text(l.content(stratagem.text)), findsOneWidget, reason: 'only the 240-wide frame has room for it');
        expect(find.byIcon(Icons.grass), findsNWidgets(2));
        expect(find.text('2+'), findsNWidgets(2), reason: 'a + marks Support raised by a low Court');
        expect(find.text('1'), findsNWidgets(2));
      });

      testWidgets('a free card says so; an event and an intent are not paid in the cost row', (tester) async {
        await pumpOverlay(
          tester,
          size,
          frames([frameForCard(l, event, width: 140, cost: free), frameForOfficer(l, king, width: 140)]),
        );
        expect(find.text(l.cardFree), findsOneWidget);
        expect(find.byIcon(Icons.favorite), findsNothing);
      });

      testWidgets('an officer shows the five stats and the signature skill', (tester) async {
        await pumpOverlay(tester, size, frames([frameForOfficer(l, king, width: 220, loyalty: 9)]));
        for (final label in [l.statLeadership, l.statWar, l.statIntelligence, l.statPolitics, l.statLoyalty]) {
          expect(find.textContaining(label, findRichText: true), findsWidgets, reason: label);
        }
        expect(find.textContaining('${king.stats.leadership}', findRichText: true), findsWidgets);
        expect(find.textContaining('9', findRichText: true), findsWidgets, reason: 'loyalty now, not at the start');
        expect(find.text(l.content(king.skill!.name)), findsOneWidget);
        expect(find.text(l.content(king.name)), findsOneWidget);
      });

      testWidgets('selected and unaffordable frames look different', (tester) async {
        await pumpOverlay(
          tester,
          size,
          frames([
            frameForCard(l, stratagem, width: 140, cost: free),
            frameForCard(l, stratagem, width: 140, cost: free, selected: true),
            frameForCard(l, stratagem, width: 140, cost: free, dimmed: true),
          ]),
        );
        BoxDecoration decorationOf(int i) =>
            tester.widget<Container>(find.byKey(const Key('card-frame')).at(i)).decoration! as BoxDecoration;
        expect((decorationOf(0).border! as Border).top.width, lessThan((decorationOf(1).border! as Border).top.width));
        expect(decorationOf(1).boxShadow, isNotEmpty);
        expect(decorationOf(0).boxShadow, isEmpty);
        expect(tester.widgetList<Opacity>(find.byType(Opacity)).map((o) => o.opacity), contains(0.6));
      });

      testWidgets('it does not look like a playing card: nothing in a corner, no suits, no ranks', (tester) async {
        for (final w in [118.0, 240.0]) {
          await pumpOverlay(
            tester,
            size,
            frames([
              frameForCard(l, stratagem, width: w, cost: (rice: 1, support: 2, surcharge: false)),
              frameForOfficer(l, king, width: w),
            ]),
          );
          for (var i = 0; i < 2; i++) {
            final frameFinder = find.byKey(const Key('card-frame')).at(i);
            final frame = tester.getRect(frameFinder);
            // A corner index sits at a corner of a card: 18 % x 12 % zones.
            final cw = frame.width * 0.18;
            final ch = frame.height * 0.12;
            final corners = [
              Rect.fromLTWH(frame.left, frame.top, cw, ch),
              Rect.fromLTWH(frame.right - cw, frame.top, cw, ch),
              Rect.fromLTWH(frame.left, frame.bottom - ch, cw, ch),
              Rect.fromLTWH(frame.right - cw, frame.bottom - ch, cw, ch),
            ];
            // Where the glyphs are drawn, not just the boxes of their widgets.
            final inks = <Rect>[];
            for (final e in find.descendant(of: frameFinder, matching: find.byType(RichText)).evaluate()) {
              final render = e.renderObject! as RenderParagraph;
              final text = render.text.toPlainText();
              for (final box in render.getBoxesForSelection(TextSelection(baseOffset: 0, extentOffset: text.length))) {
                inks.add(MatrixUtils.transformRect(render.getTransformTo(null), box.toRect()));
              }
            }
            for (final e in find.descendant(of: frameFinder, matching: find.byType(Icon)).evaluate()) {
              inks.add(tester.getRect(find.byWidget(e.widget)));
            }
            expect(inks, isNotEmpty);
            // A playing card hangs its index at a side. Here every row of
            // content (a line of text, the cost row, the stats) is centred on
            // the frame, so nothing can sit in a corner.
            inks.sort((a, b) => a.top.compareTo(b.top));
            final rows = <Rect>[];
            for (final ink in inks) {
              if (rows.isNotEmpty && ink.top < rows.last.bottom - 1) {
                rows[rows.length - 1] = rows.last.expandToInclude(ink);
              } else {
                rows.add(ink);
              }
            }
            for (final row in rows) {
              expect(
                (row.center.dx - frame.center.dx).abs(),
                lessThanOrEqualTo(frame.width * 0.08),
                reason: 'a row at $row is off-centre in a $w-wide frame',
              );
              for (final c in corners) {
                // Only a narrow mark, not a line of text across the frame, could be an index.
                if (row.width < frame.width * 0.35) expect(c.overlaps(row), isFalse, reason: '$row in corner $c');
              }
            }
          }
        }
        // No suit or playing-card glyph anywhere in the frame's vocabulary.
        const banned = ['♠', '♥', '♦', '♣', '🂡', '🃏'];
        final all = tester.widgetList<Text>(find.byType(Text)).map((t) => t.data ?? '').join();
        for (final b in banned) {
          expect(all, isNot(contains(b)));
        }
        // The cost glyphs are Rice and Support, not suits.
        expect(find.byIcon(Icons.favorite), findsWidgets);
      });

      testWidgets('painted art by id replaces the placeholder', (tester) async {
        final png = await tester.runAsync(makePng);
        final bundle = MemoryArtBundle({'assets/images/${stratagem.art}': png!});
        setViewSize(tester, size);
        await tester.pumpWidget(
          RepositoryProvider.value(
            value: bundle.library,
            child: appAround(Scaffold(body: frames([frameForCard(l, stratagem, width: 160, cost: free)]))),
          ),
        );
        await tester.runAsync(() async {
          await precacheImage(bundle.library.provider(stratagem.art)!, tester.element(find.byType(CardFrame)));
        });
        await tester.pump();
        expect(find.byType(Image), findsOneWidget);
        expect(find.byKey(const Key('art-placeholder')), findsNothing);
        expect(stratagem.art, 'cards/vuon-khong-nha-trong.png');
      });

      testWidgets('in English', (tester) async {
        final en = strings('en');
        await pumpOverlay(tester, size, frames([frameForCard(en, stratagem, width: 240, cost: free)]), lang: 'en');
        expect(find.text(en.content(stratagem.name)), findsOneWidget);
        expect(find.text('Stratagem'), findsOneWidget);
        expect(find.text('Free'), findsOneWidget);
      });
    });
  }
}
