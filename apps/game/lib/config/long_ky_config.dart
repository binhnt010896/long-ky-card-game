/// Settings that depend on the Long Ký app and its stores (build-spec
/// section 9, open inputs for T-24). None of them is invented here: each one
/// is given at build time with `--dart-define`, and a feature whose value is
/// missing stays off.
///
///     flutter build ... \
///       --dart-define=LONG_KY_LINK_TEMPLATE='https://.../{kind}/{id}' \
///       --dart-define=LONG_KY_STORE_URL='https://...' \
///       --dart-define=LK_UNLOCK_SECRET='...'
///
/// The unlock secret is kept out of the repository on purpose: the release
/// build gets it from the CI secrets (T-27).
abstract final class LongKyConfig {
  /// TODO(T-24, open input): the Long Ký deep-link format. A template with
  /// `{id}` (the person or event id) and optionally `{kind}` (`person` or
  /// `event`). Empty until the format is decided: "Read more in Long Ký" is
  /// then not shown.
  static const String linkTemplate = String.fromEnvironment('LONG_KY_LINK_TEMPLATE');

  /// TODO(T-24, open input): the store page of Long Ký, opened when the
  /// deep link cannot be.
  static const String storeUrl = String.fromEnvironment('LONG_KY_STORE_URL');

  /// TODO(T-24, open input): the shared secret of the unlock codes. Empty
  /// until supplied: then every code is rejected.
  static const String unlockSecret = String.fromEnvironment('LK_UNLOCK_SECRET');

  /// The scheme of the incoming unlock link on mobile
  /// (`longkygame://unlock?code=LK-XXXX-XXXX`). Chosen here because the game
  /// owns it; Long Ký has to open links of this form. TODO(T-24): confirm
  /// with the Long Ký side.
  static const String unlockScheme = 'longkygame';
}
