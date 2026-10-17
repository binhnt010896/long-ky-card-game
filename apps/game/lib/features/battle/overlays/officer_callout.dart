import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lk_rules/lk_rules.dart';

import '../../../app/l10n/app_localizations.dart';
import '../../../app/theme.dart';
import '../../../art/art_image.dart';
import '../../../art/art_library.dart';
import '../labels.dart';

/// Why an officer is shown: the king's shout when the turn is resolved, or
/// an officer using an activated skill.
enum CalloutKind { charge, skill }

/// An officer to put in the spotlight for a moment.
final class Callout {
  const Callout(this.officerId, this.kind);

  final String officerId;
  final CalloutKind kind;
}

/// The callout for the events of one step, or null: the king when the turn is
/// resolved (Orders → Resolution), an officer when they use a skill. Nothing
/// when the mission ends in that step: the ending is what the player sees.
Callout? calloutFor(Ruleset ruleset, GameState state, Iterable<GameEvent> events) {
  if (events.any((e) => e is MissionEnded || e is FreePlayEnded)) return null;
  for (final e in events) {
    if (e is SkillUsed) return Callout(e.officerId, CalloutKind.skill);
  }
  if (events.any((e) => e is PhaseChanged && e.phase == Phase.resolution)) {
    for (final entry in ruleset.officers.entries) {
      final o = state.officers[entry.key];
      if (entry.value.isKing && o != null && o.status == OfficerStatus.active) {
        return Callout(entry.key, CalloutKind.charge);
      }
    }
  }
  return null;
}

/// The officer's "charge" painting (pointing forward, shouting), else their
/// card painting, as an art id.
String officerCalloutArt(ArtLibrary library, OfficerDef officer) {
  final charge = 'officers/${officer.id}/charge.jpg';
  return library.has(charge) ? charge : (officer.cardArt ?? charge);
}

/// The officer's painting sweeps in under a burst of rays, with their name and
/// the caption. Takes no taps; the board under it stays usable.
class OfficerCallout extends StatefulWidget {
  const OfficerCallout({super.key, required this.officer, required this.kind, required this.ruleset, required this.onDone});

  final OfficerDef officer;
  final CalloutKind kind;
  final Ruleset ruleset;
  final VoidCallback onDone;

  static const Duration length = Duration(milliseconds: 3200);

  @override
  State<OfficerCallout> createState() => _OfficerCalloutState();
}

class _OfficerCalloutState extends State<OfficerCallout> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: OfficerCallout.length)
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
    final officer = widget.officer;
    final caption = widget.kind == CalloutKind.skill && officer.skill != null
        ? l.content(officer.skill!.name)
        : l.calloutCharge;
    final art = officerCalloutArt(ArtImage.libraryOf(context), officer);
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          final t = _c.value;
          final fade = Curves.easeOut.transform((t / 0.1).clamp(0.0, 1.0)) *
              (1 - Curves.easeIn.transform(((t - 0.88) / 0.12).clamp(0.0, 1.0)));
          final slide = Curves.easeOutBack.transform((t / 0.22).clamp(0.0, 1.0));
          final words = Curves.easeOutCubic.transform(((t - 0.18) / 0.25).clamp(0.0, 1.0));
          // A small shake as the shout lands.
          final shake = t > 0.2 && t < 0.4 ? math.sin(t * 120) * 3 * (0.4 - t) / 0.2 : 0.0;
          return Opacity(
            key: const Key('officer-callout'),
            opacity: fade,
            child: Stack(
              fit: StackFit.expand,
              children: [
                const ColoredBox(color: Color(0xE60E0B0A)),
                CustomPaint(painter: _RaysPainter(t, widget.kind == CalloutKind.charge)),
                LayoutBuilder(
                  builder: (context, c) {
                    final h = c.maxHeight * 0.94;
                    final w = h * 2 / 3;
                    return Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Transform.translate(
                            offset: Offset((slide - 1) * 120 + shake, 0),
                            child: Container(
                              width: w,
                              height: h,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: LongKyColors.goldLeaf, width: 2),
                                boxShadow: const [BoxShadow(color: Color(0x88C9A24A), blurRadius: 28)],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: ArtImage(path: art, name: l.content(officer.name), icon: Icons.person),
                              ),
                            ),
                          ),
                          const SizedBox(width: 28),
                          Opacity(
                            opacity: words,
                            child: Transform.translate(
                              offset: Offset((1 - words) * 80, 0),
                              child: ConstrainedBox(
                                constraints: BoxConstraints(maxWidth: math.max(160, math.min(380, c.maxWidth - w - 80))),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (officer.title != null)
                                      Text(
                                        l.content(officer.title!).toUpperCase(),
                                        style: const TextStyle(
                                          color: Color(0xFFE88A80),
                                          fontSize: 13,
                                          letterSpacing: 2,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    Text(
                                      l.content(officer.name),
                                      key: const Key('callout-name'),
                                      style: const TextStyle(
                                        color: LongKyColors.ivory,
                                        fontSize: 26,
                                        fontWeight: FontWeight.w700,
                                        shadows: [Shadow(color: Colors.black, blurRadius: 8)],
                                      ),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.symmetric(vertical: 8),
                                      height: 2,
                                      width: 140 * words,
                                      color: LongKyColors.goldLeaf,
                                    ),
                                    Text(
                                      caption,
                                      key: const Key('callout-caption'),
                                      style: const TextStyle(
                                        color: LongKyColors.goldLeaf,
                                        fontSize: 36,
                                        height: 1.05,
                                        fontWeight: FontWeight.w800,
                                        shadows: [Shadow(color: Colors.black, blurRadius: 10)],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
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

/// Rays bursting out from behind the officer.
class _RaysPainter extends CustomPainter {
  _RaysPainter(this.t, this.warm);

  final double t;
  final bool warm;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.3, size.height * 0.5);
    final reach = size.longestSide;
    final grow = Curves.easeOut.transform((t / 0.3).clamp(0.0, 1.0));
    const rays = 18;
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          (warm ? const Color(0xFFB3261E) : const Color(0xFF2E5E6E)).withValues(alpha: 0.55),
          const Color(0x00000000),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: reach));
    for (var i = 0; i < rays; i += 2) {
      final a0 = (i / rays) * 2 * math.pi + t * 0.5;
      final a1 = ((i + 1) / rays) * 2 * math.pi + t * 0.5;
      final path = Path()
        ..moveTo(center.dx, center.dy)
        ..lineTo(center.dx + math.cos(a0) * reach * grow, center.dy + math.sin(a0) * reach * grow)
        ..lineTo(center.dx + math.cos(a1) * reach * grow, center.dy + math.sin(a1) * reach * grow)
        ..close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_RaysPainter old) => old.t != t;
}
