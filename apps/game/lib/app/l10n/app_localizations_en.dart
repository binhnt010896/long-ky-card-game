// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Long Ký - The Game';

  @override
  String get menuContinue => 'Continue';

  @override
  String get menuCampaign => 'Campaign';

  @override
  String get menuCodex => 'Codex';

  @override
  String get menuSettings => 'Settings';

  @override
  String get comingSoon => 'Coming soon.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get languageVietnamese => 'Tiếng Việt';

  @override
  String get languageEnglish => 'English';

  @override
  String get settingsAudio => 'Audio';

  @override
  String get volumeMusic => 'Music';

  @override
  String get volumeVoice => 'Voice';

  @override
  String get volumeEffects => 'Effects';

  @override
  String percentValue(int percent) {
    return '$percent%';
  }

  @override
  String get settingsTextSize => 'Text size';

  @override
  String get settingsReduceMotion => 'Reduce motion';

  @override
  String get settingsReduceMotionHint => 'Skip map animations.';

  @override
  String get settingsResetProgress => 'Reset progress';

  @override
  String get resetConfirmTitle => 'Reset all progress?';

  @override
  String get resetConfirmBody =>
      'Stars and unlocks will be erased. Settings are kept.';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionReset => 'Reset';

  @override
  String get resetDone => 'Progress reset.';

  @override
  String get settingsCredits => 'Credits and sources';

  @override
  String get creditsFont =>
      'Be Vietnam Pro typeface, under the SIL Open Font License 1.1.';

  @override
  String get creditsLicenses => 'Software licences';

  @override
  String get creditsSources => 'Sources';

  @override
  String get creditsLoadError => 'Could not read the source list.';
}
