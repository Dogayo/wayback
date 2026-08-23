import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:wayback_design_system/src/foundations/app_motion.dart';
import 'package:wayback_design_system/src/theme/app_theme_extensions.dart';

enum WbCompassState { ok, unreliable, arrived }

class WbCompassArrow extends StatelessWidget {
  const WbCompassArrow({
    this.rotation = 0,
    this.size = 200,
    this.state = WbCompassState.ok,
    super.key,
  });
  final double rotation;
  final double size;
  final WbCompassState state;

  @override
  Widget build(BuildContext context) {
    final color = switch (state) {
      WbCompassState.ok => context.wbColors.brand600,
      WbCompassState.unreliable => context.wbColors.warning,
      WbCompassState.arrived => context.wbColors.positive,
    };
    final stateLabel = switch (state) {
      WbCompassState.ok => 'Направление определено',
      WbCompassState.unreliable => 'Направление приблизительное',
      WbCompassState.arrived => 'Вы почти у цели',
    };
    return Semantics(
      liveRegion: true,
      label: '$stateLabel, азимут ${rotation.round()} градусов',
      child: SizedBox.square(
        dimension: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              margin: EdgeInsets.all(size * .05),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.wbColors.surfaceElevated,
                border: Border.all(
                  color: context.wbColors.borderSubtle,
                  width: 2,
                ),
              ),
            ),
            for (var i = 0; i < 12; i++)
              Transform.rotate(
                angle: i * math.pi / 6,
                child: Align(
                  alignment: const Alignment(0, -.78),
                  child: Container(
                    width: i % 3 == 0 ? 2 : 1,
                    height: i % 3 == 0 ? 12 : 7,
                    color: i % 3 == 0
                        ? context.wbColors.contentSecondary
                        : context.wbColors.borderDefault,
                  ),
                ),
              ),
            TweenAnimationBuilder<double>(
              tween: Tween(end: rotation),
              duration: WbMotion.compassSmoothing,
              curve: WbMotion.easeOut,
              builder: (context, angle, child) =>
                  Transform.rotate(angle: angle * math.pi / 180, child: child),
              child: CustomPaint(
                size: Size.square(size * .55),
                painter: _ArrowPainter(color),
              ),
            ),
            if (state == WbCompassState.arrived)
              Icon(Icons.check_circle, color: color, size: size * .22),
          ],
        ),
      ),
    );
  }
}

class _ArrowPainter extends CustomPainter {
  const _ArrowPainter(this.color);
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width * .76, size.height * .72)
      ..lineTo(size.width / 2, size.height * .58)
      ..lineTo(size.width * .24, size.height * .72)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
    canvas.drawCircle(
      Offset(size.width / 2, size.height * .61),
      size.width * .07,
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant _ArrowPainter oldDelegate) =>
      oldDelegate.color != color;
}
