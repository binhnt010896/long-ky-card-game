import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The offline guard (build-spec section 7, T-29): the game is single-player and
/// fully offline (CLAUDE.md "Hard rules"). This fails if our code reaches for an
/// HTTP client or a socket, if a networking package becomes a direct
/// dependency, if a new networking-capable package joins the shipped
/// dependency tree, or if a platform file asks for network access.
///
/// What it cannot show is that no packet leaves a running app: that is checked by
/// hand on each platform (docs/store/privacy.md).
void main() {
  final repo = Directory('../..');
  final sourceDirs = [
    Directory('lib'),
    for (final p in Directory('${repo.path}/packages').listSync().whereType<Directory>()) Directory('${p.path}/lib'),
    Directory('${repo.path}/tools/sim/lib'),
    Directory('${repo.path}/tools/sim/bin'),
    Directory('${repo.path}/packages/lk_content/bin'),
  ];

  /// Our own Dart code, with comments and string-free doc lines left alone.
  Iterable<(String, String)> sources() sync* {
    for (final dir in sourceDirs.where((d) => d.existsSync())) {
      for (final f in dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'))) {
        yield (f.path, f.readAsLinesSync().where((l) => !l.trimLeft().startsWith('//')).join('\n'));
      }
    }
  }

  test('our code has files to check', () {
    expect(sources().length, greaterThan(100));
  });

  test('no Dart code of ours imports an HTTP client, a socket library or a web library', () {
    final banned = RegExp(
      r'''(?:import|export)\s+['"](?:dart:(?:html|js|js_interop|js_util|web_socket|_http)|package:(?:http|http_parser|dio|chopper|retrofit|web_socket_channel|web_socket|socket_io_client|grpc|firebase_[a-z_]+|cloud_firestore|sentry[a-z_]*|crashlytics|posthog[a-z_]*|mixpanel[a-z_]*|amplitude[a-z_]*|appsflyer[a-z_]*|google_mobile_ads|admob[a-z_]*|facebook_[a-z_]+|connectivity_plus|internet_connection_checker|network_info_plus)/)''',
    );
    final offenders = [
      for (final (path, text) in sources())
        if (banned.hasMatch(text)) path,
    ];
    expect(offenders, isEmpty, reason: 'networking or telemetry imports: $offenders');
  });

  test('no Dart code of ours uses a socket, an HTTP client or server, or a name lookup', () {
    final network = RegExp(
      r'\b(?:HttpClient|HttpServer|HttpRequest|Socket|RawSocket|ServerSocket|RawServerSocket|SecureSocket|SecureServerSocket|'
      r'WebSocket|RawDatagramSocket|NetworkInterface|HttpOverrides)\b|InternetAddress\s*\.\s*lookup|\bUri\s*\.\s*https?\s*\(',
    );
    final offenders = [
      for (final (path, text) in sources())
        if (network.hasMatch(text)) path,
    ];
    expect(offenders, isEmpty, reason: 'network classes used in: $offenders');
  });

  test('lk_rules stays pure: no dart:io, no Flutter, no clock (CLAUDE.md)', () {
    final dir = Directory('${repo.path}/packages/lk_rules/lib');
    for (final f in dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'))) {
      final text = f.readAsLinesSync().where((l) => !l.trimLeft().startsWith('//')).join('\n');
      expect(text, isNot(contains('dart:io')), reason: f.path);
      expect(text, isNot(contains('package:flutter')), reason: f.path);
      expect(text, isNot(contains('DateTime.now')), reason: f.path);
    }
  });

  group('dependencies', () {
    /// The packages the app ships with, with the versions the lock file gives.
    late List<String> shipped;
    late Set<String> direct;

    setUpAll(() {
      final r = Process.runSync('dart', ['pub', 'deps', '--no-dev', '--style=list'], workingDirectory: '.');
      expect(r.exitCode, 0, reason: 'dart pub deps failed: ${r.stderr}');
      final lines = (r.stdout as String).split('\n');
      // The section of long_ky_game itself comes last in a workspace listing.
      final start = lines.lastIndexWhere((l) => l.startsWith('long_ky_game '));
      expect(start, greaterThanOrEqualTo(0), reason: 'no long_ky_game section in\n${r.stdout}');
      final names = <String>{};
      final directNames = <String>{};
      var inDirect = false;
      for (final l in lines.skip(start + 1)) {
        if (l.startsWith('dependencies:')) inDirect = true;
        if (l.startsWith('transitive dependencies:')) inDirect = false;
        final m = RegExp(r'^- ([a-z0-9_]+) ').firstMatch(l);
        if (m != null) {
          names.add(m.group(1)!);
          if (inDirect) directNames.add(m.group(1)!);
        }
      }
      shipped = names.toList()..sort();
      direct = directNames;
    });

    test('the shipped tree was read', () {
      expect(shipped, containsAll(['flame', 'flutter_bloc', 'lk_rules', 'lk_content', 'crypto']));
      expect(direct, containsAll(['flame', 'flame_audio', 'url_launcher', 'app_links', 'qr_flutter']));
    });

    test('no networking, analytics, crash-reporting or ad package is a direct dependency', () {
      final banned = RegExp(
        r'^(?:http|dio|chopper|retrofit|web_socket_channel|web_socket|socket_io_client|grpc|firebase_.*|cloud_firestore|'
        r'sentry.*|posthog.*|mixpanel.*|amplitude.*|appsflyer.*|google_mobile_ads|.*admob.*|facebook_.*|connectivity_plus|'
        r'internet_connection_checker|network_info_plus|in_app_purchase.*|purchases_flutter|device_info_plus|package_info_plus|'
        r'webview_flutter.*|flutter_inappwebview.*|share_plus)$',
      );
      expect(direct.where(banned.hasMatch), isEmpty);
    });

    test(
      'the only networking-capable package that is shipped is the one audioplayers drags in, and nothing calls it',
      () {
        // `audioplayers` (through `flame_audio`) imports package:http for its URL
        // source cache. The game plays bundled assets only, so the code is not
        // reached; a macOS sandbox without a network entitlement and an Android
        // manifest without INTERNET also stop it. Any other package that can talk
        // to the network has to be looked at before it is added here.
        final capable = RegExp(
          r'^(?:http|http_parser|http_multi_server|dio|web_socket_channel|web_socket|shelf.*|grpc|socket_io_client|'
          r'firebase_.*|sentry.*|webview_flutter.*|flutter_inappwebview.*|connectivity_plus|internet_connection_checker)$',
        );
        expect(shipped.where(capable.hasMatch).toList(), ['http', 'http_parser']);
      },
    );
  });

  group('platform permissions', () {
    String read(String path) => File(path).readAsStringSync();

    test('Android: the release manifest has no INTERNET permission (only debug and profile do)', () {
      expect(read('android/app/src/main/AndroidManifest.xml'), isNot(contains('android.permission.INTERNET')));
      expect(read('android/app/src/debug/AndroidManifest.xml'), contains('android.permission.INTERNET'));
      expect(read('android/app/src/profile/AndroidManifest.xml'), contains('android.permission.INTERNET'));
    });

    test('Android: no other permission is asked for at all', () {
      expect(read('android/app/src/main/AndroidManifest.xml'), isNot(contains('<uses-permission')));
    });

    test('macOS: the release build is sandboxed with no network entitlement', () {
      final release = read('macos/Runner/Release.entitlements');
      expect(release, contains('com.apple.security.app-sandbox'));
      expect(release, isNot(contains('com.apple.security.network')));
    });

    test('iOS: no App Transport Security exception and no usage descriptions', () {
      final plist = read('ios/Runner/Info.plist');
      expect(plist, isNot(contains('NSAppTransportSecurity')));
      expect(plist, isNot(contains('NSAllowsArbitraryLoads')));
      expect(plist, isNot(matches(RegExp(r'NS[A-Za-z]+UsageDescription'))));
    });
  });
}
