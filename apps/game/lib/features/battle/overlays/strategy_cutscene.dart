import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lk_rules/lk_rules.dart';

import '../../../app/l10n/app_localizations.dart';
import '../../../app/theme.dart';
import '../../../art/art_image.dart';
import '../labels.dart';

/// A short cutscene when a strategy is played: the card's painting rises and
/// slowly pushes in under a brush streak and rising embers, with its name
/// and effect beside it. It never takes a tap (the board stays usable) and
/// plays only when the player has not asked for reduced motion.
class StrategyCutscene extends StatefulWidget {
  const StrategyCutscene({super.key, required this.card, required this.onDone});

  final CardDef card;
  final VoidCallback onDone;

  static const Duration length = Duration(milliseconds: 2400);

  @override
  State<StrategyCutscene> createState() => _StrategyCutsceneState();
}

class _StrategyCutsceneState extends State<StrategyCutscene> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: StrategyCutscene.length)
    ..addStatusListener((s) {
      if (s == AnimationStatus.completed) widget.onDone();
    })
    ..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final card = widget.card;
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          final t = _c.value;
          // Fade in, hold, fade out.
          final fade = Curves.easeOut.transform((t / 0.12).clamp(0.0, 1.0)) *
              (1 - Curves.easeIn.transform(((t - 0.86) / 0.14).clamp(0.0, 1.0)));
          final rise = Curves.easeOutCubic.transform((t / 0.3).clamp(0.0, 1.0));
          final push = 1.0 + 0.1 * t;
          final title = Curves.easeOutCubic.transform(((t - 0.22) / 0.3).clamp(0.0, 1.0));
          return Opacity(
            key: const Key('strategy-cutscene'),
            opacity: fade,
            child: Stack(
              fit: StackFit.expand,
              children: [
                const ColoredBox(color: Color(0xE00E0B0A)),
                CustomPaint(painter: _StreakPainter(t)),
                LayoutBuilder(
                  builder: (context, c) {
                    final h = math.min(c.maxHeight * 0.78, 380.0);
                    final w = h * 0.75;
                    final art = Transform.translate(
                      offset: Offset(0, (1 - rise) * 40),
                      child: Transform.scale(
                        scale: push,
                        child: Container(
                          width: w,
                          height: h,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: LongKyColors.goldLeaf, width: 2),
                            boxShadow: const [BoxShadow(color: Color(0xAAC9A24A), blurRadius: 24)],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: ArtImage(path: card.art, name: l.content(card.name), icon: Icons.auto_awesome),
                          ),
                        ),
                      ),
                    );
                    final words = Opacity(
                      opacity: title,
                      child: Transform.translate(
                        offset: Offset((1 - title) * 60, 0),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: math.max(160, math.min(360, c.maxWidth - w - 80))),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l.cardTypeName(card.type).toUpperCase(),
                                style: const TextStyle(
                                  color: Color(0xFFE88A80),
                                  fontSize: 13,
                                  letterSpacing: 2,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                l.content(card.name),
                                key: const Key('cutscene-name'),
                                style: const TextStyle(
                                  color: LongKyColors.goldLeaf,
                                  fontSize: 30,
                                  height: 1.1,
                                  fontWeight: FontWeight.w800,
                                  shadows: [Shadow(color: Colors.black, blurRadius: 8)],
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                height: 2,
                                width: 120 * title,
                                color: LongKyColors.goldLeaf,
                              ),
                              Text(
                                l.content(card.text),
                                maxLines: 4,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: LongKyColors.ivory, fontSize: 14, height: 1.35),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                    return Center(
                      child: Row(mainAxisSize: MainAxisSize.min, children: [art, const SizedBox(width: 28), words]),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// A diagonal brush streak sweeping across, and embers drifting up.
class _StreakPainter extends CustomPainter {
  _StreakPainter(this.t);

  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final sweep = Curves.easeInOut.transform((t / 0.5).clamp(0.0, 1.0));
    if (sweep > 0 && sweep < 1) {
      final x = -size.width * 0.3 + sweep * size.width * 1.6;
      final band = Path()
        ..moveTo(x, 0)
        ..lineTo(x + size.width * 0.22, 0)
        ..lineTo(x + size.width * 0.12, size.height)
        ..lineTo(x - size.width * 0.1, size.height)
        ..close();
      canvas.drawPath(
        band,
        Paint()
          ..shader = LinearGradient(
            colors: [
              const Color(0x00B3261E),
              const Color(0x99B3261E),
              const Color(0xAAC9A24A),
              const Color(0x00C9A24A),
            ],
          ).createShader(Rect.fromLTWH(x - size.width * 0.1, 0, size.width * 0.32, size.height)),
      );
    }
    final ember = Paint();
    for (var i = 0; i < 36; i++) {
      final seed = i * 12.9898;
      final px = (math.sin(seed) * 0.5 + 0.5) * size.width;
      final speed = 0.5 + (math.sin(seed * 3.1) * 0.5 + 0.5);
      final y = size.height * (1.1 - ((t * speed + (i % 7) / 7) % 1.0) * 1.2);
      final r = 1.2 + (i % 3);
      final a = (0.8 - (y / size.height - 0.5).abs()).clamp(0.0, 0.8);
      ember.color = Color.fromRGBO(240, 190 - (i % 4) * 25, 90, a);
      canvas.drawCircle(Offset(px + math.sin(t * 6 + i) * 8, y), r, ember);
    }
  }

  @override
  bool shouldRepaint(_StreakPainter old) => old.t != t;
}
