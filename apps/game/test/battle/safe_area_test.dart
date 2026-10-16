import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lk_rules/lk_rules.dart';
import 'package:long_ky_game/features/battle/board/board_game.dart';

import '../support.dart';
import 'overlay_support.dart';

/// "No clipped UI on a notched phone" (build-spec section 9, T-19): a phone in
/// landscape with a notch on the left, a camera cut-out margin on the right
/// and a home indicator at the bottom.
void main() {
  const phone = Size(844, 390);
  const inset = (left: 48.0, top: 0.0, right: 34.0, bottom: 21.0);

  void notch(WidgetTester tester) {
    final padding = FakeViewPadding(left: inset.left, top: inset.top, right: inset.right, bottom: inset.bottom);
    tester.view.padding = padding;
    tester.view.viewPadding = padding;
    addTearDown(tester.view.resetPadding);
    addTearDown(tester.view.resetViewPadding);
  }

  final safe = Rect.fromLTRB(inset.left, inset.top, phone.width - inset.right, phone.height - inset.bottom);

  void expectSafe(WidgetTester tester, Finder f, String what) {
    expect(f, findsOneWidget, reason: what);
    final r = tester.getRect(f);
    expect(r.left, greaterThanOrEqualTo(safe.left - 0.5), reason: '$what left $r');
    expect(r.top, greaterThanOrEqualTo(safe.top - 0.5), reason: '$what top $r');
    expect(r.right, lessThanOrEqualTo(safe.right + 0.5), reason: '$what right $r');
    expect(r.bottom, lessThanOrEqualTo(safe.bottom + 0.5), reason: '$what bottom $r');
  }

  group('battle on a notched phone', () {
    testWidgets('every overlay and the board stay inside the safe area', (tester) async {
      setViewSize(tester, phone);
      notch(tester);
      await pumpBattle(tester, phone, onExit: () {});
      for (final (key, what) in [
        ('top-bar', 'top bar'),
        ('battle-exit', 'back button'),
        ('log-button', 'log button'),
        ('officer-strip', 'officer strip'),
        ('hand-handle', 'hand handle'),
        ('phase-button', 'phase button'),
      ]) {
        expectSafe(tester, find.byKey(Key(key)), what);
      }
      expectSafe(tester, find.byType(GameWidget<BoardGame>), 'board');
    });

    testWidgets('the bar is as wide as the safe area, not the screen', (tester) async {
      setViewSize(tester, phone);
      notch(tester);
      await pumpBattle(tester, phone);
      final bar = tester.getRect(find.byKey(const Key('top-bar')));
      expect(bar.left, inset.left);
      expect(bar.right, phone.width - inset.right);
    });

    testWidgets('the open hand, the inspector, the log and the dialogs stay inside it too', (tester) async {
      setViewSize(tester, phone);
      notch(tester);
      final cubit = await pumpBattle(tester, phone);
      await tester.tap(find.byKey(const Key('hand-handle')));
      await settle(tester);
      expectSafe(tester, find.byKey(const Key('hand-fan')), 'hand fan');
      await tester.tap(find.byKey(const Key('hand-handle')));
      await settle(tester);

      await tester.tap(find.byKey(const Key('officer-tran-thai-tong')));
      await settle(tester);
      expectSafe(tester, find.byKey(const Key('inspector-officer')), 'inspector sheet');
      await tester.tap(find.byKey(const Key('inspector-close')));
      await settle(tester);

      await tester.tap(find.byKey(const Key('log-button')));
      await settle(tester);
      expectSafe(tester, find.byKey(const Key('log-popover')), 'log popover');
      await tester.tap(find.byKey(const Key('log-close')));
      await settle(tester);

      await tester.tap(find.byKey(const Key('hand-handle')));
      await settle(tester);
      final card = cubit.game.hand.first;
      await tester.tap(find.byKey(Key('card-0-$card')), warnIfMissed: false);
      await settle(tester);
      if (find.byKey(const Key('card-dialog')).evaluate().isNotEmpty) {
        expectSafe(tester, find.byKey(const Key('card-dialog')), 'card dialog');
      }
    });

    testWidgets('the choice dialog stays inside it', (tester) async {
      setViewSize(tester, phone);
      notch(tester);
      await pumpBattle(tester, phone, missionId: 'ch1_m1');
      expectSafe(tester, find.byKey(const Key('choice-0')), 'choice button');
      expectSafe(tester, find.byKey(const Key('choice-1')), 'choice button');
    });

    testWidgets('the Result screen keeps its buttons inside it', (tester) async {
      setViewSize(tester, phone);
      notch(tester);
      final cubit = await pumpBattle(tester, phone, onExit: () {});
      winM2(cubit);
      await settle(tester);
      await playOut(tester);
      expect(cubit.game.outcome, Outcome.won);
      expectSafe(tester, find.byKey(const Key('result-back')), 'Back');
      expectSafe(tester, find.byKey(const Key('result-title')), 'title');
    });
  });

  group('the other screens on a notched phone', () {
    testWidgets('title and settings keep their content inside the safe area', (tester) async {
      setViewSize(tester, phone);
      notch(tester);
      await startApp(tester);
      for (final label in ['Chiến dịch', 'Sử liệu', 'Cài đặt']) {
        expectSafe(tester, find.text(label), label);
      }
      await tester.tap(find.text('Cài đặt'));
      await tester.pumpAndSettle();
      final first = tester.getRect(find.byType(ListTile).first);
      expect(first.left, greaterThanOrEqualTo(safe.left - 0.5));
      expect(first.right, lessThanOrEqualTo(safe.right + 0.5));
    });
  });
}
