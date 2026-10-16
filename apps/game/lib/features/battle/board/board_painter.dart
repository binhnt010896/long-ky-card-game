import 'dart:math' as math;

import 'package:flutter/painting.dart';
import 'package:lk_rules/lk_rules.dart';

import '../../../app/theme.dart';
import 'board_scene.dart';

/// Draws a [BoardScene]. Everything is vector placeholder art: lacquer
/// medallions, river and road edges, tokens and intent arrows (build-spec
/// section 6). Painted art replaces it in T-21.
final class BoardPainter {
  final Map<String, TextPainter> _text = {};

  static const Color _smoke = Color(0xFF6B635C);

  Color intentColor(IntentKind k) => switch (k) {
        IntentKind.advance => LongKyColors.ivory,
        IntentKind.assault => const Color(0xFFE5483D),
        IntentKind.forage => LongKyColors.goldLeaf,
        IntentKind.retreat => const Color(0xFF6FA8BC),
        IntentKind.hold => const Color(0xFFB8B0A0),
      };

  void paint(Canvas canvas, BoardScene scene) {
    _paintMapPanel(canvas, scene);
    for (final e in scene.edges) {
      _paintEdge(canvas, e);
    }
    for (final n in scene.nodes) {
      _paintNode(canvas, scene, n);
    }
    for (final t in scene.tokens) {
      _paintToken(canvas, scene, t);
    }
    // Intents go on top: they are what the player must not miss.
    for (final a in scene.arrows) {
      _paintArrow(canvas, scene, a);
    }
    for (final b in scene.badges) {
      _paintBadge(canvas, scene, b);
    }
    _paintSelection(canvas, scene);
  }

  // -- Map ---------------------------------------------------------------------

  void _paintMapPanel(Canvas canvas, BoardScene scene) {
    final r = RRect.fromRectAndRadius(scene.layout.mapRect.inflate(6), const Radius.circular(10));
    canvas.drawRRect(r, Paint()..color = LongKyColors.lacquerRaised);
    canvas.drawRRect(
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = LongKyColors.goldLeaf.withValues(alpha: 0.35),
    );
  }

  void _paintEdge(Canvas canvas, EdgeView e) {
    if (e.kind == EdgeKind.river) {
      canvas.drawLine(
        e.a,
        e.b,
        Paint()
          ..strokeWidth = 6
          ..strokeCap = StrokeCap.round
          ..color = LongKyColors.riverBlue,
      );
      canvas.drawLine(
        e.a,
        e.b,
        Paint()
          ..strokeWidth = 1.5
          ..color = LongKyColors.goldLeaf.withValues(alpha: 0.7),
      );
    } else {
      _dashedLine(
        canvas,
        e.a,
        e.b,
        Paint()
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round
          ..color = LongKyColors.ivory.withValues(alpha: 0.55),
        dash: 9,
        gap: 7,
      );
    }
    if (e.ambushed) {
      final mid = Offset.lerp(e.a, e.b, 0.5)!;
      final p = Path()
        ..moveTo(mid.dx, mid.dy - 9)
        ..lineTo(mid.dx + 9, mid.dy)
        ..lineTo(mid.dx, mid.dy + 9)
        ..lineTo(mid.dx - 9, mid.dy)
        ..close();
      canvas.drawPath(p, Paint()..color = LongKyColors.lacquer);
      canvas.drawPath(
        p,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..color = LongKyColors.goldLeaf,
      );
    }
  }

  void _dashedLine(Canvas canvas, Offset a, Offset b, Paint paint, {required double dash, required double gap}) {
    final total = (b - a).distance;
    if (total < 1e-6) return;
    final dir = (b - a) / total;
    var d = 0.0;
    while (d < total) {
      final end = math.min(d + dash, total);
      canvas.drawLine(a + dir * d, a + dir * end, paint);
      d += dash + gap;
    }
  }

  // -- Nodes -------------------------------------------------------------------

  void _paintNode(Canvas canvas, BoardScene scene, NodeView n) {
    final ring = n.evacuated
        ? _smoke
        : switch (n.controller) {
            Side.daiViet => LongKyColors.goldLeaf,
            Side.yuan => LongKyColors.cinnabar,
            Side.none => LongKyColors.ivory.withValues(alpha: 0.4),
          };
    canvas.drawCircle(n.center, n.radius, Paint()..color = n.evacuated ? const Color(0xFF24201D) : LongKyColors.lacquer);
    canvas.drawCircle(
      n.center,
      n.radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(2.5, n.radius * 0.14)
        ..color = ring,
    );
    if (n.isCapital) {
      canvas.drawCircle(
        n.center,
        n.radius + 4,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = ring,
      );
    }
    _terrainGlyph(canvas, n.center, n.radius * 0.5, n.terrain, n.evacuated ? _smoke : ring);
    if (n.isBorder) {
      final c = n.center + Offset(n.radius * 0.8, -n.radius * 0.8);
      final p = Path()
        ..moveTo(c.dx, c.dy - 7)
        ..lineTo(c.dx + 6, c.dy + 4)
        ..lineTo(c.dx - 6, c.dy + 4)
        ..close();
      canvas.drawPath(p, Paint()..color = LongKyColors.goldLeaf);
    }
    if (n.evacuated) _smokeMark(canvas, n);
    final tp = _label(n.name, scene.layout.labelFontSize, LongKyColors.ivory, bold: true);
    tp.paint(canvas, n.labelCenter - Offset(tp.width / 2, tp.height / 2));
  }

  void _terrainGlyph(Canvas canvas, Offset c, double s, Terrain t, Color color) {
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = color;
    switch (t) {
      case Terrain.city:
        final p = Path()
          ..moveTo(c.dx - s, c.dy + s * 0.7)
          ..lineTo(c.dx - s, c.dy - s * 0.2)
          ..lineTo(c.dx - s * 0.5, c.dy - s * 0.2)
          ..lineTo(c.dx - s * 0.5, c.dy - s * 0.7)
          ..lineTo(c.dx + s * 0.5, c.dy - s * 0.7)
          ..lineTo(c.dx + s * 0.5, c.dy - s * 0.2)
          ..lineTo(c.dx + s, c.dy - s * 0.2)
          ..lineTo(c.dx + s, c.dy + s * 0.7)
          ..close();
        canvas.drawPath(p, stroke);
      case Terrain.plain:
        for (final dy in [-0.4, 0.1, 0.6]) {
          canvas.drawLine(Offset(c.dx - s, c.dy + s * dy), Offset(c.dx + s, c.dy + s * dy), stroke);
        }
      case Terrain.river:
        for (final dy in [-0.3, 0.4]) {
          final p = Path()..moveTo(c.dx - s, c.dy + s * dy);
          p.cubicTo(c.dx - s * 0.5, c.dy + s * (dy - 0.5), c.dx - s * 0.1, c.dy + s * (dy + 0.5), c.dx + s * 0.4, c.dy + s * dy);
          p.lineTo(c.dx + s, c.dy + s * dy);
          canvas.drawPath(p, stroke);
        }
      case Terrain.marsh:
        final fill = Paint()..color = color;
        for (final (dx, dy) in [(-0.6, -0.3), (0.3, -0.5), (-0.1, 0.1), (0.7, 0.2), (-0.5, 0.6), (0.2, 0.7)]) {
          canvas.drawCircle(c + Offset(dx * s, dy * s), s * 0.14, fill);
        }
      case Terrain.hill:
        final p = Path()
          ..moveTo(c.dx - s, c.dy + s * 0.6)
          ..lineTo(c.dx - s * 0.25, c.dy - s * 0.6)
          ..lineTo(c.dx + s * 0.3, c.dy + s * 0.2)
          ..lineTo(c.dx + s * 0.6, c.dy - s * 0.2)
          ..lineTo(c.dx + s, c.dy + s * 0.6);
        canvas.drawPath(p, stroke);
    }
  }

  void _smokeMark(Canvas canvas, NodeView n) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..color = _smoke;
    for (final dx in [-0.4, 0.0, 0.4]) {
      final x = n.center.dx + n.radius * dx;
      final y = n.center.dy - n.radius - 2;
      final p = Path()..moveTo(x, y);
      p.cubicTo(x - 5, y - 6, x + 5, y - 10, x, y - 16);
      canvas.drawPath(p, paint);
    }
  }

  // -- Tokens ------------------------------------------------------------------

  void _paintToken(Canvas canvas, BoardScene scene, TokenView t) {
    final r = t.radius;
    if (t.kind == TokenKind.officer) {
      canvas.drawCircle(t.center, r, Paint()..color = LongKyColors.lacquerRaised);
      canvas.drawCircle(
        t.center,
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = t.isKing ? 3.5 : 2
          ..color = LongKyColors.goldLeaf,
      );
    } else {
      final rect = RRect.fromRectAndRadius(Rect.fromCircle(center: t.center, radius: r), Radius.circular(r * 0.35));
      canvas.drawRRect(rect, Paint()..color = LongKyColors.cinnabar);
      canvas.drawRRect(
        rect,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = LongKyColors.ivory.withValues(alpha: 0.8),
      );
    }
    final initials = _label(t.initials, math.max(9.0, r * 0.85), LongKyColors.ivory, bold: true, shadow: false);
    initials.paint(canvas, t.center - Offset(initials.width / 2, initials.height / 2));

    // Troops in units of 1,000, in a small badge at the lower right.
    final bc = t.center + Offset(r * 0.78, r * 0.78);
    final count = _label('${t.troops}', math.max(9.0, r * 0.7), LongKyColors.lacquer, bold: true, shadow: false);
    final br = math.max(count.width, count.height) * 0.62;
    canvas.drawCircle(bc, br, Paint()..color = LongKyColors.goldLeaf);
    count.paint(canvas, bc - Offset(count.width / 2, count.height / 2));
  }

  // -- Intents -----------------------------------------------------------------

  void _paintArrow(Canvas canvas, BoardScene scene, ArrowView a) {
    final color = intentColor(a.intent);
    final alpha = a.predicted ? 0.75 : 1.0;
    final paint = Paint()
      ..strokeWidth = a.intent == IntentKind.assault ? 5 : 3.5
      ..strokeCap = StrokeCap.round
      ..color = color.withValues(alpha: alpha);
    final d = a.end - a.start;
    final len = d.distance;
    if (len < 1) return;
    final dir = d / len;
    final headLen = math.min(len * 0.45, 16.0);
    final lineEnd = a.end - dir * headLen * 0.6;
    if (a.predicted) {
      _dashedLine(canvas, a.start, lineEnd, paint, dash: 7, gap: 6);
    } else {
      canvas.drawLine(a.start, lineEnd, paint);
    }
    final normal = Offset(-dir.dy, dir.dx);
    final head = Path()
      ..moveTo(a.end.dx, a.end.dy)
      ..lineTo((a.end - dir * headLen + normal * headLen * 0.55).dx, (a.end - dir * headLen + normal * headLen * 0.55).dy)
      ..lineTo((a.end - dir * headLen - normal * headLen * 0.55).dx, (a.end - dir * headLen - normal * headLen * 0.55).dy)
      ..close();
    canvas.drawPath(head, Paint()..color = color.withValues(alpha: alpha));
    // The icon at the middle says what the army intends.
    final mid = Offset.lerp(a.start, a.end, 0.5)!;
    _intentGlyph(canvas, mid, 9, a.intent, color, predicted: a.predicted);
  }

  void _paintBadge(Canvas canvas, BoardScene scene, BadgeView b) {
    _intentGlyph(canvas, b.center, 9, b.intent, intentColor(b.intent), predicted: b.predicted);
  }

  /// A round icon: advance chevron, assault cross, forage grain, retreat
  /// chevron back, hold bars.
  void _intentGlyph(Canvas canvas, Offset c, double r, IntentKind kind, Color color, {required bool predicted}) {
    canvas.drawCircle(c, r + 2, Paint()..color = LongKyColors.lacquer);
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = color;
    if (predicted) {
      for (var i = 0; i < 8; i += 2) {
        canvas.drawArc(Rect.fromCircle(center: c, radius: r + 1), i * math.pi / 4, math.pi / 4, false, ring);
      }
    } else {
      canvas.drawCircle(c, r + 1, ring);
    }
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = color;
    final s = r * 0.55;
    switch (kind) {
      case IntentKind.advance:
        canvas.drawPath(
          Path()
            ..moveTo(c.dx - s * 0.5, c.dy - s)
            ..lineTo(c.dx + s * 0.6, c.dy)
            ..lineTo(c.dx - s * 0.5, c.dy + s),
          line,
        );
      case IntentKind.retreat:
        canvas.drawPath(
          Path()
            ..moveTo(c.dx + s * 0.5, c.dy - s)
            ..lineTo(c.dx - s * 0.6, c.dy)
            ..lineTo(c.dx + s * 0.5, c.dy + s),
          line,
        );
      case IntentKind.assault:
        canvas.drawLine(c + Offset(-s, -s), c + Offset(s, s), line);
        canvas.drawLine(c + Offset(-s, s), c + Offset(s, -s), line);
      case IntentKind.forage:
        canvas.drawCircle(c, s * 0.9, line);
        canvas.drawCircle(c, s * 0.25, Paint()..color = color);
      case IntentKind.hold:
        canvas.drawLine(c + Offset(-s * 0.55, -s), c + Offset(-s * 0.55, s), line);
        canvas.drawLine(c + Offset(s * 0.55, -s), c + Offset(s * 0.55, s), line);
    }
  }

  // -- Selection ---------------------------------------------------------------

  void _paintSelection(Canvas canvas, BoardScene scene) {
    final s = scene.selection;
    final c = scene.selectedCenter;
    if (s == null || c == null) return;
    final radius = switch (s.kind) {
      SelectionKind.node => scene.layout.nodeRadius + 8,
      _ => scene.layout.tokenRadius + 6,
    };
    canvas.drawCircle(
      c,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = LongKyColors.ivory,
    );
    canvas.drawCircle(
      c,
      radius + 3,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = LongKyColors.goldLeaf,
    );
  }

  // -- Text --------------------------------------------------------------------

  TextPainter _label(String text, double size, Color color, {bool bold = false, bool shadow = true}) {
    final key = '$text|${size.toStringAsFixed(1)}|${color.toARGB32()}|$bold|$shadow';
    return _text.putIfAbsent(key, () {
      final tp = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            fontFamily: longKyFontFamily,
            fontSize: size,
            color: color,
            fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
            shadows: shadow
                ? const [
                    Shadow(color: LongKyColors.lacquer, blurRadius: 4),
                    Shadow(color: LongKyColors.lacquer, blurRadius: 2),
                  ]
                : null,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      return tp;
    });
  }
}
