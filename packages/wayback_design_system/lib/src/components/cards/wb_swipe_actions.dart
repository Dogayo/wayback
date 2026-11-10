import 'package:flutter/material.dart';

import 'package:wayback_design_system/src/foundations/app_haptics.dart';
import 'package:wayback_design_system/src/foundations/app_motion.dart';
import 'package:wayback_design_system/src/foundations/app_radius.dart';
import 'package:wayback_design_system/src/foundations/app_spacing.dart';
import 'package:wayback_design_system/src/theme/app_theme_extensions.dart';

/// One button of a [WbSwipeActions] panel.
class WbSwipeAction {
  const WbSwipeAction({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.destructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool destructive;
}

const double _actionWidth = 88;

/// Share of the panel past which a released row stays open.
const double _openAt = .4;

/// How fast, in dp/s, a release counts as a flick whatever the distance.
const double _flick = 700;

/// A row that slides towards the start to show [actions] behind it.
///
/// One row is open at a time; scrolling, or a tap anywhere else, closes it.
/// Nothing runs by swiping alone, so a stray gesture changes nothing. A
/// swipe is invisible to a screen reader: offer the same actions some other
/// way, such as on a long press.
class WbSwipeActions extends StatefulWidget {
  const WbSwipeActions({required this.actions, required this.child, super.key});

  final List<WbSwipeAction> actions;
  final Widget child;

  @override
  State<WbSwipeActions> createState() => _WbSwipeActionsState();
}

class _WbSwipeActionsState extends State<WbSwipeActions>
    with SingleTickerProviderStateMixin {
  static _WbSwipeActionsState? _open;

  late final AnimationController _reveal = AnimationController(vsync: this);
  ScrollPosition? _scroll;

  double get _panelWidth => widget.actions.length * _actionWidth;

  /// Movement along the reading direction: towards the end is positive.
  double get _direction =>
      Directionality.of(context) == TextDirection.rtl ? -1 : 1;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final position = Scrollable.maybeOf(context)?.position;
    if (identical(position, _scroll)) return;
    _scroll?.isScrollingNotifier.removeListener(_onScroll);
    _scroll = position?..isScrollingNotifier.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scroll!.isScrollingNotifier.value) _settle(open: false);
  }

  void _settle({required bool open}) {
    if (open) {
      if (!identical(_open, this)) WbHaptics.play(context, WbHaptic.tick);
      _open = this;
    } else if (identical(_open, this)) {
      _open = null;
    }
    _reveal.animateTo(
      open ? 1 : 0,
      duration: WbMotion.of(context, WbMotion.base),
      curve: WbMotion.standard,
    );
  }

  void _onDragStart(DragStartDetails details) {
    if (!identical(_open, this)) _open?._settle(open: false);
  }

  void _onDragUpdate(DragUpdateDetails details) =>
      _reveal.value -= details.primaryDelta! * _direction / _panelWidth;

  void _onDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity! * _direction;
    _settle(
      open: switch (velocity) {
        < -_flick => true,
        > _flick => false,
        _ => _reveal.value >= _openAt,
      },
    );
  }

  void _close() => _settle(open: false);

  @override
  void dispose() {
    if (identical(_open, this)) _open = null;
    _scroll?.isScrollingNotifier.removeListener(_onScroll);
    _reveal.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final surface = Material(
      color: context.wbColors.surfaceDefault,
      child: widget.child,
    );
    return GestureDetector(
      onHorizontalDragStart: _onDragStart,
      onHorizontalDragUpdate: _onDragUpdate,
      onHorizontalDragEnd: _onDragEnd,
      child: AnimatedBuilder(
        animation: _reveal,
        child: surface,
        builder: (context, row) {
          final shown = _reveal.value > 0;
          return TapRegion(
            enabled: shown,
            onTapOutside: (_) => _close(),
            child: Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                if (shown)
                  Positioned.fill(
                    child: Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: SizedBox(
                        width: _panelWidth,
                        child: _Panel(
                          actions: widget.actions,
                          onPressed: _close,
                        ),
                      ),
                    ),
                  ),
                Transform.translate(
                  offset: Offset(-_panelWidth * _reveal.value * _direction, 0),
                  // While open, a tap on the row closes it and goes no further.
                  child: GestureDetector(
                    onTap: shown ? _close : null,
                    child: AbsorbPointer(absorbing: shown, child: row),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.actions, required this.onPressed});

  final List<WbSwipeAction> actions;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.wbColors;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final action in actions)
          Expanded(
            child: _Button(
              action: action,
              // White on the dark theme's light red is too faint to read.
              background: action.destructive
                  ? (dark ? colors.negativeBg : colors.negative)
                  : (dark ? colors.surfaceElevated : colors.surfaceSunken),
              foreground: action.destructive
                  ? (dark ? colors.negative : colors.actionPrimaryFg)
                  : colors.contentPrimary,
              onPressed: () {
                onPressed();
                action.onPressed();
              },
            ),
          ),
      ],
    );
  }
}

class _Button extends StatelessWidget {
  const _Button({
    required this.action,
    required this.background,
    required this.foreground,
    required this.onPressed,
  });

  final WbSwipeAction action;
  final Color background;
  final Color foreground;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Material(
    color: background,
    child: InkWell(
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: WbSpacing.xxs),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: WbSpacing.xxs,
          children: [
            Icon(action.icon, size: WbIconSize.lg, color: foreground),
            // A long label shrinks to the button instead of being cut off.
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                action.label,
                maxLines: 1,
                style: context.wbText.bodySmall?.copyWith(
                  color: foreground,
                  fontSize: 11,
                  letterSpacing: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
