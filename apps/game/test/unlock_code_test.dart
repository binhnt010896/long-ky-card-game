import 'package:flutter_test/flutter_test.dart';
import 'package:long_ky_game/data/codex.dart';
import 'package:long_ky_game/data/content_repository.dart';
import 'package:long_ky_game/data/long_ky_links.dart';
import 'package:long_ky_game/data/unlock_code.dart';

import 'battle/overlay_support.dart';

void main() {
  group('UnlockCodes', () {
    final codes = UnlockCodes('test-secret');

    test('derives the code from the id and the secret (reference values computed with Python hmac/sha256)', () {
      expect(codes.codeFor('tran-thai-tong'), 'LK-N3BK-S5R0');
      expect(codes.codeFor('khang-chien-mong-co-lan-mot'), 'LK-V9CV-VRV7');
      expect(UnlockCodes('other').codeFor('tran-thai-tong'), 'LK-4X6R-EKA2');
    });

    test('every code has the LK-XXXX-XXXX shape and the ids of the content all get different ones', () async {
      final content = await loadContentFromAssets(DiskAssetBundle());
      final ids = Codex(content).unlockableIds;
      expect(ids, isNotEmpty);
      final all = {for (final id in ids) codes.codeFor(id)};
      expect(all, hasLength(ids.length), reason: 'no two ids share a code');
      for (final c in all) {
        expect(c, matches(RegExp(r'^LK-[0-9A-HJKMNP-TV-Z]{4}-[0-9A-HJKMNP-TV-Z]{4}$')));
      }
    });

    test('a typed code is read forgivingly: case, dashes, spaces, and look-alike letters', () {
      for (final typed in [
        'LK-N3BK-S5R0',
        'lk-n3bk-s5r0',
        'LKN3BKS5R0',
        ' lk n3bk s5r0 ',
        'LK_N3BK_S5R0',
        'lk-n3bk-sSr0'.replaceAll('S', '5'),
      ]) {
        expect(UnlockCodes.normalize(typed), 'LK-N3BK-S5R0', reason: typed);
      }
      // O reads as 0, I and L as 1 (they are not in the alphabet).
      expect(UnlockCodes.normalize('LK-OOOO-IIII'), 'LK-0000-1111');
      expect(UnlockCodes.normalize('lk-oooo-llll'), 'LK-0000-1111');
    });

    test('things that cannot be codes are refused', () {
      for (final bad in [
        '',
        'LK',
        'LK-N3BK',
        'LK-N3BK-S5R',
        'LK-N3BK-S5R00',
        'XX-N3BK-S5R0',
        'LK-N3BK-S5RU',
        'LK-N3B!-S5R0',
      ]) {
        expect(UnlockCodes.normalize(bad), isNull, reason: bad);
      }
    });

    test('idFor finds the id a code belongs to, and nothing for a wrong code or the wrong secret', () {
      const ids = ['tran-thai-tong', 'khang-chien-mong-co-lan-mot', 'tran-hung-dao'];
      expect(codes.idFor('lk-n3bk-s5r0', ids), 'tran-thai-tong');
      expect(codes.idFor('LK-V9CV-VRV7', ids), 'khang-chien-mong-co-lan-mot');
      expect(codes.idFor('LK-N3BK-S5R1', ids), isNull);
      expect(codes.idFor('LK-4X6R-EKA2', ids), isNull, reason: 'made with another secret');
      expect(codes.idFor('LK-N3BK-S5R0', const ['tran-hung-dao']), isNull, reason: 'not an id of this game');
    });

    test('without a secret nothing is accepted, not even the code the empty secret would make', () {
      final none = UnlockCodes('');
      expect(none.isConfigured, isFalse);
      expect(none.idFor('LK-9JY9-C2CT', const ['x']), isNull);
    });
  });

  group('LongKyLinks', () {
    const links = LongKyLinks(
      template: 'https://example.test/{kind}/{id}?src=game',
      storeUrl: 'https://store.example.test/app',
    );

    test('fills the template with the kind and the id', () {
      expect(links.isConfigured, isTrue);
      expect(links.person('tran-thai-tong').toString(), 'https://example.test/person/tran-thai-tong?src=game');
      expect(links.event('bach-dang-1288').toString(), 'https://example.test/event/bach-dang-1288?src=game');
      expect(links.store.toString(), 'https://store.example.test/app');
    });

    test('an id is escaped so it cannot change the link', () {
      expect(links.person('a/b?c').toString(), contains('a%2Fb%3Fc'));
    });

    test('with no template, or a template without {id} or a scheme, there are no links', () {
      for (final t in ['', 'https://example.test/', 'example.test/{id}']) {
        final l = LongKyLinks(template: t);
        expect(l.isConfigured, isFalse, reason: t);
        expect(l.person('x'), isNull, reason: t);
        expect(l.event('x'), isNull, reason: t);
      }
      expect(const LongKyLinks().store, isNull);
    });
  });
}
