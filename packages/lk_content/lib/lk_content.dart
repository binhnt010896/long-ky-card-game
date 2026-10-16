/// Content models, parser and validator for Long Ký - The Game.
///
/// Pure Dart: takes file contents as strings, so the app (asset bundle), the
/// validator CLI and the simulator (dart:io) can all use it.
library;

export 'src/export_text.dart';
export 'src/issues.dart';
export 'src/longky_ids.dart';
export 'src/model.dart';
export 'src/validate.dart' show ContentException, ValidationResult, contentHash, loadContent, requiredFiles, validateContent;
