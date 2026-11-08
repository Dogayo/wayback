import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:wayback/app/localization/distance_l10n.dart';
import 'package:wayback/app/localization/localization.dart';
import 'package:wayback/app/navigation/routes.dart';
import 'package:wayback/app/settings/settings_scope.dart';
import 'package:wayback/features/points/view/bloc/home_bloc.dart';
import 'package:wayback/features/points/view/point_type_view.dart';
import 'package:wayback/features/points/view/widgets/bottom_action_bar.dart';
import 'package:wayback/features/points/view/widgets/point_actions.dart';
import 'package:wayback/features/points/view/widgets/points_error_view.dart';
import 'package:wayback_design_system/wayback_design_system.dart';

/// Dial content for one point card.
typedef PointDirectionBuilder = Widget Function(String pointId, IconData icon);

/// Active points with distances and the one-tap Save (SCREENS.md §4.1).
class HomeScreen extends StatelessWidget {
  const HomeScreen({this.gpsStatus, this.direction, super.key});

  /// Location state, supplied by the app so this feature does not depend on
  /// the location feature's view.
  final Widget? gpsStatus;

  /// Direction to a point, supplied by the app for the same reason: the
  /// compass belongs to the navigation feature.
  final PointDirectionBuilder? direction;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return PointActionsListener(
      child: Scaffold(
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
                builder: (context, state) => WbStateSwitcher(
                  child: state.map(
                    initial: (_) => const _Loading(),
                    loading: (s) => switch (s.previous) {
                      final points? => _HomeContent(points, direction),
                      null => const _Loading(),
                    },
                    success: (s) => _HomeContent(s.data, direction),
                    failure: (s) => PointsErrorView(
                      failure: s.failure,
                      actionLabel: l10n.actionRetry,
                      onAction: context.read<HomeBloc>().fetch,
                    ),
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
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent(this.points, this.direction);

  final HomePoints points;
  final PointDirectionBuilder? direction;

  @override
  Widget build(BuildContext context) {
    return WbStateSwitcher(
      // Empty and no-active are both centred messages: tell them apart.
      state: (points.hasNoPoints, points.hasNoActive),
      child: _content(context),
    );
  }

  Widget _content(BuildContext context) {
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
    return _ActivePoints(points.active, direction);
  }
}

class _ActivePoints extends StatelessWidget {
  const _ActivePoints(this.points, this.direction);

  final List<PointDistance> points;
  final PointDirectionBuilder? direction;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ListView(
      padding: const EdgeInsets.all(WbSpacing.screenPadding),
      children: [
        WbAnimatedItems<PointDistance>(
          items: points,
          keyOf: (item) => item.point.id,
          itemBuilder: (context, item, _) {
            final (:point, :distanceMeters) = item;
            return Padding(
              padding: const EdgeInsets.only(bottom: WbSpacing.sm),
              child: WbPointCard(
                title: point.name,
                distance: l10n.distanceOrUnknown(
                  distanceMeters,
                  units: context.settings.units,
                ),
                typeIcon: point.type.design.icon,
                direction: direction?.call(point.id, point.type.design.icon),
                onTap: () => context.push(Routes.navigate(point.id)),
                onLongPress: () => PointActions.openSheet(context, item),
              ),
            );
          },
        ),
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
