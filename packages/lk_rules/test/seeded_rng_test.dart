import 'package:lk_rules/lk_rules.dart';
import 'package:test/test.dart';

void main() {
  group('SeededRng (SplitMix64)', () {
    test('gives the reference sequence for seed 0', () {
      // Reference values from the published SplitMix64 algorithm.
      final rng = SeededRng(0);
      expect(hex64(rng.nextInt64()), 'e220a8397b1dcdaf');
      expect(hex64(rng.nextInt64()), '6e789e6aa1b965f4');
      expect(hex64(rng.nextInt64()), '06c45d188009454f');
    });

    test('gives the reference sequence for seed 1234567', () {
      final rng = SeededRng(1234567);
      expect(hex64(rng.nextInt64()), '599ed017fb08fc85');
      expect(hex64(rng.nextInt64()), '2c73f08458540fa5');
      expect(hex64(rng.nextInt64()), '883ebce5a3f27c77');
    });

    test('same seed gives the same sequence', () {
      final a = SeededRng(42);
      final b = SeededRng(42);
      for (var i = 0; i < 100; i++) {
        expect(a.nextInt64(), b.nextInt64());
      }
    });

    test('fromState continues the sequence', () {
      final a = SeededRng(7)..nextInt64()..nextInt64();
      final b = SeededRng.fromState(a.state);
      expect(b.nextInt64(), a.nextInt64());
    });

    test('nextDouble stays in [0, 1) and nextRange in [min, max)', () {
      final rng = SeededRng(99);
      for (var i = 0; i < 10000; i++) {
        final d = rng.nextDouble();
        expect(d, greaterThanOrEqualTo(0));
        expect(d, lessThan(1));
        final r = rng.nextRange(0.9, 1.1);
        expect(r, greaterThanOrEqualTo(0.9));
        expect(r, lessThan(1.1));
      }
    });

    test('nextInt stays in range and covers it', () {
      final rng = SeededRng(5);
      final seen = <int>{};
      for (var i = 0; i < 1000; i++) {
        final v = rng.nextInt(7);
        expect(v, inInclusiveRange(0, 6));
        seen.add(v);
      }
      expect(seen, hasLength(7));
      expect(() => rng.nextInt(0), throwsArgumentError);
    });

    test('shuffled is a deterministic permutation', () {
      final items = List.generate(10, (i) => 'c$i');
      final a = SeededRng(3).shuffled(items);
      final b = SeededRng(3).shuffled(items);
      expect(a, b);
      expect(a.toSet(), items.toSet());
      expect(a, isNot(items));
      expect(items.first, 'c0', reason: 'input list is not modified');
      expect(SeededRng(3).shuffled(items), ['c8', 'c7', 'c4', 'c2', 'c9', 'c6', 'c1', 'c0', 'c5', 'c3'],
          reason: 'locked sequence: changing it breaks every saved replay');
    });
  });
}
