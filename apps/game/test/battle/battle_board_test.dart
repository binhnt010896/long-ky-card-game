import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lk_rules/lk_rules.dart';
import 'package:long_ky_game/app/l10n/app_localizations.dart';
import 'package:long_ky_game/features/battle/board/battle_board.dart';
import 'package:long_ky_game/features/battle/board/board_game.dart';
import 'package:long_ky_game/features/battle/board/board_scene.dart';
import 'package:long_ky_game/features/battle/board_preview_screen.dart';

import 'board_support.dart';

Future<BoardGame> pumpBoard(
  WidgetTester tester, {
  required Size size,
  String missionId = 'ch1_m2',
  String lang = 'vi',
  GameState? state,
  ValueChanged<Selection?>? onSelection,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      home: BattleBoard(
        key: const Key('board'),
        ruleset: ruleset(missionId),
        state: state ?? startState(missionId),
        languageCode: lang,
        onSelectionChanged: onSelection,
      ),
    ),
  );
  // Let Flame load and lay out.
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
  return tester.widget<GameWidget<BoardGame>>(find.byType(GameWidget<BoardGame>)).game!;
}

void main() {
  for (final (name, size) in [('compact', compact), ('regular', regular)]) {
    group('Flame board at $name size', () {
      testWidgets('draws the ch1_m2 start state without errors', (tester) async {
        final game = await pumpBoard(tester, size: size);
        expect(tester.takeException(), isNull);
        final scene = game.scene!;
        expect(scene.layout.size, size);
        expect(scene.layout.isCompact, size.width < 900);
        expect(scene.nodes, hasLength(9));
        expect(scene.tokens, hasLength(4));
        expect(scene.arrows.single.intent, IntentKind.assault);
        expect(game.hasLayout, isTrue);
      });

      testWidgets('a tap selects a token or a node; a tap on empty ground clears it', (tester) async {
        final picked = <Selection?>[];
        final game = await pumpBoard(tester, size: size, onSelection: picked.add);
        final scene = game.scene!;

        Future<void> tapAt(Offset p) async {
          await tester.tapAt(p);
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 50));
        }

        final king = scene.tokens.firstWhere((t) => t.id == 'tran-thai-tong');
        await tapAt(king.center);
        expect(game.selection.value, const Selection(SelectionKind.officer, 'tran-thai-tong'));
        expect(game.scene!.selection, game.selection.value, reason: 'the scene shows the selection');

        await tapAt(scene.node('thang-long').center);
        expect(game.selection.value, const Selection(SelectionKind.node, 'thang-long'));

        final army = scene.tokens.firstWhere((t) => t.id == 'mong-co-1258');
        await tapAt(army.center);
        expect(game.selection.value, const Selection(SelectionKind.army, 'mong-co-1258'));

        await tapAt(const Offset(4, 4));
        expect(game.selection.value, isNull);
        expect(picked, [
          const Selection(SelectionKind.officer, 'tran-thai-tong'),
          const Selection(SelectionKind.node, 'thang-long'),
          const Selection(SelectionKind.army, 'mong-co-1258'),
          null,
        ]);
      });
    });
  }

  testWidgets('the board follows the state and the language live', (tester) async {
    tester.view.physicalSize = regular;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final rs = ruleset('ch1_m2');
    final engine = GameEngine(rs);
    final s0 = engine.newGame(1).state;
    final host = ValueNotifier<(GameState, String)>((s0, 'vi'));
    await tester.pumpWidget(
      MaterialApp(
        home: ValueListenableBuilder<(GameState, String)>(
          valueListenable: host,
          builder: (context, v, _) => BattleBoard(ruleset: rs, state: v.$1, languageCode: v.$2),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    final game = tester.widget<GameWidget<BoardGame>>(find.byType(GameWidget<BoardGame>)).game!;
    expect(game.scene!.node('song-thao').name, 'Sông Thao');

    host.value = (s0, 'en');
    await tester.pump();
    expect(game.scene!.node('song-thao').name, 'Thao River');

    // One full turn: the officers hold, the army assaults and wins.
    final s1 = endTurn(engine, s0).state;
    host.value = (s1, 'en');
    await tester.pump();
    expect(game.scene!.tokens, isNotEmpty);
    expect(game.scene!.node('binh-le-nguyen').controller, s1.nodes['binh-le-nguyen']!.controller);
    expect(game.state, s1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('resizing the window re-lays the board out', (tester) async {
    final game = await pumpBoard(tester, size: compact);
    final small = game.scene!.layout.nodeRadius;
    tester.view.physicalSize = regular;
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(game.scene!.layout.size, regular);
    expect(game.scene!.layout.nodeRadius, greaterThan(small));
  });

  testWidgets('the debug preview screen loads a mission from the content assets', (tester) async {
    tester.view.physicalSize = regular;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    // The preview is the battle screen now, so it needs the app's localization.
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('vi'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: const BoardPreviewScreen(missionId: 'ch1_m3'),
      ),
    );
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 500)));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    final game = tester.widget<GameWidget<BoardGame>>(find.byType(GameWidget<BoardGame>)).game!;
    expect(game.ruleset.mission.id, 'ch1_m3');
    expect(game.scene!.tokens.where((t) => t.nodeId == 'thang-long'), hasLength(4));
    // The overlays are there too: the season clock of ch1_m3 (6 turns) and the phase button.
    expect(find.text('Lượt 1/6'), findsOneWidget);
    expect(find.byKey(const Key('phase-button')), findsOneWidget);
  });
}
