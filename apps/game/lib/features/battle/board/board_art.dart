import 'dart:ui' as ui;

import 'package:flutter/painting.dart';

import '../../../art/art_library.dart';

/// Decoded painted art for the board: the map and the officer and commander
/// portraits. An image that is not shipped, or not yet decoded, is simply
/// absent, and the painter draws its placeholder instead.
class BoardArtCache {
  BoardArtCache(this.library);

  /// No art at all.
  BoardArtCache.empty() : library = ArtLibrary.empty();

  final ArtLibrary library;
  final Map<String, ui.Image> _images = {};
  final Set<String> _requested = {};

  /// How many images have been decoded so far.
  int get loaded => _images.length;

  /// The image for [path] (relative to `assets/images/`), or null. The first
  /// call for a path starts decoding it; the board repaints every frame, so
  /// it appears as soon as it is ready.
  ui.Image? image(String? path) {
    if (path == null || !library.has(path)) return null;
    final ready = _images[path];
    if (ready != null) return ready;
    if (_requested.add(path)) _decode(path);
    return null;
  }

  void _decode(String path) {
    final stream = library.provider(path)!.resolve(ImageConfiguration.empty);
    late final ImageStreamListener listener;
    listener = ImageStreamListener(
      (info, _) {
        _images[path] = info.image.clone();
        stream.removeListener(listener);
      },
      // A file that is there but cannot be read is no better than none.
      onError: (_, _) => stream.removeListener(listener),
    );
    stream.addListener(listener);
  }

  void dispose() {
    for (final image in _images.values) {
      image.dispose();
    }
    _images.clear();
  }
}
