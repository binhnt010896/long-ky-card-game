import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi'),
  ];

  /// Product name. A proper name, the same in every language.
  ///
  /// In vi, this message translates to:
  /// **'Long Ký - The Game'**
  String get appTitle;

  /// Title screen: resume the saved battle.
  ///
  /// In vi, this message translates to:
  /// **'Tiếp tục'**
  String get menuContinue;

  /// Title screen: chapter and mission select.
  ///
  /// In vi, this message translates to:
  /// **'Chiến dịch'**
  String get menuCampaign;

  /// Title screen: officer, event and card lore.
  ///
  /// In vi, this message translates to:
  /// **'Sử liệu'**
  String get menuCodex;

  /// Title screen: settings.
  ///
  /// In vi, this message translates to:
  /// **'Cài đặt'**
  String get menuSettings;

  /// Body of a screen that is not built yet.
  ///
  /// In vi, this message translates to:
  /// **'Sắp ra mắt.'**
  String get comingSoon;

  /// No description provided for @settingsTitle.
  ///
  /// In vi, this message translates to:
  /// **'Cài đặt'**
  String get settingsTitle;

  /// No description provided for @settingsLanguage.
  ///
  /// In vi, this message translates to:
  /// **'Ngôn ngữ'**
  String get settingsLanguage;

  /// Always shown in Vietnamese, whatever the current language.
  ///
  /// In vi, this message translates to:
  /// **'Tiếng Việt'**
  String get languageVietnamese;

  /// Always shown in English, whatever the current language.
  ///
  /// In vi, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @settingsAudio.
  ///
  /// In vi, this message translates to:
  /// **'Âm thanh'**
  String get settingsAudio;

  /// No description provided for @volumeMusic.
  ///
  /// In vi, this message translates to:
  /// **'Nhạc nền'**
  String get volumeMusic;

  /// No description provided for @volumeVoice.
  ///
  /// In vi, this message translates to:
  /// **'Lời dẫn'**
  String get volumeVoice;

  /// No description provided for @volumeEffects.
  ///
  /// In vi, this message translates to:
  /// **'Hiệu ứng'**
  String get volumeEffects;

  /// No description provided for @percentValue.
  ///
  /// In vi, this message translates to:
  /// **'{percent}%'**
  String percentValue(int percent);

  /// No description provided for @settingsTextSize.
  ///
  /// In vi, this message translates to:
  /// **'Cỡ chữ'**
  String get settingsTextSize;

  /// No description provided for @settingsReduceMotion.
  ///
  /// In vi, this message translates to:
  /// **'Giảm chuyển động'**
  String get settingsReduceMotion;

  /// No description provided for @settingsReduceMotionHint.
  ///
  /// In vi, this message translates to:
  /// **'Bỏ qua hoạt cảnh trên bản đồ.'**
  String get settingsReduceMotionHint;

  /// No description provided for @settingsResetProgress.
  ///
  /// In vi, this message translates to:
  /// **'Xoá tiến trình'**
  String get settingsResetProgress;

  /// No description provided for @resetConfirmTitle.
  ///
  /// In vi, this message translates to:
  /// **'Xoá toàn bộ tiến trình?'**
  String get resetConfirmTitle;

  /// No description provided for @resetConfirmBody.
  ///
  /// In vi, this message translates to:
  /// **'Sao và các mục đã mở khoá sẽ bị xoá. Cài đặt được giữ nguyên.'**
  String get resetConfirmBody;

  /// No description provided for @actionCancel.
  ///
  /// In vi, this message translates to:
  /// **'Huỷ'**
  String get actionCancel;

  /// No description provided for @actionReset.
  ///
  /// In vi, this message translates to:
  /// **'Xoá'**
  String get actionReset;

  /// No description provided for @resetDone.
  ///
  /// In vi, this message translates to:
  /// **'Đã xoá tiến trình.'**
  String get resetDone;

  /// No description provided for @settingsCredits.
  ///
  /// In vi, this message translates to:
  /// **'Ghi công và nguồn tư liệu'**
  String get settingsCredits;

  /// No description provided for @creditsFont.
  ///
  /// In vi, this message translates to:
  /// **'Phông chữ Be Vietnam Pro, theo giấy phép SIL Open Font License 1.1.'**
  String get creditsFont;

  /// No description provided for @creditsLicenses.
  ///
  /// In vi, this message translates to:
  /// **'Giấy phép phần mềm'**
  String get creditsLicenses;

  /// No description provided for @creditsSources.
  ///
  /// In vi, this message translates to:
  /// **'Nguồn tư liệu'**
  String get creditsSources;

  /// No description provided for @creditsLoadError.
  ///
  /// In vi, this message translates to:
  /// **'Không đọc được dữ liệu nguồn.'**
  String get creditsLoadError;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
