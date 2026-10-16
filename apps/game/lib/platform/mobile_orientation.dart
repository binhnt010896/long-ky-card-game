import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Landscape only on phones and tablets (build-spec section 6). The Android
/// manifest and iOS Info.plist say the same; this keeps the running app in
/// line with them.
Future<void> lockLandscape({TargetPlatform? platform}) async {
  final p = platform ?? defaultTargetPlatform;
  if (kIsWeb || (p != TargetPlatform.android && p != TargetPlatform.iOS)) return;
  await SystemChrome.setPreferredOrientations(const [
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
}
