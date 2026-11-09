import 'package:flutter/material.dart';

import 'package:wayback_design_system/src/components/inputs/wb_point_type.dart';
import 'package:wayback_design_system/src/foundations/app_motion.dart';

/// Icon of a place type with the short motion of that type, played once
/// (07 · Wave 2 · Review, «Иконки мест в движении»).
///
/// It plays when [active] turns true and, with [playOnAppear], when it first
/// shows up. With animations off the icon is simply in place.
class WbAnimatedPointIcon extends StatefulWidget {
  const WbAnimatedPointIcon(
    this.type, {
    required this.size,
    this.color,
    this.active = false,
    this.playOnAppear = false,
    super.key,
  });

  final WbPointType type;
  final double size;
  final Color? color;
  final bool active;
  final bool playOnAppear;

  @override
  State<WbAnimatedPointIcon> createState() => _WbAnimatedPointIconState();
}

class _WbAnimatedPointIconState extends State<WbAnimatedPointIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _motion = AnimationController(
    vsync: this,
    value: 1,
  );
  var _appeared = false;

  void _play() {
    _motion
      ..duration = WbMotion.of(context, WbMotion.slow)
      ..forward(from: 0);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_appeared) return;
    _appeared = true;
    if (widget.playOnAppear) _play();
  }

  @override
  void didUpdateWidget(WbAnimatedPointIcon old) {
    super.didUpdateWidget(old);
    if (widget.active && !old.active) _play();
  }

  @override
  void dispose() {
    _motion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final script = _scriptOf(widget.type);
    final unit = widget.size / _designSize;
    return AnimatedBuilder(
      animation: _motion,
      child: Icon(widget.type.icon, size: widget.size, color: widget.color),
      builder: (context, icon) {
        final pose = script.at(_motion.value);
        return Transform.translate(
          offset: Offset(pose.dx * unit, pose.dy * unit),
          child: Transform.rotate(
            angle: pose.turn,
            alignment: script.pivot,
            child: Transform.scale(
              scaleX: pose.scaleX,
              scaleY: pose.scaleY,
              alignment: script.pivot,
              child: icon,
            ),
          ),
        );
      },
    );
  }
}

/// Size the poses below are written for.
const double _designSize = 24;

final class _Pose {
  const _Pose({
    this.dx = 0,
    this.dy = 0,
    this.scaleX = 1,
    this.scaleY = 1,
    this.turn = 0,
  });

  /// Same scale in both directions.
  const _Pose.scaled(double scale)
    : dx = 0,
      dy = 0,
      scaleX = scale,
      scaleY = scale,
      turn = 0;

  final double dx;
  final double dy;
  final double scaleX;
  final double scaleY;

  /// Radians.
  final double turn;

  _Pose lerpTo(_Pose end, double t) => _Pose(
    dx: dx + (end.dx - dx) * t,
    dy: dy + (end.dy - dy) * t,
    scaleX: scaleX + (end.scaleX - scaleX) * t,
    scaleY: scaleY + (end.scaleY - scaleY) * t,
    turn: turn + (end.turn - turn) * t,
  );
}

/// Evenly spaced poses; the last is always the resting one.
final class _Script {
  const _Script(this.poses, {this.pivot = Alignment.center});

  final List<_Pose> poses;
  final Alignment pivot;

  _Pose at(double progress) {
    final position = progress * (poses.length - 1);
    final index = position.floor().clamp(0, poses.length - 2);
    return poses[index].lerpTo(poses[index + 1], position - index);
  }
}

const _rest = _Pose();

_Script _scriptOf(WbPointType type) => switch (type) {
  WbPointType.car => const _Script([
    _Pose(dx: -16),
    _Pose(dx: -6),
    _Pose(dx: 3),
    _Pose(dx: -1),
    _rest,
  ]),
  WbPointType.tent => const _Script([
    _Pose(scaleY: .4),
    _Pose(scaleY: .85),
    _Pose(scaleY: 1.12),
    _Pose(scaleY: .97),
    _rest,
  ], pivot: Alignment.bottomCenter),
  WbPointType.fishing => const _Script([
    _Pose(turn: -.38),
    _Pose(turn: .24),
    _Pose(turn: -.14),
    _Pose(turn: .05),
    _rest,
  ], pivot: Alignment.topCenter),
  WbPointType.backpack => const _Script([
    _Pose(dy: -14),
    _Pose(dy: -4),
    _Pose(dy: 3),
    _Pose(dy: -1),
    _rest,
  ]),
  WbPointType.house => const _Script([
    _Pose.scaled(.7),
    _Pose.scaled(.92),
    _Pose.scaled(1.08),
    _Pose.scaled(.98),
    _rest,
  ], pivot: Alignment.bottomCenter),
  WbPointType.meeting => const _Script([
    _rest,
    _Pose(dy: -6),
    _rest,
    _Pose(dy: -3),
    _rest,
  ]),
  WbPointType.parking => const _Script([
    _Pose.scaled(1.5),
    _Pose.scaled(1.15),
    _Pose.scaled(.92),
    _Pose.scaled(1.03),
    _rest,
  ]),
  WbPointType.generic => const _Script([
    _Pose(dy: -18),
    _Pose(dy: -4),
    _Pose(dy: 2),
    _Pose(dy: -3),
    _rest,
  ]),
};
