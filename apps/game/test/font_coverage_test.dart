import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

/// Every character of every UI string must exist in the bundled typeface
/// (build-spec section 6: fonts are bundled, never downloaded). A missing
/// glyph would draw blank on a device with no fallback font.
void main() {
  const fonts = ['Regular', 'Medium', 'SemiBold', 'Bold'];

  for (final weight in fonts) {
    test('Be Vietnam Pro $weight has a glyph for every character of the vi and en strings', () {
      final cmap = _Cmap(File('assets/fonts/BeVietnamPro/BeVietnamPro-$weight.ttf').readAsBytesSync());
      final missing = <String, Set<String>>{};
      for (final lang in ['vi', 'en']) {
        final arb = jsonDecode(File('l10n/app_$lang.arb').readAsStringSync()) as Map<String, Object?>;
        for (final e in arb.entries) {
          if (e.key.startsWith('@') || e.value is! String) continue;
          for (final rune in (e.value as String).runes) {
            // Whitespace and ICU syntax are not drawn.
            if (rune <= 0x20 || rune == 0xA0) continue;
            if (!cmap.has(rune)) missing.putIfAbsent(String.fromCharCode(rune), () => {}).add('$lang:${e.key}');
          }
        }
      }
      expect(missing, isEmpty, reason: 'characters missing from the font, with the strings that use them');
    });
  }

  test('the check itself notices a missing glyph', () {
    final cmap = _Cmap(File('assets/fonts/BeVietnamPro/BeVietnamPro-Regular.ttf').readAsBytesSync());
    expect(cmap.has('ệ'.runes.first), isTrue);
    expect(cmap.has(0x2192), isFalse, reason: '→ is not in the font; strings must not use it');
  });
}

/// The character map of a TrueType font (cmap formats 4 and 12).
class _Cmap {
  _Cmap(Uint8List bytes) : _d = ByteData.sublistView(bytes) {
    final tables = _d.getUint16(4);
    var cmapAt = -1;
    for (var i = 0; i < tables; i++) {
      final at = 12 + i * 16;
      if (String.fromCharCodes(bytes.sublist(at, at + 4)) == 'cmap') cmapAt = _d.getUint32(at + 8);
    }
    if (cmapAt < 0) throw StateError('no cmap table');
    final n = _d.getUint16(cmapAt + 2);
    for (var i = 0; i < n; i++) {
      final at = cmapAt + 4 + i * 8;
      final platform = _d.getUint16(at);
      final encoding = _d.getUint16(at + 2);
      final sub = cmapAt + _d.getUint32(at + 4);
      final format = _d.getUint16(sub);
      final unicode = platform == 0 || (platform == 3 && (encoding == 1 || encoding == 10));
      if (unicode && (format == 4 || format == 12)) _subtables.add((sub, format));
    }
    if (_subtables.isEmpty) throw StateError('no Unicode cmap subtable');
  }

  final ByteData _d;
  final List<(int, int)> _subtables = [];

  bool has(int rune) => _subtables.any((s) => s.$2 == 4 ? _has4(s.$1, rune) : _has12(s.$1, rune));

  bool _has4(int sub, int rune) {
    if (rune > 0xFFFF) return false;
    final segX2 = _d.getUint16(sub + 6);
    final endCodes = sub + 14;
    final startCodes = endCodes + segX2 + 2;
    final deltas = startCodes + segX2;
    final offsets = deltas + segX2;
    for (var i = 0; i < segX2 ~/ 2; i++) {
      if (rune > _d.getUint16(endCodes + i * 2)) continue;
      if (rune < _d.getUint16(startCodes + i * 2)) return false;
      final offset = _d.getUint16(offsets + i * 2);
      if (offset == 0) return ((rune + _d.getInt16(deltas + i * 2)) & 0xFFFF) != 0;
      final glyph = _d.getUint16(offsets + i * 2 + offset + (rune - _d.getUint16(startCodes + i * 2)) * 2);
      return glyph != 0;
    }
    return false;
  }

  bool _has12(int sub, int rune) {
    final groups = _d.getUint32(sub + 12);
    for (var i = 0; i < groups; i++) {
      final at = sub + 16 + i * 12;
      if (rune >= _d.getUint32(at) && rune <= _d.getUint32(at + 4)) return true;
    }
    return false;
  }
}
