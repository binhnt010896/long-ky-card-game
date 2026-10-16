import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import 'board_scene.dart';

/// Hover tooltips for the board (build-spec section 6): with a mouse, resting
/// on a node, officer or army names it. Touch has no hover, so nothing
/// changes there.
class BoardHover extends StatefulWidget {
  const BoardHover({super.key, required this.sceneOf, required this.describe, required this.child});

  /// The scene being drawn now (null before the board has a size).
  final BoardScene? Function() sceneOf;

  /// The words for [selection]; null for nothing worth saying.
  final String? Function(Selection selection) describe;
  final Widget child;

  @override
  State<BoardHover> createState() => _BoardHoverState();
}

class _BoardHoverState extends State<BoardHover> {
  Offset? _at;
  String? _text;

  void _onHover(PointerEvent e) {
    final hit = widget.sceneOf()?.hitTest(e.localPosition);
    final text = hit == null ? null : widget.describe(hit);
    if (text == _text && (text == null || (e.localPosition - _at!).distance < 4)) return;
    setState(() {
      _text = text;
      _at = e.localPosition;
    });
  }

  void _onExit(PointerEvent e) {
    if (_text != null) setState(() => _text = null);
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: _onHover,
      onExit: _onExit,
      child: LayoutBuilder(
        builder: (context, box) {
          const width = 240.0;
          final at = _at;
          return Stack(
            fit: StackFit.expand,
            children: [
              widget.child,
              if (_text != null && at != null)
                Positioned(
                  // Right of and below the pointer, flipped when it would leave the board.
                  left: at.dx + 14 + width > box.maxWidth ? (at.dx - 14 - width).clamp(0, box.maxWidth) : at.dx + 14,
                  top: (at.dy + 14).clamp(0, box.maxHeight - 40),
                  width: width,
                  child: IgnorePointer(
                    child: Align(
                      alignment: at.dx + 14 + width > box.maxWidth ? Alignment.topRight : Alignment.topLeft,
                      child: DecoratedBox(
                        key: const Key('board-hover'),
                        decoration: BoxDecoration(
                          color: LongKyColors.lacquerRaised,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: LongKyColors.goldLeaf.withValues(alpha: 0.7)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                          child: Text(_text!, style: const TextStyle(color: LongKyColors.ivory, fontSize: 13)),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
