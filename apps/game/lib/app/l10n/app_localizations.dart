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

  /// Battle top bar: current turn out of the mission length (the season clock).
  ///
  /// In vi, this message translates to:
  /// **'Lượt {turn}/{total}'**
  String battleTurnClock(int turn, int total);

  /// Screen-reader label of the season clock.
  ///
  /// In vi, this message translates to:
  /// **'Đồng hồ mùa: lượt {turn} trên {total}'**
  String battleSeasonClockSemantics(int turn, int total);

  /// Turn phase 1.
  ///
  /// In vi, this message translates to:
  /// **'Trinh sát'**
  String get phaseIntel;

  /// Turn phase 2: play cards.
  ///
  /// In vi, this message translates to:
  /// **'Triều nghị'**
  String get phaseCouncil;

  /// Turn phase 3: give each officer an order.
  ///
  /// In vi, this message translates to:
  /// **'Hạ lệnh'**
  String get phaseOrders;

  /// Turn phase 4: moves, battles and foraging resolve.
  ///
  /// In vi, this message translates to:
  /// **'Giao tranh'**
  String get phaseResolution;

  /// Turn phase 5.
  ///
  /// In vi, this message translates to:
  /// **'Hậu cần'**
  String get phaseUpkeep;

  /// The mission is over.
  ///
  /// In vi, this message translates to:
  /// **'Kết thúc'**
  String get phaseEnded;

  /// Player resource: Rice (Lương).
  ///
  /// In vi, this message translates to:
  /// **'Lương'**
  String get resourceRice;

  /// Player resource: Popular Support (Lòng dân).
  ///
  /// In vi, this message translates to:
  /// **'Lòng dân'**
  String get resourceSupport;

  /// Unity pillar: Court.
  ///
  /// In vi, this message translates to:
  /// **'Triều đình'**
  String get unityCourt;

  /// Unity pillar: Clan.
  ///
  /// In vi, this message translates to:
  /// **'Tông thất'**
  String get unityClan;

  /// Unity pillar: People.
  ///
  /// In vi, this message translates to:
  /// **'Dân chúng'**
  String get unityPeople;

  /// Screen-reader label of a Unity gauge.
  ///
  /// In vi, this message translates to:
  /// **'{pillar}: {value} trên 10'**
  String unitySemantics(String pillar, int value);

  /// Screen-reader label of a Unity gauge below 4.
  ///
  /// In vi, this message translates to:
  /// **'{pillar}: {value} trên 10, thấp'**
  String unitySemanticsLow(String pillar, int value);

  /// Screen-reader label of Rice or Support.
  ///
  /// In vi, this message translates to:
  /// **'{resource}: {value}'**
  String resourceSemantics(String resource, int value);

  /// Screen-reader label of the officer strip.
  ///
  /// In vi, this message translates to:
  /// **'Tướng lĩnh'**
  String get officerStripLabel;

  /// Troops in thousands, short form.
  ///
  /// In vi, this message translates to:
  /// **'{n}k'**
  String troopsShort(int n);

  /// Troops in thousands, full form.
  ///
  /// In vi, this message translates to:
  /// **'{n}.000 quân'**
  String troopsFull(int n);

  /// Morale value.
  ///
  /// In vi, this message translates to:
  /// **'Sĩ khí {n}'**
  String moraleShort(int n);

  /// Officer status.
  ///
  /// In vi, this message translates to:
  /// **'Đã đào ngũ'**
  String get statusDefected;

  /// Officer status.
  ///
  /// In vi, this message translates to:
  /// **'Bị bắt'**
  String get statusCaptured;

  /// Officer has no order yet.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có lệnh'**
  String get orderNone;

  /// Order.
  ///
  /// In vi, this message translates to:
  /// **'Cố thủ'**
  String get orderHold;

  /// Order.
  ///
  /// In vi, this message translates to:
  /// **'Hành quân'**
  String get orderMove;

  /// Order.
  ///
  /// In vi, this message translates to:
  /// **'Sơ tán'**
  String get orderEvacuate;

  /// Order.
  ///
  /// In vi, this message translates to:
  /// **'Tập kích'**
  String get orderRaid;

  /// Order.
  ///
  /// In vi, this message translates to:
  /// **'Phục kích'**
  String get orderAmbush;

  /// Order.
  ///
  /// In vi, this message translates to:
  /// **'Chiêu mộ'**
  String get orderRally;

  /// An order with its target.
  ///
  /// In vi, this message translates to:
  /// **'{order}: {target}'**
  String orderWithTarget(String order, String target);

  /// Screen-reader label of an officer tile.
  ///
  /// In vi, this message translates to:
  /// **'{name}, {troops}, {state}'**
  String officerSemantics(String name, String troops, String state);

  /// Hand of cards header.
  ///
  /// In vi, this message translates to:
  /// **'Bài trên tay ({count})'**
  String handTitle(int count);

  /// Hand is empty.
  ///
  /// In vi, this message translates to:
  /// **'Không còn lá bài nào.'**
  String get handEmpty;

  /// Compact layout: open the hand drawer.
  ///
  /// In vi, this message translates to:
  /// **'Mở bài trên tay'**
  String get handShow;

  /// Compact layout: close the hand drawer.
  ///
  /// In vi, this message translates to:
  /// **'Thu bài lại'**
  String get handHide;

  /// Cards left in the draw pile and the discard pile.
  ///
  /// In vi, this message translates to:
  /// **'Rút: {deck} · Bỏ: {discard}'**
  String handPiles(int deck, int discard);

  /// Shown while Court is below 4.
  ///
  /// In vi, this message translates to:
  /// **'Triều đình thấp: mỗi lá bài tốn thêm {extra} lòng dân.'**
  String handCourtSurcharge(int extra);

  /// Card type.
  ///
  /// In vi, this message translates to:
  /// **'Mưu kế'**
  String get cardTypeStratagem;

  /// Card type.
  ///
  /// In vi, this message translates to:
  /// **'Sự kiện'**
  String get cardTypeEvent;

  /// Card type.
  ///
  /// In vi, this message translates to:
  /// **'Ý đồ địch'**
  String get cardTypeIntent;

  /// A card with no cost.
  ///
  /// In vi, this message translates to:
  /// **'Miễn phí'**
  String get cardFree;

  /// Shown on a card the player cannot pay for.
  ///
  /// In vi, this message translates to:
  /// **'Không đủ để dùng'**
  String get cardCannotAfford;

  /// Screen-reader label of a card cost.
  ///
  /// In vi, this message translates to:
  /// **'Giá: {rice} lương, {support} lòng dân'**
  String cardCostSemantics(int rice, int support);

  /// Screen-reader label of a card.
  ///
  /// In vi, this message translates to:
  /// **'{name}, {type}, {cost}'**
  String cardSemantics(String name, String type, String cost);

  /// Ends Council and moves to Orders.
  ///
  /// In vi, this message translates to:
  /// **'Sang hạ lệnh'**
  String get phaseButtonCouncil;

  /// Ends Orders and resolves the turn.
  ///
  /// In vi, this message translates to:
  /// **'Chốt lệnh'**
  String get phaseButtonOrders;

  /// Disabled while a choice is pending.
  ///
  /// In vi, this message translates to:
  /// **'Hãy chọn trước'**
  String get phaseButtonChoice;

  /// Disabled once the mission has ended.
  ///
  /// In vi, this message translates to:
  /// **'Đã kết thúc'**
  String get phaseButtonEnded;

  /// Disabled while the turn is resolving.
  ///
  /// In vi, this message translates to:
  /// **'Đang diễn ra'**
  String get phaseButtonWait;

  /// Event log title.
  ///
  /// In vi, this message translates to:
  /// **'Nhật ký'**
  String get logTitle;

  /// Open the event log.
  ///
  /// In vi, this message translates to:
  /// **'Mở nhật ký'**
  String get logShow;

  /// Close the event log.
  ///
  /// In vi, this message translates to:
  /// **'Đóng nhật ký'**
  String get logHide;

  /// Collapse the left log panel.
  ///
  /// In vi, this message translates to:
  /// **'Thu nhật ký'**
  String get logCollapse;

  /// Expand the left log panel.
  ///
  /// In vi, this message translates to:
  /// **'Mở rộng nhật ký'**
  String get logExpand;

  /// Empty event log.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có gì xảy ra.'**
  String get logEmpty;

  /// Log line.
  ///
  /// In vi, this message translates to:
  /// **'Lượt {turn} bắt đầu.'**
  String logTurnStarted(int turn);

  /// Log line.
  ///
  /// In vi, this message translates to:
  /// **'Giai đoạn: {phase}.'**
  String logPhaseChanged(String phase);

  /// Log line.
  ///
  /// In vi, this message translates to:
  /// **'Dùng bài {card}.'**
  String logCardPlayed(String card);

  /// Log line.
  ///
  /// In vi, this message translates to:
  /// **'Dùng bài {card} tại {target}.'**
  String logCardPlayedOn(String card, String target);

  /// Log line.
  ///
  /// In vi, this message translates to:
  /// **'{officer} dùng kỹ năng {skill}.'**
  String logSkillUsed(String officer, String skill);

  /// Log line.
  ///
  /// In vi, this message translates to:
  /// **'{officer}: {order}.'**
  String logOrderSet(String officer, String order);

  /// Log line.
  ///
  /// In vi, this message translates to:
  /// **'{officer}: bỏ lệnh.'**
  String logOrderCleared(String officer);

  /// Log line.
  ///
  /// In vi, this message translates to:
  /// **'Lượt này bỏ qua giai đoạn hạ lệnh.'**
  String get logOrdersSkipped;

  /// Log line.
  ///
  /// In vi, this message translates to:
  /// **'{unit} đi từ {from} đến {to}.'**
  String logUnitMoved(String unit, String from, String to);

  /// Log line.
  ///
  /// In vi, this message translates to:
  /// **'Sơ tán {node}: thu {rice} lương.'**
  String logNodeEvacuated(String node, int rice);

  /// Log line.
  ///
  /// In vi, this message translates to:
  /// **'{officer} chiêu mộ thêm {troops} nghìn quân tại {node}.'**
  String logRallied(String officer, String node, int troops);

  /// Log line.
  ///
  /// In vi, this message translates to:
  /// **'{officer} mai phục tại {edge}.'**
  String logAmbushPlaced(String officer, String edge);

  /// Log line.
  ///
  /// In vi, this message translates to:
  /// **'Trận {node}: Đại Việt thắng.'**
  String logBattleWon(String node);

  /// Log line.
  ///
  /// In vi, this message translates to:
  /// **'Trận {node}: quân Nguyên thắng.'**
  String logBattleLost(String node);

  /// Log line.
  ///
  /// In vi, this message translates to:
  /// **'Trận {node}: không phân thắng bại.'**
  String logBattleDraw(String node);

  /// Log line.
  ///
  /// In vi, this message translates to:
  /// **'{officer} bị bắt tại {node}.'**
  String logOfficerCaptured(String officer, String node);

  /// Log line.
  ///
  /// In vi, this message translates to:
  /// **'{shield} che chắn cho {king}.'**
  String logKingShielded(String king, String shield);

  /// Log line.
  ///
  /// In vi, this message translates to:
  /// **'{officer} tập kích {army}: tiếp tế -{supply}, quân -{troops}k.'**
  String logRaided(String officer, String army, int supply, int troops);

  /// Log line.
  ///
  /// In vi, this message translates to:
  /// **'{army} cướp lương tại {node}: tiếp tế +{supply}.'**
  String logForaged(String army, String node, int supply);

  /// Log line.
  ///
  /// In vi, this message translates to:
  /// **'{node} nay thuộc về {side}.'**
  String logNodeControl(String node, String side);

  /// Log line.
  ///
  /// In vi, this message translates to:
  /// **'{army} tan vỡ.'**
  String logArmyRouted(String army);

  /// Log line.
  ///
  /// In vi, this message translates to:
  /// **'{army} thiếu ăn: sĩ khí -{morale}, quân -{troops}k.'**
  String logStarvation(String army, int morale, int troops);

  /// Log line.
  ///
  /// In vi, this message translates to:
  /// **'{army} hao quân -{troops}k.'**
  String logAttrition(String army, int troops);

  /// Log line.
  ///
  /// In vi, this message translates to:
  /// **'Thu {gained} lương, chi {upkeep} lương.'**
  String logIncome(int gained, int upkeep);

  /// Log line.
  ///
  /// In vi, this message translates to:
  /// **'Thiếu lương: sĩ khí các tướng giảm.'**
  String get logIncomeShortfall;

  /// Log line.
  ///
  /// In vi, this message translates to:
  /// **'{officer} đã đào ngũ.'**
  String logDefected(String officer);

  /// Log line.
  ///
  /// In vi, this message translates to:
  /// **'{officer} khước từ lời dụ hàng.'**
  String logInducementResisted(String officer);

  /// Log line.
  ///
  /// In vi, this message translates to:
  /// **'Cần đưa ra quyết định.'**
  String get logChoiceRequested;

  /// Log line.
  ///
  /// In vi, this message translates to:
  /// **'{pillar}: {from} sang {to}.'**
  String logUnityChanged(String pillar, int from, int to);

  /// Log line.
  ///
  /// In vi, this message translates to:
  /// **'{resource}: {from} sang {to}.'**
  String logResourceChanged(String resource, int from, int to);

  /// Log line.
  ///
  /// In vi, this message translates to:
  /// **'Chiến thắng!'**
  String get logMissionWon;

  /// Log line.
  ///
  /// In vi, this message translates to:
  /// **'Thất bại.'**
  String get logMissionLost;

  /// Closes the inspector.
  ///
  /// In vi, this message translates to:
  /// **'Đóng bảng thông tin'**
  String get inspectorClose;

  /// Terrain.
  ///
  /// In vi, this message translates to:
  /// **'Thành'**
  String get terrainCity;

  /// Terrain.
  ///
  /// In vi, this message translates to:
  /// **'Đồng bằng'**
  String get terrainPlain;

  /// Terrain.
  ///
  /// In vi, this message translates to:
  /// **'Sông'**
  String get terrainRiver;

  /// Terrain.
  ///
  /// In vi, this message translates to:
  /// **'Đầm lầy'**
  String get terrainMarsh;

  /// Terrain.
  ///
  /// In vi, this message translates to:
  /// **'Đồi núi'**
  String get terrainHill;

  /// Side. A proper name.
  ///
  /// In vi, this message translates to:
  /// **'Đại Việt'**
  String get sideDaiViet;

  /// Side.
  ///
  /// In vi, this message translates to:
  /// **'quân Nguyên'**
  String get sideYuan;

  /// Side.
  ///
  /// In vi, this message translates to:
  /// **'không ai'**
  String get sideNone;

  /// Node flag.
  ///
  /// In vi, this message translates to:
  /// **'Kinh đô'**
  String get nodeCapital;

  /// Node flag.
  ///
  /// In vi, this message translates to:
  /// **'Biên giới'**
  String get nodeBorder;

  /// Node flag.
  ///
  /// In vi, this message translates to:
  /// **'Đã sơ tán'**
  String get nodeEvacuated;

  /// Who controls a node.
  ///
  /// In vi, this message translates to:
  /// **'Do {side} kiểm soát'**
  String nodeControlledBy(String side);

  /// Node rice stock.
  ///
  /// In vi, this message translates to:
  /// **'Kho lương: {n}'**
  String nodeRiceStock(int n);

  /// Heading of the units standing at a node.
  ///
  /// In vi, this message translates to:
  /// **'Đang ở đây'**
  String get nodeUnits;

  /// No units at a node.
  ///
  /// In vi, this message translates to:
  /// **'Không có ai.'**
  String get nodeNoUnits;

  /// Officer stat.
  ///
  /// In vi, this message translates to:
  /// **'Thống'**
  String get statLeadership;

  /// Officer stat.
  ///
  /// In vi, this message translates to:
  /// **'Võ'**
  String get statWar;

  /// Officer stat.
  ///
  /// In vi, this message translates to:
  /// **'Trí'**
  String get statIntelligence;

  /// Officer stat.
  ///
  /// In vi, this message translates to:
  /// **'Chính'**
  String get statPolitics;

  /// Officer stat.
  ///
  /// In vi, this message translates to:
  /// **'Trung'**
  String get statLoyalty;

  /// Heading.
  ///
  /// In vi, this message translates to:
  /// **'Lệnh'**
  String get inspectorOrder;

  /// Heading.
  ///
  /// In vi, this message translates to:
  /// **'Kỹ năng'**
  String get inspectorSkill;

  /// Heading.
  ///
  /// In vi, this message translates to:
  /// **'Điểm yếu'**
  String get inspectorFlaw;

  /// Skill kind.
  ///
  /// In vi, this message translates to:
  /// **'Nội tại'**
  String get skillPassive;

  /// Uses of an activated skill.
  ///
  /// In vi, this message translates to:
  /// **'Còn {n} lần'**
  String skillUsesLeft(int n);

  /// Badge on the king.
  ///
  /// In vi, this message translates to:
  /// **'Quân vương'**
  String get officerIsKing;

  /// Heading of an army.
  ///
  /// In vi, this message translates to:
  /// **'Chủ tướng'**
  String get inspectorCommander;

  /// Army supply.
  ///
  /// In vi, this message translates to:
  /// **'Tiếp tế {supply}/{max}'**
  String inspectorSupply(int supply, int max);

  /// Heading.
  ///
  /// In vi, this message translates to:
  /// **'Ý đồ'**
  String get inspectorIntent;

  /// Yuan intent.
  ///
  /// In vi, this message translates to:
  /// **'Giữ nguyên'**
  String get intentHold;

  /// Yuan intent.
  ///
  /// In vi, this message translates to:
  /// **'Tiến quân'**
  String get intentAdvance;

  /// Yuan intent.
  ///
  /// In vi, this message translates to:
  /// **'Tấn công'**
  String get intentAssault;

  /// Yuan intent.
  ///
  /// In vi, this message translates to:
  /// **'Cướp lương'**
  String get intentForage;

  /// Yuan intent.
  ///
  /// In vi, this message translates to:
  /// **'Rút lui'**
  String get intentRetreat;

  /// Yuan intent not known yet.
  ///
  /// In vi, this message translates to:
  /// **'Chưa rõ'**
  String get intentUnknown;

  /// An intent with its destination.
  ///
  /// In vi, this message translates to:
  /// **'{intent} đến {node}'**
  String intentToward(String intent, String node);

  /// A predicted intent.
  ///
  /// In vi, this message translates to:
  /// **'Lượt sau: {intent}'**
  String intentPredicted(String intent);

  /// Army status.
  ///
  /// In vi, this message translates to:
  /// **'Tan vỡ'**
  String get armyRouted;

  /// Names an army by its commander.
  ///
  /// In vi, this message translates to:
  /// **'Quân của {commander}'**
  String armyOf(String commander);

  /// Button: play this card.
  ///
  /// In vi, this message translates to:
  /// **'Dùng bài'**
  String get cardPlay;

  /// Button: play this card on a target.
  ///
  /// In vi, this message translates to:
  /// **'Dùng tại {target}'**
  String cardPlayOn(String target);

  /// Heading of the target list.
  ///
  /// In vi, this message translates to:
  /// **'Chọn mục tiêu:'**
  String get cardPickTarget;

  /// Card cannot be played anywhere now.
  ///
  /// In vi, this message translates to:
  /// **'Không có mục tiêu hợp lệ.'**
  String get cardNoTargets;

  /// Shown when a card is opened outside Council.
  ///
  /// In vi, this message translates to:
  /// **'Chỉ dùng được bài trong giai đoạn Triều nghị.'**
  String get cardOnlyCouncil;

  /// Warning on the card dialog.
  ///
  /// In vi, this message translates to:
  /// **'Bài đã dùng thì không rút lại được.'**
  String get cardFinal;

  /// Closes a dialog.
  ///
  /// In vi, this message translates to:
  /// **'Đóng'**
  String get cardClose;

  /// Button: use the officer skill.
  ///
  /// In vi, this message translates to:
  /// **'Dùng kỹ năng'**
  String get skillUse;

  /// Button: use the officer skill on a target.
  ///
  /// In vi, this message translates to:
  /// **'Dùng kỹ năng tại {target}'**
  String skillUseOn(String target);

  /// Heading of the order list.
  ///
  /// In vi, this message translates to:
  /// **'Giao lệnh'**
  String get ordersTitle;

  /// Button: remove the officer order.
  ///
  /// In vi, this message translates to:
  /// **'Bỏ lệnh'**
  String get orderClear;

  /// Shown when orders cannot be given now.
  ///
  /// In vi, this message translates to:
  /// **'Giao lệnh ở giai đoạn Hạ lệnh.'**
  String get ordersOnlyInOrders;

  /// No legal order for this officer.
  ///
  /// In vi, this message translates to:
  /// **'Không có lệnh nào hợp lệ.'**
  String get ordersNone;

  /// Officer withdrawn or inactive.
  ///
  /// In vi, this message translates to:
  /// **'Không nhận lệnh lượt này.'**
  String get orderNoOrders;

  /// An order that costs Support.
  ///
  /// In vi, this message translates to:
  /// **'{order} ({support} {n})'**
  String orderCostSupport(String order, String support, int n);

  /// Title of the battle preview.
  ///
  /// In vi, this message translates to:
  /// **'Dự báo giao tranh'**
  String get previewTitle;

  /// Preview heading.
  ///
  /// In vi, this message translates to:
  /// **'Giao tranh tại {node}'**
  String previewField(String node);

  /// Preview heading.
  ///
  /// In vi, this message translates to:
  /// **'Phục kích tại {edge}'**
  String previewAmbush(String edge);

  /// Preview line.
  ///
  /// In vi, this message translates to:
  /// **'Tướng ta: {names}'**
  String previewOfficers(String names);

  /// Preview line.
  ///
  /// In vi, this message translates to:
  /// **'Quân địch: {names}'**
  String previewArmies(String names);

  /// Preview line.
  ///
  /// In vi, this message translates to:
  /// **'Sức mạnh: Đại Việt {dv}, quân Nguyên {yuan}'**
  String previewPowers(String dv, String yuan);

  /// Preview line.
  ///
  /// In vi, this message translates to:
  /// **'Dự kiến: {side} thắng'**
  String previewWinner(String side);

  /// Preview line for an ambush whose winner changes with the roll.
  ///
  /// In vi, this message translates to:
  /// **'Kết quả còn tùy vận may: {low} thắng nếu xui, {high} thắng nếu may.'**
  String previewUncertain(String low, String high);

  /// Preview line; losses in thousands, possibly a range.
  ///
  /// In vi, this message translates to:
  /// **'Thiệt hại dự kiến: Đại Việt {dv}k, quân Nguyên {yuan}k'**
  String previewLosses(String dv, String yuan);

  /// Button in the battle preview.
  ///
  /// In vi, this message translates to:
  /// **'Vẫn giao lệnh này'**
  String get previewConfirm;

  /// Title of the choice dialog.
  ///
  /// In vi, this message translates to:
  /// **'Cần đưa ra quyết định'**
  String get choiceTitle;

  /// The mission is won.
  ///
  /// In vi, this message translates to:
  /// **'Chiến thắng'**
  String get outcomeWon;

  /// The mission is lost.
  ///
  /// In vi, this message translates to:
  /// **'Thất bại'**
  String get outcomeLost;

  /// Stars at the end of a won mission.
  ///
  /// In vi, this message translates to:
  /// **'Sao đạt được: {n}/{total}'**
  String outcomeStars(int n, int total);

  /// Loss reason.
  ///
  /// In vi, this message translates to:
  /// **'Quân vương đã bị bắt.'**
  String get lossKingCaptured;

  /// Loss reason.
  ///
  /// In vi, this message translates to:
  /// **'Hết mùa chiến dịch.'**
  String get lossSeasonEnded;

  /// Loss reason.
  ///
  /// In vi, this message translates to:
  /// **'{pillar} đã cạn kiệt.'**
  String lossUnity(String pillar);

  /// Loss reason.
  ///
  /// In vi, this message translates to:
  /// **'Không đạt được mục tiêu nhiệm vụ.'**
  String get lossObjective;

  /// Leaves the finished battle.
  ///
  /// In vi, this message translates to:
  /// **'Về màn hình trước'**
  String get outcomeBack;

  /// Result screen: heading of the star objectives.
  ///
  /// In vi, this message translates to:
  /// **'Mục tiêu'**
  String get resultObjectives;

  /// An objective was met.
  ///
  /// In vi, this message translates to:
  /// **'Đã đạt'**
  String get resultMet;

  /// An objective was not met.
  ///
  /// In vi, this message translates to:
  /// **'Chưa đạt'**
  String get resultNotMet;

  /// Result screen: heading of the mission debrief.
  ///
  /// In vi, this message translates to:
  /// **'Tổng kết'**
  String get resultDebrief;

  /// Result screen: start the mission again.
  ///
  /// In vi, this message translates to:
  /// **'Chơi lại'**
  String get resultRetry;

  /// Objective.
  ///
  /// In vi, this message translates to:
  /// **'Thắng nhiệm vụ'**
  String get objWon;

  /// Objective.
  ///
  /// In vi, this message translates to:
  /// **'Đánh tan mọi đạo quân địch'**
  String get objAllArmiesBroken;

  /// Objective.
  ///
  /// In vi, this message translates to:
  /// **'Đánh tan {army}'**
  String objArmyBroken(String army);

  /// Objective.
  ///
  /// In vi, this message translates to:
  /// **'Phản công thắng lợi tại {node}'**
  String objCounterattackAt(String node);

  /// Objective.
  ///
  /// In vi, this message translates to:
  /// **'Trụ vững {n} lượt'**
  String objSurviveTurns(int n);

  /// Objective.
  ///
  /// In vi, this message translates to:
  /// **'Đưa quân vương đến {node} trước hết lượt {turn}'**
  String objKingAt(String node, int turn);

  /// Objective.
  ///
  /// In vi, this message translates to:
  /// **'Tiếp tế của {army} còn tối đa {percent}%'**
  String objArmySupplyAtMost(String army, int percent);

  /// Objective.
  ///
  /// In vi, this message translates to:
  /// **'Quân vương không bị bắt'**
  String get objKingNotCaptured;

  /// Objective.
  ///
  /// In vi, this message translates to:
  /// **'Giữ được kinh đô'**
  String get objCapitalHeld;

  /// Objective.
  ///
  /// In vi, this message translates to:
  /// **'Cả ba trụ cột đều trên {n}'**
  String objUnityAllAbove(int n);

  /// Objective.
  ///
  /// In vi, this message translates to:
  /// **'{pillar} đạt ít nhất {n} khi kết thúc'**
  String objUnityAtLeast(String pillar, int n);

  /// Objective.
  ///
  /// In vi, this message translates to:
  /// **'Không tướng nào đào ngũ'**
  String get objNoDefections;

  /// Objective.
  ///
  /// In vi, this message translates to:
  /// **'Không tướng nào bị bắt'**
  String get objNoCaptures;

  /// Objective.
  ///
  /// In vi, this message translates to:
  /// **'Mất tối đa {n} nghìn quân'**
  String objTroopsLostAtMost(int n);

  /// Objective.
  ///
  /// In vi, this message translates to:
  /// **'Thắng trước hết lượt {turn}'**
  String objWinByTurn(int turn);

  /// Two objectives, either of which is enough.
  ///
  /// In vi, this message translates to:
  /// **'{a} hoặc {b}'**
  String objAnyOf(String a, String b);

  /// Dialog title when the save cannot be replayed.
  ///
  /// In vi, this message translates to:
  /// **'Không thể tiếp tục ván đã lưu'**
  String get resumeUnusableTitle;

  /// Dialog body when the save cannot be replayed.
  ///
  /// In vi, this message translates to:
  /// **'Nội dung trò chơi đã thay đổi hoặc bản lưu bị hỏng. Bắt đầu lại nhiệm vụ này?'**
  String get resumeUnusableBody;

  /// Button: discard the save and start the mission again.
  ///
  /// In vi, this message translates to:
  /// **'Bắt đầu lại'**
  String get resumeRestart;

  /// Shown when a mission cannot be loaded.
  ///
  /// In vi, this message translates to:
  /// **'Không tải được nhiệm vụ.'**
  String get battleLoadError;

  /// Title of the battle menu (Esc).
  ///
  /// In vi, this message translates to:
  /// **'Tạm dừng'**
  String get battleMenuTitle;

  /// Closes the battle menu.
  ///
  /// In vi, this message translates to:
  /// **'Chơi tiếp'**
  String get battleMenuResume;

  /// Leaves the battle; progress is saved.
  ///
  /// In vi, this message translates to:
  /// **'Rời trận (đã tự lưu)'**
  String get battleMenuLeave;

  /// A tooltip with its keyboard shortcut.
  ///
  /// In vi, this message translates to:
  /// **'{label} ({keys})'**
  String shortcutHint(String label, String keys);

  /// Briefing: heading of the win conditions.
  ///
  /// In vi, this message translates to:
  /// **'Mục tiêu'**
  String get briefingObjectives;

  /// Briefing: heading of the starting officers.
  ///
  /// In vi, this message translates to:
  /// **'Tướng lĩnh xuất trận'**
  String get briefingOfficers;

  /// Briefing: a starting officer with troops and place.
  ///
  /// In vi, this message translates to:
  /// **'{troops} tại {node}'**
  String briefingOfficerLine(String troops, String node);

  /// Briefing: begin the battle.
  ///
  /// In vi, this message translates to:
  /// **'Xuất quân'**
  String get briefingStart;

  /// Screen-reader label of the narration text.
  ///
  /// In vi, this message translates to:
  /// **'Phụ đề lời dẫn'**
  String get briefingSubtitles;

  /// Button: play the spoken narration.
  ///
  /// In vi, this message translates to:
  /// **'Nghe lời dẫn'**
  String get briefingPlayVoice;

  /// Button: stop the spoken narration.
  ///
  /// In vi, this message translates to:
  /// **'Dừng lời dẫn'**
  String get briefingStopVoice;

  /// Shown when a briefing cannot be loaded.
  ///
  /// In vi, this message translates to:
  /// **'Không tải được phần dẫn nhiệm vụ.'**
  String get briefingLoadError;

  /// Coach mark: the next tip.
  ///
  /// In vi, this message translates to:
  /// **'Tiếp'**
  String get tutorialNext;

  /// Coach mark: the last tip.
  ///
  /// In vi, this message translates to:
  /// **'Đã hiểu'**
  String get tutorialGotIt;

  /// Coach mark: stop all tips.
  ///
  /// In vi, this message translates to:
  /// **'Bỏ qua hướng dẫn'**
  String get tutorialSkip;

  /// Which tip this is.
  ///
  /// In vi, this message translates to:
  /// **'{n}/{total}'**
  String tutorialCount(int n, int total);

  /// Screen-reader label of a coach mark.
  ///
  /// In vi, this message translates to:
  /// **'Hướng dẫn: {text}'**
  String tutorialSemantics(String text);

  /// Chapter heading.
  ///
  /// In vi, this message translates to:
  /// **'Chương {n}'**
  String campaignChapter(int n);

  /// Progress on a chapter.
  ///
  /// In vi, this message translates to:
  /// **'{won}/{total} nhiệm vụ · {stars}/{starsTotal} sao'**
  String campaignChapterSummary(int won, int total, int stars, int starsTotal);

  /// Mission number in its chapter.
  ///
  /// In vi, this message translates to:
  /// **'Nhiệm vụ {n}'**
  String campaignMissionNumber(int n);

  /// A mission or chapter that is not open yet.
  ///
  /// In vi, this message translates to:
  /// **'Chưa mở khoá'**
  String get campaignLocked;

  /// Why a mission is locked.
  ///
  /// In vi, this message translates to:
  /// **'Thắng nhiệm vụ trước để mở khoá.'**
  String get campaignLockedHint;

  /// Screen-reader label of the stars of a mission.
  ///
  /// In vi, this message translates to:
  /// **'{n} trên {total} sao'**
  String campaignStarsSemantics(int n, int total);

  /// Dialog title when starting a mission while a battle is saved.
  ///
  /// In vi, this message translates to:
  /// **'Thay ván đang chơi?'**
  String get campaignReplaceTitle;

  /// Dialog body when starting a mission while a battle is saved.
  ///
  /// In vi, this message translates to:
  /// **'Ván đã lưu sẽ mất nếu bạn bắt đầu nhiệm vụ này.'**
  String get campaignReplaceBody;

  /// Button: start the mission and drop the saved battle.
  ///
  /// In vi, this message translates to:
  /// **'Vẫn bắt đầu'**
  String get campaignStartAnyway;

  /// Result screen: the next mission has just opened.
  ///
  /// In vi, this message translates to:
  /// **'Mở khoá: {title}'**
  String resultUnlocked(String title);

  /// Result screen: go to the next mission.
  ///
  /// In vi, this message translates to:
  /// **'Nhiệm vụ tiếp theo'**
  String get resultNext;

  /// Codex section: our officers.
  ///
  /// In vi, this message translates to:
  /// **'Nhân vật Đại Việt'**
  String get codexOfficers;

  /// Codex section: enemy commanders.
  ///
  /// In vi, this message translates to:
  /// **'Tướng Mông–Nguyên'**
  String get codexEnemies;

  /// Codex section: cards.
  ///
  /// In vi, this message translates to:
  /// **'Mưu kế và sự kiện'**
  String get codexCards;

  /// Mark on a Codex entry whose Long Ký code was entered.
  ///
  /// In vi, this message translates to:
  /// **'Đã mở khoá'**
  String get codexUnlocked;

  /// Heading of the list of sources of a Codex entry.
  ///
  /// In vi, this message translates to:
  /// **'Nguồn'**
  String get codexSources;

  /// Codex: heading of the unlock code box.
  ///
  /// In vi, this message translates to:
  /// **'Nhập mã mở khoá'**
  String get codexCodeTitle;

  /// Codex: help under the unlock code box.
  ///
  /// In vi, this message translates to:
  /// **'Mã hiện ra sau khi hoàn thành một bài học trong Long Ký.'**
  String get codexCodeHelp;

  /// Label of the unlock code text field.
  ///
  /// In vi, this message translates to:
  /// **'Mã mở khoá'**
  String get codexCodeField;

  /// Button: check the unlock code.
  ///
  /// In vi, this message translates to:
  /// **'Mở khoá'**
  String get codexCodeRedeem;

  /// A valid code was entered.
  ///
  /// In vi, this message translates to:
  /// **'Đã mở khoá: {name}.'**
  String codexCodeOk(String name);

  /// A valid code was entered again.
  ///
  /// In vi, this message translates to:
  /// **'{name} đã được mở khoá từ trước.'**
  String codexCodeAlready(String name);

  /// A wrong code was entered.
  ///
  /// In vi, this message translates to:
  /// **'Mã không đúng. Kiểm tra lại và thử lần nữa.'**
  String get codexCodeInvalid;

  /// No unlock secret is configured.
  ///
  /// In vi, this message translates to:
  /// **'Bản này chưa kiểm tra được mã.'**
  String get codexCodeUnavailable;

  /// Button: open Long Ký at this person or event.
  ///
  /// In vi, this message translates to:
  /// **'Đọc thêm trong Long Ký'**
  String get longKyReadMore;

  /// Desktop: text under the QR code.
  ///
  /// In vi, this message translates to:
  /// **'Quét bằng điện thoại để mở Long Ký'**
  String get longKyScan;

  /// Screen-reader label of the QR code.
  ///
  /// In vi, this message translates to:
  /// **'Mã QR mở Long Ký'**
  String get longKyQrSemantics;

  /// Neither the link nor the store page could be opened.
  ///
  /// In vi, this message translates to:
  /// **'Không mở được Long Ký.'**
  String get longKyOpenFailed;

  /// Button: close a dialog.
  ///
  /// In vi, this message translates to:
  /// **'Đóng'**
  String get actionClose;

  /// Briefing: heading of the extra ways to lose a mission.
  ///
  /// In vi, this message translates to:
  /// **'Thua nếu'**
  String get briefingLoss;

  /// A mission that is lost when the troops lost pass a limit: used in the briefing and on the Result screen.
  ///
  /// In vi, this message translates to:
  /// **'Quân ta hao tổn quá {n} nghìn người'**
  String lossTroopsOver(int n);

  /// Tooltip of the board's zoom-in button.
  ///
  /// In vi, this message translates to:
  /// **'Phóng to bản đồ'**
  String get boardZoomIn;

  /// Tooltip of the board's zoom-out button.
  ///
  /// In vi, this message translates to:
  /// **'Thu nhỏ bản đồ'**
  String get boardZoomOut;

  /// Tooltip of the button that shows the whole map again.
  ///
  /// In vi, this message translates to:
  /// **'Xem toàn bản đồ'**
  String get boardZoomReset;

  /// Under a guided tutorial step that waits for the player to act.
  ///
  /// In vi, this message translates to:
  /// **'Làm theo hướng dẫn để tiếp tục.'**
  String get tutorialDoIt;

  /// Skips one guided tutorial step.
  ///
  /// In vi, this message translates to:
  /// **'Bỏ qua bước'**
  String get tutorialSkipStep;

  /// Name of chapter 0, the training mission (instead of 'Chương 0').
  ///
  /// In vi, this message translates to:
  /// **'Huấn luyện'**
  String get campaignTraining;

  /// Under the training chapter in the campaign.
  ///
  /// In vi, this message translates to:
  /// **'Bài huấn luyện dạy cách chơi từng bước.'**
  String get campaignTrainingHint;

  /// Dialog title: what to do in this mission.
  ///
  /// In vi, this message translates to:
  /// **'Mục tiêu nhiệm vụ'**
  String get objectivesTitle;

  /// Button and menu entry that opens the objectives.
  ///
  /// In vi, this message translates to:
  /// **'Xem mục tiêu'**
  String get objectivesShow;

  /// Heading of the win conditions.
  ///
  /// In vi, this message translates to:
  /// **'Thắng khi'**
  String get objectivesWin;

  /// Standard loss rule.
  ///
  /// In vi, this message translates to:
  /// **'Một cột Đoàn kết (Triều đình, Tông thất, Dân chúng) về 0.'**
  String get objectivesLossUnity;

  /// Standard loss rule.
  ///
  /// In vi, this message translates to:
  /// **'Hết {n} lượt mà chưa thắng.'**
  String objectivesLossSeason(int n);

  /// Heading of the star objectives.
  ///
  /// In vi, this message translates to:
  /// **'Sao thưởng'**
  String get objectivesStars;

  /// Button on the Result screen: go back to the board.
  ///
  /// In vi, this message translates to:
  /// **'Xem lại chiến trường'**
  String get reviewBoard;

  /// Button on the review banner.
  ///
  /// In vi, this message translates to:
  /// **'Xem kết quả'**
  String get reviewResult;

  /// Hint while looking at the board after the battle.
  ///
  /// In vi, this message translates to:
  /// **'Chạm vào tướng hoặc địa điểm để xem. Phóng to, kéo để di chuyển.'**
  String get reviewHint;
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
