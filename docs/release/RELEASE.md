# Releasing (T-27)

Sources: build-spec sections 8 ("CI and platform builds", "Signing and release") and 9 (T-27).
What is done in the repo, and what only the owner can do.

## State

| Platform | Built by CI on every merge (`build.yml`) | Signed build | Upload |
| --- | --- | --- | --- |
| Android | `.aab`, signed with the debug key | `release.yml` (manual) signs it from secrets | `release.yml`, track `internal`, draft |
| iOS | `--no-codesign` | by hand from Xcode (below) | TestFlight, by hand |
| macOS | `.app` zipped, unsigned | by hand from Xcode (below) | TestFlight, by hand |
| Windows | build folder | channel not chosen | not decided |

`release.yml` has **not been run**: it was written without the secrets or store access.
Run it once with `android_track: none` first, and look at the artifact.

## Done in the repo

- App name "Long Ký - The Game" on Android (`android:label`), iOS and macOS (`CFBundleDisplayName`), and Windows (window title, file description, product name).
  Phone home screens show a shortened label; the store listing carries the full name.
- Bundle id `app.longky.long_ky_game` (Android) / `app.longky.longKyGame` (iOS, macOS), from T-01.
- Android release signing reads `android/key.properties` if it exists (git-ignored), else the debug key.
- macOS: App Sandbox on and **no network entitlement** in `Release.entitlements` (only the debug profile has `network.server`, for hot reload).
- Placeholder icons for all four platforms from `tools/icons/make_icons.py`: a lacquer tablet, gold border, "LK" and a seal.
  **Replace them**: put the painted 1024×1024 master in `tools/icons/master.png` and run `python3 tools/icons/make_icons.py --master tools/icons/master.png`.
- Store text and age-rating answers: `docs/store/`.

## Secrets to add (GitHub, Settings → Secrets and variables → Actions)

| Secret | Used for |
| --- | --- |
| `ANDROID_KEYSTORE_BASE64` | upload keystore, `base64 -w0 upload-keystore.jks` |
| `ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD`, `ANDROID_STORE_PASSWORD` | its credentials |
| `PLAY_SERVICE_ACCOUNT_JSON` | Play Console API access, for the internal track |
| `LK_UNLOCK_SECRET` | the shared secret of the unlock codes (T-24); the same one Long Ký uses |
| `LONG_KY_LINK_TEMPLATE` | deep-link format, e.g. `https://…/{kind}/{id}` (`{kind}` is `person` or `event`) |
| `LONG_KY_STORE_URL` | Long Ký's store page |

Without the last three the build works, but "Read more in Long Ký" is hidden and every unlock code is refused
(`LongKyConfig`). The unlock secret ends up inside the app binary: a code only deters casual sharing (docs/plan.md).

## iOS and macOS to TestFlight (by hand, until signing is automated)

1. In Xcode open `apps/game/ios/Runner.xcworkspace` (or `macos/Runner.xcworkspace`), set the team and the signing certificate.
2. `flutter build ipa --release --dart-define=LK_UNLOCK_SECRET=… --dart-define=LONG_KY_LINK_TEMPLATE=… --dart-define=LONG_KY_STORE_URL=…`
   (for macOS: `flutter build macos --release` with the same defines, then Product → Archive in Xcode).
3. Upload from Xcode's Organizer (or Transporter) to App Store Connect, then add testers in TestFlight.

## Open inputs (build-spec section 9)

- Signing keys and certificates, and the store accounts.
- Windows distribution channel (Microsoft Store MSIX, an installer, or a zip). Not chosen, so there is no Windows signing or package yet.
- The Long Ký deep-link format and store URLs, and the unlock secret (T-24). The incoming link scheme `longkygame://unlock?code=…` is the game's own choice: Long Ký has to open links of that form.
- The painted icon.
- Age-rating questionnaires are answered in the stores by the owner: `docs/store/age-rating.md` has suggested answers, not a rating.
