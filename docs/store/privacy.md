# Privacy and offline check (T-29)

Sources: CLAUDE.md "Hard rules" (no networking, accounts, analytics or ads), build-spec sections 7 ("Offline guard"), 8 ("macOS: App Sandbox on, with no network entitlement") and 9 (T-29).

## What the game does with data

- Everything stays on the device: `progress.json` (stars, settings, unlocks, tutorial flags) and `battle.json` (the battle in progress), in the app's support directory.
- No accounts, no analytics, no crash reporting, no ads, no purchases, no network calls of its own.
- "Read more in Long Ký" hands a link to the system (browser or the Long Ký app); on desktop it shows a QR code instead. The game itself sends nothing.
- Unlock codes are checked on the device against a shared secret; nothing is sent anywhere.

## Store answers

| Store | Answer |
| --- | --- |
| App Store (privacy "nutrition label") | **Data Not Collected** |
| Google Play (Data safety) | Collects no data; shares no data; no data is encrypted in transit because none is sent; the user cannot request deletion because nothing is held by us (uninstalling removes the files) |
| Microsoft Store | No personal information collected |
| Privacy-policy URL | Needed by the stores; a one-paragraph page saying the above is enough. The owner hosts it. |

## The guard (`apps/game/test/offline_guard_test.dart`, runs in `melos run test`)

It fails if:

1. Any Dart file of ours (app, packages, simulator) imports an HTTP client, web-socket or web library, or an analytics, crash-reporting, ads, connectivity or purchase package.
2. Any Dart file of ours uses `HttpClient`, `HttpServer`, `Socket` and the other socket classes, or a name lookup.
3. `lk_rules` imports `dart:io` or Flutter, or reads the clock.
4. A networking, telemetry, ads, purchase, web-view or device-info package becomes a **direct** dependency.
5. A networking-capable package other than the known one joins the **shipped** dependency tree (`dart pub deps --no-dev`).
6. The Android release manifest asks for any permission (the debug and profile manifests keep `INTERNET` for development only), the macOS release entitlements carry a network entitlement, or the iOS `Info.plist` has an App Transport Security exception or a usage description.

## One finding

`audioplayers` (a dependency of `flame_audio`) imports `package:http` for its URL-source cache, so `http` and `http_parser` are in the shipped tree.
The game only plays bundled assets, so that code is not reached; on Android the release build has no `INTERNET` permission and on macOS the sandbox has no network entitlement, so it could not connect anyway. iOS has no such barrier: there the guarantee is "no code path", not "no permission".
Replacing the audio backend with one that has no HTTP dependency would close this; the `AudioBackend` interface (`lib/audio/audio_backend.dart`) was made for that.
The guard pins the set to exactly `http` and `http_parser`, so any further addition has to be looked at.

## Not run here (needs devices): "makes no network calls on all four platforms"

The acceptance line of T-29 is a run-time claim. A cloud container cannot show it. By hand, on each platform:

- **Android:** install the release build, check *Settings → Apps → Long Ký → Permissions* shows none and no "Network" in the manifest (`apkanalyzer manifest print app-release.apk`), then play a mission with airplane mode on.
- **iOS:** play a mission with a network proxy or Charles/mitmproxy on the same Wi-Fi and with *Settings → Cellular* off for the app; the proxy must show no request from the app.
- **macOS:** `codesign -d --entitlements - "Long Ký - The Game.app"` must show the sandbox and no `network` key; run a mission under Little Snitch or `nettop -p <pid>`.
- **Windows:** run a mission under Resource Monitor → Network, or Wireshark filtered on the process, with the unlock and Read-more screens opened too.
