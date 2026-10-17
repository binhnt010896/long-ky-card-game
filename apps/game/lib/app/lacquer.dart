import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../art/art_library.dart';
import 'theme.dart';

/// The shared look of the menu screens: a painted backdrop under a dark
/// scrim, with gold-edged lacquer panels on top.

/// A painted picture (from `assets/images/`) filling its space, under
/// [scrim]. With no picture, or while it is missing, a lacquer gradient.
class LacquerBackdrop extends StatelessWidget {
  const LacquerBackdrop({
    super.key,
    required this.child,
    this.path,
    this.alignment = Alignment.center,
    this.scrim,
  });

  /// The picture, relative to `assets/images/` (for example `ui/title-cover.jpg`).
  final String? path;
  final Alignment alignment;

  /// Darkens the picture so text on top is readable. Defaults to a strong
  /// even wash.
  final Gradient? scrim;
  final Widget child;

  /// Left to right: dark where the text is, clear where the painting shows.
  static const Gradient fromLeft = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xF20E0B0A), Color(0xCC0E0B0A), Color(0x330E0B0A)],
    stops: [0.0, 0.45, 1.0],
  );

  static const Gradient wash = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xB30E0B0A), Color(0xD90E0B0A)],
  );

  /// Dark at the top and bottom, lighter in the middle (for a hero picture).
  static const Gradient vignette = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xCC0E0B0A), Color(0x330E0B0A), Color(0x990E0B0A), Color(0xF20E0B0A)],
    stops: [0.0, 0.35, 0.7, 1.0],
  );

  @override
  Widget build(BuildContext context) {
    final image = _library(context).provider(path);
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0.6, -0.5),
              radius: 1.3,
              colors: [Color(0xFF2A1210), LongKyColors.lacquer],
            ),
          ),
        ),
        if (image != null)
          Image(
            key: const Key('backdrop-art'),
            image: image,
            fit: BoxFit.cover,
            alignment: alignment,
            gaplessPlayback: true,
            excludeFromSemantics: true,
            errorBuilder: (_, _, _) => const SizedBox.shrink(),
          ),
        DecoratedBox(decoration: BoxDecoration(gradient: scrim ?? wash)),
        child,
      ],
    );
  }
}

ArtLibrary _library(BuildContext context) {
  try {
    return context.read<ArtLibrary>();
  } on Object {
    return ArtLibrary.empty();
  }
}

/// A menu page: painted backdrop, a transparent app bar with a gold title,
/// and the body inside the safe area.
class LacquerPage extends StatelessWidget {
  const LacquerPage({
    super.key,
    required this.title,
    required this.body,
    this.backdrop = 'ui/dragon-splash.jpg',
    this.alignment = Alignment.centerRight,
    this.scrim,
    this.actions,
  });

  final String title;
  final Widget body;
  final String? backdrop;
  final Alignment alignment;
  final Gradient? scrim;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(title: Text(title), backgroundColor: Colors.transparent, actions: actions),
      body: LacquerBackdrop(
        path: backdrop,
        alignment: alignment,
        scrim: scrim,
        child: SafeArea(child: body),
      ),
    );
  }
}

/// A gold hairline with a small diamond in the middle.
class GoldDivider extends StatelessWidget {
  const GoldDivider({super.key, this.width = 220});

  final double width;

  @override
  Widget build(BuildContext context) {
    Widget line(bool left) => Expanded(
      child: Container(
        height: 1,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: left ? Alignment.centerLeft : Alignment.centerRight,
            end: left ? Alignment.centerRight : Alignment.centerLeft,
            colors: [LongKyColors.goldLeaf.withValues(alpha: 0), LongKyColors.goldLeaf],
          ),
        ),
      ),
    );
    return SizedBox(
      width: width,
      child: Row(
        children: [
          line(true),
          const SizedBox(width: 6),
          Transform.rotate(
            angle: 0.785398,
            child: Container(width: 7, height: 7, color: LongKyColors.goldLeaf),
          ),
          const SizedBox(width: 6),
          line(false),
        ],
      ),
    );
  }
}

/// A dark lacquer panel with a gold edge and a soft shadow, for text on top
/// of a painting.
BoxDecoration lacquerCard({double radius = 12, bool glow = false, double opacity = 0.82}) => BoxDecoration(
  gradient: LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      const Color(0xFF2B1411).withValues(alpha: opacity),
      LongKyColors.lacquer.withValues(alpha: opacity),
    ],
  ),
  borderRadius: BorderRadius.circular(radius),
  border: Border.all(color: LongKyColors.goldLeaf.withValues(alpha: glow ? 0.9 : 0.5), width: 1),
  boxShadow: [
    BoxShadow(color: Colors.black.withValues(alpha: 0.55), blurRadius: 14, offset: const Offset(0, 4)),
    if (glow) BoxShadow(color: LongKyColors.goldLeaf.withValues(alpha: 0.25), blurRadius: 18),
  ],
);

/// A painted picture of a fixed size, or nothing at all while it is missing
/// (for decoration that needs no stand-in).
class PaintedImage extends StatelessWidget {
  const PaintedImage({super.key, required this.path, this.width, this.height, this.fit = BoxFit.cover, this.circle = false});

  final String? path;
  final double? width;
  final double? height;
  final BoxFit fit;
  final bool circle;

  @override
  Widget build(BuildContext context) {
    final image = _library(context).provider(path);
    if (image == null) return SizedBox(width: width, height: height);
    final picture = Image(
      image: image,
      width: width,
      height: height,
      fit: fit,
      excludeFromSemantics: true,
      errorBuilder: (_, _, _) => SizedBox(width: width, height: height),
    );
    return circle ? ClipOval(child: picture) : picture;
  }
}
