import 'package:flutter/widgets.dart';

import '../features/battle/board_preview_screen.dart';
import '../features/briefing/briefing_screen.dart';
import '../features/campaign/campaign_screen.dart';
import '../features/codex/codex_screen.dart';
import '../features/menu/title_screen.dart';
import '../features/settings/credits_screen.dart';
import '../features/settings/settings_screen.dart';

abstract final class Routes {
  static const String title = '/';
  static const String campaign = '/campaign';
  static const String codex = '/codex';
  static const String settings = '/settings';
  static const String credits = '/settings/credits';

  /// Debug builds only: the board with a mission's start state.
  static const String boardPreview = '/debug/board';

  /// Debug builds only: the briefing of a mission, until the campaign (T-23)
  /// opens it.
  static const String briefingPreview = '/debug/briefing';

  static final Map<String, WidgetBuilder> table = {
    title: (_) => const TitleScreen(),
    campaign: (_) => const CampaignScreen(),
    codex: (_) => const CodexScreen(),
    settings: (_) => const SettingsScreen(),
    credits: (_) => const CreditsScreen(),
    boardPreview: (_) => const BoardPreviewScreen(),
    briefingPreview: (_) => const BriefingScreen(missionId: 'ch1_m2'),
  };
}
