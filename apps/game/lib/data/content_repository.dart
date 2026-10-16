import 'package:flutter/services.dart';
import 'package:lk_content/lk_content.dart';

/// Loads the game content JSON from the asset bundle.
Future<ContentBundle> loadContentFromAssets(AssetBundle bundle) async {
  const root = 'assets/content/';
  final manifest = await AssetManifest.loadFromAssetBundle(bundle);
  final files = <String, String>{};
  for (final path in manifest.listAssets()) {
    if (!path.startsWith(root) || !path.endsWith('.json')) continue;
    files[path.substring(root.length)] = await bundle.loadString(path);
  }
  return loadContent(files);
}
