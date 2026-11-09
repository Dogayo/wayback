import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:wayback_design_system/src/foundations/app_motion.dart';
import 'package:wayback_design_system/src/theme/app_theme_extensions.dart';

const double _dialSize = 320;

/// Base dial geometry, for a dial of [_dialSize]; everything scales with it.
const double _discRadius = 158;
const double _ringRadius = 152;
const double _ringWidth = 2;
const double _beamRadius = 150;
const double _beamArcWidth = 9;
const double _beamOpacity = .4;
const double _arrowRadius = 112;
const double _tickTop = 4;
const double _tickBottom = 22;
const double _tickWidth = 4;
const double _searchingHalfArc = 40;

enum WbDirectionTone { ok, unreliable }

/// Direction to the target: a faceted arrow inside a beam whose width shows
/// how far the direction can be trusted (DESIGN_SYSTEM.md "Навигация").
///
/// [rotation] is the arrow angle in degrees, not wrapped, so it animates
/// along the shortest arc. [spread] is the half-width of the beam in degrees,
/// kept between [minSpread] and [maxSpread].
class WbDirectionDial extends StatelessWidget {
  const WbDirectionDial({
    required this.rotation,
    required this.semanticLabel,
    this.spread = maxSpread,
    this.tone = WbDirectionTone.ok,
    this.size = _dialSize,
    super.key,
  });

  static const double minSpread = 10;
  static const double maxSpread = 45;

  final double rotation;
  final String semanticLabel;
  final double spread;
  final WbDirectionTone tone;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.wbColors;
    final dark = context.wbTheme.brightness == Brightness.dark;
    final (lit, shade) = switch (tone) {
      WbDirectionTone.ok => (colors.brand500, colors.actionPrimaryBg),
      WbDirectionTone.unreliable when dark => (
        colors.warning,
        colors.warningBg,
      ),
      WbDirectionTone.unreliable => (colors.warningBg, colors.warning),
    };
    return Semantics(
      liveRegion: true,
      label: semanticLabel,
      child: TweenAnimationBuilder<double>(
        tween: Tween(end: spread.clamp(minSpread, maxSpread)),
        duration: WbMotion.of(context, WbMotion.base),
        curve: WbMotion.standard,
        builder: (context, beam, _) => TweenAnimationBuilder<double>(
          tween: Tween(end: rotation),
          duration: WbMotion.compassSmoothing,
          curve: WbMotion.easeOut,
          builder: (context, angle, _) => CustomPaint(
            size: Size.square(size),
            painter: _BeamPainter(
              disc: colors.surfaceContainer,
              ring: colors.borderDefault,
              tick: colors.contentPrimary,
              lit: lit,
              shade: shade,
              rotation: angle,
              spread: beam,
            ),
          ),
        ),
      ),
    );
  }
}

/// The dial while the direction is not known yet: an arc circling the rim.
class WbDirectionSearching extends StatefulWidget {
  const WbDirectionSearching({this.size = _dialSize, super.key});

  final double size;

  @override
  State<WbDirectionSearching> createState() => _WbDirectionSearchingState();
}

class _WbDirectionSearchingState extends State<WbDirectionSearching>
    with SingleTickerProviderStateMixin {
  late final AnimationController _turn = AnimationController(
    vsync: this,
    duration: WbMotion.shimmer,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _turn.stop();
    } else {
      _turn.repeat();
    }
  }

  @override
  void dispose() {
    _turn.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.wbColors;
    return ExcludeSemantics(
      child: AnimatedBuilder(
        animation: _turn,
        builder: (context, _) => CustomPaint(
          size: Size.square(widget.size),
          painter: _SearchingPainter(
            disc: colors.surfaceContainer,
            ring: colors.borderDefault,
            arc: colors.actionPrimaryBg,
            turn: _turn.value,
          ),
        ),
      ),
    );
  }
}

/// The dial without a direction: [icon] says why, the text beside it explains.
class WbDirectionIcon extends StatelessWidget {
  const WbDirectionIcon(this.icon, {this.size = _dialSize, super.key});

  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.wbColors;
    return ExcludeSemantics(
      child: CustomPaint(
        size: Size.square(size),
        painter: _DiscPainter(
          disc: colors.surfaceContainer,
          ring: colors.borderDefault,
        ),
        child: SizedBox.square(
          dimension: size,
          child: Icon(icon, size: size * .3, color: colors.contentSecondary),
        ),
      ),
    );
  }
}

/// Small one-colour arrow, for the last steps after arrival.
class WbDirectionArrow extends StatelessWidget {
  const WbDirectionArrow({
    required this.rotation,
    required this.color,
    this.size = 32,
    super.key,
  });

  final double rotation;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: TweenAnimationBuilder<double>(
      tween: Tween(end: rotation),
      duration: WbMotion.compassSmoothing,
      curve: WbMotion.easeOut,
      builder: (context, angle, _) => CustomPaint(
        size: Size.square(size),
        painter: _ArrowPainter(color: color, rotation: angle),
      ),
    ),
  );
}

/// Distance as a hero value: the number large, the unit after the last
/// space smaller. The caller gives it a semantic label.
class WbDistanceValue extends StatelessWidget {
  const WbDistanceValue(this.value, {super.key});

  final String value;

  @override
  Widget build(BuildContext context) {
    final split = value.lastIndexOf(RegExp(r'\s'));
    return Text.rich(
      TextSpan(
        style: context.wbText.displayLarge,
        children: [
          TextSpan(text: split < 0 ? value : value.substring(0, split)),
          if (split >= 0)
            TextSpan(
              text: value.substring(split),
              style: context.wbText.displaySmall,
            ),
        ],
      ),
    );
  }
}

/// Colours of the full-screen arrival state: a saturated field in the light
/// theme, a muted one in the dark theme so it does not blind at night.
typedef WbArrivalColors = ({Color background, Color accent, Color content});

extension WbArrivalContext on BuildContext {
  WbArrivalColors get wbArrivalColors {
    final colors = wbColors;
    return wbTheme.brightness == Brightness.dark
        ? (
            background: colors.positiveBg,
            accent: colors.positive,
            content: colors.contentPrimary,
          )
        : (
            background: colors.positive,
            accent: colors.contentOnBrand,
            content: colors.contentOnBrand,
          );
  }
}

/// Check mark of the arrival state; the title beside it carries the meaning.
class WbArrivalMark extends StatelessWidget {
  const WbArrivalMark({this.size = 240, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.wbColors;
    final dark = context.wbTheme.brightness == Brightness.dark;
    return ExcludeSemantics(
      child: CustomPaint(
        size: Size.square(size),
        painter: _CheckPainter(
          disc: dark ? colors.positive : colors.contentOnBrand,
          check: dark ? colors.surfaceDefault : colors.positive,
        ),
      ),
    );
  }
}

double _radians(double degrees) => degrees * math.pi / 180;

void _paintDisc(Canvas canvas, Size size, Color disc, Color ring) {
  final scale = size.width / _dialSize;
  final center = size.center(Offset.zero);
  canvas
    ..drawCircle(center, _discRadius * scale, Paint()..color = disc)
    ..drawCircle(
      center,
      _ringRadius * scale,
      Paint()
        ..color = ring
        ..style = PaintingStyle.stroke
        ..strokeWidth = _ringWidth * scale,
    );
}

/// Fixed mark at the top of the dial: where the phone is facing. It does not
/// turn with the arrow, so lining the two up means walking the right way.
void _paintTick(Canvas canvas, Size size, Color color) {
  final scale = size.width / _dialSize;
  final x = size.width / 2;
  canvas.drawLine(
    Offset(x, _tickTop * scale),
    Offset(x, _tickBottom * scale),
    Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..strokeWidth = _tickWidth * scale,
  );
}

/// Arrow pointing up around the origin, split down its axis into two facets.
void _paintArrow(Canvas canvas, double radius, Color lit, Color shade) {
  final tip = Offset(0, -radius);
  final notch = Offset(0, radius * .3);
  final wing = Offset(radius * .52, radius * .62);
  canvas
    ..drawPath(
      Path()
        ..moveTo(tip.dx, tip.dy)
        ..lineTo(notch.dx, notch.dy)
        ..lineTo(-wing.dx, wing.dy)
        ..close(),
      Paint()..color = lit,
    )
    ..drawPath(
      Path()
        ..moveTo(tip.dx, tip.dy)
        ..lineTo(wing.dx, wing.dy)
        ..lineTo(notch.dx, notch.dy)
        ..close(),
      Paint()..color = shade,
    );
}

class _DiscPainter extends CustomPainter {
  const _DiscPainter({required this.disc, required this.ring});

  final Color disc;
  final Color ring;

  @override
  void paint(Canvas canvas, Size size) => _paintDisc(canvas, size, disc, ring);

  @override
  bool shouldRepaint(covariant _DiscPainter old) =>
      old.disc != disc || old.ring != ring;
}

class _BeamPainter extends CustomPainter {
  const _BeamPainter({
    required this.disc,
    required this.ring,
    required this.tick,
    required this.lit,
    required this.shade,
    required this.rotation,
    required this.spread,
  });

  final Color disc;
  final Color ring;
  final Color tick;
  final Color lit;
  final Color shade;
  final double rotation;
  final double spread;

  @override
  void paint(Canvas canvas, Size size) {
    _paintDisc(canvas, size, disc, ring);
    final scale = size.width / _dialSize;
    _paintTick(canvas, size, tick);
    final start = -math.pi / 2 - _radians(spread);
    final sweep = _radians(spread * 2);
    canvas
      ..save()
      ..translate(size.width / 2, size.height / 2)
      ..rotate(_radians(rotation))
      ..drawArc(
        Rect.fromCircle(center: Offset.zero, radius: _beamRadius * scale),
        start,
        sweep,
        true,
        Paint()..color = lit.withValues(alpha: _beamOpacity),
      )
      ..drawArc(
        Rect.fromCircle(center: Offset.zero, radius: _ringRadius * scale),
        start,
        sweep,
        false,
        Paint()
          ..color = shade
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = _beamArcWidth * scale,
      );
    _paintArrow(canvas, _arrowRadius * scale, lit, shade);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _BeamPainter old) =>
      old.rotation != rotation ||
      old.spread != spread ||
      old.disc != disc ||
      old.ring != ring ||
      old.tick != tick ||
      old.lit != lit ||
      old.shade != shade;
}

class _SearchingPainter extends CustomPainter {
  const _SearchingPainter({
    required this.disc,
    required this.ring,
    required this.arc,
    required this.turn,
  });

  final Color disc;
  final Color ring;
  final Color arc;
  final double turn;

  @override
  void paint(Canvas canvas, Size size) {
    _paintDisc(canvas, size, disc, ring);
    final scale = size.width / _dialSize;
    canvas.drawArc(
      Rect.fromCircle(
        center: size.center(Offset.zero),
        radius: _ringRadius * scale,
      ),
      -math.pi / 2 - _radians(_searchingHalfArc) + turn * 2 * math.pi,
      _radians(_searchingHalfArc * 2),
      false,
      Paint()
        ..color = arc
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = _beamArcWidth * scale,
    );
  }

  @override
  bool shouldRepaint(covariant _SearchingPainter old) =>
      old.turn != turn ||
      old.disc != disc ||
      old.ring != ring ||
      old.arc != arc;
}

class _ArrowPainter extends CustomPainter {
  const _ArrowPainter({required this.color, required this.rotation});

  final Color color;
  final double rotation;

  @override
  void paint(Canvas canvas, Size size) {
    canvas
      ..save()
      ..translate(size.width / 2, size.height / 2)
      ..rotate(_radians(rotation));
    _paintArrow(canvas, size.width / 2, color, color);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ArrowPainter old) =>
      old.color != color || old.rotation != rotation;
}

class _CheckPainter extends CustomPainter {
  const _CheckPainter({required this.disc, required this.check});

  final Color disc;
  final Color check;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.width / 2;
    final center = size.center(Offset.zero);
    final arm = radius * .45;
    canvas
      ..drawCircle(center, radius, Paint()..color = disc)
      ..drawPath(
        Path()
          ..moveTo(center.dx - arm, center.dy + arm * .05)
          ..relativeLineTo(arm * .68, arm * .68)
          ..lineTo(center.dx + arm, center.dy - arm * .62),
        Paint()
          ..color = check
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..strokeWidth = radius / 6,
      );
  }

  @override
  bool shouldRepaint(covariant _CheckPainter old) =>
      old.disc != disc || old.check != check;
}
