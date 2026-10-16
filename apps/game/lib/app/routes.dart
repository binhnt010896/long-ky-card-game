import 'package:flutter/widgets.dart';

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

  static final Map<String, WidgetBuilder> table = {
    title: (_) => const TitleScreen(),
    campaign: (_) => const CampaignScreen(),
    codex: (_) => const CodexScreen(),
    settings: (_) => const SettingsScreen(),
    credits: (_) => const CreditsScreen(),
  };
}
