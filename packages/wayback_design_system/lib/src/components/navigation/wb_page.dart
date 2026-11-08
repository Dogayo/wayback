import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:wayback_design_system/src/foundations/app_motion.dart';
import 'package:wayback_design_system/src/theme/app_theme_extensions.dart';

/// How a screen comes in (05 · Motion, «Переходы экранов»).
enum WbTransition {
  /// Deeper into the app: a 30 dp shift and a fade. iOS keeps Cupertino.
  drill,

  /// A task on top of the current screen: slides up over it.
  modal,

  /// Into a mode such as navigation: grows from 0.92 and fades in.
  /// iOS keeps Cupertino.
  enterMode,

  /// Another part of the app: the old screen fades out, then the new one in.
  fade,
}

/// A [Page] with Wayback's screen transitions.
///
/// The screen that comes in also decides what the screen under it does, so
/// a modal leaves the screen below in place while a drill pushes it aside.
class WbPage<T> extends Page<T> {
  const WbPage({
    required this.child,
    this.transition = WbTransition.drill,
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
  });

  final Widget child;
  final WbTransition transition;

  @override
  Route<T> createRoute(BuildContext context) => _WbPageRoute<T>(this);
}

/// Shift of a drill transition.
const double _drillShift = 30;

/// Dimming of the screen under a modal: the scrim token at this opacity is
/// about 8% black.
const double _modalScrim = .16;

/// Share of the transition the old screen takes to fade out.
const double _drillOut = 110 / 320;
const double _fadeOut = 120 / 320;

/// Where the new screen starts to fade in.
const double _enterModeIn = 80 / 320;

const double _enterModeScale = .92;
const double _fadeScale = .96;

class _WbPageRoute<T> extends PageRoute<T> {
  _WbPageRoute(WbPage<T> page)
    : super(
        settings: page,
        fullscreenDialog: page.transition == WbTransition.modal,
      );

  WbPage<T> get _page => settings as WbPage<T>;

  bool get _cupertino {
    if (_page.transition case WbTransition.modal || WbTransition.fade) {
      return false;
    }
    return switch (Theme.of(navigator!.context).platform) {
      TargetPlatform.iOS || TargetPlatform.macOS => true,
      _ => false,
    };
  }

  @override
  Duration get transitionDuration => WbMotion.of(
    navigator!.context,
    _cupertino ? const Duration(milliseconds: 500) : WbMotion.slow,
  );

  @override
  Duration get reverseTransitionDuration => WbMotion.of(
    navigator!.context,
    _cupertino ? const Duration(milliseconds: 500) : WbMotion.slowExit,
  );

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  bool canTransitionTo(TransitionRoute<dynamic> nextRoute) =>
      nextRoute is _WbPageRoute;

  @override
  bool canTransitionFrom(TransitionRoute<dynamic> previousRoute) =>
      previousRoute is _WbPageRoute;

  @override
  DelegatedTransitionBuilder? get delegatedTransition =>
      _cupertino ? CupertinoPageTransition.delegatedTransition : _below;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) => Semantics(
    scopesRoute: true,
    explicitChildNodes: true,
    child: _page.child,
  );

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (_cupertino) {
      return CupertinoRouteTransitionMixin.buildPageTransitions(
        this,
        context,
        animation,
        secondaryAnimation,
        child,
      );
    }
    // The screen under this one gets [_below]; [secondaryAnimation] is not
    // used here.
    return switch (_page.transition) {
      WbTransition.drill => _Shift(
        animation: _curved(animation),
        child: FadeTransition(
          opacity: _curved(animation, start: _drillOut),
          child: child,
        ),
      ),
      WbTransition.modal => SlideTransition(
        position: _curved(
          animation,
        ).drive(Tween(begin: const Offset(0, 1), end: Offset.zero)),
        child: child,
      ),
      WbTransition.enterMode => FadeTransition(
        opacity: _curved(animation, start: _enterModeIn),
        child: ScaleTransition(
          scale: _curved(
            animation,
          ).drive(Tween(begin: _enterModeScale, end: 1)),
          child: child,
        ),
      ),
      WbTransition.fade => FadeTransition(
        opacity: _curved(animation, start: _fadeOut),
        child: ScaleTransition(
          scale: _curved(
            animation,
            start: _fadeOut,
          ).drive(Tween(begin: _fadeScale, end: 1)),
          child: child,
        ),
      ),
    };
  }

  /// What the screen under this one does while this one comes and goes.
  Widget? _below(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    bool allowSnapshotting,
    Widget? child,
  ) {
    final colors = context.wbColors;
    return switch (_page.transition) {
      WbTransition.drill => _Shift(
        animation: _curved(secondaryAnimation),
        outgoing: true,
        child: _Veil(
          animation: _leaving(secondaryAnimation, end: _drillOut),
          color: colors.surfaceDefault,
          child: child,
        ),
      ),
      WbTransition.modal => _Veil(
        animation: _curved(secondaryAnimation),
        color: colors.scrim,
        opacity: _modalScrim,
        child: child,
      ),
      WbTransition.enterMode => _Veil(
        animation: _leaving(secondaryAnimation, end: _drillOut),
        color: colors.surfaceDefault,
        child: child,
      ),
      WbTransition.fade => _Veil(
        animation: _leaving(secondaryAnimation, end: _fadeOut),
        color: colors.surfaceDefault,
        child: child,
      ),
    };
  }
}

/// Eases out on the way in and accelerates on the way out, within
/// [start]–[end] of the transition.
///
/// Unlike [CurvedAnimation] it keeps no listeners of its own, so building
/// it inside a transition leaks nothing.
Animation<double> _curved(
  Animation<double> parent, {
  double start = 0,
  double end = 1,
}) => _Eased(
  parent,
  Interval(start, end, curve: WbMotion.easeOut),
  Interval(start, end, curve: WbMotion.accelerate.flipped),
);

/// The veil over the screen below: that screen leaves as the animation runs
/// forward, so it accelerates then and eases out when it comes back.
Animation<double> _leaving(Animation<double> parent, {required double end}) =>
    _Eased(
      parent,
      Interval(0, end, curve: WbMotion.accelerate),
      Interval(0, end, curve: WbMotion.easeOut.flipped),
    );

class _Eased extends Animation<double> with AnimationWithParentMixin<double> {
  _Eased(this.parent, this.forward, this.reverse);

  @override
  final Animation<double> parent;
  final Curve forward;
  final Curve reverse;

  @override
  double get value =>
      (parent.status == AnimationStatus.reverse ? reverse : forward).transform(
        parent.value,
      );
}

/// Moves [child] by [_drillShift] along the reading direction: in from the
/// end, or out towards the start when [outgoing].
class _Shift extends AnimatedWidget {
  const _Shift({
    required Animation<double> animation,
    required this.child,
    this.outgoing = false,
  }) : super(listenable: animation);

  final Widget child;
  final bool outgoing;

  @override
  Widget build(BuildContext context) {
    final value = (listenable as Animation<double>).value;
    final sign = Directionality.of(context) == TextDirection.rtl ? -1 : 1;
    final dx = outgoing ? -_drillShift * value : _drillShift * (1 - value);
    return Transform.translate(offset: Offset(dx * sign, 0), child: child);
  }
}

/// Covers [child] with [color], up to [opacity], as [animation] runs.
///
/// The screen under a transition fades into the surface instead of into
/// nothing, so no black shows through between the two screens.
class _Veil extends StatelessWidget {
  const _Veil({
    required this.animation,
    required this.color,
    required this.child,
    this.opacity = 1,
  });

  final Animation<double> animation;
  final Color color;
  final double opacity;
  final Widget? child;

  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.passthrough,
    children: [
      ?child,
      Positioned.fill(
        child: IgnorePointer(
          child: FadeTransition(
            opacity: animation.drive(Tween(begin: 0, end: opacity)),
            child: ColoredBox(color: color),
          ),
        ),
      ),
    ],
  );
}
