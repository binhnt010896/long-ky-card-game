import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/animation.dart';
import 'package:flutter/painting.dart';
import 'package:lk_rules/lk_rules.dart';

import '../../../app/theme.dart';
import 'board_animator.dart';
import 'board_art.dart';
import 'board_scene.dart';

/// Draws a [BoardScene]. Painted art (the map, officer and commander
/// portraits) is drawn when it is shipped; everything else, and the stand-in
/// for any art that is missing, is vector placeholder art: lacquer
/// medallions, river and road edges, tokens and intent arrows (build-spec
/// section 6).
final class BoardPainter {
  final Map<String, TextPainter> _text = {};
  BoardArtCache? _art;

  static const Color _smoke = Color(0xFF6B635C);

  Color intentColor(IntentKind k) => switch (k) {
        IntentKind.advance => LongKyColors.ivory,
        IntentKind.assault => const Color(0xFFE5483D),
        IntentKind.forage => LongKyColors.goldLeaf,
        IntentKind.retreat => const Color(0xFF6FA8BC),
        IntentKind.hold => const Color(0xFFB8B0A0),
      };

  /// [animator] holds the effects that are playing: tokens that travel are
  /// drawn on their way, intents are hidden until the step has played out,
  /// and battle, forage and defection marks go on top.
  void paint(Canvas canvas, BoardScene scene, {BoardAnimator? animator, BoardArtCache? art}) {
    _art = art;
    final busy = animator != null && animator.isBusy;
    _paintMapPanel(canvas, scene);
    for (final e in scene.edges) {
      _paintEdge(canvas, e);
    }
    for (final n in scene.nodes) {
      _paintNode(canvas, scene, n);
    }
    for (final t in scene.tokens) {
      _paintToken(canvas, scene, busy ? _travelling(scene, t, animator) : t);
    }
    // Intents go on top: they are what the player must not miss. While the
    // turn plays out they are the next turn's, so they wait.
    if (!busy) {
      for (final a in scene.arrows) {
        _paintArrow(canvas, scene, a);
      }
      for (final b in scene.badges) {
        _paintBadge(canvas, scene, b);
      }
    }
    _paintSelection(canvas, scene);
    if (busy) {
      for (final e in animator.active) {
        _paintEffect(canvas, scene, e);
      }
    }
  }

  /// [t] where the animation has it: still at its start, on its way, or (no
  /// move left to play) where the scene put it.
  TokenView _travelling(BoardScene scene, TokenView t, BoardAnimator animator) {
    final m = animator.moveOf(t.id);
    if (m == null) return t;
    final from = scene.nodes.where((n) => n.id == m.move.from).firstOrNull?.center;
    if (from == null) return t;
    final to = scene.nodes.where((n) => n.id == m.move.to).firstOrNull?.center ?? t.center;
    final eased = Curves.easeInOut.transform(m.progress);
    return TokenView(
      id: t.id,
      kind: t.kind,
      nodeId: t.nodeId,
      center: Offset.lerp(from, to, eased)!,
      radius: t.radius,
      initials: t.initials,
      troops: t.troops,
      isKing: t.isKing,
      artPath: t.artPath,
    );
  }

  // -- Effects -----------------------------------------------------------------

  void _paintEffect(Canvas canvas, BoardScene scene, ActiveEffect a) {
    final e = a.effect;
    final p = a.progress;
    switch (e) {
      case MoveEffect():
        break; // the token itself travels
      case BattleEffect():
        final n = scene.nodes.where((x) => x.id == e.nodeId).firstOrNull;
        if (n == null) return;
        final color = switch (e.winner) {
          Side.daiViet => LongKyColors.goldLeaf,
          Side.yuan => LongKyColors.cinnabar,
          Side.none => LongKyColors.ivory,
        };
        final r = n.radius * (1.1 + 1.4 * p);
        canvas.drawCircle(
          n.center,
          r,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3 * (1 - p) + 1
            ..color = color.withValues(alpha: 1 - p),
        );
        // Crossed blades.
        final k = n.radius * 0.8 * (0.6 + 0.4 * math.sin(math.pi * p));
        final blade = Paint()
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round
          ..color = LongKyColors.ivory.withValues(alpha: 1 - 0.6 * p);
        canvas.drawLine(n.center + Offset(-k, -k), n.center + Offset(k, k), blade);
        canvas.drawLine(n.center + Offset(k, -k), n.center + Offset(-k, k), blade);
      case ForageEffect():
        final n = scene.nodes.where((x) => x.id == e.nodeId).firstOrNull;
        if (n == null) return;
        // A ring drawing in: the army takes the node's stores.
        canvas.drawCircle(
          n.center,
          n.radius * (2.2 - 1.2 * p),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2
            ..color = LongKyColors.goldLeaf.withValues(alpha: 0.2 + 0.8 * p),
        );
      case DefectEffect():
        final n = scene.nodes.where((x) => x.id == e.nodeId).firstOrNull;
        if (n == null) return;
        // A cinnabar flash fading out where the officer turned.
        canvas.drawCircle(n.center, n.radius * (1.0 + 0.8 * p), Paint()..color = LongKyColors.cinnabar.withValues(alpha: 0.55 * (1 - p)));
    }
  }

  // -- Map ---------------------------------------------------------------------

  void _paintMapPanel(Canvas canvas, BoardScene scene) {
    final r = RRect.fromRectAndRadius(scene.layout.mapRect.inflate(6), const Radius.circular(10));
    canvas.drawRRect(r, Paint()..color = LongKyColors.lacquerRaised);
    final map = _art?.image(scene.mapImagePath);
    if (map != null) {
      canvas.save();
      canvas.clipRRect(r);
      _drawCover(canvas, map, scene.layout.mapRect.inflate(6), Paint()..filterQuality = FilterQuality.medium);
      canvas.restore();
    }
    canvas.drawRRect(
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = LongKyColors.goldLeaf.withValues(alpha: 0.35),
    );
  }

  void _paintEdge(Canvas canvas, EdgeView e) {
    if (e.kind == EdgeKind.river) {
      canvas.drawLine(
        e.a,
        e.b,
        Paint()
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round
          ..color = LongKyColors.riverBlue,
      );
      canvas.drawLine(
        e.a,
        e.b,
        Paint()
          ..strokeWidth = 1
          ..color = LongKyColors.goldLeaf.withValues(alpha: 0.7),
      );
    } else {
      _dashedLine(
        canvas,
        e.a,
        e.b,
        Paint()
          ..strokeWidth = 1.8
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
          ..strokeWidth = 1.8
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
        ..strokeWidth = math.max(1.5, n.radius * 0.07)
        ..color = ring,
    );
    if (n.isCapital) {
      canvas.drawCircle(
        n.center,
        n.radius + 4,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
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
      ..strokeWidth = 1.3
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
      ..strokeWidth = 1.4
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

  /// Draws [image] to fill [dst], cropping the overflow (like BoxFit.cover).
  /// The crop favours the upper part of the picture, where a portrait's face is.
  void _drawCover(Canvas canvas, ui.Image image, Rect dst, Paint paint) {
    final iw = image.width.toDouble();
    final ih = image.height.toDouble();
    final scale = math.max(dst.width / iw, dst.height / ih);
    final sw = dst.width / scale;
    final sh = dst.height / scale;
    final top = (ih * 0.38 - sh / 2).clamp(0.0, math.max(0.0, ih - sh)).toDouble();
    final left = (iw - sw) / 2;
    canvas.drawImageRect(image, Rect.fromLTWH(left, top, sw, sh), dst, paint);
  }

  void _paintToken(Canvas canvas, BoardScene scene, TokenView t) {
    final r = t.radius;
    final portrait = _art?.image(t.artPath);
    if (t.kind == TokenKind.officer) {
      canvas.drawCircle(t.center, r, Paint()..color = LongKyColors.lacquerRaised);
      if (portrait != null) {
        canvas.save();
        canvas.clipPath(Path()..addOval(Rect.fromCircle(center: t.center, radius: r - 0.5)));
        _drawCover(canvas, portrait, Rect.fromCircle(center: t.center, radius: r), Paint()..filterQuality = FilterQuality.medium);
        canvas.restore();
      }
      canvas.drawCircle(
        t.center,
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = t.isKing ? 2.2 : 1.4
          ..color = LongKyColors.goldLeaf,
      );
    } else {
      final rect = RRect.fromRectAndRadius(Rect.fromCircle(center: t.center, radius: r), Radius.circular(r * 0.35));
      canvas.drawRRect(rect, Paint()..color = LongKyColors.cinnabar);
      if (portrait != null) {
        canvas.save();
        canvas.clipRRect(rect);
        _drawCover(canvas, portrait, rect.outerRect, Paint()..filterQuality = FilterQuality.medium);
        canvas.restore();
      }
      canvas.drawRRect(
        rect,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4
          ..color = LongKyColors.ivory.withValues(alpha: 0.8),
      );
    }
    // A portrait says who it is; without one, the initials do.
    if (portrait == null) {
      final initials = _label(t.initials, math.max(9.0, r * 0.85), LongKyColors.ivory, bold: true, shadow: false);
      initials.paint(canvas, t.center - Offset(initials.width / 2, initials.height / 2));
    }

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
      ..strokeWidth = a.intent == IntentKind.assault ? 3.5 : 2.5
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
      ..strokeWidth = 1.4
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
      ..strokeWidth = 1.6
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
        ..strokeWidth = 2
        ..color = LongKyColors.ivory,
    );
    canvas.drawCircle(
      c,
      radius + 3,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
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
