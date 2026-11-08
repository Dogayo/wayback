import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:wayback/app/extensions/navigation_context.dart';
import 'package:wayback/app/localization/distance_l10n.dart';
import 'package:wayback/app/localization/localization.dart';
import 'package:wayback/app/localization/time_l10n.dart';
import 'package:wayback/app/navigation/routes.dart';
import 'package:wayback/app/settings/settings_scope.dart';
import 'package:wayback/features/points/view/bloc/points_list_bloc.dart';
import 'package:wayback/features/points/view/point_type_view.dart';
import 'package:wayback/features/points/view/widgets/bottom_action_bar.dart';
import 'package:wayback/features/points/view/widgets/points_error_view.dart';
import 'package:wayback_design_system/wayback_design_system.dart';

/// Every saved point, newest first (SCREENS.md §4.3).
class PointsListScreen extends StatelessWidget {
  const PointsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = context.watch<PointsListBloc>().state;
    final points = state.dataOrNull;
    return Scaffold(
      appBar: WbAppBar(
        title: l10n.pointsListTitle,
        onBack: context.back,
        actions: [
          WbIconButton(
            icon: Icons.add,
            label: l10n.pointsAddTooltip,
            onPressed: () => context.push(Routes.pointCreate),
          ),
        ],
      ),
      body: WbStateSwitcher(
        child: state.map(
          initial: (_) => const _Loading(),
          loading: (s) => switch (s.previous) {
            final points? => _PointsList(points),
            null => const _Loading(),
          },
          success: (s) => _PointsList(s.data),
          failure: (s) => PointsErrorView(
            failure: s.failure,
            actionLabel: l10n.actionRetry,
            onAction: context.read<PointsListBloc>().fetch,
          ),
        ),
      ),
      bottomNavigationBar: points != null && points.isEmpty
          ? BottomActionBar(
              children: [
                WbButton(
                  label: l10n.homeSaveLocation,
                  onPressed: () => context.push(Routes.pointCreate),
                ),
              ],
            )
          : null,
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

  static const _rows = 5;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(WbSpacing.screenPadding),
    children: [
      for (var i = 0; i < _rows; i++)
        const Padding(
          padding: EdgeInsets.symmetric(vertical: WbSpacing.sm),
          child: WbSkeleton(height: WbSpacing.xxxl),
        ),
    ],
  );
}

class _PointsList extends StatelessWidget {
  const _PointsList(this.points);

  final List<PointDistance> points;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (points.isEmpty) {
      return Center(
        child: WbEmptyState(
          icon: Icons.add_location_alt_outlined,
          title: l10n.pointsEmptyTitle,
          message: l10n.pointsEmptyBody,
        ),
      );
    }
    final now = DateTime.now();
    return ListView.builder(
      itemCount: points.length,
      itemBuilder: (context, index) {
        final (:point, :distanceMeters) = points[index];
        return WbListItem(
          title: point.name,
          subtitle: l10n.pointsListSubtitle(
            l10n.distanceOrUnknown(
              distanceMeters,
              units: context.settings.units,
            ),
            l10n.savedWhen(point.createdAt, now: now),
          ),
          leading: Icon(point.type.design.icon),
          trailing: point.isActive
              ? WbBadge(label: l10n.pointActiveLabel, tone: WbTone.positive)
              : const Icon(Icons.chevron_right),
          showDivider: index < points.length - 1,
          onTap: () => context.push(Routes.pointDetails(point.id)),
        );
      },
    );
  }
}
