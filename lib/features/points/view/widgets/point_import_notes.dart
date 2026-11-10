import 'package:flutter/material.dart';
import 'package:wayback/app/localization/distance_l10n.dart';
import 'package:wayback/app/localization/localization.dart';
import 'package:wayback/app/settings/settings_scope.dart';
import 'package:wayback/features/points/view/bloc/point_import_bloc.dart';
import 'package:wayback_design_system/wayback_design_system.dart';

/// What is worth knowing about these coordinates before saving them.
class PointImportNotes extends StatelessWidget {
  const PointImportNotes(this.import, {super.key});

  final PointImportState import;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final units = context.settings.units;
    final draft = import.draft;
    final distance = import.distanceFromHere;
    final nearby = import.nearby;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (draft != null && !draft.isPrecise) ...[
          const SizedBox(height: WbSpacing.lg),
          WbAlert(
            title: l10n.pointImpreciseTitle,
            message: l10n.pointImpreciseBody,
            tone: WbTone.warning,
          ),
        ],
        if (nearby != null) ...[
          const SizedBox(height: WbSpacing.lg),
          WbAlert(
            title: l10n.pointNearbyTitle(nearby.name),
            message: l10n.pointNearbyBody(
              l10n.distance(nearby.meters, units: units),
            ),
            tone: WbTone.warning,
          ),
        ],
        if (distance != null) ...[
          const SizedBox(height: WbSpacing.lg),
          Text(
            l10n.pointImportDistance,
            style: context.wbText.bodySmall?.copyWith(
              color: context.wbColors.contentSecondary,
            ),
          ),
          Text(
            l10n.distance(distance, units: units),
            style: context.wbText.titleMedium,
          ),
        ],
      ],
    );
  }
}
