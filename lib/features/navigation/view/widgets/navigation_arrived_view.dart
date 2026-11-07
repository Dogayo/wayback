import 'package:flutter/material.dart';
import 'package:wayback/app/localization/distance_l10n.dart';
import 'package:wayback/app/localization/localization.dart';
import 'package:wayback/app/settings/settings_scope.dart';
import 'package:wayback/features/navigation/domain/entities/navigation_guidance.dart';
import 'package:wayback/features/navigation/view/widgets/navigation_view.dart';
import 'package:wayback_design_system/wayback_design_system.dart';

/// Arrival, readable at arm's length (SCREENS.md §4.5). A small arrow and the
/// distance stay: the radius is wide enough that the point may not be in
/// sight yet.
class NavigationArrivedView extends StatelessWidget {
  const NavigationArrivedView(this.guidance, {super.key});

  final NavigationGuidance guidance;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final g = guidance;
    final units = context.settings.units;
    final field = context.wbArrivalColors;
    final distance = l10n.distance(g.distanceMeters, units: units);
    final detail = context.wbText.titleLarge?.copyWith(color: field.content);
    return NavigationFrame(
      children: [
        const WbArrivalMark(),
        Semantics(
          liveRegion: true,
          child: Text(
            l10n.navigateArrived,
            style: context.wbText.displaySmall?.copyWith(color: field.accent),
          ),
        ),
        Semantics(
          label: l10n.navigateSemantics(g.point.name, distance),
          excludeSemantics: true,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: WbSpacing.xs,
            children: [
              if (g.arrowDegrees case final degrees?)
                WbDirectionArrow(rotation: degrees, color: field.accent),
              Text(distance, style: detail),
              Text(
                l10n.accuracy(g.accuracyMeters, units: units),
                style: detail,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
