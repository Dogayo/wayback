import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'package:wayback_design_system/src/foundations/app_haptics.dart';
import 'package:wayback_design_system/src/foundations/app_motion.dart';
import 'package:wayback_design_system/src/theme/app_theme_extensions.dart';

const double _ringSize = 32;
const double _ringStroke = 3;

/// Long enough never to run out: the countdown closes the snackbar.
const Duration _untilClosed = Duration(days: 1);

/// Time left to undo something already done; it stops while the app is in
/// the background.
///
/// It lives outside the snackbar's widgets because during a route change
/// the snackbar is built on both screens, and each would start over.
final class _Countdown extends ChangeNotifier {
  _Countdown({required this.window, required this.onExpired}) {
    _ticker = Ticker(_onTick)..start();
    _lifecycle = AppLifecycleListener(onHide: _pause, onShow: _resume);
  }

  final Duration window;
  final VoidCallback onExpired;
  late final Ticker _ticker;
  late final AppLifecycleListener _lifecycle;
  late final seconds = ValueNotifier(window.inSeconds);
  Duration _spent = Duration.zero;
  Duration _spentBefore = Duration.zero;

  double get left => 1 - _spent.inMicroseconds / window.inMicroseconds;

  void _onTick(Duration elapsed) {
    _spent = _spentBefore + elapsed;
    if (_spent >= window) {
      _ticker.stop();
      onExpired();
      return;
    }
    seconds.value = (window - _spent).inSeconds + 1;
    notifyListeners();
  }

  void _pause() {
    if (!_ticker.isActive) return;
    _spentBefore = _spent;
    _ticker.stop();
  }

  void _resume() {
    if (_spent < window && !_ticker.isActive) _ticker.start();
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    _ticker.dispose();
    seconds.dispose();
    super.dispose();
  }
}

/// Says something was done and offers to take it back while a ring runs out.
abstract final class WbUndoSnackbar {
  /// Shows [message], replacing the current snackbar.
  ///
  /// With a screen reader there is no countdown, since [window] is too short
  /// to hear the message and reach the button: the snackbar stays until it
  /// is answered or replaced.
  static void show(
    BuildContext context, {
    required String message,
    required String actionLabel,
    required VoidCallback onUndo,
    Duration window = WbMotion.undoWindow,
  }) {
    final haptics = WbHaptics.playerOf(context);
    final timed = !MediaQuery.accessibleNavigationOf(context);
    final messenger = ScaffoldMessenger.of(context)..hideCurrentSnackBar();
    late final ScaffoldFeatureController<SnackBar, SnackBarClosedReason> shown;
    final countdown = timed
        ? _Countdown(window: window, onExpired: () => shown.close())
        : null;
    shown = messenger.showSnackBar(
      SnackBar(
        duration: _untilClosed,
        showCloseIcon: !timed,
        content: _Content(message: message, countdown: countdown),
        action: SnackBarAction(
          label: actionLabel,
          onPressed: () {
            haptics?.call(WbHaptic.tick);
            onUndo();
          },
        ),
      ),
    );
    unawaited(shown.closed.whenComplete(() => countdown?.dispose()));
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.message, required this.countdown});

  final String message;
  final _Countdown? countdown;

  @override
  Widget build(BuildContext context) {
    final text = Text(message, maxLines: 2, overflow: TextOverflow.ellipsis);
    final timer = countdown;
    if (timer == null) return text;
    return Row(
      spacing: 12,
      children: [
        ExcludeSemantics(child: _Ring(timer)),
        Expanded(child: text),
      ],
    );
  }
}

class _Ring extends StatelessWidget {
  const _Ring(this.countdown);

  final _Countdown countdown;

  @override
  Widget build(BuildContext context) {
    final colors = context.wbColors;
    final still = MediaQuery.disableAnimationsOf(context);
    return SizedBox.square(
      dimension: _ringSize,
      child: CustomPaint(
        painter: still
            ? null
            : _RingPainter(
                countdown,
                track: colors.borderSubtle,
                arc: colors.actionPrimaryBg,
              ),
        child: Center(
          // A count in a fixed ring must not grow out of it with large text.
          child: MediaQuery.withNoTextScaling(
            child: ValueListenableBuilder(
              valueListenable: countdown.seconds,
              builder: (context, seconds, _) => AnimatedSwitcher(
                duration: WbMotion.of(context, WbMotion.instant),
                child: Text(
                  '$seconds',
                  key: ValueKey(seconds),
                  style: context.wbText.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colors.contentPrimary,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.countdown, {required this.track, required this.arc})
    : super(repaint: countdown);

  final _Countdown countdown;
  final Color track;
  final Color arc;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(_ringStroke);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _ringStroke
      ..strokeCap = StrokeCap.round;
    canvas
      ..drawOval(rect, paint..color = track)
      ..drawArc(
        rect,
        -math.pi / 2,
        2 * math.pi * countdown.left,
        false,
        paint..color = arc,
      );
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.countdown != countdown ||
      oldDelegate.track != track ||
      oldDelegate.arc != arc;
}
