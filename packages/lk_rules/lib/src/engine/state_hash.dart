import 'dart:convert';

import '../model/game_state.dart';

/// A stable hash of [state]: FNV-1a 64 over canonical JSON (sorted keys).
///
/// Two states hash equal exactly when their JSON forms are equal, so the hash
/// is used by determinism tests and replay checks.
String stateHash(GameState state) => fnv1a64Hex(canonicalJson(state.toJson()));

/// JSON with object keys sorted at every level.
String canonicalJson(Object? value) => jsonEncode(_canonical(value));

Object? _canonical(Object? value) {
  if (value is Map) {
    final keys = value.keys.map((k) => k.toString()).toList()..sort();
    return {for (final k in keys) k: _canonical(value[k])};
  }
  if (value is List) {
    return [for (final v in value) _canonical(v)];
  }
  return value;
}

/// FNV-1a 64-bit hash of the UTF-8 bytes of [input], as 16 hex digits.
String fnv1a64Hex(String input) {
  const int offsetBasis = 0xcbf29ce484222325;
  const int prime = 0x100000001b3;
  var hash = offsetBasis;
  for (final byte in utf8.encode(input)) {
    hash ^= byte;
    hash *= prime;
  }
  return hex64(hash);
}

/// [value] as 16 hex digits, reading the 64 bits as unsigned.
String hex64(int value) =>
    (value >>> 32).toRadixString(16).padLeft(8, '0') +
    (value & 0xFFFFFFFF).toRadixString(16).padLeft(8, '0');
