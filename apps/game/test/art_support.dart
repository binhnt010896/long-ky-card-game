import 'dart:ui' as ui;

import 'package:flutter/foundation.dart' show FlutterError;
import 'package:flutter/services.dart';
import 'package:long_ky_game/art/art_library.dart';

/// An asset bundle that holds a few images in memory, with the manifest the
/// image loader needs to find them.
class MemoryArtBundle extends CachingAssetBundle {
  MemoryArtBundle(this.files);

  /// Full asset paths (`assets/images/cards/x.png`) to their bytes.
  final Map<String, Uint8List> files;

  @override
  Future<ByteData> load(String key) async {
    if (key == 'AssetManifest.bin') {
      return const StandardMessageCodec().encodeMessage({
        for (final k in files.keys)
          k: <Object?>[
            {'asset': k},
          ],
      })!;
    }
    final bytes = files[key];
    if (bytes == null) throw FlutterError('Unable to load asset: "$key".');
    return ByteData.sublistView(bytes);
  }

  ArtLibrary get library => ArtLibrary(bundle: this, assets: files.keys.toSet());
}

/// A PNG of a vermilion-to-ink gradient with a gold ring: stand-in art that is
/// obviously not the placeholder.
Future<Uint8List> makePng({int width = 240, int height = 180}) async {
  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(recorder);
  final rect = ui.Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble());
  canvas.drawRect(
    rect,
    ui.Paint()
      ..shader = ui.Gradient.linear(rect.topLeft, rect.bottomRight, const [ui.Color(0xFF7A2A1E), ui.Color(0xFF14202A)]),
  );
  canvas.drawCircle(
    rect.center,
    height * 0.32,
    ui.Paint()
      ..style = ui.PaintingStyle.stroke
      ..strokeWidth = 8
      ..color = const ui.Color(0xFFC9A24A),
  );
  final image = await recorder.endRecording().toImage(width, height);
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  return data!.buffer.asUint8List();
}
