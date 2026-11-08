import 'package:flutter/widgets.dart';

import 'package:wayback_design_system/src/foundations/app_motion.dart';

/// Crossfades [child] when [state] changes: loading, content, empty, error.
///
/// Only a new [state] starts the fade, so fresh data inside the same state —
/// a GPS fix, a compass reading — rebuilds [child] in place. Without a
/// [state] the child's type is the state: a loading view, a content view and
/// an error view are different widgets anyway. The old child
/// fades out over the first 40% with [WbMotion.accelerate]; the new one
/// fades in with [WbMotion.easeOut] from [fadeInStart].
///
/// By default the switcher fills its constraints, like a screen body.
/// With [animateSize] it hugs its child, top-aligned, and grows or shrinks
/// to the new one with [WbMotion.standard] instead of jumping.
class WbStateSwitcher extends StatelessWidget {
  const WbStateSwitcher({
    required this.child,
    this.state,
    this.duration = WbMotion.base,
    this.fadeInStart = overlapStart,
    this.scaleFrom = 1,
    this.animateSize = false,
    super.key,
  });

  /// Where the new child starts to fade in when the two may overlap.
  static const double overlapStart = 60 / 220;

  /// Where the new child starts when the old one must be gone first.
  static const double fadeThroughStart = _fadeOutEnd;

  static const double _fadeOutEnd = .4;

  /// A [scaleFrom] for a view that arrives as a moment, like the compass
  /// once the direction is known or the arrival mark.
  static const double growFrom = .95;

  /// What the content is now; the kind of state, not its data.
  final Object? state;
  final Widget child;
  final Duration duration;
  final double fadeInStart;

  /// The scale the new child grows from as it fades in.
  final double scaleFrom;
  final bool animateSize;

  @override
  Widget build(BuildContext context) {
    final time = WbMotion.of(context, duration);
    final switcher = AnimatedSwitcher(
      duration: time,
      switchInCurve: Interval(fadeInStart, 1, curve: WbMotion.easeOut),
      // The old child runs backwards, so its curve is flipped.
      switchOutCurve: const Interval(
        1 - _fadeOutEnd,
        1,
        curve: FlippedCurve(WbMotion.accelerate),
      ),
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: scaleFrom == 1
            ? child
            : ScaleTransition(
                scale: animation.drive(Tween(begin: scaleFrom, end: 1)),
                child: child,
              ),
      ),
      layoutBuilder: (current, previous) => Stack(
        alignment: animateSize
            ? AlignmentDirectional.topStart
            : AlignmentDirectional.center,
        fit: animateSize ? StackFit.loose : StackFit.expand,
        children: [...previous, ?current],
      ),
      child: KeyedSubtree(
        key: ValueKey(state ?? child.runtimeType),
        child: child,
      ),
    );
    if (!animateSize) return switcher;
    return AnimatedSize(
      duration: time,
      curve: WbMotion.standard,
      alignment: AlignmentDirectional.topStart,
      child: switcher,
    );
  }
}
