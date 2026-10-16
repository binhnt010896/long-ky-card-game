import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/l10n/app_localizations.dart';
import '../../app/theme.dart';
import '../battle/overlays/panel.dart';

/// Where to put a coach-mark bubble of [bubble] size on a [screen], next to
/// [target] (the spotlit element) and inside [safe]. Tries below, above, to
/// the right and to the left, in that order, taking the first place where the
/// bubble fits without covering the target; if there is none, the place that
/// covers it least. With no target the bubble is centred.
Offset placeBubble({
  required Size screen,
  required Rect? target,
  required Size bubble,
  EdgeInsets safe = EdgeInsets.zero,
  double gap = 12,
}) {
  final area = Rect.fromLTRB(
    safe.left + 8,
    safe.top + 8,
    screen.width - safe.right - 8,
    screen.height - safe.bottom - 8,
  );
  Offset clamp(Offset o) => Offset(
    o.dx.clamp(area.left, math.max(area.left, area.right - bubble.width)),
    o.dy.clamp(area.top, math.max(area.top, area.bottom - bubble.height)),
  );
  if (target == null) return clamp(Offset(area.center.dx - bubble.width / 2, area.center.dy - bubble.height / 2));

  final centeredX = target.center.dx - bubble.width / 2;
  final centeredY = target.center.dy - bubble.height / 2;
  final candidates = [
    Offset(centeredX, target.bottom + gap), // below
    Offset(centeredX, target.top - gap - bubble.height), // above
    Offset(target.right + gap, centeredY), // right
    Offset(target.left - gap - bubble.width, centeredY), // left
  ];
  Offset? bestOverlap;
  var bestArea = double.infinity;
  for (final c in candidates) {
    final placed = clamp(c);
    final rect = placed & bubble;
    final inside =
        rect.left >= area.left - 0.5 &&
        rect.right <= area.right + 0.5 &&
        rect.top >= area.top - 0.5 &&
        rect.bottom <= area.bottom + 0.5;
    final overlap = rect.intersect(target.inflate(2));
    final overlapArea = overlap.isEmpty ? 0.0 : overlap.width * overlap.height;
    final moved = (placed - c).distance > 0.5;
    if (inside && overlapArea == 0 && !moved) return placed;
    // Remember the least-covering place for when none is clean.
    final score = overlapArea + (moved ? 1 : 0);
    if (score < bestArea) {
      bestArea = score;
      bestOverlap = placed;
    }
  }
  return bestOverlap!;
}

/// A coach mark (T-22): the rest of the screen dims, the [target] is
/// outlined, and a bubble beside it says one thing. It does not block the
/// game: the player can act on the spotlit element while it is shown.
class TutorialCoach extends StatelessWidget {
  const TutorialCoach({
    super.key,
    required this.text,
    required this.position,
    required this.total,
    required this.target,
    required this.onNext,
    required this.onSkip,
    this.safe = EdgeInsets.zero,
  });

  final String text;

  /// 1-based place of this tip, and how many there are.
  final int position;
  final int total;

  /// The spotlit element in this widget's coordinates, or null.
  final Rect? target;
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final EdgeInsets safe;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final last = position >= total;
    return LayoutBuilder(
      builder: (context, box) {
        final screen = box.biggest;
        final width = math.min(screen.width - 24.0, screen.width < 900 ? 300.0 : 360.0);
        return Stack(
          key: const Key('tutorial-coach'),
          children: [
            // The dim and the outline never take a tap: the game stays playable.
            Positioned.fill(
              child: IgnorePointer(child: CustomPaint(painter: _SpotlightPainter(target))),
            ),
            CustomSingleChildLayout(
              delegate: _BubbleDelegate(screen: screen, target: target, safe: safe),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: width),
                child: Semantics(
                  container: true,
                  liveRegion: true,
                  label: l.tutorialSemantics(text),
                  child: Material(
                    key: const Key('tutorial-bubble'),
                    color: LongKyColors.lacquerRaised,
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: const BorderSide(color: LongKyColors.goldLeaf, width: 1.5),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ExcludeSemantics(
                            child: Text(
                              text,
                              key: const Key('tutorial-text'),
                              style: const TextStyle(color: LongKyColors.ivory, fontSize: 15, height: 1.35),
                            ),
                          ),
                          const SizedBox(height: 6),
                          // Wraps rather than overflows, at any text size.
                          Wrap(
                            alignment: WrapAlignment.spaceBetween,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 8,
                            runSpacing: 0,
                            children: [
                              TextButton(
                                key: const Key('tutorial-skip'),
                                onPressed: onSkip,
                                style: TextButton.styleFrom(
                                  minimumSize: const Size(minTouch, minTouch),
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  foregroundColor: LongKyColors.ivory.withValues(alpha: 0.85),
                                ),
                                child: Text(l.tutorialSkip, style: const TextStyle(fontSize: 13)),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    l.tutorialCount(position, total),
                                    key: const Key('tutorial-count'),
                                    style: TextStyle(color: LongKyColors.ivory.withValues(alpha: 0.7), fontSize: 12),
                                  ),
                                  const SizedBox(width: 8),
                                  FilledButton(
                                    key: const Key('tutorial-next'),
                                    onPressed: onNext,
                                    style: FilledButton.styleFrom(minimumSize: const Size(minTouch, minTouch)),
                                    child: Text(last ? l.tutorialGotIt : l.tutorialNext),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _BubbleDelegate extends SingleChildLayoutDelegate {
  _BubbleDelegate({required this.screen, required this.target, required this.safe});

  final Size screen;
  final Rect? target;
  final EdgeInsets safe;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) => constraints.loosen();

  @override
  Offset getPositionForChild(Size size, Size childSize) =>
      placeBubble(screen: screen, target: target, bubble: childSize, safe: safe);

  @override
  bool shouldRelayout(_BubbleDelegate old) => old.target != target || old.screen != screen || old.safe != safe;
}

/// Dims everything but [target], which gets a gold outline.
class _SpotlightPainter extends CustomPainter {
  _SpotlightPainter(this.target);

  final Rect? target;

  @override
  void paint(Canvas canvas, Size size) {
    final full = Path()..addRect(Offset.zero & size);
    final dim = Paint()..color = const Color(0xFF000000).withValues(alpha: 0.55);
    final hole = target?.inflate(4);
    if (hole == null) {
      canvas.drawPath(full, dim);
      return;
    }
    final rrect = RRect.fromRectAndRadius(hole, const Radius.circular(8));
    canvas.drawPath(Path.combine(PathOperation.difference, full, Path()..addRRect(rrect)), dim);
    canvas.drawRRect(
      rrect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..color = LongKyColors.goldLeaf,
    );
  }

  @override
  bool shouldRepaint(_SpotlightPainter old) => old.target != target;
}
