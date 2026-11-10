import 'package:flutter/material.dart';
import 'package:wayback/app/localization/distance_l10n.dart';
import 'package:wayback/app/localization/localization.dart';
import 'package:wayback/app/settings/settings_scope.dart';
import 'package:wayback/features/navigation/domain/entities/navigation_guidance.dart';
import 'package:wayback/features/navigation/view/widgets/navigation_view.dart';
import 'package:wayback/features/points/view/point_type_view.dart';
import 'package:wayback_design_system/wayback_design_system.dart';

/// Arrival, readable at arm's length (SCREENS.md §4.5). The direction and the
/// distance stay large: the radius is wide enough that the point may not be
/// in sight yet, so the title promises nearness, not a hit.
class NavigationArrivedView extends StatelessWidget {
  const NavigationArrivedView(this.guidance, {super.key});

  /// Wide enough for a long name in two lines at 360 dp.
  static const double _titleWidth = 328;

  final NavigationGuidance guidance;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final g = guidance;
    final units = context.settings.units;
    final field = context.wbArrivalColors;
    final distance = l10n.distance(g.distanceMeters, units: units);
    return NavigationFrame(
      children: [
        WbArrivalDial(
          g.point.type.design,
          rotation: g.arrowDegrees,
          // Comes in once the old view is gone, in step with the screen.
          delay: WbMotion.slow * WbStateSwitcher.fadeThroughStart,
        ),
        Semantics(
          liveRegion: true,
          child: SizedBox(
            width: _titleWidth,
            child: Text(
              l10n.navigateArrived(g.point.name),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: context.wbText.displaySmall?.copyWith(color: field.accent),
            ),
          ),
        ),
        Semantics(
          label: l10n.navigateSemantics(g.point.name, distance),
          excludeSemantics: true,
          child: WbDistanceValue(distance, compact: true, color: field.content),
        ),
        Text(
          l10n.accuracy(g.accuracyMeters, units: units),
          style: context.wbText.titleLarge?.copyWith(color: field.content),
        ),
      ],
    );
  }
}
