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
}
