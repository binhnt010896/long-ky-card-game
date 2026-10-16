/// `progress.json` (build-spec section 6): stars, unlocks and settings.
///
/// The file carries a `version`; [Progress.fromJson] migrates older
/// versions step by step, so files from the first release always load.
library;

/// Player settings.
final class GameSettings {
  const GameSettings({
    this.languageCode = defaultLanguage,
    this.musicVolume = 0.6,
    this.voiceVolume = 1.0,
    this.effectsVolume = 0.8,
    this.textScale = 1.0,
    this.reduceMotion = false,
  });

  /// Vietnamese is the primary language and the default.
  static const String defaultLanguage = 'vi';
  static const List<String> languages = ['vi', 'en'];
  static const double minTextScale = 1.0;
  static const double maxTextScale = 1.5;

  final String languageCode;
  final double musicVolume;
  final double voiceVolume;
  final double effectsVolume;

  /// Text size, 100–150%.
  final double textScale;
  final bool reduceMotion;

  GameSettings copyWith({
    String? languageCode,
    double? musicVolume,
    double? voiceVolume,
    double? effectsVolume,
    double? textScale,
    bool? reduceMotion,
  }) =>
      GameSettings(
        languageCode: languageCode ?? this.languageCode,
        musicVolume: _volume(musicVolume ?? this.musicVolume),
        voiceVolume: _volume(voiceVolume ?? this.voiceVolume),
        effectsVolume: _volume(effectsVolume ?? this.effectsVolume),
        textScale: _scale(textScale ?? this.textScale),
        reduceMotion: reduceMotion ?? this.reduceMotion,
      );

  Map<String, Object?> toJson() => {
        'languageCode': languageCode,
        'musicVolume': musicVolume,
        'voiceVolume': voiceVolume,
        'effectsVolume': effectsVolume,
        'textScale': textScale,
        'reduceMotion': reduceMotion,
      };

  /// Unknown or invalid values fall back to the defaults.
  factory GameSettings.fromJson(Map<String, Object?> json) {
    const d = GameSettings();
    final lang = json['languageCode'];
    double number(String key, double fallback) => switch (json[key]) {
          final num v => v.toDouble(),
          _ => fallback,
        };
    return GameSettings(
      languageCode: lang is String && languages.contains(lang) ? lang : d.languageCode,
      musicVolume: _volume(number('musicVolume', d.musicVolume)),
      voiceVolume: _volume(number('voiceVolume', d.voiceVolume)),
      effectsVolume: _volume(number('effectsVolume', d.effectsVolume)),
      textScale: _scale(number('textScale', d.textScale)),
      reduceMotion: json['reduceMotion'] is bool ? json['reduceMotion']! as bool : d.reduceMotion,
    );
  }

  static double _volume(double v) => v.clamp(0.0, 1.0);
  static double _scale(double v) => v.clamp(minTextScale, maxTextScale);

  @override
  bool operator ==(Object other) =>
      other is GameSettings &&
      other.languageCode == languageCode &&
      other.musicVolume == musicVolume &&
      other.voiceVolume == voiceVolume &&
      other.effectsVolume == effectsVolume &&
      other.textScale == textScale &&
      other.reduceMotion == reduceMotion;

  @override
  int get hashCode => Object.hash(languageCode, musicVolume, voiceVolume, effectsVolume, textScale, reduceMotion);
}

/// Everything that persists between missions.
final class Progress {
  const Progress({
    this.stars = const {},
    this.unlocks = const [],
    this.settings = const GameSettings(),
  });

  /// The current file version. Bump it and add a step to [_migrations]
  /// whenever the shape changes.
  static const int currentVersion = 1;

  /// Stars earned per mission id (best result).
  final Map<String, List<bool>> stars;

  /// Unlocked lore and bonus card ids (T-24).
  final List<String> unlocks;
  final GameSettings settings;

  Progress copyWith({Map<String, List<bool>>? stars, List<String>? unlocks, GameSettings? settings}) => Progress(
        stars: stars ?? this.stars,
        unlocks: unlocks ?? this.unlocks,
        settings: settings ?? this.settings,
      );

  /// Stars and unlocks cleared; settings kept.
  Progress reset() => Progress(settings: settings);

  Map<String, Object?> toJson() => {
        'version': currentVersion,
        'stars': {for (final e in stars.entries) e.key: e.value},
        'unlocks': unlocks,
        'settings': settings.toJson(),
      };

  /// Reads any version up to [currentVersion]. Throws [FormatException]
  /// for a file from a newer app or with the wrong shape.
  factory Progress.fromJson(Map<String, Object?> json) {
    final v = json['version'];
    if (v is! int || v < 1) throw const FormatException('progress.json has no valid version');
    var version = v;
    if (version > currentVersion) {
      throw FormatException('progress.json version $version is newer than this app ($currentVersion)');
    }
    var data = Map<String, Object?>.of(json);
    while (version < currentVersion) {
      data = _migrations[version]!(data);
      version++;
    }
    final starsJson = data['stars'];
    final stars = <String, List<bool>>{};
    if (starsJson is Map<String, Object?>) {
      for (final e in starsJson.entries) {
        if (e.value case final List<Object?> list) stars[e.key] = [for (final x in list) x == true];
      }
    }
    final unlocks = data['unlocks'];
    final settings = data['settings'];
    return Progress(
      stars: stars,
      unlocks: unlocks is List<Object?> ? unlocks.whereType<String>().toList() : const [],
      settings: settings is Map<String, Object?> ? GameSettings.fromJson(settings) : const GameSettings(),
    );
  }

  /// `_migrations[n]` turns a version-n file into version n + 1.
  static final Map<int, Map<String, Object?> Function(Map<String, Object?>)> _migrations = {};
}
