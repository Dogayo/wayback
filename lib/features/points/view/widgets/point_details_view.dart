import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:wayback/app/localization/distance_l10n.dart';
import 'package:wayback/app/localization/localization.dart';
import 'package:wayback/app/navigation/routes.dart';
import 'package:wayback/app/settings/settings_scope.dart';
import 'package:wayback/core/utils/geo/geo_format.dart';
import 'package:wayback/features/points/view/bloc/delete_point_bloc.dart';
import 'package:wayback/features/points/view/bloc/point_details_bloc.dart';
import 'package:wayback/features/points/view/bloc/rename_point_bloc.dart';
import 'package:wayback/features/points/view/bloc/set_point_active_bloc.dart';
import 'package:wayback/features/points/view/point_type_view.dart';
import 'package:wayback_design_system/wayback_design_system.dart';

/// What the details screen shows for a loaded point: type, name and
/// distance, coordinates, save date, activity and the actions.
class PointDetailsView extends StatelessWidget {
  const PointDetailsView(this.item, {super.key});

  final PointDistance item;

  Future<void> _rename(BuildContext context) async {
    final l10n = context.l10n;
    final rename = context.read<RenamePointBloc>();
    final name = await WbDialogs.prompt(
      context,
      title: l10n.pointRenameTitle,
      initialValue: item.point.name,
      label: l10n.pointNameLabel,
      confirmLabel: l10n.actionSave,
      cancelLabel: l10n.actionCancel,
    );
    if (name != null) rename.run((id: item.point.id, name: name));
  }

  Future<void> _delete(BuildContext context) async {
    final l10n = context.l10n;
    final delete = context.read<DeletePointBloc>();
    final confirmed = await WbDialogs.confirm(
      context,
      title: l10n.pointDeleteTitle(item.point.name),
      message: l10n.pointDeleteBody,
      confirmLabel: l10n.actionDelete,
      cancelLabel: l10n.actionCancel,
      destructive: true,
    );
    if (confirmed ?? false) delete.run(item.point.id);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final (:point, :distanceMeters) = item;
    final secondary = context.wbColors.contentSecondary;
    final savedAt = DateFormat.yMMMd(
      l10n.localeName,
    ).add_Hm().format(point.createdAt.toLocal());
    return ListView(
      padding: const EdgeInsets.all(WbSpacing.screenPadding),
      children: [
        Row(
          children: [
            WbIconTile(icon: point.type.design.icon),
            const SizedBox(width: WbSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(point.name, style: context.wbText.headlineSmall),
                  if (distanceMeters != null)
                    Text(
                      l10n.pointDistanceFromYou(
                        l10n.distance(
                          distanceMeters,
                          units: context.settings.units,
                        ),
                      ),
                      style: context.wbText.bodyMedium?.copyWith(
                        color: secondary,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: WbSpacing.lg),
        WbCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: WbSpacing.md,
            children: [
              _InfoRow(
                label: l10n.pointCoordinatesLabel,
                value: formatCoordinates(point.position),
              ),
              _InfoRow(label: l10n.pointSavedLabel, value: savedAt),
              WbSwitch(
                value: point.isActive,
                label: l10n.pointActiveLabel,
                onChanged: (active) => context.read<SetPointActiveBloc>().run((
                  id: point.id,
                  active: active,
                )),
              ),
            ],
          ),
        ),
        const SizedBox(height: WbSpacing.lg),
        WbButton(
          label: l10n.pointNavigate,
          onPressed: () => context.push(Routes.navigate(point.id)),
        ),
        const SizedBox(height: WbSpacing.sm),
        Row(
          spacing: WbSpacing.sm,
          children: [
            Expanded(
              child: WbButton(
                label: l10n.actionRename,
                variant: WbButtonVariant.secondary,
                onPressed: () => _rename(context),
              ),
            ),
            Expanded(
              child: WbButton(
                label: l10n.actionDelete,
                variant: WbButtonVariant.destructive,
                onPressed: () => _delete(context),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: context.wbText.bodySmall?.copyWith(
          color: context.wbColors.contentSecondary,
        ),
      ),
      Text(value, style: context.wbText.bodyLarge),
    ],
  );
}
