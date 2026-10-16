/// Validation findings (build-spec section 3, validator rules 1–8).
library;

enum Severity { error, warning }

final class Issue {
  const Issue({
    required this.rule,
    required this.severity,
    required this.code,
    required this.file,
    required this.path,
    required this.message,
  });

  /// Validator rule number, 1–8.
  final int rule;
  final Severity severity;

  /// Stable machine-readable code, e.g. `unknownField`.
  final String code;

  /// Content file relative to the content root, e.g. `missions/ch1_m2.json`.
  final String file;

  /// JSON path inside the file, e.g. `$.officers[2].stats.war`.
  final String path;
  final String message;

  bool get isError => severity == Severity.error;

  @override
  String toString() => '${severity.name.toUpperCase()} [rule $rule/$code] $file $path: $message';
}

final class Issues {
  final List<Issue> all = [];

  void error(int rule, String code, String file, String path, String message) =>
      all.add(Issue(rule: rule, severity: Severity.error, code: code, file: file, path: path, message: message));

  void warning(int rule, String code, String file, String path, String message) =>
      all.add(Issue(rule: rule, severity: Severity.warning, code: code, file: file, path: path, message: message));

  Iterable<Issue> get errors => all.where((i) => i.isError);
  Iterable<Issue> get warnings => all.where((i) => !i.isError);
  bool get hasErrors => errors.isNotEmpty;
}

/// Validator rule numbers.
abstract final class Rule {
  static const int schema = 1;
  static const int references = 2;
  static const int sourceRefs = 3;
  static const int longKyIds = 4;
  static const int localizedText = 5;
  static const int closedLists = 6;
  static const int mapGraph = 7;
  static const int assets = 8;
}
