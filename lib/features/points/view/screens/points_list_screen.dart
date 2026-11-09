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
import 'package:wayback/features/points/view/widgets/point_actions.dart';
import 'package:wayback/features/points/view/widgets/points_error_view.dart';
import 'package:wayback_design_system/wayback_design_system.dart';

/// Every saved point, newest first (SCREENS.md §4.3).
class PointsListScreen extends StatelessWidget {
  const PointsListScreen({super.key});

  void _chooseHowToAdd(BuildContext context) {
    final l10n = context.l10n;
    WbActionSheet.show(
      context,
      title: l10n.pointAddTitle,
      subtitle: l10n.pointAddSubtitle,
      icon: Icons.add_location_alt_outlined,
      actions: [
        WbSheetAction(
          icon: Icons.my_location,
          label: l10n.pointAddCurrent,
          onSelected: () => context.push(Routes.pointCreate),
        ),
        WbSheetAction(
          icon: Icons.pin_drop_outlined,
          label: l10n.pointAddByCoordinates,
          onSelected: () => context.push(Routes.pointImport),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = context.watch<PointsListBloc>().state;
    final points = state.dataOrNull;
    return PointActionsListener(
      child: Scaffold(
        appBar: WbAppBar(
          title: l10n.pointsListTitle,
          onBack: context.back,
          actions: [
            WbIconButton(
              icon: Icons.add,
              label: l10n.pointsAddTooltip,
              onPressed: () => _chooseHowToAdd(context),
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
      ),
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

  static const _rows = 5;

  @override
  Widget build(BuildContext context) => ListView(
    padding: context.wbScrollPadding,
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
    final now = DateTime.now();
    return WbStateSwitcher(
      state: points.isEmpty,
      child: points.isEmpty
          ? Center(
              child: WbEmptyState(
                icon: Icons.add_location_alt_outlined,
                title: l10n.pointsEmptyTitle,
                message: l10n.pointsEmptyBody,
              ),
            )
          : ListView(
              children: [
                WbAnimatedItems<PointDistance>(
                  items: points,
                  keyOf: (item) => item.point.id,
                  itemBuilder: (context, item, isLast) {
                    final (:point, :distanceMeters) = item;
                    return WbSwipeActions(
                      actions: PointActions.swipe(context, point),
                      child: WbListItem(
                        title: point.name,
                        subtitle: l10n.pointsListSubtitle(
                          l10n.distanceOrUnknown(
                            distanceMeters,
                            units: context.settings.units,
                          ),
                          l10n.savedWhen(point.createdAt, now: now),
                        ),
                        leading: Icon(point.type.design.icon),
                        trailing: WbStateSwitcher(
                          state: point.isActive,
                          duration: WbMotion.fast,
                          animateSize: true,
                          child: point.isActive
                              ? WbBadge(
                                  label: l10n.pointActiveLabel,
                                  tone: WbTone.positive,
                                )
                              : const Icon(Icons.chevron_right),
                        ),
                        showDivider: !isLast,
                        onTap: () =>
                            context.push(Routes.pointDetails(point.id)),
                        onLongPress: () =>
                            PointActions.openSheet(context, item),
                      ),
                    );
                  },
                ),
              ],
            ),
    );
  }
}
