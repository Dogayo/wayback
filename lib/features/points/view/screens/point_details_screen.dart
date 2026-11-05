import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:wayback/app/extensions/navigation_context.dart';
import 'package:wayback/app/localization/distance_l10n.dart';
import 'package:wayback/app/localization/error_l10n.dart';
import 'package:wayback/app/localization/localization.dart';
import 'package:wayback/app/navigation/routes.dart';
import 'package:wayback/core/error/failures.dart';
import 'package:wayback/features/points/domain/entities/saved_point.dart';
import 'package:wayback/features/points/view/bloc/delete_point_bloc.dart';
import 'package:wayback/features/points/view/bloc/point_details_bloc.dart';
import 'package:wayback/features/points/view/bloc/rename_point_bloc.dart';
import 'package:wayback/features/points/view/bloc/set_point_active_bloc.dart';
import 'package:wayback/features/points/view/point_type_view.dart';
import 'package:wayback/features/points/view/widgets/points_error_view.dart';
import 'package:wayback_design_system/wayback_design_system.dart';

/// One point: where and when, activity, navigation, rename, delete
/// (SCREENS.md §4.4).
///
/// Needs [PointDetailsBloc], [RenamePointBloc], [SetPointActiveBloc] and
/// [DeletePointBloc] above it.
class PointDetailsScreen extends StatelessWidget {
  const PointDetailsScreen({super.key});

  static void _showFailure(BuildContext context, Failure failure) =>
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.error(failure.code).title)),
      );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = context.watch<PointDetailsBloc>().state;
    // While the point is being deleted, its disappearance is not an error.
    final leaving = context.watch<DeletePointBloc>().state.mapOrElse(
      inProgress: (_) => true,
      success: (_) => true,
      orElse: (_) => false,
    );
    return MultiBlocListener(
      listeners: [
        BlocListener<DeletePointBloc, ActionState<void>>(
          listener: (context, deleted) => deleted.mapOrNull(
            success: (_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    l10n.pointDeletedSnackbar(
                      state.dataOrNull?.point.name ?? '',
                    ),
                  ),
                ),
              );
              context.go(Routes.pointsList);
            },
            failure: (s) => _showFailure(context, s.failure),
          ),
        ),
        BlocListener<RenamePointBloc, ActionState<SavedPoint>>(
          listener: (context, renamed) => renamed.mapOrNull(
            failure: (s) => _showFailure(context, s.failure),
          ),
        ),
        BlocListener<SetPointActiveBloc, ActionState<SavedPoint>>(
          listener: (context, toggled) => toggled.mapOrNull(
            failure: (s) => _showFailure(context, s.failure),
          ),
        ),
      ],
      child: Scaffold(
        appBar: WbAppBar(
          title: state.dataOrNull?.point.name ?? l10n.pointDetailsTitle,
          onBack: context.back,
        ),
        body: leaving
            ? const _Loading()
            : state.map(
                initial: (_) => const _Loading(),
                loading: (s) => switch (s.previous) {
                  final point? => _Details(point),
                  null => const _Loading(),
                },
                success: (s) => _Details(s.data),
                failure: (s) => PointsErrorView(
                  failure: s.failure,
                  actionLabel: l10n.pointBackToList,
                  onAction: () => context.go(Routes.pointsList),
                ),
              ),
      ),
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.all(WbSpacing.screenPadding),
    child: Column(
      spacing: WbSpacing.sm,
      children: [WbSkeleton(height: 56), WbSkeleton(height: 120)],
    ),
  );
}

class _Details extends StatelessWidget {
  const _Details(this.item);

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
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: context.wbColors.surfaceContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                point.type.design.icon,
                size: WbIconSize.xl,
                color: secondary,
              ),
            ),
            const SizedBox(width: WbSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(point.name, style: context.wbText.headlineSmall),
                  if (distanceMeters != null)
                    Text(
                      l10n.pointDistanceFromYou(l10n.distance(distanceMeters)),
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
                value:
                    '${point.position.latitude.toStringAsFixed(5)}, '
                    '${point.position.longitude.toStringAsFixed(5)}',
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
