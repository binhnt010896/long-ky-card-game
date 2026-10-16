/// The only source of randomness in the game (build-spec section 4).
///
/// SplitMix64 (Steele, Lea and Flood, 2014), implemented here so replays stay
/// identical across Dart versions; `dart:math` `Random` is never used. Native
/// Dart `int` is 64-bit two's complement and wraps on overflow, which is what
/// the algorithm needs. (The game has no web build, where ints are doubles.)
///
/// Used for deck shuffles and ambush rolls only.
final class SeededRng {
  SeededRng(int seed) : _state = seed;

  /// Restores a generator from [state] (as stored in `GameState.rng`).
  SeededRng.fromState(int state) : _state = state;

  static const int _gamma = 0x9E3779B97F4A7C15;
  static const int _mix1 = 0xBF58476D1CE4E5B9;
  static const int _mix2 = 0x94D049BB133111EB;
  static const double _twoPow53 = 9007199254740992.0;

  int _state;

  /// The current state; feed it to [SeededRng.fromState] to continue.
  int get state => _state;

  /// The next raw 64-bit value.
  int nextInt64() {
    _state += _gamma;
    var z = _state;
    z = (z ^ (z >>> 30)) * _mix1;
    z = (z ^ (z >>> 27)) * _mix2;
    return z ^ (z >>> 31);
  }

  /// Uniform double in [0, 1), from the top 53 bits.
  double nextDouble() => (nextInt64() >>> 11) / _twoPow53;

  /// Uniform double in [min, max).
  double nextRange(double min, double max) => min + (max - min) * nextDouble();

  /// Uniform int in [0, max). [max] must be positive.
  int nextInt(int max) {
    if (max <= 0) {
      throw ArgumentError.value(max, 'max', 'must be positive');
    }
    // Rejection sampling on the top 62 bits keeps the result unbiased.
    const int range = 1 << 62;
    final limit = range - range % max;
    while (true) {
      final v = nextInt64() >>> 2;
      if (v < limit) return v % max;
    }
  }

  /// Fisher–Yates shuffle into a new list.
  List<T> shuffled<T>(List<T> items) {
    final out = List<T>.of(items);
    for (var i = out.length - 1; i > 0; i--) {
      final j = nextInt(i + 1);
      final tmp = out[i];
      out[i] = out[j];
      out[j] = tmp;
    }
    return out;
  }
}
