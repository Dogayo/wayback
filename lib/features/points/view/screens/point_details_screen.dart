import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:wayback/app/extensions/navigation_context.dart';
import 'package:wayback/app/feedback/action_result_listener.dart';
import 'package:wayback/app/localization/localization.dart';
import 'package:wayback/app/navigation/routes.dart';
import 'package:wayback/features/points/domain/entities/saved_point.dart';
import 'package:wayback/features/points/view/bloc/delete_point_bloc.dart';
import 'package:wayback/features/points/view/bloc/point_details_bloc.dart';
import 'package:wayback/features/points/view/bloc/rename_point_bloc.dart';
import 'package:wayback/features/points/view/bloc/set_point_active_bloc.dart';
import 'package:wayback/features/points/view/widgets/point_actions.dart';
import 'package:wayback/features/points/view/widgets/point_details_view.dart';
import 'package:wayback/features/points/view/widgets/points_error_view.dart';
import 'package:wayback_design_system/wayback_design_system.dart';

/// One point: where and when, activity, navigation, rename, delete
/// (SCREENS.md §4.4).
///
/// Needs [PointDetailsBloc], [RenamePointBloc], [SetPointActiveBloc] and
/// [DeletePointBloc] above it.
class PointDetailsScreen extends StatelessWidget {
  const PointDetailsScreen({super.key});

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
        ActionResultListener<DeletePointBloc, SavedPoint>(
          successHaptic: WbHaptic.press,
          onSuccess: (context, point) {
            PointActions.showDeleted(context, point);
            context.go(Routes.pointsList);
          },
        ),
        ActionResultListener<RenamePointBloc, SavedPoint>(
          successHaptic: WbHaptic.tick,
        ),
        // The switch has already answered the tap.
        ActionResultListener<SetPointActiveBloc, SavedPoint>(
          successHaptic: null,
        ),
      ],
      child: Scaffold(
        appBar: WbAppBar(
          title: state.dataOrNull?.point.name ?? l10n.pointDetailsTitle,
          onBack: context.back,
          actions: [
            if (state.dataOrNull case (:final point, distanceMeters: _))
              WbIconButton(
                icon: Icons.share_outlined,
                label: l10n.pointActionShare,
                onPressed: () => context.push(Routes.pointShare(point.id)),
              ),
          ],
        ),
        body: WbStateSwitcher(
          child: leaving
              ? const _Loading()
              : state.map(
                  initial: (_) => const _Loading(),
                  loading: (s) => switch (s.previous) {
                    final point? => PointDetailsView(point),
                    null => const _Loading(),
                  },
                  success: (s) => PointDetailsView(s.data),
                  failure: (s) => PointsErrorView(
                    failure: s.failure,
                    actionLabel: l10n.pointBackToList,
                    onAction: () => context.go(Routes.pointsList),
                  ),
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
      children: [
        WbPointCardSkeleton(),
        WbSkeleton(height: WbSpacing.xxxxxl),
      ],
    ),
  );
}
