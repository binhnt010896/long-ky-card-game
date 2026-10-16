import 'package:flame/game.dart';
import 'package:flutter/gestures.dart' show PointerDeviceKind;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lk_rules/lk_rules.dart';
import 'package:long_ky_game/app/l10n/app_localizations.dart';
import 'package:long_ky_game/app/theme.dart';
import 'package:long_ky_game/features/battle/battle_cubit.dart';
import 'package:long_ky_game/features/battle/battle_screen.dart';
import 'package:long_ky_game/features/battle/board/board_game.dart';
import 'package:long_ky_game/features/battle/labels.dart';

import 'board_support.dart';

export 'board_support.dart';

const mission = 'ch1_m2';

/// Both layouts, as the build spec names them.
const layouts = <(String, Size, BattleLayoutMode)>[
  ('compact', compact, BattleLayoutMode.compact),
  ('regular', regular, BattleLayoutMode.regular),
];

/// The strings of [lang], for expectations.
AppLocalizations strings(String lang) => lookupAppLocalizations(Locale(lang));

Widget appAround(Widget child, {String lang = 'vi', double textScale = 1, bool reduceMotion = false}) => MaterialApp(
  debugShowCheckedModeBanner: false,
  theme: buildLongKyTheme(),
  locale: Locale(lang),
  supportedLocales: AppLocalizations.supportedLocales,
  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(textScale), disableAnimations: reduceMotion),
    child: child!,
  ),
  home: child,
);

void setViewSize(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

/// Pumps [child] full-screen at [size] on a lacquer background.
Future<void> pumpOverlay(
  WidgetTester tester,
  Size size,
  Widget child, {
  String lang = 'vi',
  double textScale = 1,
}) async {
  setViewSize(tester, size);
  await tester.pumpWidget(
    appAround(
      Scaffold(
        backgroundColor: LongKyColors.lacquer,
        body: Align(alignment: Alignment.topLeft, child: child),
      ),
      lang: lang,
      textScale: textScale,
    ),
  );
  await tester.pump();
}

/// Pumps the whole battle screen at [size] and lets Flame load.
Future<BattleCubit> pumpBattle(
  WidgetTester tester,
  Size size, {
  String lang = 'vi',
  double textScale = 1,
  String missionId = mission,
  VoidCallback? onExit,
  bool reduceMotion = false,
}) async {
  setViewSize(tester, size);
  final cubit = BattleCubit(GameEngine(ruleset(missionId)), seed: 1);
  addTearDown(cubit.close);
  await tester.pumpWidget(
    appAround(
      BlocProvider.value(
        value: cubit,
        child: BattleScreen(ruleset: ruleset(missionId), onExit: onExit),
      ),
      lang: lang,
      textScale: textScale,
      reduceMotion: reduceMotion,
    ),
  );
  await settle(tester);
  return cubit;
}

/// Flame's loop never goes idle, so pumpAndSettle would hang: pump by hand.
Future<void> settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
  await tester.pump(const Duration(milliseconds: 250));
}

BoardGame boardGame(WidgetTester tester) =>
    tester.widget<GameWidget<BoardGame>>(find.byType(GameWidget<BoardGame>)).game!;

Rect rectOf(WidgetTester tester, Finder f) => tester.getRect(f);

/// A start state with [court] Court, for the low-Court rules.
GameState withUnity(GameState s, {int? court, int? clan, int? people}) => s.copyWith(
  unity: Unity(court: court ?? s.unity.court, clan: clan ?? s.unity.clan, people: people ?? s.unity.people),
);

/// Lets the board play every queued animation to its end.
Future<void> playOut(WidgetTester tester) async {
  for (var i = 0; i < 100; i++) {
    await tester.pump(const Duration(milliseconds: 100));
    if (!boardGame(tester).busy.value) break;
  }
  expect(boardGame(tester).busy.value, isFalse, reason: 'animations should end');
  await tester.pump(const Duration(milliseconds: 50));
}

/// A click with a mouse: it hovers first, as a real one does.
Future<void> mouseTap(WidgetTester tester, Finder f) async {
  final at = tester.getCenter(f);
  final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
  await mouse.addPointer(location: at);
  await mouse.moveTo(at);
  await tester.pump();
  await mouse.down(at);
  await tester.pump();
  await mouse.up();
  await mouse.removePointer();
  await tester.pump(const Duration(milliseconds: 50));
}
