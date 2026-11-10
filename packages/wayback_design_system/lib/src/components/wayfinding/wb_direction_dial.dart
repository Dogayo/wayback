import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:wayback_design_system/src/components/inputs/wb_animated_point_icon.dart';
import 'package:wayback_design_system/src/components/inputs/wb_point_type.dart';
import 'package:wayback_design_system/src/foundations/app_motion.dart';
import 'package:wayback_design_system/src/foundations/app_typography.dart';
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

/// Direction to the target: a faceted arrow inside a beam whose width shows
/// how far the direction can be trusted (DESIGN_SYSTEM.md "Навигация"). The
/// arrow keeps its colours when the compass is off: the beam and the warning
/// above the dial say so.
///
/// [rotation] is the arrow angle in degrees, not wrapped, so it animates
/// along the shortest arc. [spread] is the half-width of the beam in degrees,
/// kept between [minSpread] and [maxSpread].
class WbDirectionDial extends StatelessWidget {
  const WbDirectionDial({
    required this.rotation,
    required this.semanticLabel,
    this.spread = maxSpread,
    this.size = _dialSize,
    super.key,
  });

  static const double minSpread = 10;
  static const double maxSpread = 45;

  final double rotation;
  final String semanticLabel;
  final double spread;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.wbColors;
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
              lit: colors.brand500,
              shade: colors.actionPrimaryBg,
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

/// The dial finding its direction, played once: an illustration of what the
/// app does. It uses no sensors; with animations off it starts at the end.
class WbDirectionFinding extends StatefulWidget {
  const WbDirectionFinding({this.size = _findingSize, super.key});

  final double size;

  @override
  State<WbDirectionFinding> createState() => _WbDirectionFindingState();
}

class _WbDirectionFindingState extends State<WbDirectionFinding>
    with SingleTickerProviderStateMixin {
  static final _rotation = _segments([-128, -52, 14, 0]);
  static final _spread = _segments([45, 30, 16, WbDirectionDial.minSpread]);

  static Animatable<double> _segments(List<double> values) => TweenSequence([
    for (var i = 0; i < values.length - 1; i++)
      TweenSequenceItem(
        tween: Tween(
          begin: values[i],
          end: values[i + 1],
        ).chain(CurveTween(curve: WbMotion.standard)),
        weight: 1,
      ),
  ]);

  late final AnimationController _progress = AnimationController(vsync: this);
  var _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    _progress
      ..duration = WbMotion.of(context, _findingDuration)
      ..forward();
  }

  @override
  void dispose() {
    _progress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.wbColors;
    return ExcludeSemantics(
      child: AnimatedBuilder(
        animation: _progress,
        builder: (context, _) => CustomPaint(
          size: Size.square(widget.size),
          painter: _BeamPainter(
            disc: colors.surfaceContainer,
            ring: colors.borderDefault,
            tick: colors.contentPrimary,
            lit: colors.brand500,
            shade: colors.actionPrimaryBg,
            rotation: _rotation.evaluate(_progress),
            spread: _spread.evaluate(_progress),
          ),
        ),
      ),
    );
  }
}

const double _findingSize = 240;
const Duration _findingDuration = Duration(milliseconds: 1600);

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
  const WbDistanceValue(
    this.value, {
    this.compact = false,
    this.color,
    super.key,
  });

  final String value;

  /// The smaller size, for a card rather than a whole screen.
  final bool compact;

  /// Text colour on a coloured field, such as arrival.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final split = value.lastIndexOf(RegExp(r'\s'));
    final text = context.wbText;
    return Text.rich(
      TextSpan(
        style: compact
            ? text.displayLarge?.copyWith(
                fontSize: _compactNumber,
                height: 1.1,
                color: color,
              )
            : text.displayLarge?.copyWith(color: color),
        children: [
          TextSpan(
            text: split < 0 ? value : value.substring(0, split),
            style: WbTypography.distanceNumber,
          ),
          if (split >= 0)
            TextSpan(
              text: value.substring(split),
              style: compact
                  ? text.displaySmall?.copyWith(
                      fontSize: _compactUnit,
                      color: color,
                    )
                  : text.displaySmall?.copyWith(color: color),
            ),
        ],
      ),
    );
  }
}

const double _compactNumber = 72;
const double _compactUnit = 28;

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

/// Arrival: the icon of the point in a disc and, while the direction is
/// known, a pointer on the rim, because the last metres are the hardest.
///
/// It comes in once: the disc springs open, the icon plays its own motion and
/// the pointer slides out to the rim. With animations off it is in place.
class WbArrivalDial extends StatefulWidget {
  const WbArrivalDial(
    this.type, {
    this.rotation,
    this.delay = Duration.zero,
    this.size = _arrivalSize,
    super.key,
  });

  final WbPointType type;

  /// Wait before coming in, while the screen around it is still changing.
  final Duration delay;

  /// Pointer angle in degrees, not wrapped; no pointer without it.
  final double? rotation;
  final double size;

  @override
  State<WbArrivalDial> createState() => _WbArrivalDialState();
}

class _WbArrivalDialState extends State<WbArrivalDial>
    with SingleTickerProviderStateMixin {
  static final _disc = Tween<double>(
    begin: _arrivalDiscFrom,
    end: 1,
  ).chain(CurveTween(curve: const Interval(0, .6, curve: Curves.easeOutBack)));
  static final _pointer = CurveTween(
    curve: const Interval(.55, 1, curve: WbMotion.easeOut),
  );

  late final AnimationController _entry = AnimationController(vsync: this);
  Timer? _wait;
  var _scheduled = false;
  var _playing = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_scheduled) return;
    _scheduled = true;
    _entry.duration = WbMotion.of(context, _arrivalDuration);
    final delay = WbMotion.of(context, widget.delay);
    if (delay == Duration.zero) {
      _play();
    } else {
      _wait = Timer(delay, () => setState(_play));
    }
  }

  void _play() {
    _playing = true;
    _entry.forward();
  }

  @override
  void dispose() {
    _wait?.cancel();
    _entry.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.wbColors;
    final dark = context.wbTheme.brightness == Brightness.dark;
    final scale = widget.size / _arrivalSize;
    final disc = _arrivalDiscRadius * 2 * scale;
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: widget.size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            ScaleTransition(
              scale: _disc.animate(_entry),
              child: Container(
                width: disc,
                height: disc,
                alignment: Alignment.center,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: dark ? colors.positive : colors.contentOnBrand,
                  shape: BoxShape.circle,
                ),
                child: WbAnimatedPointIcon(
                  widget.type,
                  size: disc / 2,
                  active: _playing,
                  playOnAppear: _playing,
                  color: dark ? colors.surfaceDefault : colors.positive,
                ),
              ),
            ),
            if (widget.rotation case final rotation?)
              TweenAnimationBuilder<double>(
                tween: Tween(end: rotation),
                duration: WbMotion.compassSmoothing,
                curve: WbMotion.easeOut,
                builder: (context, angle, _) => AnimatedBuilder(
                  animation: _entry,
                  builder: (context, _) => CustomPaint(
                    size: Size.square(widget.size),
                    painter: _RimPointerPainter(
                      color: context.wbArrivalColors.accent,
                      rotation: angle,
                      out: _pointer.evaluate(_entry),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Base arrival geometry, for a dial of [_arrivalSize].
const double _arrivalSize = 304;
const double _arrivalDiscRadius = 104;
const double _arrivalPointerRadius = 136;
const double _arrivalPointerSize = 22;
const double _arrivalDiscFrom = .6;
const Duration _arrivalDuration = Duration(milliseconds: 480);

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

class _RimPointerPainter extends CustomPainter {
  const _RimPointerPainter({
    required this.color,
    required this.rotation,
    required this.out,
  });

  final Color color;
  final double rotation;

  /// 0 hidden at the disc edge, 1 in place on the rim.
  final double out;

  @override
  void paint(Canvas canvas, Size size) {
    if (out == 0) return;
    final scale = size.width / _arrivalSize;
    final radius =
        _arrivalDiscRadius + (_arrivalPointerRadius - _arrivalDiscRadius) * out;
    canvas
      ..save()
      ..translate(size.width / 2, size.height / 2)
      ..rotate(_radians(rotation))
      ..translate(0, -radius * scale);
    _paintArrow(
      canvas,
      _arrivalPointerSize * scale,
      color.withValues(alpha: color.a * out),
      color.withValues(alpha: color.a * out),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _RimPointerPainter old) =>
      old.color != color || old.rotation != rotation || old.out != out;
}
