import 'dart:ui' show Size;

import 'package:flutter/foundation.dart';
import 'package:window_manager/window_manager.dart';

/// Window rules for the desktop builds (build-spec section 6): minimum
/// 1280×720, default 1600×900, resizable, with the game's title.
abstract final class DesktopWindowSettings {
  static const Size minimumSize = Size(1280, 720);
  static const Size defaultSize = Size(1600, 900);
  static const String title = 'Long Ký - The Game';

  /// Only Windows and macOS have a window to size.
  static bool appliesTo(TargetPlatform platform) =>
      !kIsWeb && (platform == TargetPlatform.windows || platform == TargetPlatform.macOS);
}

/// What the app asks of the window; [WindowManagerControl] does it with the
/// `window_manager` package, tests with a fake.
abstract interface class WindowControl {
  Future<void> configure({required String title, required Size minimumSize, required Size size});
}

final class WindowManagerControl implements WindowControl {
  const WindowManagerControl();

  @override
  Future<void> configure({required String title, required Size minimumSize, required Size size}) async {
    await windowManager.ensureInitialized();
    final options = WindowOptions(
      size: size,
      minimumSize: minimumSize,
      center: true,
      title: title,
      titleBarStyle: TitleBarStyle.normal,
    );
    await windowManager.waitUntilReadyToShow(options, () async {
      await windowManager.setResizable(true);
      await windowManager.show();
      await windowManager.focus();
    });
  }
}

/// Sizes the window on desktop; does nothing on phones. Called from `main`.
Future<void> configureDesktopWindow({
  WindowControl control = const WindowManagerControl(),
  TargetPlatform? platform,
}) async {
  if (!DesktopWindowSettings.appliesTo(platform ?? defaultTargetPlatform)) return;
  await control.configure(
    title: DesktopWindowSettings.title,
    minimumSize: DesktopWindowSettings.minimumSize,
    size: DesktopWindowSettings.defaultSize,
  );
}
