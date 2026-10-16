import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';

/// The painted art the app ships, found by the ids in the content JSON
/// (build-spec section 6, "Art"): `cards/vuon-khong-nha-trong.png`,
/// `officers/tran-thai-tong/portrait.png`, under `assets/images/`.
///
/// Art can be missing (it is delivered separately from the code); [has] says,
/// and [ArtImage] draws a placeholder instead.
class ArtLibrary {
  ArtLibrary({required this.bundle, required this.assets});

  /// No art at all: everything is a placeholder.
  ArtLibrary.empty() : bundle = rootBundle, assets = const {};

  /// Reads the list of shipped assets once.
  static Future<ArtLibrary> fromBundle(AssetBundle bundle) async {
    final manifest = await AssetManifest.loadFromAssetBundle(bundle);
    return ArtLibrary(bundle: bundle, assets: manifest.listAssets().toSet());
  }

  static const String root = 'assets/images/';

  final AssetBundle bundle;

  /// Every shipped asset path, as the bundle lists it.
  final Set<String> assets;

  /// Whether the file for [path] (relative to `assets/images/`) is shipped.
  bool has(String? path) => path != null && assets.contains('$root$path');

  /// The image for [path], or null if it is not shipped.
  ImageProvider? provider(String? path) => has(path) ? AssetImage('$root$path', bundle: bundle) : null;
}
