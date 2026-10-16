import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:long_ky_game/platform/desktop_window.dart';
import 'package:long_ky_game/platform/mobile_orientation.dart';

class _FakeWindow implements WindowControl {
  final List<({String title, Size minimumSize, Size size})> calls = [];

  @override
  Future<void> configure({required String title, required Size minimumSize, required Size size}) async =>
      calls.add((title: title, minimumSize: minimumSize, size: size));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('desktop window (build-spec section 6)', () {
    test('the numbers are the spec\'s: minimum 1280×720, default 1600×900', () {
      expect(DesktopWindowSettings.minimumSize, const Size(1280, 720));
      expect(DesktopWindowSettings.defaultSize, const Size(1600, 900));
      expect(DesktopWindowSettings.title, 'Long Ký - The Game');
    });

    test('Windows and macOS are sized; phones and Linux are not', () async {
      for (final p in TargetPlatform.values) {
        final fake = _FakeWindow();
        await configureDesktopWindow(control: fake, platform: p);
        final desktop = p == TargetPlatform.windows || p == TargetPlatform.macOS;
        expect(fake.calls, desktop ? hasLength(1) : isEmpty, reason: '$p');
      }
    });

    test('the window gets the title and both sizes', () async {
      final fake = _FakeWindow();
      await configureDesktopWindow(control: fake, platform: TargetPlatform.windows);
      expect(fake.calls.single.title, 'Long Ký - The Game');
      expect(fake.calls.single.minimumSize, const Size(1280, 720));
      expect(fake.calls.single.size, const Size(1600, 900));
      expect(fake.calls.single.size.width, greaterThanOrEqualTo(fake.calls.single.minimumSize.width));
      expect(fake.calls.single.size.height, greaterThanOrEqualTo(fake.calls.single.minimumSize.height));
    });
  });

  group('landscape lock', () {
    final calls = <MethodCall>[];

    setUp(() {
      calls.clear();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          calls.add(call);
          return null;
        },
      );
    });

    tearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );

    test('phones and tablets are locked to the two landscape orientations', () async {
      for (final p in [TargetPlatform.android, TargetPlatform.iOS]) {
        calls.clear();
        await lockLandscape(platform: p);
        final call = calls.singleWhere((c) => c.method == 'SystemChrome.setPreferredOrientations');
        expect(call.arguments, ['DeviceOrientation.landscapeLeft', 'DeviceOrientation.landscapeRight'], reason: '$p');
      }
    });

    test('desktop is left alone', () async {
      for (final p in [TargetPlatform.windows, TargetPlatform.macOS, TargetPlatform.linux]) {
        await lockLandscape(platform: p);
      }
      expect(calls, isEmpty);
    });

    test('the Android manifest locks the activity to landscape', () {
      final manifest = File('android/app/src/main/AndroidManifest.xml').readAsStringSync();
      expect(manifest, contains('android:screenOrientation="sensorLandscape"'));
      expect(manifest, isNot(contains('"portrait"')));
    });

    test('the iOS Info.plist lists landscape orientations only, for iPhone and iPad', () {
      final plist = File('ios/Runner/Info.plist').readAsStringSync();
      for (final key in ['UISupportedInterfaceOrientations', 'UISupportedInterfaceOrientations~ipad']) {
        final start = plist.indexOf('<key>$key</key>');
        expect(start, greaterThanOrEqualTo(0), reason: key);
        final block = plist.substring(start, plist.indexOf('</array>', start));
        expect(block, contains('UIInterfaceOrientationLandscapeLeft'), reason: key);
        expect(block, contains('UIInterfaceOrientationLandscapeRight'), reason: key);
        expect(block, isNot(contains('Portrait')), reason: key);
      }
    });
  });
}
