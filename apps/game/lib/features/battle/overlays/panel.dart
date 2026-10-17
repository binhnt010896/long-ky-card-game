import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app/theme.dart';
import '../../../art/art_library.dart';

/// Smallest touch target (build-spec section 6).
const double minTouch = 48;

/// Lacquer panel with a gold edge, the common look of the battle overlays.
BoxDecoration lacquerPanel({bool selected = false, double radius = 8, Color? fill}) => BoxDecoration(
  color: fill ?? LongKyColors.lacquerRaised,
  borderRadius: BorderRadius.circular(radius),
  border: Border.all(
    color: LongKyColors.goldLeaf.withValues(alpha: selected ? 1 : 0.45),
    width: selected ? 2 : 1,
  ),
);

/// A small round badge with up to two letters, standing in for a portrait
/// until the painted art arrives (T-21).
class InitialsBadge extends StatelessWidget {
  const InitialsBadge({super.key, required this.initials, this.size = 32, this.heavy = false, this.fill});

  final String initials;
  final double size;

  /// A heavier ring, for the king.
  final bool heavy;
  final Color? fill;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: fill ?? LongKyColors.lacquer,
        border: Border.all(color: LongKyColors.goldLeaf, width: heavy ? 3 : 1.5),
      ),
      child: Text(
        initials,
        style: TextStyle(color: LongKyColors.ivory, fontSize: size * 0.38, fontWeight: FontWeight.w700, height: 1),
      ),
    );
  }
}

/// A round portrait with a gold ring: the painted portrait when it is
/// shipped, the person's initials otherwise.
class PortraitBadge extends StatelessWidget {
  const PortraitBadge({super.key, required this.path, required this.initials, this.size = 32, this.heavy = false});

  /// The portrait under `assets/images/`, when the content names one.
  final String? path;
  final String initials;
  final double size;

  /// A heavier ring, for the king.
  final bool heavy;

  @override
  Widget build(BuildContext context) {
    ArtLibrary library;
    try {
      library = context.read<ArtLibrary>();
    } on Object {
      library = ArtLibrary.empty();
    }
    final image = library.provider(path);
    if (image == null) return InitialsBadge(initials: initials, size: size, heavy: heavy);
    return Container(
      key: const Key('portrait-badge'),
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: LongKyColors.lacquer,
        border: Border.all(color: LongKyColors.goldLeaf, width: heavy ? 2.5 : 1.2),
      ),
      child: ClipOval(
        child: Image(
          image: image,
          fit: BoxFit.cover,
          alignment: const Alignment(0, -0.35),
          excludeFromSemantics: true,
          errorBuilder: (_, _, _) => InitialsBadge(initials: initials, size: size, heavy: heavy),
        ),
      ),
    );
  }
}
