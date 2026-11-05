import 'package:flutter/material.dart';
import 'package:wayback/app/localization/distance_l10n.dart';
import 'package:wayback/app/localization/error_l10n.dart';
import 'package:wayback/app/localization/localization.dart';
import 'package:wayback/app/settings/settings_scope.dart';
import 'package:wayback/features/navigation/domain/entities/navigation_guidance.dart';
import 'package:wayback/features/navigation/domain/repositories/compass_repository.dart';
import 'package:wayback_design_system/wayback_design_system.dart';

/// Arrow and distance dominate; accuracy and warnings stay secondary
/// (SCREENS.md §4.5).
class NavigationView extends StatelessWidget {
  const NavigationView(this.guidance, {super.key});

  final NavigationGuidance guidance;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final g = guidance;
    final distance = l10n.distance(
      g.distanceMeters,
      units: context.settings.units,
    );
    return Padding(
      padding: const EdgeInsets.all(WbSpacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: WbSpacing.md,
        children: [
          ..._alerts(context),
          // Scales down instead of overflowing: landscape, large text and
          // several warnings at once all leave less room for the arrow.
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                spacing: WbSpacing.lg,
                children: [
                  if (g.arrived) const _Arrived(),
                  switch (g.arrowDegrees) {
                    final degrees? => WbCompassArrow(
                      rotation: degrees,
                      state: g.arrived
                          ? WbCompassState.arrived
                          : g.compass == CompassStatus.unreliable
                          ? WbCompassState.unreliable
                          : WbCompassState.ok,
                    ),
                    null => Icon(
                      Icons.explore_off_outlined,
                      size: WbIconSize.xxl,
                      color: context.wbColors.contentTertiary,
                    ),
                  },
                  Semantics(
                    label: l10n.navigateSemantics(g.point.name, distance),
                    excludeSemantics: true,
                    child: Text(distance, style: context.wbText.displayLarge),
                  ),
                  _Accuracy(g),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _alerts(BuildContext context) {
    final l10n = context.l10n;
    return [
      if (guidance.compass == CompassStatus.unavailable)
        WbAlert(
          title: l10n.error(NavigationErrorCodes.compassUnavailable).title,
          message: l10n.error(NavigationErrorCodes.compassUnavailable).body,
          tone: WbTone.negative,
        ),
      if (guidance.compass == CompassStatus.unreliable)
        WbAlert(
          title: l10n.navigateCompassCalibrationTitle,
          message: l10n.navigateCompassCalibrationBody,
          tone: WbTone.warning,
        ),
      if (guidance.weakSignal)
        WbAlert(
          title: l10n.navigateWeakSignalTitle,
          message: l10n.navigateWeakSignalBody,
          tone: WbTone.warning,
        ),
    ];
  }
}

class _Arrived extends StatelessWidget {
  const _Arrived();

  @override
  Widget build(BuildContext context) {
    final color = context.wbColors.positive;
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: WbSpacing.xs,
      children: [
        Icon(Icons.check_circle_outline, color: color),
        Text(
          context.l10n.navigateArrived,
          style: context.wbText.headlineSmall?.copyWith(color: color),
        ),
      ],
    );
  }
}

class _Accuracy extends StatelessWidget {
  const _Accuracy(this.guidance);

  final NavigationGuidance guidance;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final color = guidance.weakSignal
        ? context.wbColors.warning
        : context.wbColors.contentSecondary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: WbSpacing.xs,
      children: [
        Icon(Icons.my_location, size: WbIconSize.sm, color: color),
        Text(
          l10n.accuracy(guidance.accuracyMeters, units: context.settings.units),
          style: context.wbText.bodyMedium?.copyWith(color: color),
        ),
      ],
    );
  }
}
