import 'dart:math' as math;
import 'dart:ui' show PointMode;

import 'package:flutter/material.dart';

import 'package:wayback_design_system/src/foundations/app_colors.dart';
import 'package:wayback_design_system/src/theme/app_theme_extensions.dart';

/// Pictures for explanatory screens such as onboarding (Penpot
/// «03 · Screens», Onboarding / Step 1–3).
enum WbIllustrationKind {
  /// The brand compass rose.
  compassRose,

  /// A saved spot, a dotted trail away from it and an arrow pointing back.
  trail,

  /// The current location with rings around it.
  location,
}

/// A decorative illustration in a [WbColors.surfaceContainer] circle.
/// It is excluded from semantics: the text next to it carries the meaning.
class WbIllustration extends StatelessWidget {
  const WbIllustration(this.kind, {this.size = 200, super.key});

  final WbIllustrationKind kind;
  final double size;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: CustomPaint(
      size: Size.square(size),
      painter: _IllustrationPainter(kind, context.wbColors),
    ),
  );
}

class _IllustrationPainter extends CustomPainter {
  const _IllustrationPainter(this.kind, this.colors);

  final WbIllustrationKind kind;
  final WbColors colors;

  /// Drawing space of the Penpot boards.
  static const _canvas = 200.0;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / _canvas);
    const center = Offset(_canvas / 2, _canvas / 2);
    canvas.drawCircle(
      center,
      _canvas / 2,
      Paint()..color = colors.surfaceContainer,
    );
    switch (kind) {
      case WbIllustrationKind.compassRose:
        _rose(canvas, center, 108);
      case WbIllustrationKind.trail:
        _trail(canvas);
      case WbIllustrationKind.location:
        _location(canvas, center);
    }
  }

  /// The four-point star of `assets/logo.svg`, each ray split into a solid
  /// and a translucent half like a compass rose.
  void _rose(Canvas canvas, Offset center, double extent) {
    final k = extent / 20;
    Offset at(double x, double y) =>
        center + Offset((x - 12) * k, (y - 12) * k);
    const tips = [(12.0, 2.0), (22.0, 12.0), (12.0, 22.0), (2.0, 12.0)];
    const sides = [(9.5, 9.5), (14.5, 9.5), (14.5, 14.5), (9.5, 14.5)];
    final solid = Paint()..color = colors.brand500;
    final shade = Paint()..color = colors.brand500.withValues(alpha: .72);
    for (var i = 0; i < 4; i++) {
      final tip = at(tips[i].$1, tips[i].$2);
      final left = at(sides[i].$1, sides[i].$2);
      final right = at(sides[(i + 1) % 4].$1, sides[(i + 1) % 4].$2);
      canvas
        ..drawPath(_triangle(center, left, tip), solid)
        ..drawPath(_triangle(center, tip, right), shade);
    }
  }

  void _trail(Canvas canvas) {
    final trail = Path()
      ..moveTo(58, 140)
      ..cubicTo(58, 96, 142, 112, 142, 64);
    final dot = Paint()
      ..color = colors.contentDisabled
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    for (final metric in trail.computeMetrics()) {
      for (var d = 0.0; d < metric.length; d += 12) {
        final p = metric.getTangentForOffset(d)!.position;
        canvas.drawPoints(PointMode.points, [p], dot);
      }
    }
    _spot(canvas, const Offset(58, 140), 14);
    // The arrow at the far end points back along the trail.
    canvas
      ..save()
      ..translate(142, 58)
      ..rotate(228 * math.pi / 180)
      ..drawPath(
        Path()
          ..moveTo(0, -22)
          ..lineTo(15, 16)
          ..lineTo(0, 8)
          ..lineTo(-15, 16)
          ..close(),
        Paint()..color = colors.brand600,
      )
      ..restore();
  }

  void _location(Canvas canvas, Offset center) {
    for (final (radius, alpha) in [(70.0, .25), (46.0, .5)]) {
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = colors.brand500.withValues(alpha: alpha),
      );
    }
    _spot(canvas, center, 22);
  }

  /// A filled dot with a hole in the screen color.
  void _spot(Canvas canvas, Offset at, double radius) => canvas
    ..drawCircle(at, radius, Paint()..color = colors.brand500)
    ..drawCircle(at, radius * .4, Paint()..color = colors.surfaceDefault);

  static Path _triangle(Offset a, Offset b, Offset c) => Path()
    ..moveTo(a.dx, a.dy)
    ..lineTo(b.dx, b.dy)
    ..lineTo(c.dx, c.dy)
    ..close();

  @override
  bool shouldRepaint(covariant _IllustrationPainter oldDelegate) =>
      oldDelegate.kind != kind || oldDelegate.colors != colors;
}
