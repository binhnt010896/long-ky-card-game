import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../app/theme.dart';
import 'art_library.dart';

/// Painted art by id, or a placeholder (build-spec section 6): a lacquer
/// background, a gold border and the item's name. This lets code ship before
/// art does.
class ArtImage extends StatelessWidget {
  const ArtImage({
    super.key,
    required this.path,
    required this.name,
    this.fit = BoxFit.cover,
    this.showName = true,
    this.icon,
    this.radius = 4,
  });

  /// The id of the file under `assets/images/`; null when the content names none.
  final String? path;

  /// The item's name, drawn in the placeholder.
  final String name;
  final BoxFit fit;

  /// False where the name is already written next to the art.
  final bool showName;

  /// A faint glyph in the placeholder, standing for the kind of item.
  final IconData? icon;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final library = _library(context);
    final image = library.provider(path);
    final placeholder = ArtPlaceholder(name: name, showName: showName, icon: icon, radius: radius);
    if (image == null) return placeholder;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Image(
        image: image,
        fit: fit,
        // A file that is there but cannot be read is no better than none.
        errorBuilder: (_, _, _) => placeholder,
        semanticLabel: name,
      ),
    );
  }

  /// The app's art library, or an empty one outside the app.
  static ArtLibrary libraryOf(BuildContext context) => _library(context);

  static ArtLibrary _library(BuildContext context) {
    try {
      return context.read<ArtLibrary>();
    } on Object {
      return ArtLibrary.empty();
    }
  }
}

/// The stand-in for art that is not there yet.
class ArtPlaceholder extends StatelessWidget {
  const ArtPlaceholder({super.key, required this.name, this.showName = true, this.icon, this.radius = 4});

  final String name;
  final bool showName;
  final IconData? icon;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      key: const Key('art-placeholder'),
      decoration: BoxDecoration(
        color: LongKyColors.lacquer,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: LongKyColors.goldLeaf, width: 1.5),
      ),
      child: LayoutBuilder(
        builder: (context, box) {
          final small = box.biggest.shortestSide < 56;
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null)
                      Icon(icon, size: small ? 18 : 30, color: LongKyColors.goldLeaf.withValues(alpha: 0.5)),
                    if (showName && !small)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: box.maxWidth.isFinite ? box.maxWidth - 12 : 120),
                          child: Text(
                            name,
                            textAlign: TextAlign.center,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: LongKyColors.ivory,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
