import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lk_content/lk_content.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:long_ky_game/app/unlock_link_listener.dart';
import 'package:long_ky_game/data/codex.dart';
import 'package:long_ky_game/data/content_repository.dart';
import 'package:long_ky_game/data/long_ky_access.dart';
import 'package:long_ky_game/data/long_ky_links.dart';
import 'package:long_ky_game/data/progress.dart';
import 'package:long_ky_game/data/progress_repository.dart';
import 'package:long_ky_game/data/progress_store.dart';
import 'package:long_ky_game/data/unlock_code.dart';
import 'package:long_ky_game/features/battle/labels.dart';
import 'package:long_ky_game/features/codex/codex_entry_screen.dart';
import 'package:long_ky_game/features/codex/codex_screen.dart';
import 'package:long_ky_game/features/settings/progress_cubit.dart';

import 'battle/overlay_support.dart';

class FakeLauncher implements LinkLauncher {
  FakeLauncher({this.opens = const {}});

  /// Hosts the "system" can open.
  final Set<String> opens;
  final List<Uri> tried = [];

  @override
  Future<bool> open(Uri uri) async {
    tried.add(uri);
    return opens.contains(uri.host);
  }
}

void main() {
  late ContentBundle content;
  late Codex codex;
  final codes = UnlockCodes('test-secret');
  const links = LongKyLinks(template: 'https://lk.example.test/{kind}/{id}', storeUrl: 'https://store.example.test/lk');

  setUpAll(() async {
    content = await loadContentFromAssets(DiskAssetBundle());
    codex = Codex(content);
  });

  LongKyAccess access({
    UnlockCodes? codesOverride,
    LongKyLinks? linksOverride,
    FakeLauncher? launcher,
    bool desktop = false,
  }) => LongKyAccess(
    links: linksOverride ?? links,
    codes: codesOverride ?? codes,
    launcher: launcher ?? FakeLauncher(),
    isDesktop: desktop,
  );

  Future<ProgressCubit> pump(
    WidgetTester tester,
    Size size,
    Widget home, {
    LongKyAccess? access_,
    Progress progress = const Progress(),
    String lang = 'vi',
  }) async {
    setViewSize(tester, size);
    final cubit = ProgressCubit(ProgressRepository(MemoryProgressStore()), progress);
    await tester.pumpWidget(
      RepositoryProvider.value(
        value: access_ ?? access(),
        child: BlocProvider.value(
          value: cubit,
          child: DefaultAssetBundle(
            bundle: DiskAssetBundle(),
            child: appAround(home, lang: lang),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    return cubit;
  }

  Future<void> redeem(WidgetTester tester, String typed) async {
    await tester.enterText(find.byKey(const Key('code-field')), typed);
    await tester.tap(find.byKey(const Key('code-redeem')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
  }

  String codeOfFirst(CodexKind kind) => codes.codeFor(codex.ofKind(kind).first.longKyId!);

  group('Codex model', () {
    test('has a page for every officer, commander and card of the content', () {
      expect(codex.ofKind(CodexKind.officer), hasLength(content.officers.length));
      expect(codex.ofKind(CodexKind.enemy), hasLength(content.commanders.length));
      expect(codex.ofKind(CodexKind.card), hasLength(content.cards.length));
      expect(
        codex.entries.every((e) => e.sourceRefs.isNotEmpty),
        isTrue,
        reason: 'CLAUDE.md: every item has a sourceRef',
      );
    });

    test('cards of one event share its id, and one code opens them all', () {
      final event = codex.ofKind(CodexKind.card).first.longKyId!;
      expect(codex.entriesOf(event).length, greaterThan(1));
      expect(codex.unlockableIds.where((i) => i == event), hasLength(1));
    });
  });

  for (final (name, size, _) in layouts) {
    group('Codex screen ($name)', () {
      testWidgets('lists the officers, the commanders and the cards, with the code box on top', (tester) async {
        await pump(tester, size, const CodexScreen());
        final l = strings('vi');
        expect(find.byKey(const Key('unlock-box')), findsOneWidget);
        expect(find.text(l.codexOfficers), findsOneWidget);
        expect(find.text(l.codexEnemies), findsOneWidget);
        expect(find.text(l.codexCards), findsOneWidget);
        for (final e in codex.entries) {
          expect(find.byKey(Key('codex-${e.id}')), findsOneWidget, reason: e.id);
        }
        expect(tester.takeException(), isNull);
      });

      testWidgets('a valid code unlocks the page and marks it; the same code again says so', (tester) async {
        final cubit = await pump(tester, size, const CodexScreen());
        final l = strings('vi');
        final entry = codex.ofKind(CodexKind.officer).first;
        await redeem(tester, codeOfFirst(CodexKind.officer));
        expect(cubit.state.unlocks, [entry.longKyId]);
        expect(find.text(l.codexCodeOk(l.content(entry.name))), findsOneWidget);
        expect(
          find.descendant(of: find.byKey(Key('codex-${entry.id}')), matching: find.byKey(const Key('unlocked-mark'))),
          findsOneWidget,
        );
        expect(tester.widget<TextField>(find.byKey(const Key('code-field'))).controller!.text, isEmpty);

        await redeem(tester, codeOfFirst(CodexKind.officer).toLowerCase());
        expect(cubit.state.unlocks, [entry.longKyId], reason: 'not added twice');
        expect(find.text(l.codexCodeAlready(l.content(entry.name))), findsOneWidget);
      });

      testWidgets('a wrong code is rejected and unlocks nothing', (tester) async {
        final cubit = await pump(tester, size, const CodexScreen());
        final l = strings('vi');
        for (final bad in ['LK-0000-0000', 'nonsense', '']) {
          await redeem(tester, bad);
          expect(find.text(l.codexCodeInvalid), findsOneWidget, reason: bad);
        }
        expect(cubit.state.unlocks, isEmpty);
        expect(find.byKey(const Key('unlocked-mark')), findsNothing);
      });

      testWidgets('a code made with another secret is rejected', (tester) async {
        final cubit = await pump(tester, size, const CodexScreen());
        await redeem(tester, UnlockCodes('another-secret').codeFor(codex.ofKind(CodexKind.officer).first.longKyId!));
        expect(find.text(strings('vi').codexCodeInvalid), findsOneWidget);
        expect(cubit.state.unlocks, isEmpty);
      });

      testWidgets('a build without a secret says codes cannot be checked, and accepts none', (tester) async {
        final cubit = await pump(tester, size, const CodexScreen(), access_: access(codesOverride: UnlockCodes('')));
        await redeem(tester, codeOfFirst(CodexKind.officer));
        expect(find.text(strings('vi').codexCodeUnavailable), findsOneWidget);
        expect(cubit.state.unlocks, isEmpty);
      });

      testWidgets('an event code opens all the cards of that event', (tester) async {
        final cubit = await pump(tester, size, const CodexScreen());
        final card = codex.ofKind(CodexKind.card).first;
        await redeem(tester, codes.codeFor(card.longKyId!));
        expect(cubit.state.unlocks, [card.longKyId]);
        final shared = codex.entriesOf(card.longKyId!);
        for (final e in shared) {
          expect(
            find.descendant(of: find.byKey(Key('codex-${e.id}')), matching: find.byKey(const Key('unlocked-mark'))),
            findsOneWidget,
            reason: e.id,
          );
        }
      });

      testWidgets('the messages are in English too', (tester) async {
        await pump(tester, size, const CodexScreen(), lang: 'en');
        await redeem(tester, 'LK-0000-0000');
        expect(find.text('That code is not valid. Check it and try again.'), findsOneWidget);
        expect(find.text('Enter an unlock code'), findsOneWidget);
      });

      testWidgets('the unlock marks survive in the saved progress', (tester) async {
        final entry = codex.ofKind(CodexKind.officer).first;
        await pump(tester, size, const CodexScreen(), progress: Progress(unlocks: [entry.longKyId!]));
        expect(
          find.descendant(of: find.byKey(Key('codex-${entry.id}')), matching: find.byKey(const Key('unlocked-mark'))),
          findsOneWidget,
        );
      });
    });

    group('Codex entry ($name)', () {
      Future<void> open(WidgetTester tester, CodexEntry e, {LongKyAccess? a, Progress progress = const Progress()}) =>
          pump(
            tester,
            size,
            CodexEntryScreen(entry: e, sources: content.sources),
            access_: a,
            progress: progress,
          );

      testWidgets('an officer shows stats, skill, flaw and each source by its title', (tester) async {
        final e = codex.ofKind(CodexKind.officer).first;
        final o = e.officer!;
        await open(tester, e);
        final l = strings('vi');
        expect(find.text(l.content(e.name)), findsWidgets);
        expect(find.text('${l.statWar}: ${o.stats.war}'), findsOneWidget);
        expect(find.textContaining(l.content(o.skill!.name)), findsOneWidget);
        expect(find.text(l.content(o.skill!.text)), findsOneWidget);
        for (final ref in e.sourceRefs) {
          final src = content.sources[ref]!;
          expect(
            find.descendant(of: find.byKey(Key('source-$ref')), matching: find.textContaining(src.work)),
            findsOneWidget,
          );
        }
        expect(tester.takeException(), isNull);
      });

      testWidgets('a commander and a card have pages too', (tester) async {
        for (final kind in [CodexKind.enemy, CodexKind.card]) {
          final e = codex.ofKind(kind).first;
          await open(tester, e);
          expect(find.byKey(const Key('codex-entry')), findsOneWidget);
          expect(find.text(strings('vi').content(e.name)), findsWidgets);
          if (kind == CodexKind.card) expect(find.text(strings('vi').content(e.card!.text)), findsOneWidget);
          expect(tester.takeException(), isNull);
        }
      });

      testWidgets('shows "Unlocked" only after the code was entered', (tester) async {
        final e = codex.ofKind(CodexKind.officer).first;
        await open(tester, e);
        expect(find.byKey(const Key('entry-unlocked')), findsNothing);
        await open(tester, e, progress: Progress(unlocks: [e.longKyId!]));
        expect(find.byKey(const Key('entry-unlocked')), findsOneWidget);
      });
    });
  }

  group('Read more in Long Ký', () {
    CodexEntry person() => codex.ofKind(CodexKind.officer).firstWhere((e) => e.longKyId != null);

    Future<void> openPage(WidgetTester tester, LongKyAccess a, {Size size = compact}) => pump(
      tester,
      size,
      CodexEntryScreen(entry: person(), sources: content.sources),
      access_: a,
    );

    testWidgets('is not offered when the build has no link format', (tester) async {
      await openPage(tester, access(linksOverride: const LongKyLinks()));
      expect(find.byKey(const Key('read-more')), findsNothing);
    });

    testWidgets('on a phone it opens the person link', (tester) async {
      final launcher = FakeLauncher(opens: {'lk.example.test'});
      await openPage(tester, access(launcher: launcher));
      expect(find.text(strings('vi').longKyReadMore), findsOneWidget);
      await tester.ensureVisible(find.byKey(const Key('read-more')));
      await tester.tap(find.byKey(const Key('read-more')));
      await tester.pump();
      expect(launcher.tried.map((u) => u.toString()), ['https://lk.example.test/person/${person().longKyId}']);
      expect(find.text(strings('vi').longKyOpenFailed), findsNothing);
    });

    testWidgets('if the link cannot be opened it opens the store page', (tester) async {
      final launcher = FakeLauncher(opens: {'store.example.test'});
      await openPage(tester, access(launcher: launcher));
      await tester.ensureVisible(find.byKey(const Key('read-more')));
      await tester.tap(find.byKey(const Key('read-more')));
      await tester.pump();
      expect(launcher.tried.map((u) => u.host), ['lk.example.test', 'store.example.test']);
      expect(find.text(strings('vi').longKyOpenFailed), findsNothing);
    });

    testWidgets('if neither opens it says so', (tester) async {
      final launcher = FakeLauncher();
      await openPage(tester, access(launcher: launcher));
      await tester.ensureVisible(find.byKey(const Key('read-more')));
      await tester.tap(find.byKey(const Key('read-more')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text(strings('vi').longKyOpenFailed), findsOneWidget);
    });

    testWidgets('on a desktop it shows the same link as a QR code with the text, and opens nothing', (tester) async {
      final launcher = FakeLauncher(opens: {'lk.example.test'});
      await openPage(tester, access(launcher: launcher, desktop: true), size: regular);
      await tester.ensureVisible(find.byKey(const Key('read-more')));
      await tester.tap(find.byKey(const Key('read-more')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byKey(const Key('qr-dialog')), findsOneWidget);
      expect(find.text('Quét bằng điện thoại để mở Long Ký'), findsOneWidget);
      expect(find.byType(QrImageView), findsOneWidget);
      expect(
        tester.widget<SelectableText>(find.byKey(const Key('qr-link'))).data,
        'https://lk.example.test/person/${person().longKyId}',
        reason: 'the QR code carries this same link',
      );
      expect(launcher.tried, isEmpty);
      await tester.tap(find.text(strings('vi').actionClose));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byKey(const Key('qr-dialog')), findsNothing);
    });

    testWidgets('the QR text is English in English', (tester) async {
      setViewSize(tester, regular);
      await pump(
        tester,
        regular,
        CodexEntryScreen(entry: person(), sources: content.sources),
        access_: access(desktop: true),
        lang: 'en',
      );
      await tester.ensureVisible(find.byKey(const Key('read-more')));
      await tester.tap(find.byKey(const Key('read-more')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Scan with your phone to open Long Ký'), findsOneWidget);
    });
  });

  group('incoming unlock link (mobile)', () {
    test('only longkygame://unlock?code=... is an unlock link', () {
      expect(unlockCodeOf(Uri.parse('longkygame://unlock?code=LK-N3BK-S5R0')), 'LK-N3BK-S5R0');
      for (final other in [
        'longkygame://unlock',
        'longkygame://unlock?code=',
        'longkygame://other?code=LK-N3BK-S5R0',
        'https://unlock/?code=LK-N3BK-S5R0',
        'othergame://unlock?code=LK-N3BK-S5R0',
      ]) {
        expect(unlockCodeOf(Uri.parse(other)), isNull, reason: other);
      }
    });

    Future<(ProgressCubit, StreamController<Uri>)> pumpListener(WidgetTester tester, {LongKyAccess? a}) async {
      final controller = StreamController<Uri>();
      addTearDown(controller.close);
      setViewSize(tester, compact);
      final cubit = ProgressCubit(ProgressRepository(MemoryProgressStore()), const Progress());
      await tester.pumpWidget(
        RepositoryProvider.value(
          value: a ?? access(),
          child: BlocProvider.value(
            value: cubit,
            child: DefaultAssetBundle(
              bundle: DiskAssetBundle(),
              child: appAround(
                UnlockLinkListener(
                  links: controller.stream,
                  child: const Scaffold(body: SizedBox()),
                ),
              ),
            ),
          ),
        ),
      );
      return (cubit, controller);
    }

    testWidgets('a valid code in a link unlocks and says so', (tester) async {
      final (cubit, links) = await pumpListener(tester);
      final entry = codex.ofKind(CodexKind.officer).first;
      links.add(Uri.parse('longkygame://unlock?code=${codes.codeFor(entry.longKyId!)}'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(cubit.state.unlocks, [entry.longKyId]);
      final l = strings('vi');
      expect(find.text(l.codexCodeOk(l.content(entry.name))), findsOneWidget);
    });

    testWidgets('a wrong code in a link is rejected, and other links are ignored', (tester) async {
      final (cubit, links) = await pumpListener(tester);
      links.add(Uri.parse('longkygame://unlock?code=LK-0000-0000'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text(strings('vi').codexCodeInvalid), findsOneWidget);
      expect(cubit.state.unlocks, isEmpty);

      links.add(Uri.parse('https://example.test/whatever'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(cubit.state.unlocks, isEmpty);
    });
  });
}
