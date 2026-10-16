import 'dart:io' show Platform;

import 'package:url_launcher/url_launcher.dart';

import '../config/long_ky_config.dart';
import 'long_ky_links.dart';
import 'unlock_code.dart';

/// Opens a link outside the game. The only thing here that leaves the app:
/// it hands a URL to the system, the game itself makes no network call.
abstract interface class LinkLauncher {
  /// Whether the system opened [uri].
  Future<bool> open(Uri uri);
}

final class SystemLinkLauncher implements LinkLauncher {
  const SystemLinkLauncher();

  @override
  Future<bool> open(Uri uri) async {
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } on Object {
      return false;
    }
  }
}

/// Everything about Long Ký the screens need: links, the unlock codes, how
/// to open a link, and whether this is a desktop (which shows a QR code
/// instead, because Long Ký is a phone app).
final class LongKyAccess {
  const LongKyAccess({required this.links, required this.codes, required this.launcher, required this.isDesktop});

  /// From the build configuration, on the real platform.
  factory LongKyAccess.fromConfig() => LongKyAccess(
    links: const LongKyLinks(template: LongKyConfig.linkTemplate, storeUrl: LongKyConfig.storeUrl),
    codes: UnlockCodes(LongKyConfig.unlockSecret),
    launcher: const SystemLinkLauncher(),
    isDesktop: Platform.isMacOS || Platform.isWindows,
  );

  final LongKyLinks links;
  final UnlockCodes codes;
  final LinkLauncher launcher;
  final bool isDesktop;

  /// Nothing to show without a link format.
  bool get canReadMore => links.isConfigured;

  /// The link for a codex page's Long Ký id.
  Uri? linkFor({required String longKyId, required bool isPerson}) =>
      isPerson ? links.person(longKyId) : links.event(longKyId);

  /// Opens [link] on a phone; when it cannot be opened, the store page.
  /// False if neither opened.
  Future<bool> openOnPhone(Uri link) async {
    if (await launcher.open(link)) return true;
    final store = links.store;
    return store != null && await launcher.open(store);
  }
}
