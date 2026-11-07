import 'package:flutter/material.dart';
import 'package:wayback/app/localization/distance_l10n.dart';
import 'package:wayback/app/localization/error_l10n.dart';
import 'package:wayback/app/localization/localization.dart';
import 'package:wayback/app/settings/settings_scope.dart';
import 'package:wayback/features/navigation/domain/entities/navigation_guidance.dart';
import 'package:wayback/features/navigation/domain/repositories/compass_repository.dart';
import 'package:wayback_design_system/wayback_design_system.dart';

/// Direction and distance dominate; accuracy and warnings stay secondary
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
    return NavigationFrame(
      status: _alerts(context),
      children: [
        _Direction(g),
        Semantics(
          label: l10n.navigateSemantics(g.point.name, distance),
          excludeSemantics: true,
          child: WbDistanceValue(distance),
        ),
        _Accuracy(g),
      ],
    );
  }

  List<Widget> _alerts(BuildContext context) {
    final l10n = context.l10n;
    return [
      if (guidance.compass == CompassStatus.unavailable)
        WbAlertRow(
          title: l10n.error(NavigationErrorCodes.compassUnavailable).title,
          message: l10n.navigateCompassDistanceOnly,
          tone: WbTone.negative,
        ),
      if (guidance.compass == CompassStatus.unreliable)
        WbAlertRow(
          title: l10n.navigateCompassCalibrationTitle,
          message: l10n.navigateCompassCalibrationBody,
          tone: WbTone.warning,
        ),
      if (guidance.weakSignal)
        WbAlertRow(
          title: l10n.navigateWeakSignalTitle,
          message: l10n.navigateWeakSignalBody,
          tone: WbTone.warning,
        ),
    ];
  }
}

/// Layout shared by the navigation states: warnings in a slot of their own,
/// so the dial keeps its place while they come and go.
class NavigationFrame extends StatelessWidget {
  const NavigationFrame({
    required this.children,
    this.status = const [],
    super.key,
  });

  final List<Widget> status;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(WbSpacing.screenPadding),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: WbSpacing.md,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(minHeight: WbAlertRow.slotHeight),
          child: Column(spacing: WbSpacing.xs, children: status),
        ),
        // Scales down instead of overflowing: landscape and large text
        // leave less room for the dial.
        Expanded(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.topCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: WbSpacing.md,
              children: children,
            ),
          ),
        ),
      ],
    ),
  );
}

class _Direction extends StatelessWidget {
  const _Direction(this.guidance);

  final NavigationGuidance guidance;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final g = guidance;
    if (g.compass == CompassStatus.unavailable) {
      return const WbDirectionIcon(Icons.explore_off_outlined);
    }
    final degrees = g.arrowDegrees;
    if (degrees == null) return const WbDirectionSearching();
    final unreliable = g.compass == CompassStatus.unreliable;
    return WbDirectionDial(
      rotation: degrees,
      spread: g.compassAccuracyDegrees ?? WbDirectionDial.maxSpread,
      tone: unreliable ? WbDirectionTone.unreliable : WbDirectionTone.ok,
      semanticLabel: unreliable
          ? l10n.navigateDirectionApproximate(g.arrowBearing)
          : l10n.navigateDirection(g.arrowBearing),
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
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: WbSpacing.md,
        vertical: WbSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: context.wbColors.surfaceContainer,
        borderRadius: WbRadius.pill,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: WbSpacing.xs,
        children: [
          Icon(Icons.my_location, size: WbIconSize.sm, color: color),
          Text(
            l10n.accuracy(
              guidance.accuracyMeters,
              units: context.settings.units,
            ),
            style: context.wbText.titleMedium?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
