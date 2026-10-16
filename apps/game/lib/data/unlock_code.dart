import 'dart:convert';

import 'package:crypto/crypto.dart';

/// Unlock codes (build-spec section 6): `LK-XXXX-XXXX`, derived from a person
/// or event id and a shared secret, and checked offline.
///
/// This file is pure Dart on purpose: copy it into Long Ký to make the codes
/// there. The derivation, to be implemented identically on both sides:
///
///   1. `mac = HMAC-SHA256(key = UTF-8(secret), message = UTF-8(id))`
///   2. take the first 5 bytes of `mac` (40 bits)
///   3. write them as 8 symbols of 5 bits, high bits first, from the
///      alphabet `0123456789ABCDEFGHJKMNPQRSTVWXYZ`
///   4. format as `LK-` + first four symbols + `-` + last four symbols
///
/// A code only deters casual sharing: any offline check can be taken apart
/// (docs/plan.md, "Long Ký integration"). That is fine for cosmetic unlocks.
final class UnlockCodes {
  UnlockCodes(String secret) : _key = utf8.encode(secret), isConfigured = secret.isNotEmpty;

  /// Without a secret every code is refused.
  final bool isConfigured;
  final List<int> _key;

  static const String alphabet = '0123456789ABCDEFGHJKMNPQRSTVWXYZ';

  /// The code that unlocks [id].
  String codeFor(String id) {
    final mac = Hmac(sha256, _key).convert(utf8.encode(id)).bytes;
    var bits = 0;
    var buffer = 0;
    final symbols = StringBuffer();
    for (final b in mac.take(5)) {
      buffer = (buffer << 8) | b;
      bits += 8;
      while (bits >= 5) {
        bits -= 5;
        symbols.write(alphabet[(buffer >> bits) & 31]);
      }
      buffer &= (1 << bits) - 1;
    }
    final s = symbols.toString();
    return 'LK-${s.substring(0, 4)}-${s.substring(4)}';
  }

  /// Reads what a player typed or pasted: any case, with or without dashes
  /// and spaces; `O` read as 0 and `I`/`L` as 1, as people mistype them.
  /// Returns the canonical `LK-XXXX-XXXX`, or null if it cannot be a code.
  static String? normalize(String input) {
    final s = input
        .toUpperCase()
        .replaceAll(RegExp(r'[\s\-_]'), '')
        .replaceAll('O', '0')
        .replaceAll(RegExp('[IL]'), '1');
    // "LK" itself has an L; it was turned into 1 above, so look for that.
    if (!s.startsWith('1K') || s.length != 10) return null;
    final body = s.substring(2);
    for (final ch in body.split('')) {
      if (!alphabet.contains(ch)) return null;
    }
    return 'LK-${body.substring(0, 4)}-${body.substring(4)}';
  }

  /// The id among [ids] that [input] unlocks, or null for a wrong code (or
  /// when no secret is configured).
  String? idFor(String input, Iterable<String> ids) {
    if (!isConfigured) return null;
    final code = normalize(input);
    if (code == null) return null;
    for (final id in ids) {
      if (codeFor(id) == code) return id;
    }
    return null;
  }
}
