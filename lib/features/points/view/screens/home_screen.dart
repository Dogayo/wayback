import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:wayback/app/localization/distance_l10n.dart';
import 'package:wayback/app/localization/localization.dart';
import 'package:wayback/app/navigation/routes.dart';
import 'package:wayback/features/points/view/bloc/home_bloc.dart';
import 'package:wayback/features/points/view/point_type_view.dart';
import 'package:wayback/features/points/view/widgets/bottom_action_bar.dart';
import 'package:wayback/features/points/view/widgets/points_error_view.dart';
import 'package:wayback_design_system/wayback_design_system.dart';

/// Active points with distances and the one-tap Save (SCREENS.md §4.1).
class HomeScreen extends StatelessWidget {
  const HomeScreen({this.gpsStatus, super.key});

  /// Location state, supplied by the app so this feature does not depend on
  /// the location feature's view.
  final Widget? gpsStatus;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: WbAppBar(
        title: l10n.homeTitle,
        actions: [
          WbIconButton(
            icon: Icons.settings_outlined,
            label: l10n.homeSettingsTooltip,
            onPressed: () => context.push(Routes.settings),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (gpsStatus case final status?)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                WbSpacing.screenPadding,
                WbSpacing.xs,
                WbSpacing.screenPadding,
                0,
              ),
              child: status,
            ),
          Expanded(
            child: BlocBuilder<HomeBloc, DataState<HomePoints>>(
              builder: (context, state) => state.map(
                initial: (_) => const _Loading(),
                loading: (s) => switch (s.previous) {
                  final points? => _HomeContent(points),
                  null => const _Loading(),
                },
                success: (s) => _HomeContent(s.data),
                failure: (s) => PointsErrorView(
                  failure: s.failure,
                  actionLabel: l10n.actionRetry,
                  onAction: context.read<HomeBloc>().fetch,
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomActionBar(
        children: [
          WbButton(
            label: l10n.homeSaveLocation,
            onPressed: () => context.push(Routes.pointCreate),
          ),
        ],
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent(this.points);

  final HomePoints points;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (points.hasNoPoints) {
      return Center(
        child: WbEmptyState(
          icon: Icons.add_location_alt_outlined,
          title: l10n.homeEmptyTitle,
          message: l10n.homeEmptyBody,
        ),
      );
    }
    if (points.hasNoActive) {
      return Center(
        child: WbEmptyState(
          icon: Icons.location_off_outlined,
          title: l10n.homeNoActiveTitle,
          message: l10n.homeNoActiveBody,
          action: WbButton(
            label: l10n.homeNoActiveAction,
            variant: WbButtonVariant.secondary,
            onPressed: () => context.push(Routes.pointsList),
          ),
        ),
      );
    }
    return _ActivePoints(points.active);
  }
}

class _ActivePoints extends StatelessWidget {
  const _ActivePoints(this.points);

  final List<PointDistance> points;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ListView(
      padding: const EdgeInsets.all(WbSpacing.screenPadding),
      children: [
        for (final (:point, :distanceMeters) in points) ...[
          WbPointCard(
            title: point.name,
            distance: distanceMeters == null
                ? '—'
                : l10n.distance(distanceMeters),
            typeIcon: point.type.design.icon,
            onTap: () => context.push(Routes.navigate(point.id)),
          ),
          const SizedBox(height: WbSpacing.sm),
        ],
        Align(
          alignment: Alignment.centerLeft,
          child: WbButton(
            label: l10n.homeAllPoints,
            variant: WbButtonVariant.tertiary,
            onPressed: () => context.push(Routes.pointsList),
          ),
        ),
      ],
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
      children: [WbPointCardSkeleton(), WbPointCardSkeleton()],
    ),
  );
}
