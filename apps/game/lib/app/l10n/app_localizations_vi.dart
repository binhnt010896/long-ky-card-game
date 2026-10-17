// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appTitle => 'Long Ký - The Game';

  @override
  String get menuContinue => 'Tiếp tục';

  @override
  String get menuCampaign => 'Chiến dịch';

  @override
  String get menuCodex => 'Sử liệu';

  @override
  String get menuSettings => 'Cài đặt';

  @override
  String get comingSoon => 'Sắp ra mắt.';

  @override
  String get settingsTitle => 'Cài đặt';

  @override
  String get settingsLanguage => 'Ngôn ngữ';

  @override
  String get languageVietnamese => 'Tiếng Việt';

  @override
  String get languageEnglish => 'English';

  @override
  String get settingsAudio => 'Âm thanh';

  @override
  String get volumeMusic => 'Nhạc nền';

  @override
  String get volumeVoice => 'Lời dẫn';

  @override
  String get volumeEffects => 'Hiệu ứng';

  @override
  String percentValue(int percent) {
    return '$percent%';
  }

  @override
  String get settingsTextSize => 'Cỡ chữ';

  @override
  String get settingsReduceMotion => 'Giảm chuyển động';

  @override
  String get settingsReduceMotionHint => 'Bỏ qua hoạt cảnh trên bản đồ.';

  @override
  String get settingsResetProgress => 'Xoá tiến trình';

  @override
  String get resetConfirmTitle => 'Xoá toàn bộ tiến trình?';

  @override
  String get resetConfirmBody =>
      'Sao và các mục đã mở khoá sẽ bị xoá. Cài đặt được giữ nguyên.';

  @override
  String get actionCancel => 'Huỷ';

  @override
  String get actionReset => 'Xoá';

  @override
  String get resetDone => 'Đã xoá tiến trình.';

  @override
  String get settingsCredits => 'Ghi công và nguồn tư liệu';

  @override
  String get creditsFont =>
      'Phông chữ Be Vietnam Pro, theo giấy phép SIL Open Font License 1.1.';

  @override
  String get creditsLicenses => 'Giấy phép phần mềm';

  @override
  String get creditsSources => 'Nguồn tư liệu';

  @override
  String get creditsLoadError => 'Không đọc được dữ liệu nguồn.';

  @override
  String battleTurnClock(int turn, int total) {
    return 'Lượt $turn/$total';
  }

  @override
  String battleSeasonClockSemantics(int turn, int total) {
    return 'Đồng hồ mùa: lượt $turn trên $total';
  }

  @override
  String get phaseIntel => 'Trinh sát';

  @override
  String get phaseCouncil => 'Triều nghị';

  @override
  String get phaseOrders => 'Hạ lệnh';

  @override
  String get phaseResolution => 'Giao tranh';

  @override
  String get phaseUpkeep => 'Hậu cần';

  @override
  String get phaseEnded => 'Kết thúc';

  @override
  String get resourceRice => 'Lương';

  @override
  String get resourceSupport => 'Lòng dân';

  @override
  String get unityCourt => 'Triều đình';

  @override
  String get unityClan => 'Tông thất';

  @override
  String get unityPeople => 'Dân chúng';

  @override
  String unitySemantics(String pillar, int value) {
    return '$pillar: $value trên 10';
  }

  @override
  String unitySemanticsLow(String pillar, int value) {
    return '$pillar: $value trên 10, thấp';
  }

  @override
  String resourceSemantics(String resource, int value) {
    return '$resource: $value';
  }

  @override
  String get officerStripLabel => 'Tướng lĩnh';

  @override
  String troopsShort(int n) {
    return '${n}k';
  }

  @override
  String troopsFull(int n) {
    return '$n.000 quân';
  }

  @override
  String moraleShort(int n) {
    return 'Sĩ khí $n';
  }

  @override
  String get statusDefected => 'Đã đào ngũ';

  @override
  String get statusCaptured => 'Bị bắt';

  @override
  String get orderNone => 'Chưa có lệnh';

  @override
  String get orderHold => 'Cố thủ';

  @override
  String get orderMove => 'Hành quân';

  @override
  String get orderEvacuate => 'Sơ tán';

  @override
  String get orderRaid => 'Tập kích';

  @override
  String get orderAmbush => 'Phục kích';

  @override
  String get orderRally => 'Chiêu mộ';

  @override
  String orderWithTarget(String order, String target) {
    return '$order: $target';
  }

  @override
  String officerSemantics(String name, String troops, String state) {
    return '$name, $troops, $state';
  }

  @override
  String handTitle(int count) {
    return 'Bài trên tay ($count)';
  }

  @override
  String get handEmpty => 'Không còn lá bài nào.';

  @override
  String get handShow => 'Mở bài trên tay';

  @override
  String get handHide => 'Thu bài lại';

  @override
  String handPiles(int deck, int discard) {
    return 'Rút: $deck · Bỏ: $discard';
  }

  @override
  String handCourtSurcharge(int extra) {
    return 'Triều đình thấp: mỗi lá bài tốn thêm $extra lòng dân.';
  }

  @override
  String get cardTypeStratagem => 'Mưu kế';

  @override
  String get cardTypeEvent => 'Sự kiện';

  @override
  String get cardTypeIntent => 'Ý đồ địch';

  @override
  String get cardFree => 'Miễn phí';

  @override
  String get cardCannotAfford => 'Không đủ để dùng';

  @override
  String cardCostSemantics(int rice, int support) {
    return 'Giá: $rice lương, $support lòng dân';
  }

  @override
  String cardSemantics(String name, String type, String cost) {
    return '$name, $type, $cost';
  }

  @override
  String get phaseButtonCouncil => 'Sang hạ lệnh';

  @override
  String get phaseButtonOrders => 'Chốt lệnh';

  @override
  String get phaseButtonChoice => 'Hãy chọn trước';

  @override
  String get phaseButtonEnded => 'Đã kết thúc';

  @override
  String get phaseButtonWait => 'Đang diễn ra';

  @override
  String get logTitle => 'Nhật ký';

  @override
  String get logShow => 'Mở nhật ký';

  @override
  String get logHide => 'Đóng nhật ký';

  @override
  String get logCollapse => 'Thu nhật ký';

  @override
  String get logExpand => 'Mở rộng nhật ký';

  @override
  String get logEmpty => 'Chưa có gì xảy ra.';

  @override
  String logTurnStarted(int turn) {
    return 'Lượt $turn bắt đầu.';
  }

  @override
  String logPhaseChanged(String phase) {
    return 'Giai đoạn: $phase.';
  }

  @override
  String logCardPlayed(String card) {
    return 'Dùng bài $card.';
  }

  @override
  String logCardPlayedOn(String card, String target) {
    return 'Dùng bài $card tại $target.';
  }

  @override
  String logSkillUsed(String officer, String skill) {
    return '$officer dùng kỹ năng $skill.';
  }

  @override
  String logOrderSet(String officer, String order) {
    return '$officer: $order.';
  }

  @override
  String logOrderCleared(String officer) {
    return '$officer: bỏ lệnh.';
  }

  @override
  String get logOrdersSkipped => 'Lượt này bỏ qua giai đoạn hạ lệnh.';

  @override
  String logUnitMoved(String unit, String from, String to) {
    return '$unit đi từ $from đến $to.';
  }

  @override
  String logNodeEvacuated(String node, int rice) {
    return 'Sơ tán $node: thu $rice lương.';
  }

  @override
  String logRallied(String officer, String node, int troops) {
    return '$officer chiêu mộ thêm $troops nghìn quân tại $node.';
  }

  @override
  String logAmbushPlaced(String officer, String edge) {
    return '$officer mai phục tại $edge.';
  }

  @override
  String logBattleWon(String node) {
    return 'Trận $node: Đại Việt thắng.';
  }

  @override
  String logBattleLost(String node) {
    return 'Trận $node: quân Nguyên thắng.';
  }

  @override
  String logBattleDraw(String node) {
    return 'Trận $node: không phân thắng bại.';
  }

  @override
  String logOfficerCaptured(String officer, String node) {
    return '$officer bị bắt tại $node.';
  }

  @override
  String logKingShielded(String king, String shield) {
    return '$shield che chắn cho $king.';
  }

  @override
  String logRaided(String officer, String army, int supply, int troops) {
    return '$officer tập kích $army: tiếp tế -$supply, quân -${troops}k.';
  }

  @override
  String logForaged(String army, String node, int supply) {
    return '$army cướp lương tại $node: tiếp tế +$supply.';
  }

  @override
  String logNodeControl(String node, String side) {
    return '$node nay thuộc về $side.';
  }

  @override
  String logArmyRouted(String army) {
    return '$army tan vỡ.';
  }

  @override
  String logStarvation(String army, int morale, int troops) {
    return '$army thiếu ăn: sĩ khí -$morale, quân -${troops}k.';
  }

  @override
  String logAttrition(String army, int troops) {
    return '$army hao quân -${troops}k.';
  }

  @override
  String logIncome(int gained, int upkeep) {
    return 'Thu $gained lương, chi $upkeep lương.';
  }

  @override
  String get logIncomeShortfall => 'Thiếu lương: sĩ khí các tướng giảm.';

  @override
  String logDefected(String officer) {
    return '$officer đã đào ngũ.';
  }

  @override
  String logInducementResisted(String officer) {
    return '$officer khước từ lời dụ hàng.';
  }

  @override
  String get logChoiceRequested => 'Cần đưa ra quyết định.';

  @override
  String logUnityChanged(String pillar, int from, int to) {
    return '$pillar: $from sang $to.';
  }

  @override
  String logResourceChanged(String resource, int from, int to) {
    return '$resource: $from sang $to.';
  }

  @override
  String get logMissionWon => 'Chiến thắng!';

  @override
  String get logMissionLost => 'Thất bại.';

  @override
  String get inspectorClose => 'Đóng bảng thông tin';

  @override
  String get terrainCity => 'Thành';

  @override
  String get terrainPlain => 'Đồng bằng';

  @override
  String get terrainRiver => 'Sông';

  @override
  String get terrainMarsh => 'Đầm lầy';

  @override
  String get terrainHill => 'Đồi núi';

  @override
  String get sideDaiViet => 'Đại Việt';

  @override
  String get sideYuan => 'quân Nguyên';

  @override
  String get sideNone => 'không ai';

  @override
  String get nodeCapital => 'Kinh đô';

  @override
  String get nodeBorder => 'Biên giới';

  @override
  String get nodeEvacuated => 'Đã sơ tán';

  @override
  String nodeControlledBy(String side) {
    return 'Do $side kiểm soát';
  }

  @override
  String nodeRiceStock(int n) {
    return 'Kho lương: $n';
  }

  @override
  String get nodeUnits => 'Đang ở đây';

  @override
  String get nodeNoUnits => 'Không có ai.';

  @override
  String get statLeadership => 'Thống';

  @override
  String get statWar => 'Võ';

  @override
  String get statIntelligence => 'Trí';

  @override
  String get statPolitics => 'Chính';

  @override
  String get statLoyalty => 'Trung';

  @override
  String get inspectorOrder => 'Lệnh';

  @override
  String get inspectorSkill => 'Kỹ năng';

  @override
  String get inspectorFlaw => 'Điểm yếu';

  @override
  String get skillPassive => 'Nội tại';

  @override
  String skillUsesLeft(int n) {
    return 'Còn $n lần';
  }

  @override
  String get officerIsKing => 'Quân vương';

  @override
  String get inspectorCommander => 'Chủ tướng';

  @override
  String inspectorSupply(int supply, int max) {
    return 'Tiếp tế $supply/$max';
  }

  @override
  String get inspectorIntent => 'Ý đồ';

  @override
  String get intentHold => 'Giữ nguyên';

  @override
  String get intentAdvance => 'Tiến quân';

  @override
  String get intentAssault => 'Tấn công';

  @override
  String get intentForage => 'Cướp lương';

  @override
  String get intentRetreat => 'Rút lui';

  @override
  String get intentUnknown => 'Chưa rõ';

  @override
  String intentToward(String intent, String node) {
    return '$intent đến $node';
  }

  @override
  String intentPredicted(String intent) {
    return 'Lượt sau: $intent';
  }

  @override
  String get armyRouted => 'Tan vỡ';

  @override
  String armyOf(String commander) {
    return 'Quân của $commander';
  }

  @override
  String get cardPlay => 'Dùng bài';

  @override
  String cardPlayOn(String target) {
    return 'Dùng tại $target';
  }

  @override
  String get cardPickTarget => 'Chọn mục tiêu:';

  @override
  String get cardNoTargets => 'Không có mục tiêu hợp lệ.';

  @override
  String get cardOnlyCouncil => 'Chỉ dùng được bài trong giai đoạn Triều nghị.';

  @override
  String get cardFinal => 'Bài đã dùng thì không rút lại được.';

  @override
  String get cardClose => 'Đóng';

  @override
  String get skillUse => 'Dùng kỹ năng';

  @override
  String skillUseOn(String target) {
    return 'Dùng kỹ năng tại $target';
  }

  @override
  String get ordersTitle => 'Giao lệnh';

  @override
  String get orderClear => 'Bỏ lệnh';

  @override
  String get ordersOnlyInOrders => 'Giao lệnh ở giai đoạn Hạ lệnh.';

  @override
  String get ordersNone => 'Không có lệnh nào hợp lệ.';

  @override
  String get orderNoOrders => 'Không nhận lệnh lượt này.';

  @override
  String orderCostSupport(String order, String support, int n) {
    return '$order ($support $n)';
  }

  @override
  String get previewTitle => 'Dự báo giao tranh';

  @override
  String previewField(String node) {
    return 'Giao tranh tại $node';
  }

  @override
  String previewAmbush(String edge) {
    return 'Phục kích tại $edge';
  }

  @override
  String previewOfficers(String names) {
    return 'Tướng ta: $names';
  }

  @override
  String previewArmies(String names) {
    return 'Quân địch: $names';
  }

  @override
  String previewPowers(String dv, String yuan) {
    return 'Sức mạnh: Đại Việt $dv, quân Nguyên $yuan';
  }

  @override
  String previewWinner(String side) {
    return 'Dự kiến: $side thắng';
  }

  @override
  String previewUncertain(String low, String high) {
    return 'Kết quả còn tùy vận may: $low thắng nếu xui, $high thắng nếu may.';
  }

  @override
  String previewLosses(String dv, String yuan) {
    return 'Thiệt hại dự kiến: Đại Việt ${dv}k, quân Nguyên ${yuan}k';
  }

  @override
  String get previewConfirm => 'Vẫn giao lệnh này';

  @override
  String get choiceTitle => 'Cần đưa ra quyết định';

  @override
  String get outcomeWon => 'Chiến thắng';

  @override
  String get outcomeLost => 'Thất bại';

  @override
  String outcomeStars(int n, int total) {
    return 'Sao đạt được: $n/$total';
  }

  @override
  String get lossKingCaptured => 'Quân vương đã bị bắt.';

  @override
  String get lossSeasonEnded => 'Hết mùa chiến dịch.';

  @override
  String lossUnity(String pillar) {
    return '$pillar đã cạn kiệt.';
  }

  @override
  String get lossObjective => 'Không đạt được mục tiêu nhiệm vụ.';

  @override
  String get outcomeBack => 'Về màn hình trước';

  @override
  String get resultObjectives => 'Mục tiêu';

  @override
  String get resultMet => 'Đã đạt';

  @override
  String get resultNotMet => 'Chưa đạt';

  @override
  String get resultDebrief => 'Tổng kết';

  @override
  String get resultRetry => 'Chơi lại';

  @override
  String get objWon => 'Thắng nhiệm vụ';

  @override
  String get objAllArmiesBroken => 'Đánh tan mọi đạo quân địch';

  @override
  String objArmyBroken(String army) {
    return 'Đánh tan $army';
  }

  @override
  String objCounterattackAt(String node) {
    return 'Phản công thắng lợi tại $node';
  }

  @override
  String objSurviveTurns(int n) {
    return 'Trụ vững $n lượt';
  }

  @override
  String objKingAt(String node, int turn) {
    return 'Đưa quân vương đến $node trước hết lượt $turn';
  }

  @override
  String objArmySupplyAtMost(String army, int percent) {
    return 'Tiếp tế của $army còn tối đa $percent%';
  }

  @override
  String get objKingNotCaptured => 'Quân vương không bị bắt';

  @override
  String get objCapitalHeld => 'Giữ được kinh đô';

  @override
  String objUnityAllAbove(int n) {
    return 'Cả ba trụ cột đều trên $n';
  }

  @override
  String objUnityAtLeast(String pillar, int n) {
    return '$pillar đạt ít nhất $n khi kết thúc';
  }

  @override
  String get objNoDefections => 'Không tướng nào đào ngũ';

  @override
  String get objNoCaptures => 'Không tướng nào bị bắt';

  @override
  String objTroopsLostAtMost(int n) {
    return 'Mất tối đa $n nghìn quân';
  }

  @override
  String objWinByTurn(int turn) {
    return 'Thắng trước hết lượt $turn';
  }

  @override
  String objAnyOf(String a, String b) {
    return '$a hoặc $b';
  }

  @override
  String get resumeUnusableTitle => 'Không thể tiếp tục ván đã lưu';

  @override
  String get resumeUnusableBody =>
      'Nội dung trò chơi đã thay đổi hoặc bản lưu bị hỏng. Bắt đầu lại nhiệm vụ này?';

  @override
  String get resumeRestart => 'Bắt đầu lại';

  @override
  String get battleLoadError => 'Không tải được nhiệm vụ.';

  @override
  String get battleMenuTitle => 'Tạm dừng';

  @override
  String get battleMenuResume => 'Chơi tiếp';

  @override
  String get battleMenuLeave => 'Rời trận (đã tự lưu)';

  @override
  String shortcutHint(String label, String keys) {
    return '$label ($keys)';
  }

  @override
  String get briefingObjectives => 'Mục tiêu';

  @override
  String get briefingOfficers => 'Tướng lĩnh xuất trận';

  @override
  String briefingOfficerLine(String troops, String node) {
    return '$troops tại $node';
  }

  @override
  String get briefingStart => 'Xuất quân';

  @override
  String get briefingSubtitles => 'Phụ đề lời dẫn';

  @override
  String get briefingPlayVoice => 'Nghe lời dẫn';

  @override
  String get briefingStopVoice => 'Dừng lời dẫn';

  @override
  String get briefingLoadError => 'Không tải được phần dẫn nhiệm vụ.';

  @override
  String get tutorialNext => 'Tiếp';

  @override
  String get tutorialGotIt => 'Đã hiểu';

  @override
  String get tutorialSkip => 'Bỏ qua hướng dẫn';

  @override
  String tutorialCount(int n, int total) {
    return '$n/$total';
  }

  @override
  String tutorialSemantics(String text) {
    return 'Hướng dẫn: $text';
  }

  @override
  String campaignChapter(int n) {
    return 'Chương $n';
  }

  @override
  String campaignChapterSummary(int won, int total, int stars, int starsTotal) {
    return '$won/$total nhiệm vụ · $stars/$starsTotal sao';
  }

  @override
  String campaignMissionNumber(int n) {
    return 'Nhiệm vụ $n';
  }

  @override
  String get campaignLocked => 'Chưa mở khoá';

  @override
  String get campaignLockedHint => 'Thắng nhiệm vụ trước để mở khoá.';

  @override
  String campaignStarsSemantics(int n, int total) {
    return '$n trên $total sao';
  }

  @override
  String get campaignReplaceTitle => 'Thay ván đang chơi?';

  @override
  String get campaignReplaceBody =>
      'Ván đã lưu sẽ mất nếu bạn bắt đầu nhiệm vụ này.';

  @override
  String get campaignStartAnyway => 'Vẫn bắt đầu';

  @override
  String resultUnlocked(String title) {
    return 'Mở khoá: $title';
  }

  @override
  String get resultNext => 'Nhiệm vụ tiếp theo';

  @override
  String get codexOfficers => 'Nhân vật Đại Việt';

  @override
  String get codexEnemies => 'Tướng Mông–Nguyên';

  @override
  String get codexCards => 'Mưu kế và sự kiện';

  @override
  String get codexUnlocked => 'Đã mở khoá';

  @override
  String get codexSources => 'Nguồn';

  @override
  String get codexCodeTitle => 'Nhập mã mở khoá';

  @override
  String get codexCodeHelp =>
      'Mã hiện ra sau khi hoàn thành một bài học trong Long Ký.';

  @override
  String get codexCodeField => 'Mã mở khoá';

  @override
  String get codexCodeRedeem => 'Mở khoá';

  @override
  String codexCodeOk(String name) {
    return 'Đã mở khoá: $name.';
  }

  @override
  String codexCodeAlready(String name) {
    return '$name đã được mở khoá từ trước.';
  }

  @override
  String get codexCodeInvalid => 'Mã không đúng. Kiểm tra lại và thử lần nữa.';

  @override
  String get codexCodeUnavailable => 'Bản này chưa kiểm tra được mã.';

  @override
  String get longKyReadMore => 'Đọc thêm trong Long Ký';

  @override
  String get longKyScan => 'Quét bằng điện thoại để mở Long Ký';

  @override
  String get longKyQrSemantics => 'Mã QR mở Long Ký';

  @override
  String get longKyOpenFailed => 'Không mở được Long Ký.';

  @override
  String get actionClose => 'Đóng';

  @override
  String get briefingLoss => 'Thua nếu';

  @override
  String lossTroopsOver(int n) {
    return 'Quân ta hao tổn quá $n nghìn người';
  }

  @override
  String get boardZoomIn => 'Phóng to bản đồ';

  @override
  String get boardZoomOut => 'Thu nhỏ bản đồ';

  @override
  String get boardZoomReset => 'Xem toàn bản đồ';

  @override
  String get tutorialDoIt => 'Làm theo hướng dẫn để tiếp tục.';

  @override
  String get tutorialSkipStep => 'Bỏ qua bước';

  @override
  String get campaignTraining => 'Huấn luyện';

  @override
  String get campaignTrainingHint => 'Bài huấn luyện dạy cách chơi từng bước.';

  @override
  String get objectivesTitle => 'Mục tiêu nhiệm vụ';

  @override
  String get objectivesShow => 'Xem mục tiêu';

  @override
  String get objectivesWin => 'Thắng khi';

  @override
  String get objectivesLossUnity =>
      'Một cột Đoàn kết (Triều đình, Tông thất, Dân chúng) về 0.';

  @override
  String objectivesLossSeason(int n) {
    return 'Hết $n lượt mà chưa thắng.';
  }

  @override
  String get objectivesStars => 'Sao thưởng';

  @override
  String get reviewBoard => 'Xem lại chiến trường';

  @override
  String get reviewResult => 'Xem kết quả';

  @override
  String get reviewHint =>
      'Chạm vào tướng hoặc địa điểm để xem. Phóng to, kéo để di chuyển.';

  @override
  String get freePlayContinue => 'Chơi tiếp';

  @override
  String get freePlayTag => 'Chơi tiếp';

  @override
  String get freePlayHint => 'Chơi tiếp đến khi một bên hết quân.';

  @override
  String get freePlayWon => 'Chơi tiếp kết thúc: quân Nguyên hết quân.';

  @override
  String get freePlayLost => 'Chơi tiếp kết thúc: quân ta hết quân.';

  @override
  String get logFreePlayStarted => 'Chơi tiếp bắt đầu.';
}
