import 'package:flutter/material.dart';

import '../../../app/theme.dart';

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
