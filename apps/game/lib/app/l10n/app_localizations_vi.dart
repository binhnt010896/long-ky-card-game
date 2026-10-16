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
    return '$order → $target';
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
    return '$pillar: $from → $to.';
  }

  @override
  String logResourceChanged(String resource, int from, int to) {
    return '$resource: $from → $to.';
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
    return '$intent → $node';
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
}
