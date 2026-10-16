import 'package:lk_rules/lk_rules.dart';

import 'issues.dart';

/// A strict reader over one JSON object. Reports missing, mistyped and
/// unknown fields (validator rule 1) instead of throwing, and returns
/// placeholder values so parsing can continue and report everything.
final class Obj {
  Obj(this.issues, this.file, this.path, this.map);

  final Issues issues;
  final String file;
  final String path;
  final Map<String, Object?> map;
  final Set<String> _read = {};

  /// Wraps [value] as an object, or reports a type error and returns null.
  static Obj? from(Issues issues, String file, String path, Object? value) {
    if (value is Map<String, Object?>) return Obj(issues, file, path, value);
    issues.error(Rule.schema, 'type', file, path, 'expected an object');
    return null;
  }

  String sub(String key) => '$path.$key';

  bool has(String key) => map.containsKey(key);

  Object? _get(String key, {required bool required}) {
    _read.add(key);
    if (!map.containsKey(key)) {
      if (required) issues.error(Rule.schema, 'missingField', file, path, 'missing "$key"');
      return null;
    }
    return map[key];
  }

  void _type(String key, String expected) =>
      issues.error(Rule.schema, 'type', file, sub(key), 'expected $expected');

  String str(String key) => strOrNull(key, required: true, nullable: false) ?? '';

  /// A string that may be absent (unless [required]) or null (if [nullable]).
  String? strOrNull(String key, {bool required = false, bool nullable = true}) {
    final v = _get(key, required: required);
    if (v == null) {
      if (!nullable && map.containsKey(key)) _type(key, 'a string');
      return null;
    }
    if (v is String) return v;
    _type(key, 'a string');
    return null;
  }

  int integer(String key, {int? min, int? max}) =>
      intOrNull(key, required: true, nullable: false, min: min, max: max) ?? 0;

  int? intOrNull(String key, {bool required = false, bool nullable = true, int? min, int? max}) {
    final v = _get(key, required: required);
    if (v == null) {
      if (!nullable && map.containsKey(key)) _type(key, 'an integer');
      return null;
    }
    if (v is! int) {
      _type(key, 'an integer');
      return null;
    }
    if ((min != null && v < min) || (max != null && v > max)) {
      issues.error(Rule.schema, 'range', file, sub(key), '$v is outside ${min ?? '-∞'}..${max ?? '∞'}');
    }
    return v;
  }

  double number(String key, {double? min, double? max}) =>
      numberOrNull(key, required: true, nullable: false, min: min, max: max) ?? 0;

  double? numberOrNull(String key, {bool required = false, bool nullable = true, double? min, double? max}) {
    final v = _get(key, required: required);
    if (v == null) {
      if (!nullable && map.containsKey(key)) _type(key, 'a number');
      return null;
    }
    if (v is! num) {
      _type(key, 'a number');
      return null;
    }
    final d = v.toDouble();
    if ((min != null && d < min) || (max != null && d > max)) {
      issues.error(Rule.schema, 'range', file, sub(key), '$d is outside ${min ?? '-∞'}..${max ?? '∞'}');
    }
    return d;
  }

  bool boolean(String key, {bool? defaultValue}) {
    final v = _get(key, required: defaultValue == null);
    if (v == null) return defaultValue ?? false;
    if (v is bool) return v;
    _type(key, 'true or false');
    return defaultValue ?? false;
  }

  List<Object?> list(String key, {bool required = true}) {
    final v = _get(key, required: required);
    if (v == null) return const [];
    if (v is List<Object?>) return v;
    _type(key, 'a list');
    return const [];
  }

  /// A list of objects, each parsed by [parse].
  List<T> objects<T>(String key, T? Function(Obj o) parse, {bool required = true}) {
    final out = <T>[];
    final items = list(key, required: required);
    for (var i = 0; i < items.length; i++) {
      final o = Obj.from(issues, file, '${sub(key)}[$i]', items[i]);
      if (o == null) continue;
      final v = parse(o);
      o.done();
      if (v != null) out.add(v);
    }
    return out;
  }

  List<String> strings(String key, {bool required = true}) {
    final out = <String>[];
    final items = list(key, required: required);
    for (var i = 0; i < items.length; i++) {
      final v = items[i];
      if (v is String) {
        out.add(v);
      } else {
        issues.error(Rule.schema, 'type', file, '${sub(key)}[$i]', 'expected a string');
      }
    }
    return out;
  }

  /// An object; absent is an error if [required], null is an error unless
  /// [nullable].
  Obj? obj(String key, {bool required = true, bool nullable = false}) {
    final v = _get(key, required: required);
    if (v == null) {
      if (!nullable && map.containsKey(key)) _type(key, 'an object');
      return null;
    }
    return Obj.from(issues, file, sub(key), v);
  }

  /// One of [values] by name.
  T enumValue<T extends Enum>(String key, List<T> values, {T? defaultValue, int rule = Rule.schema}) {
    final s = strOrNull(key, required: defaultValue == null, nullable: false);
    if (s == null) return defaultValue ?? values.first;
    for (final v in values) {
      if (v.name == s) return v;
    }
    issues.error(rule, 'unknownValue', file, sub(key),
        '"$s" is not one of ${values.map((v) => v.name).join(', ')}');
    return defaultValue ?? values.first;
  }

  /// `{ "vi": ..., "en": ... }` (validator rule 5: both non-empty).
  LocalizedText text(String key) =>
      textOrNull(key, required: true, nullable: false) ?? const LocalizedText(vi: '', en: '');

  LocalizedText? textOrNull(String key, {bool required = false, bool nullable = true}) {
    final o = obj(key, required: required, nullable: nullable);
    if (o == null) return null;
    final vi = o.str('vi');
    final en = o.str('en');
    o.done();
    for (final (lang, value) in [('vi', vi), ('en', en)]) {
      if (value.trim().isEmpty) {
        issues.error(Rule.localizedText, 'emptyText', file, '${sub(key)}.$lang', 'text must not be empty');
      }
    }
    return LocalizedText(vi: vi, en: en);
  }

  /// Marks every key as read (after reporting the object itself as invalid).
  void markAllRead() => _read.addAll(map.keys);

  /// Reports every key that was never read (validator rule 1).
  void done() {
    for (final k in map.keys) {
      if (!_read.contains(k)) {
        issues.error(Rule.schema, 'unknownField', file, sub(k), 'unknown field "$k"');
      }
    }
  }
}
